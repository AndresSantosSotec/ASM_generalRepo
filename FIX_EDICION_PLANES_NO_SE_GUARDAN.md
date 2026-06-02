# Fix: Planes no se guardan al editar prospecto

## Problema reportado
- **Usuario**: Joshua/Martin
- **Caso**: Darlyn Aular
- **Síntoma**: Al editar un prospecto desde "Gestión de Prospectos", los cambios en el plan (programa, inscripción, cuota mensual, etc.) NO se guardan. Cuando intentan enviar a firma digital, dice "no hay plan seleccionado".

## Causa raíz encontrada

### Frontend: `editar-prospecto-completo.tsx`
En el método `handleSubmit` (línea ~685-722), el código **SÍ** intentaba actualizar `estudiante_programa` con un PUT, PERO tenía varios problemas:

1. **Usaba el ID incorrecto**: Usaba `estudiantePrograma.id` en lugar de `epIdEnEdicion`
   - `estudiantePrograma` es el primer programa cargado inicialmente
   - Si el usuario edita un programa diferente (doble titulación), el ID era incorrecto
   - Si el usuario edita el mismo programa pero cambia valores, `estudiantePrograma` puede no estar sincronizado

2. **Condición débil**: La condición `if (estudiantePrograma && datosAcademicos.programa)` podía fallar silenciosamente
   - Si `datosAcademicos.programa` está vacío/undefined, el bloque completo NO se ejecuta
   - No había logging ni alertas al usuario de por qué no se guardó

3. **Fecha incorrecta**: Usaba `datosAcademicos.fechaInicio` pero el código de carga setea `fechaInicioEspecifica`

## Solución aplicada

### Cambios en `editar-prospecto-completo.tsx`

```typescript
// ANTES (línea 705):
const resFinanciero = await fetch(`${API_URL}/estudiante-programa/${estudiantePrograma.id}`, {

// AHORA:
const programaIdParaActualizar = epIdEnEdicion ?? estudiantePrograma?.id
const resFinanciero = await fetch(`${API_URL}/estudiante-programa/${programaIdParaActualizar}`, {
```

**Mejoras implementadas:**
1. ✅ Usa `epIdEnEdicion` primero (el programa que el usuario está editando ACTUALMENTE)
2. ✅ Fallback a `estudiantePrograma?.id` si `epIdEnEdicion` es null
3. ✅ Agrega logging detallado en consola para debugging:
   ```typescript
   console.log("📝 Actualizando estudiante_programa:", { id, payload })
   ```
4. ✅ Muestra errores específicos al usuario en lugar de fallar silenciosamente:
   - Si falla el PUT: muestra el mensaje de error del backend
   - Si no hay programa asignado: alerta al usuario
5. ✅ Usa la fecha correcta: `fechaInicioEspecifica` → `fechaInicio` → fallback a fecha actual
6. ✅ Logging de advertencia cuando no se puede actualizar con detalles completos

## Cómo probar el fix

### Caso 1: Editar plan de prospecto con un solo programa
1. Ir a **Gestión de Prospectos**
2. Buscar "Darlyn Aular" (u otro prospecto)
3. Click en **"Editar"**
4. Cambiar valores en la pestaña **"Académico"**:
   - Cambiar inscripción
   - Cambiar cuota mensual
5. Click en **"Guardar Cambios"**
6. **Verificar en consola del navegador** (F12):
   - Debe aparecer: `📝 Actualizando estudiante_programa: { id: X, payload: {...} }`
   - Debe aparecer: `✅ Datos financieros actualizados correctamente para estudiante_programa: X`
7. Recargar la página y editar de nuevo → los cambios deben persistir
8. Ir a **Firma → Ver Detalles** del prospecto
   - El plan debe mostrar los valores actualizados

### Caso 2: Editar plan en doble titulación
1. Buscar prospecto con **2+ programas** asignados
2. Click en **"Editar"**
3. En la sección de programas inscritos, hacer click en el ícono **✏️ Editar** del segundo programa
4. Cambiar valores (inscripción, cuota)
5. **Guardar**
6. Verificar en consola que actualiza el programa correcto (id del segundo programa, NO del primero)

### Caso 3: Prospecto sin programa asignado
1. Buscar prospecto que NO tiene programas en `estudiante_programa`
2. Editar y cambiar datos básicos (nombre, teléfono, etc.)
3. Guardar
4. **Debe mostrar alerta**: "Sin programa asignado - Los datos del prospecto se guardaron, pero no se pudo actualizar el plan..."

## Archivos modificados

### Frontend
- ✅ `blue-atlas-dashboard/components/gestion/editar-prospecto-completo.tsx`
  - Método `handleSubmit`: líneas ~685-750
  - Usa `epIdEnEdicion` en lugar de `estudiantePrograma.id`
  - Agrega logging y manejo de errores mejorado

### Backend (NO requiere cambios)
- ✅ `EstudianteProgramaController::update()` ya funciona correctamente
- ✅ Backend ya valida y actualiza los datos
- El problema estaba 100% en el frontend

## Monitoreo post-deploy

### Logs a revisar en producción
Abrir consola del navegador al editar prospectos y buscar:
- ✅ `📝 Actualizando estudiante_programa:`
- ✅ `✅ Datos financieros actualizados correctamente`
- ⚠️ `⚠️ No se puede actualizar estudiante_programa` (si aparece, indica que falta asignar programa)
- ❌ `❌ Error actualizando datos financieros` (si aparece, ver payload y error del backend)

### Validación final
1. Martin edita el prospecto de Darlyn Aular
2. Cambia inscripción/cuota
3. Guarda cambios
4. Va a **Firma → Ver Detalles → ID de Darlyn**
5. ✅ El contrato debe generarse correctamente con los valores actualizados
6. ✅ NO debe decir "no hay plan seleccionado"

## Notas adicionales

- Este fix también resuelve el problema de edición en doble/triple titulación
- El componente ahora es más robusto y muestra errores claros al usuario
- Los logs en consola ayudarán a diagnosticar futuros problemas

---

**Fecha**: 2 de junio de 2026  
**Autor**: GitHub Copilot  
**Revisado por**: Pendiente
