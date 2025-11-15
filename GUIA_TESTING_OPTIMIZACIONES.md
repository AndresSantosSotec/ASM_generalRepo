# 🧪 Guía de Testing - Optimizaciones del Módulo Académico

## 📋 Resumen

Esta guía te permite **probar todas las optimizaciones** del módulo académico **sin modificar nada en Moodle**. Todos los endpoints son de **SOLO LECTURA**.

---

## 🚀 Endpoints de Testing Disponibles

### Base URL
```
{{BASE_URL}}/api/moodle/test-optimizacion
```

**Autenticación requerida:** `Bearer Token` (Sanctum)

---

## 1️⃣ Test de Conexión

**Endpoint:** `GET /conexion`

**Descripción:** Verifica que la conexión a Moodle funciona correctamente.

**Uso:**
```bash
curl -X GET "{{BASE_URL}}/api/moodle/test-optimizacion/conexion" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Conexión exitosa a Moodle",
  "data": {
    "conectado": true,
    "tiempo_ms": 12.5,
    "test_query": {
      "test": 1
    }
  }
}
```

---

## 2️⃣ Test: Buscar Estudiante (Optimizado)

**Endpoint:** `GET /buscar-estudiante?carnet=ASM20241911`

**Descripción:** Busca un estudiante usando la consulta optimizada (sin `UPPER()` en WHERE).

**Parámetros:**
- `carnet` (opcional): Carnet del estudiante. Si no se envía, usa el del usuario autenticado.

**Uso:**
```bash
curl -X GET "{{BASE_URL}}/api/moodle/test-optimizacion/buscar-estudiante?carnet=ASM20241911" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Estudiante encontrado",
  "data": {
    "carnet_buscado": "ASM20241911",
    "carnet_normalizado": "ASM20241911",
    "encontrado": true,
    "estudiante": {
      "user_id": 123,
      "carnet": "ASM20241911",
      "nombre_completo": "Juan Pérez López",
      "email": "juan.perez@example.com",
      "deleted": 0,
      "suspended": 0,
      "firstaccess": 1697000000,
      "lastaccess": 1730000000
    },
    "tiempo_ms": 8.2,
    "nota": "Consulta optimizada sin funciones en WHERE"
  }
}
```

**✅ Qué verificar:**
- `tiempo_ms` debe ser < 50ms (si hay índices)
- `encontrado` debe ser `true` si el carnet existe
- `nota` confirma que se usa la versión optimizada

---

## 3️⃣ Test: Cursos del Estudiante

**Endpoint:** `GET /cursos-estudiante?carnet=ASM20241911`

**Descripción:** Obtiene todos los cursos del estudiante usando la consulta optimizada en 2 pasos.

**Uso:**
```bash
curl -X GET "{{BASE_URL}}/api/moodle/test-optimizacion/cursos-estudiante?carnet=ASM20241911" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Cursos encontrados",
  "data": {
    "carnet": "ASM20241911",
    "user_id": 123,
    "total_cursos": 5,
    "cursos": [
      {
        "course_id": 45,
        "curso": "Programación Orientada a Objetos",
        "codigo_curso": "POO101",
        "startdate": 1697000000,
        "enddate": 1705000000,
        "visible": 1,
        "enrol_status": 0,
        "estado": "Finalizado",
        "fecha_inicio": "2023-10-11 00:00:00",
        "fecha_fin": "2024-01-11 00:00:00",
        "fecha_matricula": "2023-10-01 10:30:00"
      }
    ],
    "performance": {
      "paso_1_buscar_usuario_ms": 5.2,
      "paso_2_obtener_cursos_ms": 12.8,
      "tiempo_total_ms": 18.0,
      "optimizaciones_aplicadas": [
        "✅ Sin funciones en WHERE (username = ?)",
        "✅ Consulta en 2 pasos (divide y vencerás)",
        "✅ Formato de fechas en PHP",
        "✅ Sin FROM_UNIXTIME en SELECT"
      ]
    }
  }
}
```

**✅ Qué verificar:**
- `tiempo_total_ms` debe ser < 100ms
- `paso_1_buscar_usuario_ms` debe ser < 20ms
- `paso_2_obtener_cursos_ms` debe ser < 80ms
- Fechas formateadas correctamente (`fecha_inicio`, `fecha_fin`)

---

## 4️⃣ Test: Calificaciones del Estudiante

**Endpoint:** `GET /calificaciones?carnet=ASM20241911`

**Descripción:** Obtiene calificaciones usando consulta optimizada separada.

**Uso:**
```bash
curl -X GET "{{BASE_URL}}/api/moodle/test-optimizacion/calificaciones?carnet=ASM20241911" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Calificaciones obtenidas",
  "data": {
    "carnet": "ASM20241911",
    "user_id": 123,
    "resumen": {
      "promedio_general": 85.5,
      "cursos_aprobados": 4,
      "cursos_reprobados": 1,
      "cursos_sin_calificar": 2,
      "total_cursos": 7
    },
    "calificaciones": [
      {
        "course_id": 45,
        "curso": "Programación Orientada a Objetos",
        "codigo_curso": "POO101",
        "calificacion": 92.0,
        "nota_aprobacion": 60,
        "nota_maxima": 100,
        "nota_minima": 0,
        "estado": "Aprobado"
      }
    ],
    "performance": {
      "consulta_calificaciones_ms": 15.3,
      "tiempo_total_ms": 18.7,
      "optimizaciones": [
        "✅ Consulta directa sin JOIN pesado con enrolments",
        "✅ Cálculos estadísticos en PHP",
        "✅ Sin subqueries complejas"
      ]
    }
  }
}
```

**✅ Qué verificar:**
- Resumen calculado correctamente
- `promedio_general` es el promedio de cursos calificados
- Tiempo de consulta < 50ms

---

## 5️⃣ Test: Comparar Rendimiento (Antes vs Después)

**Endpoint:** `GET /comparar-rendimiento?carnet=ASM20241911`

**Descripción:** Ejecuta la misma consulta con 2 métodos y compara tiempos.

**Uso:**
```bash
curl -X GET "{{BASE_URL}}/api/moodle/test-optimizacion/comparar-rendimiento?carnet=ASM20241911" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Comparación completada",
  "data": {
    "carnet_probado": "ASM20241911",
    "resultados": {
      "version_antigua": {
        "tiempo_ms": 45.8,
        "encontrado": true,
        "optimizacion": "UPPER() en WHERE - Lento ❌"
      },
      "version_optimizada": {
        "tiempo_ms": 3.2,
        "encontrado": true,
        "optimizacion": "Sin funciones en WHERE - Rápido ✅"
      },
      "comparacion": {
        "mejora_porcentaje": "93.01%",
        "factor_mejora": "14.31x más rápido",
        "tiempo_ahorrado_ms": 42.6
      }
    },
    "recomendacion": "✅ Usar versión optimizada para mejor rendimiento"
  }
}
```

**✅ Qué verificar:**
- `version_optimizada` debe ser significativamente más rápida
- Factor de mejora típico: 10-100x
- Si ambas son similares: **falta crear índices**

---

## 6️⃣ Test: Verificar Índices en Moodle

**Endpoint:** `GET /verificar-indices`

**Descripción:** Revisa qué índices de optimización están presentes en Moodle.

**Uso:**
```bash
curl -X GET "{{BASE_URL}}/api/moodle/test-optimizacion/verificar-indices" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Verificación de índices completada",
  "data": {
    "tablas_verificadas": {
      "mdl_user": {
        "total_indices": 5,
        "indices_existentes": ["PRIMARY", "idx_username", "idx_deleted"],
        "indices_optimizacion_presentes": ["idx_username", "idx_deleted"],
        "indices_optimizacion_faltantes": [],
        "estado": "✅ Completo"
      },
      "mdl_user_enrolments": {
        "total_indices": 3,
        "indices_existentes": ["PRIMARY", "userid"],
        "indices_optimizacion_presentes": [],
        "indices_optimizacion_faltantes": ["idx_userid_status"],
        "estado": "⚠️ Faltan índices"
      }
    },
    "nota": "Si faltan índices, ejecutar: moodle_indices_optimizacion.sql"
  }
}
```

**✅ Qué verificar:**
- Si `indices_optimizacion_faltantes` NO está vacío: **CREAR ÍNDICES**
- Estado ideal: Todos con `✅ Completo`

---

## 7️⃣ Test: Análisis EXPLAIN de Consulta

**Endpoint:** `GET /analizar-consulta?carnet=ASM20241911`

**Descripción:** Muestra el plan de ejecución de MySQL para la consulta optimizada.

**Uso:**
```bash
curl -X GET "{{BASE_URL}}/api/moodle/test-optimizacion/analizar-consulta?carnet=ASM20241911" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Análisis EXPLAIN completado",
  "data": {
    "carnet_analizado": "ASM20241911",
    "plan_ejecucion": [
      {
        "id": 1,
        "select_type": "SIMPLE",
        "table": "mdl_user",
        "type": "ref",
        "possible_keys": "idx_username,idx_deleted",
        "key": "idx_username",
        "key_len": "767",
        "ref": "const",
        "rows": 1,
        "Extra": "Using where"
      }
    ],
    "interpretacion": {
      "type": "Tipo de acceso (ref = usando índice)",
      "key": "Índice utilizado (debería ser idx_username)",
      "rows": "Filas escaneadas (menor es mejor)",
      "Extra": "Información adicional (Using index es óptimo)"
    }
  }
}
```

**✅ Qué verificar:**
- `type` = `ref` o `const` (bueno) vs `ALL` (malo - table scan)
- `key` = `idx_username` (confirma uso de índice)
- `rows` = 1 o muy bajo (eficiente)
- Si `key` = `NULL`: **NO HAY ÍNDICE, CREAR URGENTE**

---

## 📊 Interpretación de Resultados

### ✅ BUENOS Resultados

| Métrica | Valor Ideal |
|---------|-------------|
| Tiempo de búsqueda estudiante | < 20ms |
| Tiempo obtener cursos | < 100ms |
| Tiempo obtener calificaciones | < 80ms |
| Factor de mejora (comparación) | > 10x |
| Índices faltantes | 0 |
| EXPLAIN `type` | `ref` o `const` |
| EXPLAIN `rows` | 1-10 |

### ⚠️ RESULTADOS QUE REQUIEREN ACCIÓN

| Problema | Causa | Solución |
|----------|-------|----------|
| Tiempos > 500ms | Sin índices | Ejecutar `moodle_indices_optimizacion.sql` |
| Factor mejora < 2x | Índices no usados | Verificar configuración MySQL |
| EXPLAIN `type` = ALL | Table scan | Crear índices urgente |
| EXPLAIN `key` = NULL | No hay índice | Crear índice en columna |
| Estudiante no encontrado | Carnet incorrecto | Verificar carnet en Moodle |

---

## 🔧 Cómo Ejecutar los Tests

### Opción 1: Usando cURL (Terminal)

```bash
# 1. Autenticarse y obtener token
TOKEN="your_bearer_token_here"
BASE_URL="http://localhost:8000"

# 2. Test de conexión
curl -X GET "$BASE_URL/api/moodle/test-optimizacion/conexion" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json"

# 3. Buscar estudiante
curl -X GET "$BASE_URL/api/moodle/test-optimizacion/buscar-estudiante?carnet=ASM20241911" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json"

# 4. Comparar rendimiento
curl -X GET "$BASE_URL/api/moodle/test-optimizacion/comparar-rendimiento?carnet=ASM20241911" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json"

# 5. Verificar índices
curl -X GET "$BASE_URL/api/moodle/test-optimizacion/verificar-indices" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json"
```

### Opción 2: Usando Postman

1. Crear nueva colección: "Moodle Optimización Tests"
2. Configurar variable `{{BASE_URL}}` = `http://localhost:8000`
3. Configurar variable `{{TOKEN}}` = tu token de Sanctum
4. Importar los 7 endpoints:
   - GET `{{BASE_URL}}/api/moodle/test-optimizacion/conexion`
   - GET `{{BASE_URL}}/api/moodle/test-optimizacion/buscar-estudiante?carnet=ASM20241911`
   - GET `{{BASE_URL}}/api/moodle/test-optimizacion/cursos-estudiante?carnet=ASM20241911`
   - GET `{{BASE_URL}}/api/moodle/test-optimizacion/calificaciones?carnet=ASM20241911`
   - GET `{{BASE_URL}}/api/moodle/test-optimizacion/comparar-rendimiento?carnet=ASM20241911`
   - GET `{{BASE_URL}}/api/moodle/test-optimizacion/verificar-indices`
   - GET `{{BASE_URL}}/api/moodle/test-optimizacion/analizar-consulta?carnet=ASM20241911`
5. Agregar header: `Authorization: Bearer {{TOKEN}}`
6. Ejecutar colección completa con "Run Collection"

### Opción 3: Usando Thunder Client (VS Code)

1. Instalar extensión "Thunder Client"
2. Crear nueva colección
3. Agregar los 7 requests con los endpoints
4. Configurar headers y ejecutar

---

## 🎯 Checklist de Validación

Ejecuta este checklist para validar que todo funciona:

- [ ] **Test 1:** Conexión a Moodle exitosa
- [ ] **Test 2:** Estudiante encontrado con carnet conocido
- [ ] **Test 3:** Cursos del estudiante obtenidos (tiempo < 100ms)
- [ ] **Test 4:** Calificaciones obtenidas con resumen correcto
- [ ] **Test 5:** Versión optimizada > 10x más rápida que antigua
- [ ] **Test 6:** Todos los índices presentes (estado ✅ Completo)
- [ ] **Test 7:** EXPLAIN muestra uso de índice `idx_username`

**Si TODOS los checks pasan:** ✅ Optimización completa y funcional

**Si alguno falla:** Ver sección "Solución de Problemas" abajo

---

## 🚨 Solución de Problemas

### Problema: "Estudiante no encontrado"

**Causa:** El carnet no existe en Moodle o está en diferente formato.

**Solución:**
1. Verificar carnets existentes:
   ```sql
   SELECT username FROM mdl_user WHERE deleted = 0 LIMIT 10;
   ```
2. Probar con un carnet válido de la lista

### Problema: "Tiempos muy lentos (> 500ms)"

**Causa:** Índices no creados en Moodle.

**Solución:**
1. Ejecutar: `php artisan tinker`
2. Verificar índices:
   ```php
   DB::connection('mysql')->select('SHOW INDEX FROM mdl_user');
   ```
3. Si falta `idx_username`, crear índices:
   ```sql
   ALTER TABLE mdl_user ADD INDEX idx_username (username);
   ```

### Problema: "MySQL server has gone away"

**Causa:** Timeout de conexión MySQL.

**Solución:**
1. Editar `config/database.php`:
   ```php
   'mysql' => [
       // ...
       'options' => [
           PDO::ATTR_TIMEOUT => 30,
       ],
   ],
   ```
2. Reiniciar servidor Laravel

---

## 📞 Siguiente Paso

Una vez que todos los tests pasen:

1. ✅ Confirmar que las optimizaciones funcionan
2. 🔧 Crear índices faltantes (si los hay)
3. 🚀 Integrar endpoints optimizados en frontend
4. 📊 Monitorear rendimiento en producción

---

## 📝 Notas Importantes

- ⚠️ **SOLO LECTURA:** Ningún endpoint modifica datos en Moodle
- 🔒 **Autenticación:** Requiere token de Sanctum válido
- 🎯 **Carnet:** Si no se envía, usa el del usuario autenticado
- 📊 **Performance:** Los tiempos dependen de hardware y red
- 🗄️ **Índices:** Críticos para rendimiento óptimo

