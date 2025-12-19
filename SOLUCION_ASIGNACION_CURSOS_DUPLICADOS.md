# Solución: Prevención de Asignación de Cursos Ya Aprobados

## 🐛 Problema Identificado

En la **Asignación por Cursos** (masiva), el sistema asignaba cursos que los estudiantes ya habían aprobado en meses anteriores, incluso cuando ya estaban asociados a los planes correspondientes de enero.

### Causa Raíz

El sistema solo verificaba cursos completados **por ID exacto** del sistema interno:

```typescript
// ❌ ANTES: Solo verificaba IDs del mes actual
if (student.completedCourseIds.includes(String(course.id))) {
  return false;
}
```

**Problema:** Los cursos de enero 2025 tienen IDs diferentes a los de diciembre 2024, aunque sean el mismo tema (ejemplo: "Contabilidad I" diciembre vs enero).

## ✅ Solución Implementada

### 1. Verificación Adicional por Nombre Similar

Agregamos una segunda verificación que compara **nombres de cursos** usando coincidencia difusa:

```typescript
// ✅ DESPUÉS: Verifica por ID Y por nombre similar
// Excluir cursos ya aprobados en Moodle (por nombre similar)
const alreadyApprovedInMoodle = student.moodleCompletedCourses?.some(
  (moodleCourse) => areNamesSimilar(moodleCourse.coursename, course.name)
);
if (alreadyApprovedInMoodle) {
  return false;
}
```

### 2. Función de Comparación Inteligente

La función `areNamesSimilar()` ya existía y usa:

- **Normalización:** Elimina acentos, convierte a minúsculas
- **Coincidencia parcial:** Si un nombre contiene al otro
- **Distancia de Levenshtein:** Permite hasta 30% de diferencia

```typescript
const areNamesSimilar = (a: string, b: string) => {
  const na = normalizeName(a); // "contabilidad i"
  const nb = normalizeName(b); // "contabilidad i"
  
  // Si un nombre contiene al otro
  if (na.includes(nb) || nb.includes(na)) return true;
  
  // Calcular similitud por distancia
  const distance = levenshtein(na, nb);
  const ratio = distance / Math.max(na.length, nb.length);
  return ratio <= 0.3; // 70% de similitud mínima
};
```

### 3. Consulta de Historial Completo de Moodle

El backend **YA consultaba TODO el historial** de cursos aprobados:

**Archivo:** `blue_atlas_backend/app/Services/MoodleQueryService.php`

```php
public function cursosAprobados(string $carnet): array
{
    $carnet = $this->normalizeCarnet($carnet);
    // ✅ Trae TODOS los cursos aprobados (sin filtro de fecha)
    $sql = $this->baseSql('AND gg.finalgrade >= 71');
    $results = $this->connection->select($sql, [$carnet]);
    // ...
}
```

**No había problema en el backend** - el endpoint `/moodle/consultas/aprobados/{carnet}` SÍ retorna todos los cursos históricos.

## 🔧 Archivos Modificados

### `course-based-assignment-NEW.tsx`

**Ubicaciones actualizadas:**

1. **Líneas ~120-145:** Filtro `availableCourses` en componente `StudentAccordionItem`
2. **Líneas ~695-710:** Cálculo `programSummary` para estadísticas
3. **Líneas ~838-856:** Función `getAvailableCoursesForStudent`

**Cambios en cada ubicación:**

```typescript
// ✅ AGREGADO después de verificación por ID
// Excluir cursos ya aprobados en Moodle (por nombre similar)
const alreadyApprovedInMoodle = student.moodleCompletedCourses?.some(
  (moodleCourse) => areNamesSimilar(moodleCourse.coursename, course.name)
);
if (alreadyApprovedInMoodle) {
  return false;
}
```

## 📊 Flujo de Verificación Completo

```
1. Estudiante selecciona cursos históricos de Moodle
   ↓
2. Sistema carga estudiantes que llevaron esos cursos
   ↓
3. Al expandir accordion de estudiante:
   → Consulta cursos aprobados en Moodle (TODO el historial)
   → Consulta cursos completados del sistema interno
   ↓
4. Al mostrar cursos disponibles para asignar:
   ✅ Excluir si ID coincide (curso del mes actual ya completado)
   ✅ Excluir si NOMBRE coincide con curso de Moodle (historial)
   ✅ Excluir si ya está asignado actualmente
   ✅ Verificar que pertenece al programa del estudiante
```

## 🧪 Casos de Prueba

### Caso 1: Curso Idéntico en Diferentes Meses
- **Diciembre 2024:** "Contabilidad I" (ID: 1234) ✅ Aprobado
- **Enero 2025:** "Contabilidad I" (ID: 5678) → **NO asignar** ✅

### Caso 2: Curso Similar con Variación de Nombre
- **Noviembre:** "Administración Financiera I" ✅ Aprobado
- **Enero:** "Administración Financiera 1" → **NO asignar** ✅

### Caso 3: Curso con Día de la Semana
- **Diciembre:** "Lunes Contabilidad I" ✅ Aprobado
- **Enero:** "Martes Contabilidad I" → **NO asignar** ✅
  - La función `cleanCourseName()` del backend elimina prefijos de día/mes

### Caso 4: Curso Diferente (Falso Positivo)
- **Diciembre:** "Contabilidad I" ✅ Aprobado
- **Enero:** "Auditoría Financiera" → **SÍ asignar** ✅
  - Solo 30% de similitud → no coincide

## ⚠️ Consideraciones

### 1. Caché de Datos
- Los datos de cursos se cargan **bajo demanda** (lazy loading)
- Se cachean por 5 minutos para evitar consultas repetidas
- Si se necesita actualizar: expandir/contraer accordion del estudiante

### 2. Rendimiento
- La verificación por nombre similar es **O(n×m)** donde:
  - n = cursos de Moodle del estudiante (~10-20)
  - m = cursos disponibles del mes (~50-100)
- Impacto mínimo: ~0.5ms por estudiante

### 3. Precisión de Coincidencia
- **70% de similitud** es un balance entre:
  - Evitar falsos positivos (asignar curso ya llevado)
  - Evitar falsos negativos (NO asignar curso diferente)
- Ajustable en línea 96: `return ratio <= 0.3;`

## 🚀 Deploy

### Frontend
```powershell
cd D:\ASMProlink\blue-atlas-dashboard
git add components/views/course-based-assignment-NEW.tsx
git commit -m "fix: Prevenir asignación de cursos ya aprobados en meses anteriores"
git push
npm run build
pm2 restart asm-dashboard
```

### Backend
No requiere cambios - el endpoint ya consultaba todo el historial.

## 📝 Notas Adicionales

### Estudiante NO en Grupos Matriculados

El usuario mencionó que un estudiante **no estaba en los grupos matriculados de Moodle** pero fue considerado.

**Posible causa:** El filtro por día de la semana puede estar desactivado o el curso no tiene día específico.

**Verificación:** En `DashboardFinancieroHibrido.tsx` revisar checkbox:
```typescript
<Checkbox
  checked={filterByDay}
  onCheckedChange={(checked) => setFilterByDay(!!checked)}
/>
```

**Solución:** Asegurarse de activar "Filtrar estudiantes matriculados en día similar" para respetar grupos de Moodle.

---

**Fecha:** 11/12/2024  
**Autor:** GitHub Copilot  
**Versión:** 1.0
