# 🔐 Guía de Instalación - Permisos de Personalización

## Estado Actual

Los permisos han sido creados y están listos para instalarse en el sistema. Se han generado 4 permisos:

- `system.customization.view` - Ver configuración
- `system.customization.edit` - Editar configuración
- `system.customization.create` - Crear nuevas configuraciones
- `system.customization.delete` - Eliminar configuraciones

## Pasos para Instalar

### 1️⃣ Backend - Ejecutar Migración

```bash
cd blue_atlas_backend

# Ejecutar la migración de permisos
php artisan migrate

# Si necesitas verificar que la migración se ejecutó
php artisan migrate:status
```

**¿Qué hace esta migración?**
- ✅ Crea 4 nuevos permisos en tabla `permissions`
- ✅ Asigna automáticamente el permiso `system.customization.edit` al rol **Admin**
- ✅ Usa transacciones, por lo que es seguro ejecutar múltiples veces

### 2️⃣ Frontend - Verificar Cambios

No requiere cambios de instalación. El frontend ya:
- ✅ Verifica si el usuario es Admin
- ✅ Muestra interfaz de personalización solo a admins
- ✅ Maneja errores 403 cuando no hay permiso

### 3️⃣ Verificar Instalación

#### En Laravel Artisan Tinker:

```bash
php artisan tinker

# Ver los permisos creados
>>> App\Models\Permission::where('name', 'like', '%customization%')->get();

# Ver qué rol tiene el permiso
>>> App\Models\RolePermission::whereHas('permission', fn($q) => 
    $q->where('name', 'system.customization.edit'))->with('role', 'permission')->get();
```

#### En la BD directamente:

```sql
-- Ver los permisos creados
SELECT * FROM permissions 
WHERE name LIKE '%customization%';

-- Ver permisos asignados a Admin
SELECT rp.*, r.name as role_name, p.name as permission_name
FROM rolepermissions rp
JOIN roles r ON rp.role_id = r.id
JOIN permissions p ON rp.permission_id = p.id
WHERE p.name LIKE '%customization%';
```

## Flujo de Validación en la Aplicación

### Backend

```
Request a /api/customization/update
    ↓
¿Usuario autenticado?
    ├─ NO → Rechazar (middleware auth:sanctum)
    └─ SÍ ↓
¿Es Admin?
    ├─ SÍ → Permitir ✅
    └─ NO ↓
¿Tiene permiso system.customization.edit?
    ├─ SÍ → Permitir ✅
    └─ NO → Error 403 ❌
```

### Frontend

```
Navegar a /configuracion/personalizacion
    ↓
¿Usuario autenticado?
    ├─ NO → Mostrar "Usuario no autenticado"
    └─ SÍ ↓
¿user.role.name === 'admin' o 'Admin'?
    ├─ SÍ → Mostrar interfaz de personalización ✅
    └─ NO → Mostrar "Acceso denegado" ❌
```

## Asignación Manual de Permisos

Si necesitas asignar el permiso a un usuario específico (no admin):

### Opción 1: Vía Tinker

```bash
php artisan tinker

>>> $user = App\Models\User::find(5); // usuario con ID 5
>>> $permission = App\Models\Permission::where('name', 'system.customization.edit')->first();
>>> App\Models\UserPermission::create(['user_id' => $user->id, 'permission_id' => $permission->id]);
```

### Opción 2: Vía Query SQL

```sql
-- Obtener el ID del permiso
SELECT id FROM permissions WHERE name = 'system.customization.edit';

-- Asignar a un usuario (reemplaza 1 con el user_id y 1 con el permission_id)
INSERT INTO userpermissions (user_id, permission_id) VALUES (1, 1);
```

### Opción 3: Asignar a un Rol

```bash
php artisan tinker

>>> $role = App\Models\Role::where('name', 'Editor')->first(); // o el rol que desees
>>> $permission = App\Models\Permission::where('name', 'system.customization.edit')->first();
>>> App\Models\RolePermission::create(['role_id' => $role->id, 'permission_id' => $permission->id, 'scope' => 'global']);
```

## Troubleshooting

### ❌ Error: "Tabla 'permissions' no existe"

**Solución**: Ejecutar todas las migraciones
```bash
php artisan migrate:fresh  # ⚠️ Esto borra toda la BD
# o simplemente
php artisan migrate
```

### ❌ Error: "No tienes permiso para personalizar el sistema"

**Causas posibles**:
1. El usuario no es Admin
2. La migración no se ejecutó correctamente
3. El rol Admin no existe o no tiene el permiso

**Solución**:
```bash
php artisan tinker
>>> App\Models\Role::all(); // Ver roles disponibles
>>> App\Models\Permission::where('name', 'like', '%customization%')->get();
>>> App\Models\RolePermission::whereHas('permission', fn($q) => 
    $q->where('name', 'system.customization.edit'))->get();
```

### ❌ Los cambios no se aplican en el frontend

**Solución**:
1. Limpiar caché del navegador
2. Hard refresh: `Ctrl+Shift+R` (Windows) o `Cmd+Shift+R` (Mac)
3. Verificar en DevTools si hay errores
4. Revisar que el token de autenticación sea válido

## Rollback (Deshacer)

Si necesitas deshacer los cambios:

```bash
php artisan migrate:rollback

# O si ejecutaste múltiples migraciones
php artisan migrate:rollback --step=2
```

Esto eliminará automáticamente:
- ✅ Los 4 permisos creados
- ✅ Las asignaciones en rolepermissions
- ✅ Toda la configuración asociada

## Ramas Involucradas

- **Backend**: `gaia_business_school_back`
- **Frontend**: `gaia_business_school_front`

## Archivos Modificados

### Backend
```
database/migrations/
  └─ 2026_02_16_add_system_customization_permissions.php (NUEVO)
  
app/Http/Controllers/
  └─ SystemCustomizationController.php (ACTUALIZADO - agregué validación)
```

### Frontend
```
app/configuracion/personalizacion/
  └─ page.tsx (ACTUALIZADO - mejor manejo de permisos)
```

## Seguridad

✅ **Validación en Backend**: La validación de permisos ocurre siempre en el servidor
✅ **Autenticación**: Requiere token sanctum válido
✅ **Autorización**: Verifica permisos antes de permitir cambios
✅ **Transacciones**: La migración es atómica (todo o nada)

---

**Fecha**: 16 de Febrero de 2026
**Versión**: 1.0.0
**Estado**: ✅ Listo para instalar
