# Implementación de Control de Accesos y Sesiones

## 📋 Resumen

Se ha implementado completamente la funcionalidad real para el **Dashboard de Seguridad - Control de Accesos**, reemplazando los datos hardcodeados con integración completa de API.

## ✅ Funcionalidades Implementadas

### 1. Backend (Laravel)

#### Controlador: `SeguridadAccesosController.php`
**Ubicación:** `blue_atlas_backend/app/Http/Controllers/Api/SeguridadAccesosController.php`

**Endpoints implementados:**

1. **GET `/api/seguridad/accesos`** - Listar sesiones
   - Paginación (50 registros por defecto)
   - Filtros:
     - `search`: Buscar por nombre, email o IP
     - `estado`: `todos`, `activo`, `cerrado`
     - `fecha_inicio` y `fecha_fin`: Rango de fechas
   - Retorna: accesos, resumen (stats), paginación

2. **POST `/api/seguridad/accesos/{sessionId}/cerrar`** - Cerrar sesión remota
   - Valida que la sesión exista y esté activa
   - Actualiza `is_active = false` en la BD
   - Registra en logs

3. **GET `/api/seguridad/accesos/reporte`** - Descargar PDF
   - Genera reporte en PDF con hasta 500 registros
   - Aplica los mismos filtros que el listado
   - Formato landscape con tabla completa
   - Incluye resumen estadístico

**Características adicionales:**
- Parseo de User Agent (detecta OS y navegador)
- Cálculo de duración de sesión
- Unión con tablas `users` y `roles`
- Manejo de errores con logging detallado

#### Vista PDF: `accesos-pdf.blade.php`
**Ubicación:** `blue_atlas_backend/resources/views/exports/accesos-pdf.blade.php`

- Diseño profesional con header y logo
- Tabla en formato landscape
- Sección de filtros aplicados
- Resumen estadístico
- Fecha de generación

### 2. Frontend (Next.js)

#### Servicio: `seguridad.ts`
**Ubicación:** `blue-atlas-dashboard/services/seguridad.ts`

**Funciones exportadas:**
```typescript
obtenerAccesos(filtros?: FiltrosAccesos): Promise<RespuestaAccesos>
cerrarSesion(sessionId: number): Promise<void>
descargarReporteAccesos(filtros?: FiltrosAccesos): Promise<void>
```

**Interfaces TypeScript:**
- `AccesoSesion` - Estructura de cada sesión
- `ResumenAccesos` - Stats del dashboard
- `FiltrosAccesos` - Parámetros de búsqueda
- `RespuestaAccesos` - Respuesta completa del API

#### Página: `page.tsx`
**Ubicación:** `blue-atlas-dashboard/app/seguridad/accesos/page.tsx`

**Cambios realizados:**
- ✅ Eliminados datos hardcodeados (8 registros mock)
- ✅ Integración con API real via `useEffect`
- ✅ Estados de loading y error
- ✅ Filtros funcionando:
  - Búsqueda por texto
  - Tabs: Todos / Activos / Cerrados
  - Paginación
- ✅ Botón de descarga de reporte PDF
- ✅ Botón para cerrar sesión individual
- ✅ Dialog de confirmación para cerrar sesión
- ✅ Stats en tiempo real (total, activos, cerrados, hoy)

### 3. Rutas API

**Ubicación:** `blue_atlas_backend/routes/api.php`

```php
Route::middleware(['auth:sanctum'])->prefix('seguridad')->group(function () {
    Route::get('/accesos', [SeguridadAccesosController::class, 'listarAccesos']);
    Route::post('/accesos/{sessionId}/cerrar', [SeguridadAccesosController::class, 'cerrarSesion']);
    Route::get('/accesos/reporte', [SeguridadAccesosController::class, 'descargarReporte']);
});
```

## 🗄️ Estructura de Base de Datos

### Tabla `sessions`
```sql
- id (int)
- user_id (int) -> FK users.id
- token_hash (string)
- ip_address (string)
- user_agent (text)
- created_at (timestamp)
- last_activity (timestamp)
- is_active (boolean) - Campo usado para estado Activo/Cerrado
- device_type (string)
- platform (string)
- browser (string)
- start_time (timestamp)
- duration (string)
```

**Nota importante:** Se usa `is_active` (boolean) en lugar de `closed_at` (timestamp).

## 🔄 Flujo de Datos

1. **Carga inicial:**
   ```
   Usuario accede → page.tsx useEffect → obtenerAccesos() → 
   Backend query → Respuesta con accesos/resumen/pagination
   ```

2. **Filtros:**
   ```
   Usuario cambia filtro → Actualiza estado → 
   Llama obtenerAccesos(nuevos filtros) → Actualiza tabla
   ```

3. **Cerrar sesión:**
   ```
   Usuario click "X" → Dialog confirmación → cerrarSesion(id) → 
   Backend actualiza is_active=false → Recargar lista
   ```

4. **Descargar reporte:**
   ```
   Usuario click "Descargar" → descargarReporteAccesos(filtros) → 
   Backend genera PDF → Descarga archivo
   ```

## 📊 Datos Retornados

### Ejemplo de respuesta `/accesos`:
```json
{
  "success": true,
  "message": "Accesos obtenidos exitosamente",
  "data": {
    "accesos": [
      {
        "id": 1,
        "usuario": "Juan Pérez",
        "email": "juan@example.com",
        "rol": "Administrador",
        "ip": "192.168.1.100",
        "dispositivo": "Windows 10 - Chrome",
        "fecha": "2024-01-20",
        "hora": "14:30:00",
        "ultima_actividad": "2024-01-20 15:45:00",
        "estado": "Activo",
        "duracion_minutos": 75
      }
    ],
    "resumen": {
      "total": 150,
      "activos": 12,
      "cerrados": 138,
      "hoy": 8
    },
    "pagination": {
      "current_page": 1,
      "per_page": 50,
      "total": 150,
      "total_pages": 3,
      "from": 1,
      "to": 50,
      "has_more": true
    }
  }
}
```

## 🎨 UI/UX

- **Loading states** con spinner durante carga
- **Empty states** cuando no hay datos
- **Error handling** con mensajes claros
- **Confirmación** antes de cerrar sesión
- **Feedback visual** con badges de estado
- **Responsivo** con tabla scrollable
- **Paginación** clara con "Anterior/Siguiente"

## 🔒 Seguridad

- ✅ Protegido con middleware `auth:sanctum`
- ✅ Validación de sesión antes de cerrar
- ✅ Logs de todas las operaciones
- ✅ Solo administradores pueden cerrar sesiones
- ✅ Límite de 500 registros en PDF para evitar sobrecarga

## 🚀 Para Probar

1. Asegúrate de que el backend esté corriendo
2. Navega a: `http://localhost:3000/seguridad/accesos`
3. La página cargará automáticamente las sesiones desde la BD
4. Prueba los filtros, paginación y descarga de reporte
5. Intenta cerrar una sesión activa

## 📝 Notas

- Los datos de sesión se guardan automáticamente cuando el usuario inicia sesión con Laravel Sanctum
- El campo `is_active` se actualiza automáticamente en cada request (middleware)
- La duración se calcula como diferencia entre `created_at` y `last_activity`
- El parseo de User Agent detecta: Windows, MacOS, Linux, iOS, Android, Chrome, Firefox, Safari, Edge, etc.

## ✨ Código Limpio

- ✅ Sin errores de TypeScript
- ✅ Sin errores de PHP
- ✅ Interfaces bien definidas
- ✅ Separación de responsabilidades
- ✅ Código reutilizable
- ✅ Comentarios explicativos
