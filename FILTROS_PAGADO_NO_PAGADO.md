# Sistema de Filtros de Estado de Pago por Mes/Año

## 📋 Descripción General

Este sistema permite filtrar estudiantes según su estado de pago (PAGADO/NO PAGADO) para un mes y año específicos. Reemplaza la lógica anterior de "últimos 30 días" con una verificación exacta por período.

## 🎯 Objetivo

Determinar si un estudiante tiene registrado el pago de su mensualidad para un mes y año específico, considerando múltiples fuentes de datos (cuotas, kardex de pagos, y registros de reconciliación).

## 🔶 Formas de Consulta

El endpoint `/api/dashboard-financiero/estado-pagos` acepta dos formas de especificar el período:

### Forma A: Numérica (Recomendada)
```json
{
  "carnets": ["202145353", "202145354"],
  "mes": 11,
  "anio": 2025
}
```

### Forma B: Texto (Excel/Moodle)
```json
{
  "carnets": ["202145353", "202145354"],
  "mes_pago": "Noviembre",
  "anio_pago": "2025"
}
```

## 🔍 Lógica de Validación

### ✅ Un estudiante es considerado **PAGADO** si cumple AL MENOS UNA de estas condiciones:

1. **Cuota Pagada**: Existe registro en `cuotas_programa_estudiante` donde:
   - `estado = 'pagado'`
   - Y el `mes`/`ano` coincide con el período consultado
   - O el `mes_pago`/`anio_pago` (texto del Excel) coincide

2. **Kardex Aprobado**: Existe registro en `kardex_pagos` donde:
   - `estado_pago = 'aprobado'`
   - Y el `mes`/`ano` coincide con el período consultado
   - O el `mes_pago`/`anio_pago` (texto del Excel) coincide

3. **Reconciliación Aprobada**: Existe registro en `reconciliation_records` donde:
   - `estado_reconciliacion = 'reconciled'`
   - Y el `mes`/`ano` coincide con el período consultado

### ❌ Un estudiante es considerado **NO PAGADO** si:

- NO cumple ninguna de las condiciones anteriores para el mes/año específico

## 📊 Estructura de Respuesta

```json
{
  "success": true,
  "data": {
    "202145353": {
      "carnet": "202145353",
      "estado": "pagado",
      "detalle": {
        "cuota_estado": "pagado",
        "tiene_kardex": true,
        "kardex_estado": "aprobado",
        "tiene_reconciliacion": false,
        "mes_detectado": 11,
        "anio_detectado": 2025
      }
    },
    "202145354": {
      "carnet": "202145354",
      "estado": "no_pagado",
      "detalle": {
        "cuota_estado": null,
        "tiene_kardex": false,
        "kardex_estado": null,
        "tiene_reconciliacion": false,
        "mes_detectado": 11,
        "anio_detectado": 2025
      }
    }
  }
}
```

## 🔧 Implementación Backend

### Archivo
`d:\ASMProlink\blue_atlas_backend\app\Http\Controllers\Api\DashboardFinancieroController.php`

### Método Principal
`public function estadoPagos(Request $request)`

### Helpers Auxiliares

1. **`normalizarMesTexto($mesTexto)`**
   - Convierte texto de mes (español/inglés) a número 1-12
   - Ejemplos: "Noviembre" → 11, "Nov" → 11, "11" → 11

2. **`obtenerVariantesMes($mes)`**
   - Retorna todas las variantes textuales posibles de un mes
   - Ejemplo para mes 11: ['noviembre', 'november', 'nov', '11']

## 💻 Implementación Frontend

### Archivo
`d:\ASMProlink\blue-atlas-dashboard\components\finanzas\dashboard-financiero.tsx`

### Integración

El dashboard carga automáticamente el estado de pago de todos los estudiantes cuando:
1. Cambia el mes seleccionado (`mesSeleccionado`)
2. Cambia el año seleccionado (`anioSeleccionado`)
3. Se cargan nuevos estudiantes

```typescript
api.post('/dashboard-financiero/estado-pagos', { 
  carnets: carnetsFaltantes,
  mes: mesSeleccionado,
  anio: anioSeleccionado
})
```

### Filtros Disponibles

El sistema permite filtrar estudiantes por:
- **Pagado**: Estudiantes con pago registrado para el mes/año
- **No Pagado**: Estudiantes sin pago registrado para el mes/año
- **Tiene Kardex**: Estudiantes con al menos un registro en kardex
- **Sin Kardex**: Estudiantes sin registros en kardex

## 🗄️ Tablas Involucradas

### 1. `cuotas_programa_estudiante`
- **Campo clave**: `estado` ('pagado', 'pendiente')
- **Campos de período**: `mes` (1-12), `ano` (YYYY), `mes_pago` (texto), `anio_pago` (texto)

### 2. `kardex_pagos`
- **Campo clave**: `estado_pago` ('aprobado', 'pendiente', etc.)
- **Campos de período**: `mes` (1-12), `ano` (YYYY), `mes_pago` (texto), `anio_pago` (texto)

### 3. `reconciliation_records`
- **Campo clave**: `estado_reconciliacion` ('reconciled')
- **Campos de período**: `mes` (1-12), `ano` (YYYY), `mes_pago` (texto), `anio_pago` (texto)

## 🔄 Relación con Moodle

### Validación de Cursos
- NO se valida `suspended` (ya viene limpio desde MoodleQueryService)
- NO se valida `active enrolment`
- Solo se valida que el curso pertenezca a un path cuyo mes/año coincida:
  - El path usa `category.depth = 3`
  - Ejemplo: `/2025/11/CRM/`

## 📈 Casos de Uso

### 1. Ver estudiantes que NO han pagado noviembre 2025
```typescript
// En el dashboard
setMesSeleccionado(11)
setAnioSeleccionado(2025)
setFiltroEstadoPago(['no_pagado'])
```

### 2. Ver estudiantes con pagos en kardex (histórico completo)
```typescript
setFiltroEstadoPago(['tiene_kardex'])
```

### 3. Exportar lista de morosos del mes actual
1. Seleccionar mes/año actual
2. Filtrar por "No Pagado"
3. Exportar a CSV/Excel

## 🚀 Ventajas del Sistema

✅ **Precisión**: Solo considera pagos del mes/año exacto (no mezcla períodos)  
✅ **Flexibilidad**: Acepta tanto formato numérico como texto del Excel  
✅ **Multi-fuente**: Valida en cuotas, kardex y reconciliación  
✅ **Auditoría**: Preserva texto original del Excel para comparación  
✅ **Performance**: Queries optimizadas con índices compuestos en mes/ano  

## ⚠️ Consideraciones Importantes

1. **Programa Más Reciente**: Solo se consideran pagos del programa activo del estudiante (inscripción más reciente)

2. **Campos Duales**: El sistema mantiene dos juegos de campos:
   - `mes`/`ano`: Normalizados (INTEGER) para SQL
   - `mes_pago`/`anio_pago`: Originales (VARCHAR) para auditoría

3. **Sin Mezcla de Meses**: La lógica NO permite búsquedas cruzadas entre meses (ej: "pagos de octubre mostrados en noviembre")

4. **Prioridad de Matching**:
   - Primera prioridad: Coincidencia numérica (`mes = 11 AND ano = 2025`)
   - Segunda prioridad: Coincidencia por texto (`mes_pago IN ('noviembre', 'nov', '11')`)

## 🔗 Archivos Relacionados

- **Backend Controller**: `app/Http/Controllers/Api/DashboardFinancieroController.php`
- **Frontend Dashboard**: `components/finanzas/dashboard-financiero.tsx`
- **Modelos**: `KardexPago.php`, `CuotaProgramaEstudiante.php`, `ReconciliationRecord.php`
- **Importador**: `app/Imports/PaymentHistoryImportNew.php`
- **Migración**: `database/migrations/2025_12_01_000001_add_mes_ano_to_payment_tables.php`

## 📝 Notas de Desarrollo

- Implementado: Diciembre 2025
- Reemplaza: Sistema anterior de "últimos 30 días"
- Requiere: PostgreSQL 12+ (para DISTINCT ON)
- Compatible con: Laravel 8+, React 18+
