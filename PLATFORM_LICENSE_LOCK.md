# Bloqueo de plataforma por licencia (cliente moroso)

Sistema para **suspender ASMProlink** cuando el **cliente** (institución) no paga la licencia del software.  
**No bloquea estudiantes por mora académica** — eso sigue en `BlockingService`.

---

## Guía rápida (lo más simple)

### En tu PC / servidor donde tienes la clave privada

Doble clic en Windows (carpeta `blue_atlas_backend/scripts/`):

| Archivo | Qué hace |
|---------|----------|
| `bloquear-plataforma.bat` | Bloquea **ya** (un solo paso) |
| `desbloquear-plataforma.bat` | Desbloquea **ya** (un solo paso) |
| `generar-token-bloqueo.bat` | Solo genera token para pegar en servidor remoto |
| `generar-token-desbloqueo.bat` | Solo genera token de desbloqueo remoto |

O por consola:

```bash
cd blue_atlas_backend
php artisan platform:block      # BLOQUEAR (firma + aplica)
php artisan platform:unblock    # DESBLOQUEAR (firma + aplica)
php artisan platform:status     # Ver estado
```

### En servidor del cliente (sin clave privada)

El cliente **no puede** bloquear ni desbloquear solo. Usted genera el token en su PC:

```bash
php artisan platform:block --token-only
```

Y en el servidor del cliente (solo aplica el token que usted envía):

```bash
php artisan platform:apply-license "PEGAR_TOKEN_AQUI"
```

---

## Seguridad: por qué el cliente no puede desactivarlo

El estado `locked` en base de datos **no es confiable por sí solo**. Cada cambio debe traer una **firma RSA** generada con la **clave privada del proveedor**.

| Acción del cliente en el servidor | Resultado |
|-----------------------------------|-----------|
| `UPDATE platform_license_locks SET is_locked = 0` | **Sigue bloqueado** — la firma no coincide |
| Borrar fila de licencia | **Bloqueado** — sin licencia válida = fail-safe |
| Alterar `license_payload` | **Bloqueado** + mensaje de alteración detectada |
| Desbloquear sin token firmado | **Imposible** sin la clave privada del proveedor |

La **clave privada nunca se instala** en el servidor del cliente.

---

## 1. Instalación inicial (una vez)

### En entorno del proveedor (tu máquina segura)

```bash
cd blue_atlas_backend
php artisan platform:generate-keypair
```

Guardar:
- **Clave privada** → solo en `.env` del proveedor (`PLATFORM_LICENSE_PRIVATE_KEY`)
- **Clave pública** → en `.env` del cliente (`PLATFORM_LICENSE_PUBLIC_KEY`)

### En servidor del cliente

`.env`:

```env
PLATFORM_LICENSE_ENFORCE=true
PLATFORM_LICENSE_PUBLIC_KEY="-----BEGIN PUBLIC KEY-----\n...\n-----END PUBLIC KEY-----"
PLATFORM_LICENSE_CONTACT_PHONES="+502 3218 0070"
```

Migración:

```bash
php artisan migrate
```

Desbloqueo inicial (token generado por el proveedor):

```bash
php artisan platform:apply-license "TOKEN_BASE64_AQUI"
```

---

## 2. Bloquear cliente (falta de pago)

**Forma simple (recomendada):**

```bash
php artisan platform:block
```

**Servidor remoto:** `php artisan platform:block --token-only` → copiar token → `platform:apply-license` en cliente.

---

## 3. Desbloquear cliente (pagó)

```bash
php artisan platform:unblock
```

Remoto: `php artisan platform:unblock --token-only`

---

## 4. Verificar estado

```bash
php artisan platform:status
```

API pública (frontend):

```
GET /api/platform/license-status
```

---

## 5. Desarrollo local

En `.env` local del desarrollador:

```env
APP_ENV=local
PLATFORM_LICENSE_ENFORCE_IN_LOCAL=false
```

En producción del cliente **no** desactivar `PLATFORM_LICENSE_ENFORCE`.

---

## 6. Archivos del sistema

| Archivo | Rol |
|---------|-----|
| `config/platform.php` | Configuración pública |
| `app/Services/PlatformLicenseService.php` | Verificación y firma |
| `app/Http/Middleware/EnsurePlatformLicensed.php` | Bloqueo API |
| `app/Http/Controllers/Api/PlatformLicenseController.php` | Estado para frontend |
| `app/Http/Controllers/Api/LoginController.php` | Segunda capa en login |
| `app/Console/Commands/Platform*.php` | Generar claves, firmar, aplicar |
| `database/migrations/2026_06_10_000001_create_platform_license_locks_table.php` | Tabla |
| Frontend `PlatformLicenseGate` + `PlatformLicenseScreen` | Bloqueo UI |

---

## 7. Limitaciones honestas

Si el cliente tiene acceso root al servidor **y** modifica el código fuente (elimina middleware, cambia `PlatformLicenseService`), podría evadir el bloqueo. Este diseño impide el bypass **solo vía base de datos o `.env` simple**. Para máxima protección combinar con:

- Despliegue controlado por el proveedor
- Obfuscación / builds firmados
- Heartbeat contra servidor del proveedor (opcional futuro)

Para el objetivo pedido (“que no lo desactive fácil desde la BD”), la **firma RSA** cumple.

---

## 8. Flujo resumido

```
Proveedor (clave privada)
    │
    ├─ platform:sign-license --locked=true|false
    │
    └─ token base64 ──► Cliente: platform:apply-license
                              │
                              ▼
                    platform_license_locks (payload + firma)
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
        Middleware API                   Frontend Gate
        HTTP 423                           Pantalla bloqueo
```
