# 🎨 Módulo de Personalización del Sistema - Gaia Business School

## Descripción General

El módulo de personalización permite a los administradores del sistema personalizar completamente la apariencia de la aplicación Gaia Business School, incluyendo:

- 🎯 **Colores Primarios, Secundarios y de Acento** - Totalmente adaptables
- 🖼️ **Imagen del Sidebar** - Cambiar el fondo del menú lateral
- 🔗 **Favicon** - Personalizar el ícono de la pestaña
- 📱 **Logo** - Actualizar el logo de la organización
- 🌙 **Modo Oscuro** - Habilitar/deshabilitar automáticamente
- 📝 **Información General** - Nombre de organización y descripción

## Estructura del Proyecto

### Backend (Laravel)

#### 1. Migración de Base de Datos
**Archivo**: `database/migrations/2026_02_16_create_system_customizations_table.php`

Crea tabla `system_customizations` con los siguientes campos:
- `id` - ID único
- `organization_name` - Nombre de la organización
- `primary_color` - Color primario (hexadecimal)
- `secondary_color` - Color secundario (hexadecimal)
- `accent_color` - Color de acento (hexadecimal)
- `logo_url` - URL del logo
- `sidebar_image_url` - URL de imagen del sidebar
- `favicon_url` - URL del favicon
- `dark_mode_enabled` - Booleano para modo oscuro
- `custom_css` - JSON para CSS personalizado
- `description` - Descripción del sistema

#### 2. Modelo
**Archivo**: `app/Models/SystemCustomization.php`

```php
use App\Models\SystemCustomization;

// Obtener configuración actual
$config = SystemCustomization::getCurrent();

// Actualizar
$config->update([
    'primary_color' => '#FF0000',
    'organization_name' => 'Mi Empresa'
]);
```

#### 3. Controlador
**Archivo**: `app/Http/Controllers/SystemCustomizationController.php`

Proporciona los siguientes métodos:
- `show()` - Obtener configuración actual (público)
- `update()` - Actualizar colores y configuración general (autenticado)
- `uploadSidebarImage()` - Cargar imagen del sidebar (autenticado)
- `uploadFavicon()` - Cargar favicon (autenticado)
- `uploadLogo()` - Cargar logo (autenticado)
- `reset()` - Resetear a valores por defecto (autenticado)

#### 4. Rutas API
**Archivo**: `routes/api.php`

```php
// Rutas públicas
GET  /api/customization/current

// Rutas protegidas (require auth:sanctum)
POST /api/customization/update
POST /api/customization/sidebar-image
POST /api/customization/favicon
POST /api/customization/logo
POST /api/customization/reset
```

### Frontend (Next.js/React)

#### 1. Context de Personalización
**Archivo**: `contexts/CustomizationContext.tsx`

Proporciona estado global y funciones:

```tsx
import { useCustomization } from "@/contexts/CustomizationContext";

function MyComponent() {
  const {
    customization,      // Datos actuales
    loading,            // Estado de carga
    error,              // Errores
    updateCustomization,
    uploadSidebarImage,
    uploadFavicon,
    uploadLogo,
    resetCustomization,
    refreshCustomization
  } = useCustomization();
}
```

#### 2. Hooks Personalizados
**Archivo**: `hooks/useCustomization.ts`

```tsx
import { useSystemColors, useCustomizationStyles } from "@/hooks/useCustomization";

// Obtener colores
const { primary, secondary, accent, sidebarImage } = useSystemColors();

// Obtener estilos inline
const { primaryBg, primaryText, sidebarBg } = useCustomizationStyles();
```

#### 3. Componente de Configuración
**Archivo**: `components/customization/CustomizationSettings.tsx`

Componente completo con UI para:
- Edición de colores con picker visual
- Vista previa de colores
- Carga de imágenes (logo, favicon, sidebar)
- Información general
- Botón de reset

#### 4. Página de Personalización
**Archivo**: `app/configuracion/personalizacion/page.tsx`

Página accesible solo para administradores que muestra la interfaz completa de personalización.

#### 5. Actualización del Layout Principal
**Archivo**: `app/layout.tsx`

Se agregó `<CustomizationProvider>` envolviendo toda la aplicación para que la personalización esté disponible globalmente.

#### 6. Actualización del Sidebar
**Archivo**: `components/layout/sidebar.tsx`

Ahora usa:
- `useSystemColors()` para obtener imagen personalizada
- `backgroundImage` dinámico si existe imagen del sidebar
- Colores dinámicos para el gradiente por defecto

## Flujo de Uso

### 1. Acceder a la Página de Personalización

```
http://localhost:3000/configuracion/personalizacion
```

*Solo disponible para usuarios con rol Admin*

### 2. Personalizar Colores

1. Ve a la pestaña "Colores"
2. Usa los selectores de color para elegir:
   - Color Primario
   - Color Secundario
   - Color de Acento
3. Opcionalmente, activa el "Modo Oscuro"
4. Haz clic en "Guardar Colores"

### 3. Cambiar Imágenes

1. Ve a la pestaña "Imágenes"
2. Carga:
   - **Logo** (máx. 2MB) - Se muestra en el navbar
   - **Favicon** (máx. 1MB) - Se muestra en la pestaña del navegador
   - **Imagen del Sidebar** (máx. 5MB) - Fondo del menú lateral
3. Las imágenes se guardan automáticamente

### 4. Configuración General

1. Ve a la pestaña "General"
2. Actualiza:
   - Nombre de la Organización
   - Descripción
3. Haz clic en "Guardar Cambios"

### 5. Vista Previa

1. Ve a la pestaña "Vista Previa"
2. Visualiza cómo se verán los cambios en tiempo real

### 6. Resetear Configuración

Haz clic en el botón "Resetear" para volver a los valores por defecto.

## Ejemplo de Uso en Componentes

### Usar Colores en un Componente

```tsx
import { useSystemColors } from "@/hooks/useCustomization";

export function MyButton() {
  const { primary, secondary } = useSystemColors();
  
  return (
    <button style={{ backgroundColor: primary }}>
      Haz clic aquí
    </button>
  );
}
```

### Usar el Context Completo

```tsx
import { useCustomization } from "@/contexts/CustomizationContext";

export function OrganizationHeader() {
  const { customization } = useCustomization();
  
  return (
    <div>
      <h1>{customization?.organization_name}</h1>
      <p>{customization?.description}</p>
      {customization?.logo_url && (
        <img src={customization.logo_url} alt="Logo" />
      )}
    </div>
  );
}
```

### Usar Estilos Inline

```tsx
import { useCustomizationStyles } from "@/hooks/useCustomization";

export function StyledCard() {
  const { primaryBg, sidebarBg } = useCustomizationStyles();
  
  return (
    <div style={primaryBg} className="p-4 rounded">
      Contenido con color primario
    </div>
  );
}
```

## Variables CSS Disponibles

El sistema automáticamente setea estas variables CSS en el `<html>` root:

```css
--primary-color    /* Color primario */
--secondary-color  /* Color secundario */
--accent-color     /* Color de acento */
```

Úsalas en tu CSS personalizado:

```css
.my-element {
  color: var(--primary-color);
  background: var(--secondary-color);
  border: 2px solid var(--accent-color);
}
```

## Formatos Aceptados

### Colores
- Formato hexadecimal: `#FF0000`, `#f00`
- Validación: Solo se aceptan colores hexadecimales válidos

### Imágenes
- **Logo**: JPEG, PNG, GIF, WebP (máx. 2MB)
- **Favicon**: JPEG, PNG, ICO, GIF, WebP (máx. 1MB)
- **Sidebar**: JPEG, PNG, GIF, WebP (máx. 5MB)

### Nombre de Organización
- Máximo: 255 caracteres

## Seguridad

- ✅ Las rutas de actualización requieren autenticación (`auth:sanctum`)
- ✅ Las rutas públicas solo permiten lectura
- ✅ Validación de tipos de archivo en backend
- ✅ Validación de formato de colores hexadecimales
- ✅ Las imágenes se almacenan en carpetas públicas con nombres únicos

## Persistencia de Datos

1. **Base de Datos**: Los datos se guardan en `system_customizations`
2. **localStorage**: El frontend cachea los datos para acceso rápido
3. **CSS Variables**: Se aplican automáticamente al cargar la página
4. **Favicon**: Se actualiza dinámicamente en el DOM

## Migración e Instalación

Para instalar en un proyecto existente:

```bash
# 1. Backend - ejecutar migración
php artisan migrate

# 2. Frontend - agregar CustomizationProvider al layout
# (Ver app/layout.tsx)

# 3. Backend - crear registro inicial (opcional)
php artisan tinker
App\Models\SystemCustomization::create([...])
```

## Troubleshooting

### Los colores no se actualizan
1. Limpia la caché del navegador
2. Hard refresh: `Ctrl+Shift+R` (Windows) o `Cmd+Shift+R` (Mac)
3. Verifica que el localStorage no esté bloqueado

### Las imágenes no carga
1. Verifica que el storage está configurado correctamente
2. Asegúrate de que el path `storage/app/public` es accesible
3. Ejecuta: `php artisan storage:link`

### Favicon no cambia
1. El navegador cachea favicons agresivamente
2. Hard refresh de la página
3. O abre en una ventana privada/incógnito

## Próximas Mejoras

- [ ] Temas predefinidos (claro, oscuro, personalizado)
- [ ] Exportar/Importar configuraciones
- [ ] Historial de cambios
- [ ] Preview en vivo mientras editas
- [ ] Soporte para múltiples temas por usuario
- [ ] Integración con PWA para actualizar colores en mobile

## Rutas de Acceso

### Archivo de Configuración
```
d:\ASMProlink\blue-atlas-dashboard\app\configuracion\personalizacion\page.tsx
```

### Contexto
```
d:\ASMProlink\blue-atlas-dashboard\contexts\CustomizationContext.tsx
```

### Componente
```
d:\ASMProlink\blue-atlas-dashboard\components\customization\CustomizationSettings.tsx
```

### Hooks
```
d:\ASMProlink\blue-atlas-dashboard\hooks\useCustomization.ts
```

## Ramas

- **Backend**: `gaia_business_school_back`
- **Frontend**: `gaia_business_school_front`

---

**Última actualización**: 16 de Febrero de 2026
**Versión**: 1.0.0
