# 🧪 Test de Foto de Perfil

## ✅ Cambios Realizados

### Backend
1. **URL completa en respuesta**: Ahora retorna `url($relativePath)` en lugar de solo la ruta relativa
2. **URL completa en mi-perfil**: Convierte la ruta a URL completa al cargar el perfil

### Frontend
1. **Elimina concatenación doble**: Ya no agrega la URL base porque viene completa del backend
2. **Cache busting**: Agrega timestamp `?t={timestamp}` para evitar caché del navegador

## 🔍 Cómo Verificar

### 1. Revisar en Base de Datos
```sql
SELECT id, user_id, foto_perfil 
FROM profile_students 
WHERE foto_perfil IS NOT NULL 
ORDER BY updated_at DESC 
LIMIT 5;
```

### 2. Verificar que el archivo existe
```bash
# Windows PowerShell
Get-ChildItem D:\ASMProlink\blue_atlas_backend\public\storage\perfiles\
```

### 3. Probar la URL directamente
Si el archivo es `profile_123_1234567890.jpg`, prueba en el navegador:
```
http://localhost:8000/storage/perfiles/profile_123_1234567890.jpg
```

### 4. Ver logs del backend
```bash
cd blue_atlas_backend
php artisan tail
# O
Get-Content storage\logs\laravel.log -Tail 50
```

### 5. Ver respuesta de la API

**Al subir foto:**
```json
{
  "success": true,
  "message": "Foto de perfil actualizada correctamente",
  "data": {
    "foto_perfil": "http://localhost:8000/storage/perfiles/profile_1_1731647890.jpg"
  }
}
```

**Al cargar perfil:**
```json
{
  "success": true,
  "data": {
    "perfil_editable": {
      "foto_perfil": "http://localhost:8000/storage/perfiles/profile_1_1731647890.jpg"
    }
  }
}
```

## 🐛 Problemas Comunes

### Problema: La imagen no se muestra
**Solución 1**: Verificar permisos de carpeta
```bash
# Windows
icacls "D:\ASMProlink\blue_atlas_backend\public\storage\perfiles" /grant Everyone:F
```

**Solución 2**: Verificar que el archivo existe
```bash
ls D:\ASMProlink\blue_atlas_backend\public\storage\perfiles\
```

**Solución 3**: Limpiar caché del navegador
- Ctrl + Shift + R (Chrome/Edge)
- Ctrl + F5 (Firefox)

### Problema: Error 404 en la imagen
**Causa**: La URL no es correcta

**Verificar**:
1. Que `APP_URL` en `.env` sea `http://localhost:8000`
2. Que la ruta sea `/storage/perfiles/` no `/public/storage/perfiles/`

### Problema: Error al subir
**Posibles causas**:
1. Tamaño > 2MB
2. Formato no permitido (solo jpg, png, gif)
3. Falta de permisos en carpeta

## 🎯 Proceso de Debugging

1. **Abrir DevTools** (F12)
2. **Ir a Network tab**
3. **Hacer clic en botón de cámara**
4. **Seleccionar imagen**
5. **Ver request a** `/api/estudiante/perfil/foto-perfil`
6. **Ver response**:
   - Status: 200 OK
   - Body: `{ "success": true, "data": { "foto_perfil": "http://..." } }`
7. **Ver en Elements tab**:
   - Buscar el `<img>` del avatar
   - Verificar que el `src` tenga la URL completa
8. **Si el src es correcto pero no carga**:
   - Copiar la URL de la imagen
   - Abrirla en una nueva pestaña
   - Si da 404 → problema en backend
   - Si carga → problema de CORS o caché

## ✅ Checklist Final

- [ ] Backend: Método `subirFotoPerfil()` retorna URL completa
- [ ] Backend: Método `miPerfil()` convierte ruta a URL completa  
- [ ] Archivo existe en `public/storage/perfiles/`
- [ ] Base de datos tiene la ruta correcta
- [ ] Frontend recibe URL completa en response
- [ ] Avatar actualiza `src` después de subir
- [ ] Imagen carga sin error 404
- [ ] Imagen persiste después de recargar página
