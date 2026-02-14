# 💰 Módulo de Precios de Servicios Electrónicos

## 📋 Resumen

Se ha creado un **módulo completo y dinámico** para gestionar los precios de servicios electrónicos desde la base de datos, eliminando los valores hardcodeados y permitiendo actualizaciones en tiempo real desde la interfaz administrativa.

---

## 🎯 Problema Resuelto

**Antes**: Los precios de servicios electrónicos estaban hardcodeados en **3 controladores diferentes** (PlanPagosController, InscripcionController, AlertaAlumnoNuevoController) y en el frontend (FinancieroTab.tsx), haciendo difícil su actualización y mantenimiento.

**Ahora**: Los precios se almacenan en la base de datos y se pueden gestionar dinámicamente desde la interfaz de administración.

---

## 🗄️ Estructura de Base de Datos

### Tabla: `precios_servicios_electronicos`

```sql
CREATE TABLE precios_servicios_electronicos (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    cantidad_cursos INT UNIQUE COMMENT 'Cantidad de cursos (8, 9, 12, 18, 21, 24, 32)',
    precio_transferencia DECIMAL(10,2) COMMENT 'Precio con transferencia/depósito',
    precio_otro_metodo DECIMAL(10,2) COMMENT 'Precio con otro método de pago (+10%)',
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

### Datos Iniciales

| Cantidad Cursos | Precio Transferencia | Precio Otro Método |
|----------------|---------------------|-------------------|
| 8              | Q560.00             | Q616.00           |
| 9              | Q630.00             | Q693.00           |
| 12             | Q840.00             | Q924.00           |
| 18             | Q1,260.00           | Q1,386.00         |
| 21             | Q1,470.00           | Q1,617.00         |
| 24             | Q1,680.00           | Q1,848.00         |
| 32             | Q2,240.00           | Q2,464.00         |

---

## 🏗️ Archivos Creados

### Backend

#### 1. **Migración**
- `database/migrations/2026_02_07_000000_create_precios_servicios_electronicos_table.php`
- Crea la tabla y pobla con datos iniciales

#### 2. **Modelo**
- `app/Models/PrecioServicioElectronico.php`
- Métodos:
  - `obtenerPorDuracion($duracionMeses)`: Obtiene el precio según duración
  - `obtenerTodosParaFrontend()`: Formatea precios para el frontend

#### 3. **Controlador**
- `app/Http/Controllers/Api/PrecioServicioElectronicoController.php`
- Endpoints:
  - `GET /api/precios-servicios-electronicos` - Listar todos
  - `GET /api/precios-servicios-electronicos/frontend` - Para ficha de inscripción
  - `GET /api/precios-servicios-electronicos/{id}` - Ver uno
  - `POST /api/precios-servicios-electronicos` - Crear
  - `PUT /api/precios-servicios-electronicos/{id}` - Actualizar
  - `DELETE /api/precios-servicios-electronicos/{id}` - Desactivar
  - `POST /api/precios-servicios-electronicos/{id}/activar` - Activar

### Frontend

#### 4. **Interfaz de Administración**
- `app/admin/precios-servicios-electronicos/page.tsx`
- Características:
  - ✅ CRUD completo
  - ✅ Cálculo automático del precio con 10% adicional
  - ✅ Activar/Desactivar precios
  - ✅ Edición inline
  - ✅ Validaciones

---

## 🔧 Archivos Modificados

### Backend

1. **routes/api.php**
   - Agregadas rutas para el módulo de precios

2. **database/seeders/ModulesSeeder.php**
   - Actualizado `view_count` del módulo Administración (de 6 a 7)

3. **database/seeders/ModuleViewsSeeder.php**
   - Agregada vista ID 86: "Precios Servicios / Servicios Electrónicos"
   - Ruta: `/admin/precios-servicios-electronicos`
   - Icono: `DollarSign`

4. **Controladores actualizados para leer de BD:**
   - `app/Http/Controllers/Api/PlanPagosController.php`
   - `app/Http/Controllers/InscripcionController.php`
   - `app/Http/Controllers/Api/AlertaAlumnoNuevoController.php`

### Frontend

5. **components/inscripcion/tabs/FinancieroTab.tsx**
   - Ahora carga precios dinámicamente desde la API
   - Fallback a valores por defecto en caso de error

---

## 📡 Endpoints API

### Listado Completo
```http
GET /api/precios-servicios-electronicos
Authorization: Bearer {token}
```

**Respuesta:**
```json
[
  {
    "id": 1,
    "cantidad_cursos": 8,
    "precio_transferencia": "560.00",
    "precio_otro_metodo": "616.00",
    "activo": true,
    "created_at": "2026-02-07T...",
    "updated_at": "2026-02-07T..."
  }
]
```

### Para Frontend (Ficha de Inscripción)
```http
GET /api/precios-servicios-electronicos/frontend
Authorization: Bearer {token}
```

**Respuesta:**
```json
[
  {
    "curso": "8",
    "transfer": "Q560.00",
    "otro": "Q616.00"
  },
  {
    "curso": "9",
    "transfer": "Q630.00",
    "otro": "Q693.00"
  }
]
```

### Crear Precio
```http
POST /api/precios-servicios-electronicos
Authorization: Bearer {token}
Content-Type: application/json

{
  "cantidad_cursos": 10,
  "precio_transferencia": 700.00,
  "precio_otro_metodo": 770.00
}
```

### Actualizar Precio
```http
PUT /api/precios-servicios-electronicos/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "precio_transferencia": 750.00
}
```

### Desactivar Precio
```http
DELETE /api/precios-servicios-electronicos/{id}
Authorization: Bearer {token}
```

### Activar Precio
```http
POST /api/precios-servicios-electronicos/{id}/activar
Authorization: Bearer {token}
```

---

## 🚀 Despliegue

### 1. Ejecutar Migración
```bash
cd blue_atlas_backend
php artisan migrate
```

### 2. Ejecutar Seeders (Opcional)
```bash
php artisan db:seed --class=ModulesSeeder
php artisan db:seed --class=ModuleViewsSeeder
```

### 3. Verificar Permisos
- Acceder a `/seguridad/permisos`
- Asignar permiso del módulo ID 86 a los roles correspondientes (Admin, Super Admin)

### 4. Acceder al Módulo
- URL: `http://localhost:3000/admin/precios-servicios-electronicos`
- Menú: **Administración → Precios Servicios → Servicios Electrónicos**

---

## ✅ Beneficios

1. **Centralización**: Un solo lugar para gestionar precios
2. **Flexibilidad**: Cambios en tiempo real sin modificar código
3. **Auditoría**: Timestamps de creación y actualización
4. **Escalabilidad**: Fácil agregar nuevas cantidades de cursos
5. **Mantenibilidad**: Eliminación de código duplicado
6. **UI Amigable**: Interfaz intuitiva para administradores

---

## 🔐 Permisos

**Módulo:** Administración (ID: 8)  
**Vista:** Servicios Electrónicos (ID: 86)  
**Roles con acceso:** Super Admin, Admin (configurar según necesidad)

---

## 📝 Notas Importantes

1. **Cálculo Automático**: El precio con "otro método" se calcula automáticamente como +10% del precio de transferencia
2. **Soft Delete**: No se eliminan físicamente los precios, solo se marcan como inactivos
3. **Caché**: El frontend implementa fallback en caso de error al cargar precios
4. **Validación**: La cantidad de cursos debe ser única en la BD

---

## 🔄 Flujo de Uso

1. Admin accede a `/admin/precios-servicios-electronicos`
2. Crea/edita precios según necesidad
3. Los cambios se reflejan inmediatamente en:
   - Ficha de inscripción (FinancieroTab)
   - Generación de planes de pago
   - Boletas de inscripción
   - Alertas de alumno nuevo

---

## 🎨 Interfaz de Usuario

- **Tabla responsiva** con todos los precios
- **Botón crear** para agregar nuevos precios
- **Edición inline** para modificar existentes
- **Toggle activo/inactivo** para desactivar temporalmente
- **Iconos intuitivos** (DollarSign, CheckCircle, XCircle)
- **Validación en tiempo real**

---

## 📊 Impacto

**Archivos Backend:** 3 creados + 6 modificados  
**Archivos Frontend:** 1 creado + 1 modificado  
**Endpoints nuevos:** 7  
**Migración:** 1  
**Seeders actualizados:** 2  

---

**Fecha de implementación:** 7 de febrero de 2026  
**Desarrollado por:** GitHub Copilot + Asistente
