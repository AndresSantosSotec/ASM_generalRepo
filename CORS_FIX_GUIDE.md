# 🔧 Solución de Errores - CORS y Duplicados

## ✅ Errores Corregidos

### 1. Error CORS (Access-Control-Allow-Origin)

**Error Original:**
```
Access to XMLHttpRequest at 'http://localhost:8000/api/massive-user-generation/prospectos/count' 
from origin 'http://localhost:3000' has been blocked by CORS policy
```

**Solución Aplicada:**
- ✅ Configurado `config/cors.php` con orígenes específicos
- ✅ Agregado `http://localhost:3000` a allowed_origins
- ✅ Configurado `supports_credentials: true`
- ✅ Headers expuestos: `Authorization`
- ✅ Cache de preflight: 24 horas (86400s)

**Archivo modificado:** `config/cors.php`

### 2. Método Duplicado `usuario()` en Prospecto.php

**Error Original:**
```
Cannot redeclare App\Models\Prospecto::usuario()
Duplicate symbol declaration 'usuario'
```

**Problema:**
Había dos declaraciones del método `usuario()`:
- Línea 103: `belongsTo(User::class, 'id_usuario')` ✅ CORRECTO
- Línea 331: `belongsTo(User::class, 'carnet_generado', 'carnet')` ❌ DUPLICADO

**Solución Aplicada:**
- ✅ Eliminada declaración duplicada en línea 331
- ✅ Mantenida versión correcta que usa `id_usuario`

**Archivo modificado:** `app/Models/Prospecto.php`

### 3. Parámetros Nullable Deprecados (PHP 8.1+)

**Error Original:**
```
Implicitly nullable parameters are deprecated.
```

**Problema:**
PHP 8.1+ requiere tipado explícito `?Type` para parámetros nullable.

**Soluciones Aplicadas:**

| Método | Antes | Después |
|--------|-------|---------|
| `activeExceptionCategories()` | `Carbon $date = null` | `?Carbon $date = null` |
| `hasActiveException()` | `Carbon $date = null` | `?Carbon $date = null` |
| `getCustomDueDay()` | `Carbon $date = null` | `?Carbon $date = null` |

**Archivo modificado:** `app/Models/Prospecto.php`

### 4. Error en PaymentController - Acceso a Propiedad Protegida

**Error Original:**
```
Cannot access protected property Illuminate\Http\Request::$method from 
App\Http\Controllers\Api\PaymentController scope.
```

**Problema:**
```php
$method = $request->method; // ❌ 'method' es propiedad protegida de Request
```

**Solución Aplicada:**
```php
$method = $request->input('method'); // ✅ Usar método input()
```

**Archivo modificado:** `app/Http/Controllers/Api/PaymentController.php` (línea 41)

---

## 🚀 Verificación de la Solución

### 1. Verificar Cache Limpio

```bash
cd blue_atlas_backend

# Limpiar todos los caches
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
```

### 2. Verificar Configuración CORS

```bash
php artisan tinker

# Verificar configuración cargada
> config('cors.allowed_origins');
=> [
     "http://localhost:3000",
     "http://localhost:3001",
     "http://127.0.0.1:3000",
     "http://localhost:3000", // env('FRONTEND_URL')
   ]
```

### 3. Verificar Rutas API

```bash
php artisan route:list --path=massive-user-generation

# Debería mostrar:
# GET|HEAD  api/massive-user-generation/prospectos/count
# GET|HEAD  api/massive-user-generation/prospectos/list
# POST      api/massive-user-generation/start
# GET|HEAD  api/massive-user-generation/batch/{batchId}/stats
# GET|HEAD  api/massive-user-generation/batch/{batchId}/logs
# GET|HEAD  api/massive-user-generation/batch/history
```

### 4. Test Manual de CORS

```bash
# Desde PowerShell o Git Bash
curl -H "Origin: http://localhost:3000" \
     -H "Access-Control-Request-Method: GET" \
     -H "Access-Control-Request-Headers: Content-Type" \
     -X OPTIONS \
     http://localhost:8000/api/massive-user-generation/prospectos/count -v

# Debería incluir en la respuesta:
# Access-Control-Allow-Origin: http://localhost:3000
# Access-Control-Allow-Credentials: true
```

### 5. Verificar Modelo Prospecto

```bash
php artisan tinker

# Verificar que no hay métodos duplicados
> $methods = get_class_methods(\App\Models\Prospecto::class);
> in_array('usuario', $methods); // true
> count(array_keys($methods, 'usuario')); // debería ser 1 (no duplicado)
```

---

## 📝 Configuración .env Recomendada

Agregar al archivo `.env` del backend:

```env
# Frontend Configuration
FRONTEND_URL=http://localhost:3000

# CORS Configuration (opcional, ya está en config/cors.php)
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:3001

# Session Configuration (para Sanctum)
SESSION_DRIVER=cookie
SESSION_LIFETIME=120
SESSION_DOMAIN=localhost
SESSION_SECURE_COOKIE=false
SANCTUM_STATEFUL_DOMAINS=localhost:3000,127.0.0.1:3000
```

---

## 🧪 Test de Integración Frontend → Backend

### Test 1: Llamada API desde Frontend

```typescript
// En Next.js (blue-atlas-dashboard)
const testCORS = async () => {
  try {
    const response = await fetch('http://localhost:8000/api/massive-user-generation/prospectos/count', {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${yourToken}` // Si usas Sanctum
      },
      credentials: 'include' // Importante para cookies
    });
    
    const data = await response.json();
    console.log('✅ CORS funcionando:', data);
  } catch (error) {
    console.error('❌ Error CORS:', error);
  }
};
```

### Test 2: Verificar Preflight (OPTIONS)

```bash
# El navegador automáticamente envía OPTIONS antes de GET/POST
# Verificar que el servidor responde correctamente:

curl -X OPTIONS http://localhost:8000/api/massive-user-generation/prospectos/count \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: GET" \
  -v
```

---

## 🔍 Solución de Problemas Comunes

### Problema: CORS sigue bloqueado

**Solución:**
```bash
# 1. Verificar que el servidor Laravel está corriendo
php artisan serve --host=0.0.0.0 --port=8000

# 2. Verificar middleware CORS en Kernel.php
# Debe incluir: \Illuminate\Http\Middleware\HandleCors::class

# 3. Limpiar cache del navegador (Ctrl + Shift + Delete)

# 4. Verificar que no hay proxy/VPN bloqueando
```

### Problema: Error 401 Unauthorized

**Solución:**
```bash
# Verificar token de autenticación
# En Next.js, asegurar que el token se envía correctamente:

axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
```

### Problema: Error 404 Not Found

**Solución:**
```bash
# Verificar rutas registradas
php artisan route:list | grep massive-user-generation

# Si no aparecen, verificar routes/api.php líneas 895-906
```

---

## ✅ Checklist de Verificación Final

- [x] ✅ Método `usuario()` duplicado eliminado en Prospecto.php
- [x] ✅ Parámetros nullable corregidos con `?Type` syntax
- [x] ✅ Error de `$request->method` corregido a `$request->input('method')`
- [x] ✅ CORS configurado para localhost:3000
- [x] ✅ Cache de configuración limpiado
- [x] ✅ Cache de rutas limpiado
- [ ] 🔄 Servidor Laravel reiniciado (ejecutar `php artisan serve`)
- [ ] 🔄 Frontend reiniciado (ejecutar `npm run dev`)
- [ ] 🧪 Test manual de endpoint desde navegador

---

## 🎯 Siguiente Paso: Reiniciar Servidores

```bash
# Terminal 1 - Backend
cd blue_atlas_backend
php artisan serve --host=0.0.0.0 --port=8000

# Terminal 2 - Frontend
cd blue-atlas-dashboard
npm run dev
```

Luego navega a: `http://localhost:3000/academico/generacion_envio_masivo`

**Resultado esperado:**
- ✅ Página carga sin errores CORS
- ✅ Contador de prospectos aparece correctamente
- ✅ Consola del navegador sin errores

---

**Fecha de corrección:** 13 de Noviembre, 2025  
**Archivos modificados:** 3
- `config/cors.php`
- `app/Models/Prospecto.php`
- `app/Http/Controllers/Api/PaymentController.php`
