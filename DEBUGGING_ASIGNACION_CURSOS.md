# 🔍 Análisis y Debugging: Asignación de Cursos Duplicados

## 📋 Problemas Reportados

1. ✅ **Sistema asigna cursos ya aprobados anteriormente**
2. ⚠️ **Cursos eliminados directamente de Moodle (manual)**
3. ⚠️ **Estudiante sin historial (inscrito desde agosto) recibe asignaciones incorrectas**

## 🧪 Cambios Implementados para Debugging

### Frontend: `course-based-assignment-NEW.tsx`

Se agregaron logs detallados en 3 puntos críticos:

#### 1. Carga de Cursos (`loadStudentCompletedCourses`)

**Logs agregados:**
```javascript
console.log(`🔄 [${carnet}] Iniciando carga de cursos...`);
console.log(`📥 [${carnet}] Respuestas recibidas:`, { ... });
console.log(`📋 [${carnet}] Cursos de Moodle RAW:`, [ ... ]);
console.log(`✅ [${carnet}] Cursos finales:`, { ... });
console.log(`📚 [${carnet}] ✅ Carga completa`);
```

**Qué verificar:**
- ¿Se ejecuta la carga cuando se expande el accordion?
- ¿Cuántos cursos trae de Moodle?
- ¿Los nombres de cursos coinciden con los del sistema?

#### 2. Filtro de Disponibilidad (`availableCourses`)

**Logs agregados:**
```javascript
console.log(`🚫 [${carnet}] EXCLUIDO por ID del sistema: ${courseName}`);
console.log(`🚫 [${carnet}] EXCLUIDO por Moodle (similar): "${courseA}" ≈ "${courseB}"`);
console.log(`🚫 [${carnet}] EXCLUIDO por asignación actual: ${courseName}`);
console.log(`✅ [${carnet}] Cursos disponibles: X/Y`);
```

**Qué verificar:**
- ¿Se están excluyendo los cursos correctos?
- ¿La comparación de nombres funciona?
- ¿Cuántos cursos quedan disponibles?

### Backend: `MoodleConsultasController.php`

**Logs agregados:**
```php
Log::info("[MoodleConsultasController] 📥 Consultando cursos aprobados para carnet: {$carnet}");
Log::info("[MoodleConsultasController] ✅ Cursos aprobados encontrados", [
    'carnet' => $carnet,
    'total' => count($results),
    'cursos' => [ ... ]
]);
```

**Ubicación de logs:** `storage/logs/laravel.log`

## 🧪 Procedimiento de Prueba

### Paso 1: Preparar el Entorno

```powershell
# Terminal 1 - Backend
cd D:\ASMProlink\blue_atlas_backend
php artisan config:clear
php artisan cache:clear

# Limpiar logs anteriores
Remove-Item storage\logs\laravel.log -ErrorAction SilentlyContinue
New-Item storage\logs\laravel.log -ItemType File

# Terminal 2 - Frontend
cd D:\ASMProlink\blue-atlas-dashboard
npm run dev
```

### Paso 2: Abrir Consola del Navegador

1. Presionar **F12** para abrir DevTools
2. Ir a la pestaña **Console**
3. Activar filtros:
   - ☑️ Verbose
   - ☑️ Info
   - ☑️ Warnings
   - ☑️ Errors

### Paso 3: Realizar Prueba

1. **Navegar a:** Asignación → Asignación por Cursos
2. **Seleccionar:** Cursos históricos de sábado
3. **Expandir accordion** de un estudiante que tenga cursos aprobados
4. **Observar logs en consola**

### Paso 4: Recolectar Información

#### En la Consola del Navegador (F12):

Buscar y copiar logs que contengan:
- `🔄 Iniciando carga de cursos`
- `📥 Respuestas recibidas`
- `📋 Cursos de Moodle RAW`
- `✅ Cursos finales`
- `🚫 EXCLUIDO`
- `✅ Cursos disponibles`

#### En el Backend (Laravel):

```powershell
cd D:\ASMProlink\blue_atlas_backend
Get-Content storage\logs\laravel.log -Tail 100 | Select-String "MoodleConsultasController"
```

Buscar líneas que contengan:
- `📥 Consultando cursos aprobados`
- `✅ Cursos aprobados encontrados`

## 📊 Casos de Prueba Específicos

### Caso 1: Estudiante con Cursos Aprobados Anteriormente

**Objetivo:** Verificar que NO se muestren como disponibles

**Estudiante de prueba:** (Usar carnet real de las pruebas)
- Carnet: `ASM_____`
- Curso aprobado en nov/dic: "Curso X"
- Curso disponible en enero: "Curso X" (ID diferente)

**Resultado esperado:**
```
🚫 [ASM_____] EXCLUIDO por Moodle (similar): "Curso X" ≈ "Curso X"
```

### Caso 2: Estudiante Sin Historial (Inscrito desde Agosto)

**Objetivo:** Verificar por qué se le asignan cursos

**Datos a verificar:**
- ¿Tiene registro en Moodle? (revisar backend logs)
- ¿Cuántos cursos trae `moodleCompletedCourses`?
- ¿El array está vacío o undefined?

**Posibles causas:**
1. **Carnet en mayúsculas/minúsculas:** Moodle usa `asm12345`, sistema usa `ASM12345`
2. **Sin cursos en Moodle:** Array vacío = todos los cursos parecen disponibles
3. **Error en consulta:** Backend devuelve `[]` por error de conexión

### Caso 3: Cursos Eliminados de Moodle

**Objetivo:** Entender el impacto de eliminaciones manuales

**Escenario:**
1. Estudiante aprobó "Curso Y" en noviembre
2. Curso fue eliminado de Moodle manualmente
3. Sistema consulta cursos aprobados → NO incluye "Curso Y"
4. Sistema permite asignar "Curso Y" nuevamente

**Solución:**
- Los cursos eliminados de Moodle **no se pueden detectar**
- **Recomendación:** NO eliminar cursos de Moodle, usar `visible=0`

## 🔧 Diagnósticos Adicionales

### Verificar Consulta Directa a Moodle

```sql
-- Conectar a base de datos Moodle
-- Buscar cursos aprobados para un carnet específico

SELECT
    u.username AS carnet,
    c.fullname AS coursename,
    ROUND(gg.finalgrade, 2) AS finalgrade,
    FROM_UNIXTIME(c.startdate) AS fecha_inicio
FROM mdl_user u
JOIN mdl_user_enrolments ue ON ue.userid = u.id
JOIN mdl_enrol e ON e.id = ue.enrolid
JOIN mdl_course c ON c.id = e.courseid
JOIN mdl_grade_items gi ON gi.courseid = c.id AND gi.itemtype = 'course'
JOIN mdl_grade_grades gg ON gg.userid = u.id AND gg.itemid = gi.id
WHERE u.deleted = 0
  AND gg.finalgrade IS NOT NULL
  AND gg.finalgrade >= 71
  AND u.username = 'asm12345'  -- CAMBIAR POR CARNET REAL
ORDER BY c.fullname;
```

### Verificar API desde Postman

```http
GET http://localhost:8000/api/moodle/consultas/aprobados/ASM12345
Authorization: Bearer {{token}}
```

**Resultado esperado:**
```json
{
  "data": [
    {
      "userid": 123,
      "carnet": "ASM12345",
      "fullname": "Juan Perez",
      "courseid": 456,
      "coursename": "Contabilidad I",
      "finalgrade": 85.5,
      "estado_curso": "Completado"
    }
  ]
}
```

## 🐛 Posibles Causas Identificadas

### 1. Timing de Carga (MÁS PROBABLE)

**Problema:**
```typescript
// Estado inicial
completedCourseIds: [],        // ❌ Vacío
moodleCompletedCourses: [],    // ❌ Vacío
coursesLoaded: false           // ❌ No cargado

// El filtro se ejecuta ANTES de cargar datos
availableCourses = currentMonthCourses.filter(...)
// NO excluye nada porque arrays están vacíos
```

**Solución implementada:**
- UI muestra loading hasta que `coursesLoaded === true`
- Logs para verificar que se ejecuta en orden correcto

### 2. Normalización de Carnets

**Problema:**
```
Moodle: "asm12345"  (minúsculas)
Sistema: "ASM12345" (mayúsculas)
```

**Verificar:**
```typescript
// En loadStudentCompletedCourses
console.log(`Consultando Moodle con carnet: "${student.carnet}"`);
// Debe mostrar el formato correcto
```

### 3. Comparación de Nombres Fallida

**Problema:**
```typescript
// Curso en Moodle:  "Lunes Enero 2025 BBA Contabilidad I"
// Curso en sistema: "Sábado Enero 2025 MBA Contabilidad I"
// ¿La función areNamesSimilar() los detecta como iguales?
```

**Verificar en logs:**
```
🚫 EXCLUIDO por Moodle (similar): "Contabilidad I" ≈ "Contabilidad I"
```

### 4. Error Silencioso en Backend

**Problema:**
```php
// Si hay error de conexión a Moodle
try {
    $results = $this->queries->cursosAprobados($carnet);
} catch (\Exception $e) {
    // Devuelve array vacío en lugar de error
    return response()->json(['data' => []], 500);
}
```

**Verificar en logs:**
```
❌ Error en cursosAprobados
```

## 📝 Reporte de Resultados

### Formato para Reportar

```
CARNET DE PRUEBA: ASM_____

=== LOGS DE CONSOLA (Frontend) ===
🔄 [ASM_____] Iniciando carga de cursos...
📥 [ASM_____] Respuestas recibidas: { completedFromSystem: X, approvedFromMoodle: Y }
📋 [ASM_____] Cursos de Moodle RAW: [...]
✅ [ASM_____] Cursos finales: [...]
🚫 [ASM_____] EXCLUIDO por...: ...
✅ [ASM_____] Cursos disponibles: X/Y

=== LOGS DE BACKEND (Laravel) ===
[Copiar salida de storage/logs/laravel.log]

=== PROBLEMA OBSERVADO ===
- Sistema muestra curso "X" como disponible
- Estudiante ya aprobó "X" en noviembre con nota 85
- ¿Por qué no se excluye?
```

## 🚀 Próximos Pasos

### Si los Logs Muestran Datos Correctos

→ El problema está en la **lógica del filtro** o **timing de ejecución**

### Si Moodle Devuelve Array Vacío

→ El problema está en la **consulta SQL** o **conexión a Moodle**

### Si los Nombres No Coinciden

→ Ajustar la función `areNamesSimilar()` o `cleanCourseName()`

---

**Fecha:** 11/12/2024
**Autor:** GitHub Copilot
**Estado:** Debugging en progreso
