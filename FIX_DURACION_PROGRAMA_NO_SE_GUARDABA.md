# FIX: Duración del programa no se guardaba al editar prospecto

## Problema reportado

Al editar un prospecto y cambiar la duración del programa (ej: de BBA 32 meses a 24 meses), el cambio **NO se guardaba** en la base de datos. Esto afectaba:

1. El registro en `estudiante_programa` (`duracion_meses`)
2. El cálculo del plan de pagos (inversión total incorrecta)
3. La fecha de finalización del programa

## Causa raíz

El componente `editar-prospecto-completo.tsx` tiene **dos campos separados** para la duración:

- **`datosAcademicos.duracion`**: Campo visible en la pestaña "Académico" donde el usuario edita
- **`datosFinancieros.cantidadMeses`**: Campo usado en el `handleSubmit` para el PUT a `/estudiante-programa`

### El flujo fallido:

1. Usuario edita "Duración (meses)" → actualiza `datosAcademicos.duracion`
2. Al hacer submit, el código usa:
   ```typescript
   const duracionMeses = parseInt(datosFinancieros.cantidadMeses || datosAcademicos.duracion || "12")
   ```
3. Como `datosFinancieros.cantidadMeses` **nunca se sincronizaba**, siempre usaba el valor antiguo
4. El PUT enviaba la duración original, ignorando la edición del usuario

## Solución aplicada

### 1. Sincronización automática de duración

Agregado `useEffect` que sincroniza `datosAcademicos.duracion` → `datosFinancieros.cantidadMeses`:

```typescript
useEffect(() => {
  if (datosAcademicos.duracion && datosAcademicos.duracion !== datosFinancieros.cantidadMeses) {
    console.log("🔄 Sincronizando duración:", datosAcademicos.duracion, "→ cantidadMeses")
    setDatosFinancieros(prev => ({ ...prev, cantidadMeses: datosAcademicos.duracion }))
  }
}, [datosAcademicos.duracion])
```

### 2. Recálculo automático de inversión total

Agregado `useEffect` que recalcula `inversionTotal` cuando cambian los componentes del costo:

```typescript
useEffect(() => {
  const inscripcion = parseFloat(datosFinancieros.inscripcion || "0")
  const cuotaMensual = parseFloat(datosFinancieros.cuotaMensual || "0")
  const cantidadMeses = parseInt(datosFinancieros.cantidadMeses || "0")
  
  if (cantidadMeses > 0) {
    const total = inscripcion + (cuotaMensual * cantidadMeses)
    const totalStr = total.toFixed(2)
    
    if (datosFinancieros.inversionTotal !== totalStr) {
      console.log("💰 Recalculando inversión total:", totalStr)
      setDatosFinancieros(prev => ({ ...prev, inversionTotal: totalStr }))
    }
  }
}, [datosFinancieros.inscripcion, datosFinancieros.cuotaMensual, datosFinancieros.cantidadMeses])
```

## Resultado esperado

✅ **Ahora funciona:**

1. Usuario cambia duración de 32 → 24 meses en "Datos Académicos"
2. `useEffect` sincroniza `cantidadMeses` automáticamente
3. `useEffect` recalcula `inversionTotal` con la nueva duración
4. Al hacer submit, el PUT a `/estudiante-programa` envía `duracion_meses: 24`
5. El plan de pagos se genera con 24 cuotas (en lugar de 32)

## Archivos modificados

- `blue-atlas-dashboard/components/gestion/editar-prospecto-completo.tsx`:
  - Línea ~846: `useEffect` para sincronizar duración
  - Línea ~855: `useEffect` para recalcular inversión total

## Testing recomendado

1. Editar un prospecto que ya tiene programa asignado (ej: Darlyn Aular)
2. Cambiar la duración del programa (ej: de 32 a 24 meses)
3. Verificar que el campo "Cantidad Meses" se actualice automáticamente
4. Verificar que "Inversión Total" se recalcule
5. Guardar cambios
6. Ir a firma digital y verificar que el contrato muestre la duración correcta
7. Verificar en la BD: `SELECT duracion_meses FROM estudiante_programa WHERE prospecto_id = X`

## Prevención de regresión

- Los `console.log` permiten trackear las sincronizaciones en DevTools
- El campo "Cantidad Meses" es `readOnly` para evitar ediciones manuales que generen inconsistencias
- La duración solo se edita en un lugar: "Datos Académicos" → "Duración (meses)"

---

**Fecha:** 2 de junio de 2026  
**Reportado por:** Joshua  
**Prospecto afectado:** Darlyn Aular (y otros)
