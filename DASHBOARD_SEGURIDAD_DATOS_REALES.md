# Dashboard de Seguridad - Datos Dinámicos Disponibles

## 📊 Datos que YA se pueden consumir en tiempo real

### 1. **Estadísticas Principales (4 Cards superiores)**

#### Usuarios Activos
- **Endpoint:** `GET /api/usuarios/estadisticas`
- **Dato:** Total de usuarios con `is_active = true`
- **Actualizar:** "152" → valor real de BD

#### Sesiones Activas (recomendado agregar)
- **Endpoint:** `GET /api/seguridad/accesos` (ya existe)
- **Dato:** `resumen.activos` (sesiones con `is_active = true`)
- **Mostrar:** Cuántos usuarios están conectados ahora mismo

#### Roles Configurados
- **Endpoint:** `GET /api/roles`
- **Dato:** `count(roles)`
- **Actualizar:** "7" → valor real de BD

#### Eventos de Auditoría
- **Endpoint:** Crear `GET /api/seguridad/auditoria/count`
- **Dato:** Total de eventos registrados
- **Actualizar:** "1,284" → valor real de BD

---

### 2. **Gráfico de Actividad de Seguridad**

Actualmente muestra valores hardcodeados:
- Inicios de sesión: 452
- Cambios de permisos: 128
- Cambios de configuración: 86
- Intentos fallidos: 24

**Datos reales disponibles:**

#### Inicios de sesión
- **Endpoint:** `GET /api/seguridad/accesos`
- **Dato:** `resumen.total` (todas las sesiones creadas)
- **Filtro:** Últimos 30 días con `fecha_inicio` y `fecha_fin`

#### Intentos fallidos
- **Fuente:** Tabla `auditlogs` o crear tabla `failed_login_attempts`
- **Query:** `SELECT COUNT(*) FROM auditlogs WHERE action = 'failed_login' AND created_at >= NOW() - INTERVAL '30 days'`

#### Cambios de permisos/configuración
- **Fuente:** Tabla `auditlogs`
- **Query:** Filtrar por tipo de acción
- **Endpoint:** Crear `GET /api/seguridad/estadisticas/actividad`

---

### 3. **Actividad Reciente (Panel derecho)**

Actualmente hardcodeado:
- "Nuevo usuario creado" - hace 35 minutos
- "Rol modificado" - hace 2 horas
- "Usuario desactivado" - hace 5 horas
- "Política actualizada" - hace 1 día

**Datos reales:**
- **Endpoint:** Crear `GET /api/seguridad/auditoria/recientes?limit=5`
- **Fuente:** Tabla `auditlogs`
- **Campos:** `action`, `user`, `description`, `created_at`
- **Ejemplo:**
```json
{
  "data": [
    {
      "icon": "UserCheck",
      "title": "Nuevo usuario creado",
      "description": "El administrador Juan Pérez creó el usuario María López",
      "timestamp": "2024-01-15T10:30:00Z",
      "relative_time": "Hace 35 minutos"
    }
  ]
}
```

---

### 4. **Tab: Sesiones Activas**

Actualmente hardcodeado con 5 usuarios ficticios.

**Datos reales YA disponibles:**
- **Endpoint:** `GET /api/seguridad/accesos?estado=activo&per_page=10`
- **Datos:** Lista de sesiones activas con:
  - Usuario
  - Email
  - IP
  - Dispositivo
  - Hora de inicio
  - Duración
  - Botón para cerrar sesión remota ✅ (ya funciona y expulsa al usuario)

---

### 5. **Tab: Alertas de Seguridad**

Actualmente hardcodeado:
- "3 intentos fallidos de inicio de sesión"
- "Usuario con permisos elevados sin actividad"
- "Sesión sospechosa desde nueva ubicación"

**Datos reales:**
- **Endpoint:** Crear `GET /api/seguridad/alertas`
- **Fuente:** Tabla `security_alerts` o lógica calculada
- **Tipos de alertas:**
  1. Intentos fallidos > threshold
  2. Múltiples sesiones del mismo usuario
  3. Sesiones desde IPs sospechosas
  4. Usuarios inactivos con roles críticos

---

### 6. **Tab: Estado de Políticas**

Actualmente hardcodeado:
- Política de contraseñas
- Autenticación multifactor
- Tiempo de sesión
- Cambio periódico de contraseña

**Datos reales:**
- **Endpoint:** Crear `GET /api/seguridad/politicas`
- **Fuente:** Tabla `securitypolicies` (ya existe en BD)
- **Campos:**
  - `password_min_length`
  - `password_require_uppercase`
  - `password_require_lowercase`
  - `password_require_numbers`
  - `password_require_special`
  - `password_expiry_days`
  - `max_login_attempts`
  - `lockout_duration`
  - `session_timeout`
  - `require_mfa`

---

## 🛠️ Endpoints a Crear

### 1. Estadísticas del Dashboard
```php
GET /api/seguridad/dashboard/estadisticas
```
**Retorna:**
```json
{
  "usuarios_activos": 152,
  "roles_configurados": 7,
  "sesiones_activas": 12,
  "eventos_auditoria": 1284,
  "alertas_pendientes": 3
}
```

### 2. Actividad de Seguridad (últimos 30 días)
```php
GET /api/seguridad/dashboard/actividad?dias=30
```
**Retorna:**
```json
{
  "inicios_sesion": 452,
  "cambios_permisos": 128,
  "cambios_configuracion": 86,
  "intentos_fallidos": 24,
  "porcentajes": {
    "inicios_sesion": 75,
    "cambios_permisos": 35,
    "cambios_configuracion": 25,
    "intentos_fallidos": 10
  }
}
```

### 3. Eventos Recientes
```php
GET /api/seguridad/auditoria/recientes?limit=5
```
**Retorna:**
```json
{
  "data": [
    {
      "id": 1,
      "tipo": "usuario_creado",
      "titulo": "Nuevo usuario creado",
      "descripcion": "El administrador Juan Pérez creó el usuario María López",
      "usuario": "Juan Pérez",
      "timestamp": "2024-01-15T10:30:00Z",
      "tiempo_relativo": "Hace 35 minutos"
    }
  ]
}
```

### 4. Alertas de Seguridad
```php
GET /api/seguridad/alertas?pendientes=true
```
**Retorna:**
```json
{
  "data": [
    {
      "id": 1,
      "severidad": "alta",
      "titulo": "3 intentos fallidos de inicio de sesión",
      "descripcion": "El usuario carlos@example.com ha fallado 3 veces",
      "timestamp": "2024-01-15T09:00:00Z",
      "leida": false
    }
  ],
  "total_pendientes": 3
}
```

### 5. Políticas de Seguridad
```php
GET /api/seguridad/politicas
```
**Retorna:**
```json
{
  "data": {
    "password_policy": {
      "min_length": 8,
      "require_uppercase": true,
      "require_numbers": true,
      "require_special": true,
      "expiry_days": 90
    },
    "session_policy": {
      "timeout_minutes": 30,
      "max_simultaneous": 3
    },
    "login_policy": {
      "max_attempts": 5,
      "lockout_duration_minutes": 15
    },
    "mfa": {
      "enabled": true,
      "required_for_admins": true
    }
  }
}
```

---

## ✅ Funcionalidad de Cerrar Sesión - IMPLEMENTADA

**Endpoint:** `POST /api/seguridad/accesos/{sessionId}/cerrar`

### ¿Qué hace ahora?
1. ✅ Elimina el token de `personal_access_tokens` (Sanctum)
2. ✅ Marca `is_active = false` en la tabla `sessions`
3. ✅ **Expulsa al usuario inmediatamente del sistema**

### ¿Cómo funciona?
Cuando presionas la X en una sesión activa:
- El token se elimina de la BD
- El usuario pierde acceso instantáneamente
- Su próximo request devolverá 401 Unauthorized
- Será redirigido al login automáticamente

### Pruébalo:
1. Abre el dashboard en dos navegadores diferentes
2. Inicia sesión en ambos
3. En el dashboard de seguridad, cierra una de las sesiones
4. El usuario en el otro navegador será expulsado al hacer cualquier acción

---

## 📝 Prioridad de Implementación

### Alta Prioridad (impacto inmediato)
1. ✅ **Sesiones activas** - Ya funcional con cierre remoto
2. 🔄 **Estadísticas principales** - Fácil de implementar
3. 🔄 **Actividad reciente** - Depende de tabla auditlogs

### Media Prioridad
4. 🔄 **Gráfico de actividad** - Requiere queries agregados
5. 🔄 **Alertas de seguridad** - Requiere lógica de detección

### Baja Prioridad
6. 🔄 **Estado de políticas** - Ya existe la tabla, solo leer

---

## 🎯 Siguiente Paso Recomendado

**Crear el endpoint de estadísticas del dashboard:**
```php
// En SeguridadAccesosController.php
public function estadisticasDashboard()
{
    return response()->json([
        'success' => true,
        'data' => [
            'usuarios_activos' => DB::table('users')->where('is_active', true)->count(),
            'roles_configurados' => DB::table('roles')->count(),
            'sesiones_activas' => DB::table('sessions')->where('is_active', true)->count(),
            'eventos_auditoria' => DB::table('auditlogs')->count(),
        ]
    ]);
}
```

¿Quieres que implemente este endpoint y actualice el dashboard para consumirlo?
