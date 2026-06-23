# Documentación de mejoras — Ficha de Inscripción y Contrato

**Proyecto:** ASMProlink  
**Módulos:** Ficha de inscripción · Editar prospecto · Contrato / PDF · Firma de contrato  
**Fecha:** Junio 2026  
**Versión del documento:** 1.0  

---

## Portada (opcional en Word)

**Título sugerido:**  
Mejoras en Ficha de Inscripción, Datos Laborales e Información Institucional

**Subtítulo sugerido:**  
ASMProlink — American School of Management

<br><br><br>

**[INSERTAR LOGO INSTITUCIONAL AQUÍ]**

<br><br><br><br><br>

---

## Índice sugerido

1. Resumen ejecutivo  
2. Campo: Ingresos aproximados  
3. Sección: Información institucional y notas importantes  
4. Archivos modificados  
5. Base de datos y despliegue  
6. Guía de pruebas  
7. Anexos — Capturas de pantalla  

---

## 1. Resumen ejecutivo

Se implementaron mejoras en la **ficha de inscripción** y en los **documentos PDF del contrato**, con el objetivo de:

- Registrar los **ingresos aproximados** del prospecto en la sección **DATOS LABORALES**.
- Incorporar una sección fija de **Información institucional y notas importantes** con el texto oficial de ASM (títulos, HAYA, colegiado, mora, doble titulación, envío por correo, etc.).
- Mantener la misma información visible en el **formulario web**, en la **edición de prospecto**, en los **PDF** y en la **vista de firma del estudiante**.

<br>

**[INSERTAR CAPTURA AQUÍ — Figura 0: Vista general del módulo de inscripción]**

<br><br>

---

## 2. Campo: Ingresos aproximados

### 2.1 Objetivo

Permitir capturar y consultar los **ingresos aproximados** del prospecto dentro de la sección **DATOS LABORALES**, tanto en la ficha de inscripción como en el resto de pantallas y PDFs donde se muestran los datos laborales.

### 2.2 Detalle funcional

| Elemento | Descripción |
|----------|-------------|
| **Nombre del campo** | Ingresos aproximados |
| **Ubicación** | Sección DATOS LABORALES |
| **Tipo** | Texto libre (ejemplo: *Q 8,500 mensuales*) |
| **Obligatorio** | No |
| **Columna en BD** | `prospectos.ingresos_aproximados` |
| **Longitud máxima** | 100 caracteres |

### 2.3 Dónde se muestra y guarda

- Ficha de inscripción → pestaña **Datos Laborales**
- Editar prospecto → pestaña/sección laboral
- PDF de ficha de inscripción
- PDF del contrato (ficha incluida)
- Pantalla de firma del estudiante (`/firmar-contrato/[token]`)
- Modales de revisión de ficha (detalle, aprobación académica, aprobación financiera)

<br>

**[INSERTAR CAPTURA AQUÍ — Figura 1: Campo “Ingresos aproximados” en ficha de inscripción]**

<br><br>

**[INSERTAR CAPTURA AQUÍ — Figura 2: Campo “Ingresos aproximados” en editar prospecto]**

<br><br>

**[INSERTAR CAPTURA AQUÍ — Figura 3: Campo visible en PDF de ficha / contrato]**

<br><br>

### 2.4 Migración de base de datos

**Archivo:**  
`blue_atlas_backend/database/migrations/2026_06_09_000001_add_ingresos_aproximados_to_prospectos_table.php`

**Comando en servidor:**

```bash
php artisan migrate
```

<br>

---

## 3. Sección: Información institucional y notas importantes

### 3.1 Objetivo

Agregar en la ficha de inscripción y en la ficha embebida del contrato una sección fija con la información institucional oficial de ASM.

### 3.2 Texto incorporado

La sección incluye, entre otros puntos:

1. Compromiso con la formación de líderes y estrategas.  
2. Validez nacional e internacional de los títulos ASM.  
3. Apostille de la **HAYA**.  
4. Emisión del título al completar cursos y pagos.  
5. Aceptación del título en otras universidades según sus regulaciones.  
6. **No ofrecemos Colegiado.**  
7. Nota de mora: pago del **01 al 05** de cada mes; a partir del **6**, cargo de **Q.50.00**.  
8. Indicación de envío del archivo por correo al departamento comercial y académico.  
9. Programa de **doble titulación**: debe cancelar doble título.

### 3.3 Dónde aparece

| Ubicación | Estado |
|-----------|--------|
| Formulario web — ficha de inscripción (al final del formulario) | Implementado |
| PDF — partial de ficha (`ficha_inscripcion`) | Implementado |
| PDF — contrato con ficha incluida | Implementado |
| PDF — contrato de confidencialidad completo | Implementado |
| PDF — ficha standalone | Implementado |
| Pantalla de firma del estudiante | Implementado |

<br>

**[INSERTAR CAPTURA AQUÍ — Figura 4: Sección institucional al final de la ficha web]**

<br><br>

**[INSERTAR CAPTURA AQUÍ — Figura 5: Sección institucional en PDF del contrato]**

<br><br>

**[INSERTAR CAPTURA AQUÍ — Figura 6: Sección institucional en pantalla de firma del estudiante]**

<br><br>

### 3.4 Archivos principales de esta sección

**Backend (Blade):**

- `blue_atlas_backend/resources/views/pdf/partials/ficha_notas_institucionales.blade.php`
- `blue_atlas_backend/resources/views/pdf/partials/ficha_inscripcion.blade.php`
- `blue_atlas_backend/resources/views/pdf/contrato_confidencialidad_completo.blade.php`
- `blue_atlas_backend/resources/views/pdf/ficha-inscripcion.blade.php`

**Frontend (React):**

- `blue-atlas-dashboard/utils/fichaNotasInstitucionales.ts`
- `blue-atlas-dashboard/components/inscripcion/FichaNotasInstitucionales.tsx`
- `blue-atlas-dashboard/components/inscripcion/registration-form.tsx`
- `blue-atlas-dashboard/app/firmar-contrato/[token]/page.tsx`

<br>

---

## 4. Archivos modificados (resumen técnico)

### 4.1 Backend

| Archivo | Cambio |
|---------|--------|
| `app/Models/Prospecto.php` | Campo `ingresos_aproximados` en fillable |
| `app/Http/Controllers/InscripcionController.php` | Guardado y lectura de ingresos |
| `app/Http/Controllers/Api/ProspectoController.php` | CRUD, PDF y `datosLaborales` |
| `app/Http/Controllers/Api/FirmaContratoController.php` | Datos para firma y PDF |
| `app/Http/Controllers/Api/ContactoEnviadoController.php` | Datos laborales en envíos |
| `resources/views/pdf/partials/ficha_inscripcion.blade.php` | Ingresos + notas institucionales |
| `resources/views/pdf/partials/ficha_notas_institucionales.blade.php` | **Nuevo** — texto institucional |
| `resources/views/pdf/ficha-inscripcion.blade.php` | Ingresos + notas |
| `resources/views/pdf/contrato_confidencialidad_completo.blade.php` | Notas institucionales |
| `resources/views/pdf/reporte-consolidado-prospecto.blade.php` | Ingresos aproximados |

### 4.2 Frontend

| Archivo | Cambio |
|---------|--------|
| `components/inscripcion/types.ts` | Tipo `ingresosAproximados` |
| `components/inscripcion/tabs/LaboralTab.tsx` | Input de ingresos |
| `components/inscripcion/registration-form.tsx` | Guardado + notas institucionales |
| `components/inscripcion/tabs/ProspectSearchModal.tsx` | Mapeo al cargar prospecto |
| `components/gestion/editar-prospecto-completo.tsx` | Edición del campo |
| `components/inscripcion/FichaNotasInstitucionales.tsx` | **Nuevo** — componente visual |
| `utils/fichaNotasInstitucionales.ts` | **Nuevo** — texto centralizado |
| `services/fichas.ts` | Mapeo backend |
| `app/firmar-contrato/[token]/page.tsx` | Vista de firma |
| Modales de ficha/aprobación | Visualización del campo |

<br>

**[INSERTAR CAPTURA AQUÍ — Figura 7: Flujo completo ficha → guardar → PDF]**

<br><br>

---

## 5. Base de datos y despliegue

### 5.1 Migraciones pendientes en producción

Ejecutar en el servidor backend:

```bash
php artisan migrate
```

Migraciones relacionadas:

1. `2026_06_08_000001_add_ficha_inscripcion_fields_to_prospectos_table.php`  
   - `sector_empresa`  
   - `es_reinscripcion`  

2. `2026_06_09_000001_add_ingresos_aproximados_to_prospectos_table.php`  
   - `ingresos_aproximados`  

### 5.2 Despliegue recomendado

1. Respaldar base de datos.  
2. Desplegar backend.  
3. Ejecutar migraciones.  
4. Desplegar frontend.  
5. Validar ficha, edición, PDF y firma.

<br>

**[INSERTAR CAPTURA AQUÍ — Figura 8: Resultado de migración en servidor (opcional)]**

<br><br>

---

## 6. Guía de pruebas

### 6.1 Ingresos aproximados

| Paso | Acción | Resultado esperado |
|------|--------|-------------------|
| 1 | Abrir ficha de inscripción | Existe campo en Datos Laborales |
| 2 | Ingresar valor (ej. Q 8,500 mensuales) | Campo acepta texto |
| 3 | Finalizar inscripción | Valor guardado en prospecto |
| 4 | Abrir editar prospecto | Valor visible y editable |
| 5 | Generar PDF de ficha/contrato | Valor aparece en DATOS LABORALES |
| 6 | Abrir firma del estudiante | Valor visible en ficha |

<br>

**[INSERTAR CAPTURA AQUÍ — Figura 9: Prueba de guardado y consulta]**

<br><br>

### 6.2 Información institucional

| Paso | Acción | Resultado esperado |
|------|--------|-------------------|
| 1 | Abrir ficha de inscripción | Sección visible al final |
| 2 | Generar/enviar contrato con ficha | Texto completo en PDF |
| 3 | Abrir enlace de firma del estudiante | Misma sección visible |
| 4 | Revisar PDF standalone de ficha | Sección incluida |

<br>

**[INSERTAR CAPTURA AQUÍ — Figura 10: Comparación web vs PDF]**

<br><br>

---

## 7. Anexos — Espacios para capturas

Use esta sección si prefiere agrupar todas las imágenes al final del documento Word.

<br><br>

### Anexo A — Ficha de inscripción (web)

**[INSERTAR IMAGEN AQUÍ]**

<br><br><br><br>

---

### Anexo B — Datos laborales con ingresos

**[INSERTAR IMAGEN AQUÍ]**

<br><br><br><br>

---

### Anexo C — Editar prospecto

**[INSERTAR IMAGEN AQUÍ]**

<br><br><br><br>

---

### Anexo D — Información institucional (formulario)

**[INSERTAR IMAGEN AQUÍ]**

<br><br><br><br>

---

### Anexo E — PDF ficha de inscripción

**[INSERTAR IMAGEN AQUÍ]**

<br><br><br><br>

---

### Anexo F — PDF contrato con ficha

**[INSERTAR IMAGEN AQUÍ]**

<br><br><br><br>

---

### Anexo G — Pantalla firma del estudiante

**[INSERTAR IMAGEN AQUÍ]**

<br><br><br><br>

---

### Anexo H — Reporte consolidado (opcional)

**[INSERTAR IMAGEN AQUÍ]**

<br><br><br><br>

---

## Notas para pegar en Word

1. Abra este archivo `.md` en Word o copie todo el contenido y péguelo en un documento nuevo.  
2. Reemplace cada texto **`[INSERTAR ... AQUÍ]`** con la captura correspondiente.  
3. Ajuste márgenes, numeración de figuras y portada según plantilla institucional.  
4. Si Word no respeta los saltos `<br>`, deje líneas en blanco manualmente donde indica el documento.  
5. Las tablas se pueden convertir a formato de tabla nativo de Word desde **Insertar → Tabla → Convertir texto en tabla**.

---

**Elaborado por:** ___________________________  
**Revisado por:** ___________________________  
**Fecha de revisión:** _______________________
