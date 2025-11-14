# 📧 Rework Sistema de Generación de Usuarios y Emails Corporativos

## ✅ Cambios Implementados

### 1. **Generación de Email Corporativo** 
**Archivo**: `app/Services/MassiveUserGenerationService.php`

- ✅ Nuevo método `generateCorporateEmail()` que crea emails con formato:
  - **Patrón**: `nombre.apellido@americanschool.edu.gt`
  - **Ejemplo**: Juan Carlos Pérez → `juan.perez@americanschool.edu.gt`
  
- ✅ Validación de unicidad: Si el email ya existe, agrega número correlativo
  - `juan.perez@americanschool.edu.gt`
  - `juan.perez1@americanschool.edu.gt`
  - `juan.perez2@americanschool.edu.gt`

- ✅ Método `removeAccents()` para normalizar nombres:
  - Elimina acentos (á, é, í, ó, ú, ñ)
  - Remueve caracteres especiales
  - Filtra artículos comunes (de, la, del, los, las)

### 2. **Filtrado Mejorado de Prospectos**
**Archivo**: `app/Services/MassiveUserGenerationService.php`

- ✅ Excluye prospectos cuyo **carnet ya tiene usuario registrado**
- ✅ Query actualizado:
```php
->whereNotIn('carnet', function($query) {
    $query->select('carnet')
        ->from('users')
        ->whereNotNull('carnet');
})
```

- ✅ Verificación adicional por carnet antes de crear usuario:
```php
$existingUserByCarnet = User::where('carnet', $prospecto->carnet)
    ->whereNotNull('carnet')
    ->first();
```

### 3. **Email Corporativo vs Email Personal**

#### Email Corporativo (Sistema)
- 🔐 **Generado automáticamente** por el sistema
- 📧 **Formato**: `nombre.apellido@americanschool.edu.gt`
- 🎯 **Uso**: Identificador de usuario en la plataforma
- ⚠️ **Nota**: NO es una cuenta de email real, solo credencial de acceso

#### Email Personal (Prospecto)
- 📬 **Mantiene** el correo original del prospecto en la base de datos
- 📨 **Uso**: Para notificaciones y comunicaciones reales
- ✉️ **Ejemplo**: `estudiante@gmail.com` (el que registró el prospecto)

### 4. **Nuevo Template de Email con Diseño Corporativo ASM**
**Archivo**: `resources/views/emails/user-credentials.blade.php`

#### Colores Corporativos Aplicados:
- 🔵 **Azul Corporativo**: `#213362` (header, footer, títulos)
- 🟡 **Dorado ASM**: `#B7A053` (acentos, botones, bordes)
- 🤍 **Crema**: `#EBDDB7` (texto en fondos oscuros)

#### Secciones del Email:
1. **Header Corporativo**
   - Fondo azul #213362
   - Título con emoji 🔐
   - Línea dorada de acento

2. **Credenciales Box**
   - 👤 Usuario (username)
   - 📧 Email Sistema (corporativo generado)
   - 🔑 Contraseña temporal

3. **Info Box Azul** 📌
   - Explica que el email corporativo es **SOLO para acceso al sistema**
   - Aclara que NO es una cuenta de email real
   - Muestra el email personal del prospecto donde llegarán notificaciones

4. **Warning Box Dorado** ⚠️
   - Instrucciones de seguridad
   - Cambio obligatorio de contraseña

5. **Pasos a Seguir** 📋
   - 5 pasos claros con instrucciones

6. **Botón de Acceso** 🚀
   - Color dorado #B7A053
   - Link al sistema

7. **Footer Corporativo**
   - Fondo azul con información de contacto
   - Links útiles (sitio web, privacidad, contacto)

### 5. **Actualización del Mailable**
**Archivo**: `app/Mail/UserCredentialsMail.php`

```php
public function __construct(
    string $username, 
    string $password, 
    string $corporateEmail,  // NUEVO: Email generado para el sistema
    string $personalEmail = null  // NUEVO: Email personal del prospecto
)
```

- ✅ Ahora recibe **dos emails**:
  - `$corporateEmail`: Para mostrar en credenciales
  - `$personalEmail`: Para informar dónde llegarán notificaciones

### 6. **Actualización del Job de Creación**
**Archivo**: `app/Jobs/CreateUserAndSendCredentialsJob.php`

- ✅ Actualizado para enviar ambos emails al Mailable
- ✅ Logging mejorado con ambos emails
- 🧪 **Modo prueba activo**: Todos los emails van a `mlpdbz300@gmail.com`

## 📊 Flujo Completo del Sistema

```mermaid
flowchart TD
    A[Prospecto Inscrito] --> B{¿Tiene usuario?}
    B -->|No| C[Generar Email Corporativo]
    B -->|Sí| Z[Skip]
    
    C --> D[nombre.apellido@americanschool.edu.gt]
    D --> E{¿Email existe?}
    E -->|Sí| F[Agregar número: nombre.apellido1@...]
    E -->|No| G[Usar email generado]
    F --> G
    
    G --> H[Crear Usuario en DB]
    H --> I[Usuario.email = Email Corporativo]
    I --> J[Prospecto.correo_electronico = MANTIENE SU VALOR]
    
    J --> K[Generar Contraseña Temporal]
    K --> L[Asignar Rol Estudiante]
    L --> M[Asignar Permisos de Módulos]
    
    M --> N[Enviar Email con Credenciales]
    N --> O[🧪 A mlpdbz300@gmail.com modo prueba]
    
    O --> P[Email Muestra:]
    P --> Q[👤 Username: carnet123]
    P --> R[📧 Email Sistema: juan.perez@americanschool.edu.gt]
    P --> S[📬 Email Personal: juan@gmail.com]
    P --> T[🔑 Contraseña: Abc123!@#]
```

## 🎯 Resultado Final

### Cuando un prospecto se convierte en usuario:

| Campo | Antes | Después |
|-------|-------|---------|
| **Username** | - | `carnet123` o generado |
| **Email (Usuario)** | - | `juan.perez@americanschool.edu.gt` ⭐ NUEVO |
| **Email (Prospecto)** | `juan@gmail.com` | `juan@gmail.com` ✅ SE MANTIENE |
| **Contraseña** | - | Generada aleatoria 12 caracteres |
| **Rol** | - | Estudiante (con permisos) |

### El estudiante recibe un email a su correo personal con:
✉️ **Destinatario**: `mlpdbz300@gmail.com` (modo prueba)

📄 **Contenido del email**:
- 👤 Tu usuario es: `carnet123`
- 📧 **Tu email del sistema es: `juan.perez@americanschool.edu.gt`**
  - ⚠️ Este email es SOLO para acceso a la plataforma
  - 💡 NO es una cuenta de email real
- 📬 Las notificaciones llegarán a: `juan@gmail.com`
- 🔑 Tu contraseña temporal es: `Abc123!@#`
- 🚀 Botón para acceder al sistema

## 🔧 Archivos Modificados

1. ✅ `app/Services/MassiveUserGenerationService.php`
   - Método `generateCorporateEmail()`
   - Método `removeAccents()`
   - Filtrado por carnet en `getProspectosWithoutUser()`
   - Verificación de carnet en `createUserForProspecto()`
   - Respuesta con `corporate_email` y `personal_email`

2. ✅ `app/Mail/UserCredentialsMail.php`
   - Constructor actualizado con 4 parámetros
   - Subject actualizado con emoji 🔐

3. ✅ `app/Jobs/CreateUserAndSendCredentialsJob.php`
   - Método `sendCredentialsEmail()` actualizado
   - Logging con ambos emails

4. ✅ `resources/views/emails/user-credentials.blade.php`
   - **COMPLETAMENTE REDISEÑADO**
   - Colores corporativos ASM
   - Info box explicando email corporativo
   - Warning box con seguridad
   - Diseño profesional y moderno

## 🧪 Modo Prueba Activo

⚠️ **IMPORTANTE**: El sistema está en modo prueba

- Todos los emails se envían a: `mlpdbz300@gmail.com`
- Los emails corporativos se generan normalmente en la DB
- Los logs muestran ambos emails (corporativo y personal)

### Para activar modo producción:

1. **CreateUserAndSendCredentialsJob.php** (línea ~87):
```php
// Cambiar de:
$testEmail = 'mlpdbz300@gmail.com';
Mail::to($testEmail)->send(...)

// A:
Mail::to($userData['personal_email'])->send(...)
```

## 📝 Notas Importantes

1. ✅ El **email del prospecto NO se modifica** en la tabla `prospectos`
2. ✅ El **email corporativo se guarda** en la tabla `users`
3. ✅ Los prospectos con **carnet ya registrado NO aparecen** en lista sin usuario
4. ✅ El diseño del email usa **colores oficiales de ASM**
5. ✅ El email **explica claramente** que el correo corporativo es solo para acceso
6. ✅ Los **permisos de módulos se asignan automáticamente** según rol Estudiante

## 🎨 Paleta de Colores ASM Utilizada

```css
/* Azul Corporativo */
#213362 - Header, Footer, Títulos principales

/* Dorado ASM */
#B7A053 - Botones, Bordes, Acentos, Links

/* Crema Claro */
#EBDDB7 - Texto sobre fondos oscuros

/* Dorado Claro (Gradientes) */
#D4C088 - Acentos degradados
```

---

## ✅ Testing Checklist

- [ ] Verificar que emails corporativos se generan correctamente
- [ ] Confirmar que emails llegan a mlpdbz300@gmail.com
- [ ] Validar diseño del email en diferentes clientes
- [ ] Probar con nombres con acentos (José, María, etc.)
- [ ] Verificar que carnets duplicados no crean usuarios
- [ ] Confirmar que email personal del prospecto se mantiene
- [ ] Validar que permisos de rol Estudiante se asignan
- [ ] Probar login con email corporativo generado

---

**Fecha de Implementación**: 13 de Noviembre, 2025
**Modo**: 🧪 PRUEBA (emails a mlpdbz300@gmail.com)
**Status**: ✅ COMPLETO Y LISTO PARA TESTING
