# PROTECCIÓN: Cuotas pagadas al editar duración del programa

## Problema crítico detectado

Al editar la duración del programa (ej: de 32 a 24 meses), el sistema **eliminaba TODAS las cuotas** incluyendo las ya pagadas:

```php
// ANTES (línea 55-70 PlanPagosController.php)
if ($existingCuotas > 0 && !$esReinscripcion) {
    // ❌ Elimina TODAS las cuotas sin verificar estado
    CuotaProgramaEstudiante::where('estudiante_programa_id', $est->id)->delete();
}
```

### Consecuencias del bug

1. **Pérdida de pagos registrados**: Todas las cuotas pagadas se eliminaban
2. **Pérdida de kardex**: Los registros de pago en `kardex_pagos` se eliminaban
3. **Plan de pagos inconsistente**: Se generaba un plan nuevo desde cero
4. **Problemas de auditoría**: No había rastro de los pagos anteriores

## Solución implementada

### 1. Detección de cuotas pagadas

Antes de regenerar el plan, se verifica si existen cuotas pagadas:

```php
// Línea 47-52
$cuotasPagadas = CuotaProgramaEstudiante::where('estudiante_programa_id', $est->id)
    ->where('estado', 'pagado')
    ->count();

if ($cuotasPagadas > 0) {
    // Ajustar solo las pendientes en lugar de borrar todo
    return $this->ajustarPlanConCuotasPagadas($est, $duracionMeses, $soloCuotasMensuales);
}
```

### 2. Ajuste inteligente del plan (`ajustarPlanConCuotasPagadas`)

El nuevo método ajusta solo las cuotas pendientes según la nueva duración:

#### Caso A: Aumentar duración (32 → 36 meses)
- **Preserva**: Todas las cuotas existentes (pagadas y pendientes)
- **Agrega**: 4 cuotas mensuales nuevas al final
- **Actualiza**: Los montos de cuotas pendientes si cambió la mensualidad

#### Caso B: Reducir duración (32 → 24 meses)
- **Preserva**: Todas las cuotas pagadas
- **Elimina**: Solo cuotas **pendientes** desde el final (8 cuotas)
- **Valida**: Si no hay suficientes cuotas pendientes, rechaza el cambio

```php
// Línea 211-223: Validación crítica
if ($cuotasPendientes->count() < $cuotasAEliminar) {
    DB::rollback();
    return response()->json([
        'message' => 'No se puede reducir la duración porque hay más cuotas pagadas que la nueva duración permite.',
        'error' => 'cuotas_pagadas_exceden_nueva_duracion',
    ], 422);
}
```

## Flujo protegido

```
Usuario edita duración 32 → 24 meses
    ↓
Frontend envía PUT /estudiante-programa/{id}
    ↓
Backend actualiza duracion_meses
    ↓
Llama a PlanPagosController::generar()
    ↓
✅ Verifica cuotas pagadas
    ↓
SI hay pagadas → ajustarPlanConCuotasPagadas()
    ├─ Obtiene cuotas mensuales ordenadas
    ├─ Calcula diferencia (24 - 32 = -8)
    ├─ Busca 8 cuotas pendientes desde el final
    ├─ Valida que haya suficientes pendientes
    ├─ Elimina solo esas 8 cuotas pendientes
    ├─ Actualiza montos de pendientes restantes
    └─ Preserva TODAS las pagadas
    ↓
SI NO hay pagadas → regenera plan completo (comportamiento original)
```

## Casos de uso

### ✅ Caso 1: Estudiante con 12 cuotas pagadas, cambiar 32 → 24 meses
- Cuotas 1-12: **Pagadas** → ✅ Se preservan
- Cuotas 13-32: **Pendientes** (20 cuotas)
- Elimina cuotas 25-32 (8 cuotas pendientes)
- **Resultado**: 24 cuotas totales (12 pagadas + 12 pendientes)

### ✅ Caso 2: Estudiante sin pagos, cambiar 32 → 24 meses
- Sin cuotas pagadas → regenera plan completo
- Crea 24 cuotas nuevas
- **Resultado**: Plan limpio de 24 cuotas

### ❌ Caso 3: Estudiante con 30 cuotas pagadas, cambiar 32 → 24 meses
- Cuotas 1-30: **Pagadas**
- Solo 2 cuotas pendientes (31-32)
- Necesita eliminar 8 pero solo hay 2 pendientes
- **Resultado**: Error 422 - "No se puede reducir la duración"

### ✅ Caso 4: Aumentar duración 24 → 32 meses
- Preserva todas las existentes
- Agrega 8 cuotas nuevas (25-32)
- **Resultado**: Siempre exitoso

## Registros de log

El sistema genera logs detallados para auditoría:

```php
Log::info("[PlanPagos] Ajustando plan con cuotas pagadas. EP: {$est->id}, nueva duración: {$nuevaDuracionMeses} meses");
Log::info("[PlanPagos] Agregando {$diferencia} cuotas mensuales");
Log::info("[PlanPagos] Eliminando {$cuotasAEliminar} cuotas pendientes sobrantes");
```

## Respuesta API exitosa

```json
{
  "message": "Plan de pagos ajustado correctamente. Se preservaron las cuotas pagadas.",
  "cuotas": [...],
  "resumen": {
    "total_cuotas": 24,
    "cuotas_agregadas": 0,
    "cuotas_eliminadas": 8,
    "cuotas_pagadas_preservadas": 12
  }
}
```

## Respuesta API error

```json
{
  "message": "No se puede reducir la duración porque hay más cuotas pagadas que la nueva duración permite.",
  "error": "cuotas_pagadas_exceden_nueva_duracion",
  "cuotas_pendientes": 2,
  "cuotas_a_eliminar": 8
}
```

## Archivos modificados

### Backend
- `app/Http/Controllers/Api/PlanPagosController.php`:
  - Línea 47-52: Detección de cuotas pagadas
  - Línea 177-276: Nuevo método `ajustarPlanConCuotasPagadas()`

### Frontend
- Ya funciona con los cambios anteriores de sincronización de duración
- No requiere cambios adicionales

## Testing recomendado

### Prueba 1: Sin pagos (regeneración completa)
1. Prospecto sin pagos con programa 32 meses
2. Editar duración a 24 meses
3. Verificar: Plan regenerado desde cero

### Prueba 2: Con pagos - Reducir duración OK
1. Prospecto con 10 cuotas pagadas, programa 32 meses
2. Editar duración a 24 meses
3. Verificar: 10 pagadas + 14 pendientes = 24 total
4. Verificar: Cuotas 25-32 eliminadas

### Prueba 3: Con pagos - Aumentar duración
1. Prospecto con 10 cuotas pagadas, programa 24 meses
2. Editar duración a 32 meses
3. Verificar: 10 pagadas + 14 pendientes + 8 nuevas = 32 total

### Prueba 4: Con pagos - Reducción imposible
1. Prospecto con 30 cuotas pagadas, programa 32 meses
2. Intentar editar duración a 24 meses
3. Verificar: Error 422 con mensaje claro

### Verificación en BD

```sql
-- Ver estado de cuotas antes/después
SELECT numero_cuota, estado, monto, fecha_vencimiento
FROM cuota_programa_estudiante
WHERE estudiante_programa_id = X
ORDER BY numero_cuota;

-- Verificar que no se eliminaron cuotas pagadas
SELECT COUNT(*) FROM cuota_programa_estudiante
WHERE estudiante_programa_id = X AND estado = 'pagado';
-- Este número NO debe cambiar después de editar duración
```

## Ventajas de la solución

1. ✅ **Protege inversión del estudiante**: No se pierden pagos
2. ✅ **Auditoría completa**: Logs detallados de cada ajuste
3. ✅ **Retrocompatible**: Si no hay pagos, funciona como antes
4. ✅ **Validaciones robustas**: Previene errores de negocio
5. ✅ **Transparente**: Respuesta API clara sobre lo que se hizo

## Casos edge detectados y manejados

- ✅ Reducir más de lo posible → Error claro
- ✅ Cambiar solo la mensualidad (no duración) → Actualiza montos
- ✅ Cambiar duración sin cambiar mensualidad → Ajusta cantidad
- ✅ Estudiante sin cuotas → Regeneración completa
- ✅ Transacciones atómicas → Rollback en caso de error

---

**Fecha:** 2 de junio de 2026  
**Protección crítica:** Cuotas pagadas preservadas  
**Impacto:** Alto - Previene pérdida de datos financieros
