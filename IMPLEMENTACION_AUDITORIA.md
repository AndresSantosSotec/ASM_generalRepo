# Sistema de Auditoría - Implementación Completa

## ✅ **Backend Implementado**

### Controlador: `AuditoriaController.php`
**Ubicación:** `blue_atlas_backend/app/Http/Controllers/Api/AuditoriaController.php`

#### Endpoint Principal
```
GET /api/seguridad/auditoria
```

**Parámetros:**
- `search` - Buscar en usuario, acción, descripción
- `tipo` - Filtrar por tipo: `todos`, `activity`, `email`, `collection`
- `nivel` - Filtrar por severidad: `info`, `warning`, `error`
- `fecha_inicio` - Fecha desde
- `fecha_fin` - Fecha hasta
- `page` - Número de página
- `per_page` - Registros por página (default: 50)

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "logs": [
      {
        "id": 123,
        "usuario": "Juan Pérez",
        "email": "juan@example.com",
        "accion": "create_user",
        "modulo": "Users",
        "detalles": "Creó el usuario María López",
        "fecha": "2024-01-15",
        "hora": "10:30:45",
        "nivel": "info",
        "ip": "192.168.1.100",
        "tipo_log": "activity",
        "tiempo_relativo": "Hace 2 horas"
      }
    ],
    "estadisticas": {
      "total": 5000,
      "activity": 3500,
      "email": 1000,
      "collection": 500,
      "hoy": 150
    },
    "pagination": {
      "current_page": 1,
      "per_page": 50,
      "total": 5000,
      "total_pages": 100,
      "from": 1,
      "to": 50,
      "has_more": true
    }
  }
}
```

---

## 📊 **Tablas de Logs Unificadas**

### 1. **activity_log** - Logs de Actividad General
```sql
SELECT id, user_id, entity_type, entity_id, action, description, 
       meta, ip_address, user_agent, created_at, updated_at
FROM public.activity_log;
```

**Usos:**
- CRUD de usuarios
- CRUD de roles
- CRUD de permisos  
- CRUD de prospectos
- CRUD de estudiantes
- Cambios de configuración
- Accesos a módulos

**Niveles detectados automáticamente:**
- `info` - Acciones normales (create, read, update)
- `warning` - Acciones críticas (delete, remove)
- `error` - Errores en operaciones

---

### 2. **email_logs** - Logs de Envío de Emails
```sql
SELECT id, sending_id, template_id, destinatario_email, destinatario_nombre, 
       prospecto_id, asunto, contenido_html, estado, fecha_envio, 
       fecha_apertura, veces_abierto, error_mensaje, metadata, 
       created_at, updated_at
FROM public.email_logs;
```

**Estados:**
- `sent` → Nivel `info`
- `failed` → Nivel `error`
- Otros → Nivel `warning`

**Información mostrada:**
- Destinatario
- Asunto del email
- Estado de envío
- Fecha y hora

---

### 3. **collection_logs** - Logs de Gestión de Cobranza
```sql
SELECT id, prospecto_id, date, type, notes, agent, 
       next_contact_at, created_at, updated_at
FROM public.collection_logs;
```

**Información mostrada:**
- Agente de cobranza
- Tipo de gestión
- Notas del contacto
- Próximo contacto programado

---

## 🔧 **Función Helper para Registro Automático**

### Uso en Controladores

```php
use App\Http\Controllers\Api\AuditoriaController;

// En cualquier controlador, después de una operación
AuditoriaController::registrarLog(
    userId: auth()->id(),
    action: 'create_user',
    entityType: 'User',
    entityId: $usuario->id,
    description: "Creó el usuario {$usuario->name}",
    meta: ['email' => $usuario->email, 'role' => $usuario->role]
);
```

**Parámetros:**
- `userId` (int) - ID del usuario que realiza la acción
- `action` (string) - Acción realizada (create_user, update_role, delete_student, etc.)
- `entityType` (string) - Tipo de entidad (User, Role, Student, etc.)
- `entityId` (int|null) - ID de la entidad afectada
- `description` (string|null) - Descripción legible
- `meta` (array|null) - Datos adicionales en JSON

---

## 📝 **Ejemplos de Acciones a Registrar**

### Módulo de Usuarios
```php
// Crear usuario
AuditoriaController::registrarLog(
    auth()->id(),
    'create_user',
    'User',
    $user->id,
    "Creó el usuario {$user->first_name} {$user->last_name}"
);

// Actualizar usuario
AuditoriaController::registrarLog(
    auth()->id(),
    'update_user',
    'User',
    $user->id,
    "Actualizó el usuario {$user->first_name} {$user->last_name}",
    ['changes' => $request->only(['email', 'role_id'])]
);

// Eliminar usuario
AuditoriaController::registrarLog(
    auth()->id(),
    'delete_user',
    'User',
    $user->id,
    "Eliminó el usuario {$user->first_name} {$user->last_name}"
);
```

### Módulo de Roles
```php
// Crear rol
AuditoriaController::registrarLog(
    auth()->id(),
    'create_role',
    'Role',
    $role->id,
    "Creó el rol {$role->name}"
);

// Asignar permisos
AuditoriaController::registrarLog(
    auth()->id(),
    'assign_permissions',
    'Role',
    $role->id,
    "Asignó {$count} permisos al rol {$role->name}",
    ['permissions' => $permissions->pluck('name')->toArray()]
);
```

### Módulo de Estudiantes
```php
// Inscribir estudiante
AuditoriaController::registrarLog(
    auth()->id(),
    'enroll_student',
    'Student',
    $student->id,
    "Inscribió al estudiante {$student->nombre} en el curso {$course->name}",
    ['course_id' => $course->id, 'period' => $period->name]
);
```

### Módulo de Reportes
```php
// Descargar reporte
AuditoriaController::registrarLog(
    auth()->id(),
    'download_report',
    'Report',
    null,
    "Descargó el reporte {$reportName}",
    ['tipo' => $tipo, 'filtros' => $request->all()]
);
```

---

## 🎯 **Siguiente Paso: Frontend**

### Crear Servicio TypeScript

**Ubicación:** `blue-atlas-dashboard/services/auditoria.ts`

```typescript
import api from './api'

export interface LogAuditoria {
  id: number
  usuario: string
  email: string
  accion: string
  modulo: string
  detalles: string
  fecha: string
  hora: string
  nivel: 'info' | 'warning' | 'error'
  ip: string
  tipo_log: 'activity' | 'email' | 'collection'
  tiempo_relativo: string
}

export interface FiltrosAuditoria {
  search?: string
  tipo?: 'todos' | 'activity' | 'email' | 'collection'
  nivel?: 'todos' | 'info' | 'warning' | 'error'
  fecha_inicio?: string
  fecha_fin?: string
  page?: number
  per_page?: number
}

export async function obtenerLogs(filtros?: FiltrosAuditoria) {
  const response = await api.get('/seguridad/auditoria', { params: filtros })
  return response.data.data
}
```

### Actualizar Página

**Ubicación:** `blue-atlas-dashboard/app/seguridad/auditoria/page.tsx`

- Reemplazar datos hardcodeados
- Integrar con `obtenerLogs()`
- Añadir filtros funcionales
- Mostrar estadísticas reales
- Paginación dinámica

---

## 📈 **Estadísticas Disponibles**

El sistema proporciona:
- **Total de logs** acumulados
- **Logs por tipo** (activity, email, collection)
- **Logs de hoy**
- **Distribución por nivel** (info, warning, error)

---

## ⚠️ **Importante: Agregar Logs a Controladores Existentes**

Para tener un sistema completo de auditoría, necesitas agregar la función `AuditoriaController::registrarLog()` en todos los métodos de:

- `UserController` - CRUD de usuarios
- `RoleController` - CRUD de roles
- `PermissionController` - Asignación de permisos
- `ProspectoController` - Gestión de prospectos
- `StudentController` - Gestión de estudiantes
- `CourseController` - CRUD de cursos
- `EnrollmentController` - Inscripciones
- `PaymentController` - Pagos y cuotas
- Etc.

**Patrón recomendado:**
```php
public function store(Request $request)
{
    // Validación
    $validated = $request->validate([...]);
    
    // Operación
    $entity = Model::create($validated);
    
    // ✅ REGISTRAR LOG
    AuditoriaController::registrarLog(
        auth()->id(),
        'create_entity',
        'Entity',
        $entity->id,
        "Descripción de la acción"
    );
    
    return response()->json([...]);
}
```

---

## 🚀 **Resumen**

✅ **Backend completo** - Controller unifica 3 tablas de logs
✅ **Endpoint funcional** - `/api/seguridad/auditoria`
✅ **Filtros avanzados** - Por tipo, nivel, fecha, búsqueda
✅ **Paginación** - 50 registros por página
✅ **Estadísticas** - Totales y distribución
✅ **Helper function** - Para registrar logs fácilmente
✅ **Rutas registradas** - Listas para consumir

⏳ **Pendiente:**
- Crear servicio TypeScript frontend
- Actualizar página de auditoría con datos reales
- Agregar logs a controladores existentes

¿Quieres que implemente el frontend ahora?
