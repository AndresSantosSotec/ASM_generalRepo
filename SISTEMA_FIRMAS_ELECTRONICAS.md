# Sistema de Firmas Electrónicas - Documentación

## 📋 Resumen

Sistema de doble firma electrónica para contratos de confidencialidad. El asesor firma primero, luego el estudiante recibe un link personalizado para completar su firma. **Ambas firmas se guardan en formato imagen (base64) en la base de datos** para consulta posterior.

## 🔄 Flujo Completo

### 1. Asesor Firma el Contrato
- **Ubicación**: `/firma/[id]` (Vista existente `student-details.tsx`)
- **Proceso**:
  1. Asesor dibuja su firma en el canvas
  2. Al hacer clic en "Enviar Contrato":
     - Se llama a `POST /api/contratos/firma-asesor`
     - **Se guarda la firma del asesor en `contactos_enviados.firma_asesor`**
     - Se genera un token único
     - Se retorna el URL: `{APP_URL}/firma-estudiante/{token}`
  3. Se envía el email al estudiante con:
     - PDF del contrato con firma del asesor
     - Botón/Link para que el estudiante firme

### 2. Estudiante Firma el Contrato
- **Ubicación**: `/firma-estudiante/[token]` (Vista pública nueva)
- **Proceso**:
  1. Estudiante abre el link recibido por email
  2. Se carga el contrato con `GET /api/contratos/token/{token}`
  3. Estudiante revisa el contrato y ve la firma del asesor
  4. Dibuja su firma en el canvas
  5. Al hacer clic en "Firmar y Completar":
     - Se llama a `POST /api/contratos/firma-estudiante`
     - **Se actualiza `contactos_enviados.firma_estudiante`**
     - Estado cambia a `firmado_completo`

### 3. Consulta de Contratos (NUEVO)
- **Ubicación**: `/firma/contratos` (Lista) y `/firma/contratos/[id]` (Detalle)
- **Proceso**:
  1. Lista todos los contratos con filtros
  2. Muestra estado de firmas
  3. Al hacer clic en "Ver":
     - **Se cargan ambas firmas desde la BD en formato imagen**
     - Se muestra el contrato completo con ambas firmas visibles

## 🗄️ Almacenamiento en Base de Datos

### Tabla `contactos_enviados`

**Columnas relevantes para firmas**:

```sql
-- Firma del asesor (imagen base64)
firma_asesor TEXT NULL

-- Firma del estudiante (imagen base64)
firma_estudiante TEXT NULL

-- Token único para acceso del estudiante
token_firma VARCHAR(64) UNIQUE NULL

-- Estado del proceso de firma
estado_firma ENUM('pendiente', 'firmado_asesor', 'firmado_completo') DEFAULT 'pendiente'

-- Fecha en que el estudiante firmó
fecha_firma_estudiante TIMESTAMP NULL

-- JSON con datos del contrato para regenerar vista
datos_contrato JSON NULL
```

**Ejemplo de consulta**:
```sql
SELECT 
    id,
    prospecto_id,
    estado_firma,
    LENGTH(firma_asesor) as tamaño_firma_asesor,
    LENGTH(firma_estudiante) as tamaño_firma_estudiante,
    fecha_envio,
    fecha_firma_estudiante
FROM contactos_enviados
WHERE tipo_contacto = 'contrato_confidencialidad'
ORDER BY created_at DESC;
```

**Las firmas se guardan como**: `data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...`

## 🔌 Endpoints API

### 1. Guardar Firma del Asesor
```
POST /api/contratos/firma-asesor
Authorization: Bearer {token}
```

**Body**:
```json
{
  "prospecto_id": 123,
  "firma_asesor": "data:image/png;base64,...",
  "datos_contrato": { ... }
}
```

**Response**:
```json
{
  "success": true,
  "contrato_id": 456,
  "token": "abc123...",
  "url_firma_estudiante": "http://localhost:3000/firma-estudiante/abc123..."
}
```

### 2. Obtener Contrato por Token (Pública)
```
GET /api/contratos/token/{token}
```

### 3. Guardar Firma del Estudiante (Pública)
```
POST /api/contratos/firma-estudiante
Body: { "token": "...", "firma_estudiante": "data:image/png;base64,..." }
```

### 4. Obtener Contrato con Firmas (NUEVO)
```
GET /api/contratos/{id}
Authorization: Bearer {token}
```

**Response**:
```json
{
  "success": true,
  "contrato": {
    "id": 456,
    "firma_asesor": "data:image/png;base64,...",
    "firma_estudiante": "data:image/png;base64,...",
    "estado_firma": "firmado_completo",
    ...
  }
}
```

### 5. Listar Todos los Contratos (NUEVO)
```
GET /api/contratos?page=1&per_page=15&search=nombre&estado=firmado_completo
Authorization: Bearer {token}
```

## 📁 Archivos del Sistema

### Backend (Laravel)
- ✅ `database/migrations/2025_01_19_000000_add_firmas_to_contactos_enviados.php`
- ✅ `app/Http/Controllers/Api/FirmaContratoController.php`
- ✅ `app/Http/Controllers/Api/ProspectoController.php` - `enviarContrato()`
- ✅ `app/Mail/SendContractPdf.php`
- ✅ `resources/views/emails/confidencialidad.blade.php`
- ✅ `routes/api.php`

### Frontend (Next.js/React)
- ✅ `components/firma/student-details.tsx` - Firma del asesor
- ✅ `app/firma-estudiante/[token]/page.tsx` - Firma del estudiante (pública)
- ✅ `app/firma/contratos/page.tsx` - Lista de contratos (NUEVO)
- ✅ `app/firma/contratos/[id]/page.tsx` - Vista previa con firmas (NUEVO)
- ✅ `app/firma/page.tsx` - Módulo principal (actualizado con estados ampliados)

## 🎯 Estados de Prospectos Cargados

El módulo `/firma` ahora carga prospectos con los siguientes estados:

1. **Pendiente Aprobacion**
2. **Pendiente de Aprobación Financiera**
3. **Pendiente de Aprobación Académica**
4. **Inscrito**
5. **Preinscripción**
6. **revisada**
7. **aprobada**

## 🚀 Navegación del Sistema

```
┌─────────────────────────────────────────────────────────────┐
│  /firma (Módulo Principal)                                   │
│  - Prospectos pendientes (estados ampliados)                 │
│  - Botón: "Ver Todos los Contratos" → /firma/contratos      │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  /firma/contratos (Lista de Contratos)                       │
│  - Tabla con todos los contratos                             │
│  - Filtros: búsqueda, estado                                 │
│  - Botón "Ver" → /firma/contratos/[id]                      │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  /firma/contratos/[id] (Vista Previa)                        │
│  - Contrato completo                                          │
│  - 🖼️ Firma del Asesor (imagen desde BD)                    │
│  - 🖼️ Firma del Estudiante (imagen desde BD)                │
│  - Link para firma estudiante (si falta)                     │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  /firma/[id] (Firmar como Asesor)                           │
│  - Canvas para firma del asesor                               │
│  - Guarda en: contactos_enviados.firma_asesor               │
│  - Genera token y envía email                                 │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  /firma-estudiante/[token] (Firmar como Estudiante)         │
│  - Vista pública (sin autenticación)                          │
│  - Canvas para firma del estudiante                           │
│  - Guarda en: contactos_enviados.firma_estudiante           │
└─────────────────────────────────────────────────────────────┘
```

## 🖼️ Visualización de Firmas

### En la Vista Previa (`/firma/contratos/[id]`)

```tsx
{/* Firma del Asesor */}
<Image
  src={contrato.firma_asesor}  // data:image/png;base64,...
  alt="Firma del asesor"
  width={300}
  height={150}
/>

{/* Firma del Estudiante */}
<Image
  src={contrato.firma_estudiante}  // data:image/png;base64,...
  alt="Firma del estudiante"
  width={300}
  height={150}
/>
```

## 🔒 Seguridad

- **Tokens únicos** generados con `Str::random(32)`
- **Vista pública** para estudiantes protegida solo por token
- **Endpoints autenticados** para ver contratos completos
- **Validación** de estado antes de permitir firmar

## 📊 Consultas Útiles

### Ver contratos con ambas firmas
```sql
SELECT 
    id,
    prospecto_id,
    estado_firma,
    CASE 
        WHEN firma_asesor IS NOT NULL THEN '✓ Tiene'
        ELSE '✗ Falta'
    END as firma_asesor,
    CASE 
        WHEN firma_estudiante IS NOT NULL THEN '✓ Tiene'
        ELSE '✗ Falta'
    END as firma_estudiante
FROM contactos_enviados
WHERE tipo_contacto = 'contrato_confidencialidad';
```

### Extraer firma como imagen
```sql
-- Las firmas están en base64 y se pueden usar directamente en <img> tags
SELECT firma_asesor FROM contactos_enviados WHERE id = 123;
-- Resultado: data:image/png;base64,iVBORw0KGgo...
```

## ✨ Mejoras Futuras

- [ ] Almacenar firmas en cloud storage (S3/CloudStorage) en lugar de base64
- [ ] Comprimir imágenes de firmas
- [ ] Agregar marca de agua con timestamp
- [ ] Exportar contratos firmados en PDF
- [ ] Notificaciones cuando estudiante firma
- [ ] Dashboard de estadísticas de firmas

## 🗄️ Cambios en Base de Datos

### Tabla `contactos_enviados`

**Nuevas columnas agregadas**:

```sql
-- Firma del asesor (imagen base64)
firma_asesor TEXT NULL

-- Firma del estudiante (imagen base64)
firma_estudiante TEXT NULL

-- Token único para acceso del estudiante
token_firma VARCHAR(64) UNIQUE NULL

-- Estado del proceso de firma
estado_firma ENUM('pendiente', 'firmado_asesor', 'firmado_completo') DEFAULT 'pendiente'

-- Fecha en que el estudiante firmó
fecha_firma_estudiante TIMESTAMP NULL

-- JSON con datos del contrato para regenerar vista
datos_contrato JSON NULL
```

**Migración**: `database/migrations/2025_01_19_000000_add_firmas_to_contactos_enviados.php`

## 🔌 Endpoints API

### 1. Guardar Firma del Asesor
```
POST /api/contratos/firma-asesor
Authorization: Bearer {token}
```

**Body**:
```json
{
  "prospecto_id": 123,
  "firma_asesor": "data:image/png;base64,...",
  "datos_contrato": {
    "prospecto": "Nombre Completo",
    "email": "email@example.com",
    "programa": "Master in Business Administration",
    "programa_abreviatura": "MBA",
    "matricula": "5000.00",
    "mensualidad": "2500.00",
    "convenio_id": 1,
    "asesor": "Juan Pérez",
    "fecha": "martes, 19 de noviembre de 2025"
  }
}
```

**Response**:
```json
{
  "success": true,
  "contrato_id": 456,
  "token": "abc123def456...",
  "url_firma_estudiante": "http://localhost:3000/firma-estudiante/abc123def456..."
}
```

### 2. Obtener Contrato por Token (Pública)
```
GET /api/contratos/token/{token}
```

**Response**:
```json
{
  "success": true,
  "contrato": {
    "id": 456,
    "prospecto_id": 123,
    "estado_firma": "firmado_asesor",
    "fecha_envio": "2025-11-19 10:30:00",
    "datos_contrato": {...},
    "firma_asesor": "data:image/png;base64,..."
  },
  "prospecto": {
    "id": 123,
    "nombre": "Nombre Completo",
    "email": "email@example.com"
  }
}
```

### 3. Guardar Firma del Estudiante (Pública)
```
POST /api/contratos/firma-estudiante
```

**Body**:
```json
{
  "token": "abc123def456...",
  "firma_estudiante": "data:image/png;base64,..."
}
```

**Response**:
```json
{
  "success": true,
  "message": "Contrato firmado exitosamente"
}
```

## 📁 Archivos Modificados/Creados

### Backend (Laravel)
- ✅ `database/migrations/2025_01_19_000000_add_firmas_to_contactos_enviados.php` (NUEVO)
- ✅ `app/Http/Controllers/Api/FirmaContratoController.php` (NUEVO)
- ✅ `routes/api.php` - Agregadas rutas de firmas
- ✅ `app/Http/Controllers/Api/ProspectoController.php` - Modificado `enviarContrato()`
- ✅ `app/Mail/SendContractPdf.php` - Agregado parámetro `$urlFirmaEstudiante`
- ✅ `resources/views/emails/confidencialidad.blade.php` - Agregado botón con link

### Frontend (Next.js/React)
- ✅ `components/firma/student-details.tsx` - Modificado para guardar firma antes de enviar
- ✅ `app/firma-estudiante/[token]/page.tsx` (NUEVO) - Vista pública de firma

## 🚀 Cómo Ejecutar

### 1. Backend
```bash
cd blue_atlas_backend

# Ejecutar migración
php artisan migrate

# Verificar que se crearon las columnas
php artisan tinker
>>> Schema::hasColumn('contactos_enviados', 'firma_asesor');
>>> Schema::hasColumn('contactos_enviados', 'token_firma');
```

### 2. Frontend
```bash
cd blue-atlas-dashboard
npm run dev
```

## 🧪 Pruebas

### Flujo Completo
1. Ir a `http://localhost:3000/firma/123` (ID de un prospecto válido)
2. Firmar en el canvas como asesor
3. Hacer clic en "Enviar Contrato"
4. Verificar que aparece modal con el link generado
5. Copiar el link y abrir en navegador (puede ser incógnito)
6. Verificar que se muestra el contrato con la firma del asesor
7. Firmar como estudiante
8. Verificar mensaje de éxito

### Verificar en Base de Datos
```sql
-- Ver registros con firmas
SELECT 
    id, 
    prospecto_id, 
    estado_firma, 
    token_firma,
    LENGTH(firma_asesor) as firma_asesor_size,
    LENGTH(firma_estudiante) as firma_estudiante_size,
    fecha_firma_estudiante
FROM contactos_enviados
WHERE tipo_contacto = 'contrato_confidencialidad'
ORDER BY created_at DESC;
```

## 🔒 Seguridad

### Tokens
- Generados con `Str::random(32)` (Laravel)
- Únicos en la base de datos (constraint UNIQUE)
- No expiran (considerar agregar expiración si es necesario)

### Validaciones
- Token debe existir en BD
- Contrato no puede firmarse dos veces por el estudiante
- Vista del estudiante es pública pero requiere token válido

## 📧 Email

El email enviado incluye:
- PDF con el contrato y firma del asesor
- Botón destacado "Firmar Contrato Ahora"
- Link alternativo en texto plano
- Todos los términos del contrato

## 🔄 Estados de Firma

| Estado | Descripción |
|--------|-------------|
| `pendiente` | Registro creado pero sin firmas |
| `firmado_asesor` | Asesor firmó, esperando al estudiante |
| `firmado_completo` | Ambos firmaron, proceso completado |

## 📝 Notas Importantes

1. **Firmas Base64**: Las imágenes se guardan como base64 en la BD (considerar almacenamiento en S3/similar para producción)
2. **Sin autenticación**: La vista del estudiante es pública, solo protegida por el token
3. **Email**: Requiere configuración SMTP en Laravel (`.env`)
4. **CORS**: Asegurar que el frontend puede hacer llamadas al backend

## 🐛 Troubleshooting

### "Token no encontrado"
- Verificar que el token existe en BD: `SELECT * FROM contactos_enviados WHERE token_firma = 'xxx'`
- Verificar que el endpoint público funciona: `/api/contratos/token/{token}`

### "Contrato ya firmado"
- Verificar estado: debe ser `firmado_asesor` para que el estudiante pueda firmar
- Si necesita resetear: `UPDATE contactos_enviados SET estado_firma='firmado_asesor', firma_estudiante=NULL WHERE id=X`

### Firma no se guarda
- Verificar que el canvas tiene contenido antes de enviar
- Ver console del navegador para errores
- Verificar que la imagen base64 se está generando correctamente

## ✨ Mejoras Futuras

- [ ] Almacenar firmas en cloud storage (S3/CloudStorage)
- [ ] Agregar expiración de tokens (ej: 30 días)
- [ ] Notificar al asesor cuando el estudiante firma
- [ ] Dashboard para ver estado de contratos pendientes
- [ ] Reenviar link si el estudiante lo perdió
- [ ] Versión móvil mejorada del canvas
- [ ] Firma con touch en móviles
