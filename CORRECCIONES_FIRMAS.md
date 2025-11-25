# Correcciones Aplicadas - Sistema de Firmas

## ✅ Cambios Realizados

### 1. 🔗 URL Corregida para Firma de Estudiante

**Problema**: El link generado apuntaba al backend (puerto 8000) en lugar del frontend (puerto 3000)
- ❌ Antes: `http://localhost:8000/firma-estudiante/token`
- ✅ Ahora: `http://localhost:3000/firma-estudiante/token`

**Archivos modificados**:
- `app/Http/Controllers/Api/FirmaContratoController.php`
- `.env` (agregada variable `FRONTEND_URL`)

**Configuración**:
```env
FRONTEND_URL=http://localhost:3000
```

### 2. 🔓 Eliminada Restricción de Un Contrato Por Día

**Problema**: No se podían enviar múltiples contratos al mismo prospecto el mismo día debido al constraint único

**Solución**:
- ✅ Creada migración para eliminar constraint `ux_contactos_env_prosp_canal_dia`
- ✅ Eliminada validación en el frontend

**Archivos modificados**:
- `database/migrations/2025_11_19_000001_remove_unique_constraint_contactos_enviados.php` (NUEVA)
- `components/firma/student-details.tsx`

### 3. ✅ Formato de Firmas Verificado

Las firmas se guardan correctamente en formato:
```
data:image/png;base64,iVBORw0KGgoAAAANSUhEUg...
```

**Ubicación en BD**:
- Tabla: `contactos_enviados`
- Columna firma asesor: `firma_asesor` (TEXT)
- Columna firma estudiante: `firma_estudiante` (TEXT)

## 🚀 Pasos para Aplicar los Cambios

### Backend

1. **Ejecutar migración para quitar restricción**:
```bash
cd blue_atlas_backend
php artisan migrate
```

2. **Verificar que el constraint se eliminó**:
```bash
php artisan tinker
```
```php
DB::select("SELECT constraint_name FROM information_schema.table_constraints WHERE table_name='contactos_enviados' AND constraint_type='UNIQUE'");
// No debe aparecer 'ux_contactos_env_prosp_canal_dia'
```

3. **Reiniciar servidor backend**:
```bash
php artisan serve
```

### Frontend

1. **Reiniciar servidor**:
```bash
cd blue-atlas-dashboard
npm run dev
```

## 🧪 Pruebas

### Probar URL Correcta

1. Ir a `/firma/[id]` con un prospecto válido
2. Firmar como asesor
3. Verificar en el modal que el link es: `http://localhost:3000/firma-estudiante/...`
4. Copiar y pegar el link en navegador
5. ✅ Debe cargar la página de firma del estudiante

### Probar Múltiples Contratos

1. Enviar un contrato a un prospecto
2. Sin esperar al día siguiente, enviar otro contrato al mismo prospecto
3. ✅ Debe permitirlo sin errores

### Verificar Firmas en BD

Ejecutar el script de verificación:
```bash
psql -U tu_usuario -d tu_base_datos -f database/verificacion_firmas.sql
```

O ejecutar queries individuales desde tu cliente PostgreSQL.

## 📊 Verificación de Firmas

### Query Rápida
```sql
SELECT 
    id,
    prospecto_id,
    estado_firma,
    CASE WHEN firma_asesor LIKE 'data:image/png;base64,%' THEN '✓' ELSE '✗' END as firma_asesor_ok,
    CASE WHEN firma_estudiante LIKE 'data:image/png;base64,%' THEN '✓' ELSE '✗' END as firma_estudiante_ok
FROM contactos_enviados
WHERE tipo_contacto = 'contrato_confidencialidad'
ORDER BY created_at DESC
LIMIT 5;
```

### Ver Firma Como Imagen

Para visualizar una firma específica:

1. Ejecutar:
```sql
SELECT firma_asesor FROM contactos_enviados WHERE id = 123;
```

2. Copiar el resultado (data:image/png;base64,...)

3. Crear un HTML temporal:
```html
<html>
<body>
<img src="data:image/png;base64,iVBORw0KG..." />
</body>
</html>
```

4. Abrir en navegador para ver la firma

## 🎯 Flujo de Prueba Completo

1. **Login como asesor**
2. **Ir a `/firma`**
3. **Seleccionar prospecto y hacer clic para firmar**
4. **Firmar en canvas y enviar**
5. **Copiar link generado** (debe ser localhost:3000)
6. **Abrir link en navegador incógnito** (simular estudiante)
7. **Firmar como estudiante**
8. **Verificar en `/firma/contratos/[id]`** que ambas firmas se ven correctamente
9. **Opcional**: Enviar otro contrato al mismo prospecto para verificar que no hay restricción

## ⚠️ Troubleshooting

### Link apunta a puerto 8000
- Verificar que existe `FRONTEND_URL=http://localhost:3000` en `.env`
- Reiniciar servidor backend: `php artisan serve`

### Error de constraint único
- Ejecutar: `php artisan migrate:rollback --step=1`
- Luego: `php artisan migrate`

### Firmas no se ven
- Verificar que las firmas empiezan con `data:image/png;base64,`
- Verificar en BD que las columnas tienen contenido
- Verificar permisos de lectura en endpoints `/api/contratos/{id}`

## 📝 Notas Importantes

1. **En producción**: Cambiar `FRONTEND_URL` a la URL real del frontend
2. **Migración**: Ya existe la migración para quitar el constraint
3. **Formato**: Las firmas se guardan en PNG/base64 automáticamente desde el canvas
4. **Tamaño**: Cada firma ocupa aproximadamente 20-50 KB

## ✅ Checklist de Verificación

- [ ] Migración ejecutada sin errores
- [ ] Constraint `ux_contactos_env_prosp_canal_dia` eliminado
- [ ] Variable `FRONTEND_URL` agregada al `.env`
- [ ] Links generados apuntan a localhost:3000
- [ ] Se pueden enviar múltiples contratos al mismo prospecto
- [ ] Firmas del asesor se guardan en formato PNG/base64
- [ ] Firmas del estudiante se guardan en formato PNG/base64
- [ ] Vista previa `/firma/contratos/[id]` muestra ambas firmas como imágenes
