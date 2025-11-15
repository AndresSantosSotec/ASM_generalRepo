# 🚀 GUÍA RÁPIDA DE INICIO - RANKING ACADÉMICO

## ⚡ INICIO RÁPIDO (3 PASOS)

### Paso 1: Iniciar Backend
```bash
cd D:\ASMProlink\blue_atlas_backend
php artisan serve
```
✅ Backend en: `http://localhost:8000`

### Paso 2: Iniciar Frontend
```bash
cd D:\ASMProlink\blue-atlas-dashboard
npm run dev
```
✅ Frontend en: `http://localhost:3000`

### Paso 3: Abrir Módulo
Navegar a: **http://localhost:3000/academico/ranking**

---

## 🧪 PRUEBAS RÁPIDAS

### Verificar Rutas (Backend)
```bash
cd D:\ASMProlink\blue_atlas_backend
php artisan route:list --path=academico/ranking
```

### Limpiar Cache
```bash
cd D:\ASMProlink\blue_atlas_backend
php artisan cache:clear
```

### Test Completo
```bash
cd D:\ASMProlink\blue_atlas_backend
.\test_ranking.ps1
```

---

## 📋 ENDPOINTS DISPONIBLES

### Base URL
```
http://localhost:8000/api/academico/ranking
```

### Endpoints
| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/students` | Ranking general |
| GET | `/courses` | Estadísticas de cursos |
| GET | `/curso/{id}` | Ranking por curso |
| GET | `/categoria/{id}` | Ranking por categoría |
| GET | `/programa/{id}` | Ranking por programa |
| GET | `/report` | Descargar reporte |

### Ejemplo de Request
```bash
curl -X GET "http://localhost:8000/api/academico/ranking/students?perPage=10" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

---

## 🔧 PARÁMETROS DE FILTRADO

Todos los endpoints aceptan:

```typescript
{
  search?: string       // Buscar por nombre/carnet/email
  perPage?: number      // Límite de resultados (default: 100)
  program?: string      // Filtrar por programa
  categoria?: string    // Filtrar por categoría
  semester?: number     // Filtrar por semestre
  sortBy?: string       // Ordenar: ranking, gpa, name, credits
}
```

### Ejemplos
```bash
# Top 5 estudiantes
?perPage=5

# Buscar "maria"
?search=maria

# Programa específico + búsqueda
?program=Maestría en Informática&search=juan

# Ordenar por promedio
?sortBy=gpa
```

---

## 🐛 TROUBLESHOOTING

### ❌ "No se encuentran estudiantes"

**Verificar:**
1. Hay estudiantes con `roleid=5` en Moodle
2. Hay carnets en tabla `prospectos` del CRM
3. Los carnets coinciden (case insensitive)

**Test SQL Moodle:**
```sql
SELECT COUNT(*) FROM mdl_user u
JOIN mdl_role_assignments ra ON ra.userid = u.id
WHERE ra.roleid = 5 AND u.deleted = 0;
```

**Test SQL CRM:**
```sql
SELECT COUNT(*) FROM prospectos 
WHERE activo = true AND carnet IS NOT NULL;
```

### ❌ "Error de conexión"

**Verificar `.env`:**
```env
# PostgreSQL (CRM)
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=tu_base_datos

# MySQL (Moodle)
MOODLE_DB_CONNECTION=mysql
MOODLE_DB_HOST=127.0.0.1
MOODLE_DB_PORT=3306
MOODLE_DB_DATABASE=moodle
```

**Test de conexión:**
```bash
php artisan tinker
>>> DB::connection('mysql')->select('SELECT 1');
>>> DB::connection('pgsql')->select('SELECT 1');
```

### ❌ "CORS Error"

**Solución:** Verificar `config/cors.php`:
```php
'allowed_origins' => [
    env('FRONTEND_URL', 'http://localhost:3000')
],
```

---

## 📊 DATOS QUE VERÁS

### Top 3 Destacados
- 🥇 Primer lugar con badge dorado
- 🥈 Segundo lugar con badge plateado
- 🥉 Tercer lugar con badge bronce

### Tabla de Ranking
- Posición en ranking
- Nombre completo
- Programa académico
- Promedio (0-100)
- Progreso (créditos completados/totales)
- Cambio de posición vs. anterior
- Badges de reconocimiento

### Estadísticas de Cursos
- Nombre del curso
- Código
- Estudiantes inscritos
- Promedio del curso
- Tasa de aprobación

---

## 🎯 BADGES AUTOMÁTICOS

El sistema asigna badges según el promedio:

| Promedio | Badge |
|----------|-------|
| ≥ 95% | 🏆 Excelencia |
| ≥ 90% | ⭐ Sobresaliente |
| ≥ 85% | 📘 Honor |
| ≥ 80% | ✅ Aprobado |

---

## 📁 ARCHIVOS IMPORTANTES

### Backend
```
app/Services/MoodleRankingService.php           ← Lógica principal
app/Http/Controllers/Api/RankingAcademicoController.php  ← API REST
routes/api.php                                   ← Rutas registradas
config/database.php                              ← Conexiones BD
```

### Frontend
```
services/ranking.ts                              ← Cliente API
app/academico/ranking/page.tsx                   ← Interfaz UI
```

### Documentación
```
IMPLEMENTACION_RANKING_ACADEMICO.md             ← Guía técnica completa
RESUMEN_RANKING_ACADEMICO.md                    ← Resumen ejecutivo
GUIA_RAPIDA_RANKING.md                          ← Esta guía
test_ranking.ps1                                ← Script de pruebas
```

---

## 💾 CACHE

El sistema usa cache de **5 minutos** para optimizar consultas.

### Limpiar Cache Manual
```bash
php artisan cache:clear
```

### Cache por Consulta
- `ranking_general_*` - Ranking general
- `ranking_curso_{id}_*` - Ranking por curso
- `ranking_categoria_{id}_*` - Ranking por categoría
- `ranking_programa_{id}_*` - Ranking por programa
- `ranking_cursos_stats_*` - Estadísticas de cursos

---

## 🔐 AUTENTICACIÓN

Todas las rutas requieren token de Sanctum:

```javascript
// Frontend: services/api.ts
headers: {
  'Authorization': `Bearer ${token}`,
  'Accept': 'application/json'
}
```

---

## 📞 SOPORTE

### Logs Backend
```bash
tail -f storage/logs/laravel.log
```

Buscar etiquetas:
- `[RANKING]` - Operaciones del ranking
- `[RANKING API]` - Requests a API

### Consola Frontend
Buscar logs:
```javascript
[RANKING] Estudiantes obtenidos: X
[RANKING] Cursos obtenidos: Y
[RANKING] Error: ...
```

---

## ✅ CHECKLIST ANTES DE USAR

- [ ] Backend iniciado en puerto 8000
- [ ] Frontend iniciado en puerto 3000
- [ ] Conexión a Moodle (MySQL) funcionando
- [ ] Conexión a CRM (PostgreSQL) funcionando
- [ ] Token de autenticación válido
- [ ] Cache limpiado

---

## 🎉 ¡LISTO!

El módulo de Ranking Académico está completamente funcional y listo para usar.

**URL Final:** http://localhost:3000/academico/ranking

---

**Última actualización:** 2025-11-14
**Versión:** 1.0.0
