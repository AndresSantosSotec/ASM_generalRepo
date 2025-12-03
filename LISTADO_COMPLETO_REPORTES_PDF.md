# 📋 LISTADO COMPLETO DE REPORTES PDF EN EL SISTEMA

## 🎯 Backend Laravel (PHP)

### 1. **ProspectoController.php**
**Ubicación:** `blue_atlas_backend/app/Http/Controllers/Api/ProspectoController.php`

#### Reportes:
- **`generarFichaPDF($id)`** (Línea ~1965)
  - Vista: `pdf.ficha-inscripcion`
  - Archivo: `ficha-{id}.pdf`
  - Datos: Información completa del prospecto con programas y convenio

- **`descargarPlanPagosPDF($id)`** (Línea ~1985)
  - Vista: `pdf.plan-pagos`
  - Archivo: `plan-pagos-{id}.pdf`
  - Datos: Plan de pagos con cuotas, programas y fechas de vencimiento

- **`descargarContratoPDF($id)`** (Línea ~2013)
  - Vista: `pdf.contrato`
  - Archivo: `contrato-{id}.pdf`
  - Datos: Contrato de confidencialidad con firmas digitales (asesor y estudiante)
  - Incluye: Base64 de firmas, programas, montos (inscripción, mensualidad)

---

### 2. **ReportsController.php**
**Ubicación:** `blue_atlas_backend/app/Http/Controllers/Api/ReportsController.php`

#### Reportes:
- **`summary()`** (Línea ~121)
  - Vista: `pdf.report-summary`
  - Archivo: `reporte.pdf`
  - Datos: Resumen financiero (ingresos mensuales, morosidad, estudiantes activos)

- **`exportReport($request)`** (Línea ~556)
  - **Reporte de Asesores:**
    - Vista: `pdf.reporte-asesores`
    - Archivo: `reporte_asesores_{timestamp}.pdf`
    - Datos: Estadísticas por asesor (leads, conversiones, interacciones)
  
  - **Reporte de Leads:**
    - Vista: `pdf.reporte-leads`
    - Archivo: `reporte_leads_{timestamp}.pdf`
    - Datos: Estadísticas de leads (capturados, contactados, convertidos)
  
  - **Reporte de Conversiones:**
    - Vista: `pdf.reporte-conversiones`
    - Archivo: `reporte_conversiones_{timestamp}.pdf`
    - Datos: Análisis de conversiones por programa

---

### 3. **AdministracionController.php**
**Ubicación:** `blue_atlas_backend/app/Http/Controllers/Api/AdministracionController.php`

#### Reportes:
- **`exportarReportesMatricula()`** (Línea ~600-650)
  - Vista: `reportes-matricula.blade.php`
  - Archivo: `reporte_matricula_{formato}_{timestamp}.pdf`
  - Datos: Estudiantes matriculados por mes/año con métricas comparativas
  - Opciones:
    - `complete`: Resumen + gráficos + lista de alumnos
    - `summary`: Solo resumen ejecutivo
    - `data`: Solo listado de alumnos

- **`exportarGraduacionesPDF()`** (Línea ~2020-2053)
  - Vista: `pdf.reporte-graduaciones`
  - Archivo: `reporte-graduaciones-{fecha}.pdf`
  - Datos: Estudiantes graduados con métricas por programa
  - **Nota:** Si hay más de 500 registros, genera múltiples PDFs en un ZIP

---

### 4. **ReconciliationController.php**
**Ubicación:** `blue_atlas_backend/app/Http/Controllers/Api/ReconciliationController.php`

#### Reportes:
- **`exportConciliados()`** (Línea ~756-844)
  - Vista: `exports.conciliados-pdf`
  - Archivo: `conciliados_{from}_{to}.pdf`
  - Datos: Registros de pagos conciliados con banco, monto, estudiante, programa

- **`exportTransaccionesConciliados()`** (Línea ~890-960)
  - Vista: Similar estructura a `conciliados-pdf`
  - Archivo: `transacciones_conciliados_{timestamp}.pdf`
  - Datos: Transacciones específicas con detalles de kardex y prospectos

---

### 5. **SeguridadAccesosController.php**
**Ubicación:** `blue_atlas_backend/app/Http/Controllers/Api/SeguridadAccesosController.php`

#### Reportes:
- **`descargarReporte()`** (Línea ~211-322)
  - Vista: `exports.accesos-pdf`
  - Archivo: `Reporte_Accesos_{timestamp}.pdf`
  - Datos: Logs de accesos al sistema (usuario, IP, dispositivo, fecha)
  - Orientación: **Landscape** (horizontal)
  - Límite: Hasta 500 registros

---

### 6. **RankingController.php**
**Ubicación:** `blue_atlas_backend/app/Http/Controllers/Api/RankingController.php`

#### Reportes:
- **`downloadRanking()`** (Línea ~81)
  - Vista: `pdf.ranking` (presumible)
  - Archivo: `ranking.pdf`
  - Datos: Ranking académico de estudiantes

---

### 7. **EstudiantePerfilController.php**
**Ubicación:** `blue_atlas_backend/app/Http/Controllers/Api/EstudiantePerfilController.php`

#### Reportes:
- **`descargarEstadoCuenta()`** (Línea ~737)
  - Vista: No especificada en el grep (posible `pdf.estado-cuenta`)
  - Archivo: `{filename}.pdf` (nombre dinámico)
  - Datos: Estado de cuenta del estudiante (pagos, cuotas, balance)

---

### 8. **CourseController.php**
**Ubicación:** `blue_atlas_backend/app/Http/Controllers/Api/CourseController.php`

#### Reportes:
- **Descargas de archivos de cursos** (Líneas 1172, 1413)
  - No son PDFs generados, son archivos subidos (materiales de curso)
  - Método: `response()->download($filepath, $filename)`

---

## 🖥️ Frontend React/TypeScript (Next.js)

### 1. **Estado de Cuenta Estudiante**
**Componente:** `components/estudiantes/estado-cuenta-estudiante.tsx`

#### Función:
- **`handleGeneratePDF()`** (Línea 56)
  - Llama a backend: Probablemente `/api/estudiantes/{id}/estado-cuenta`
  - Genera PDF del estado de cuenta individual

**Componente:** `components/finanzas/estado-cuenta-estudiante.tsx`
- **`handleGeneratePDF()`** (Línea 115)
  - Similar función desde módulo de finanzas

**Componente:** `components/finanzas/StudentAccountModal.tsx`
- **`handleGeneratePDF()`** (Línea 39)
  - Modal con generación de estado de cuenta

---

### 2. **Firma de Contratos**
**Archivo:** `app/firma/page.tsx`

#### Función:
- **Descarga de contrato firmado** (Línea 164-174)
  - Endpoint: `/api/prospectos/{id}/contrato-pdf`
  - Acepta: `application/pdf`
  - Archivo: `Contrato_{nombreEstudiante}.pdf`

---

### 3. **Aprobación Académica**
**Componente:** `components/inscripcion/modal/AprobacionAcademicaModal.tsx`

#### Funciones:
- **Descargar contrato firmado** (Línea 274)
  - Endpoint: Probablemente `/api/prospectos/{id}/contrato-pdf`
  - Archivo: `contrato-firmado-{id}.pdf`

- **Descargar ficha** (Línea 359)
  - Endpoint: Probablemente `/api/prospectos/{id}/ficha-pdf`
  - Archivo: `ficha-{id}.pdf`

- **Descargar plan de pagos** (Línea 383)
  - Endpoint: Probablemente `/api/prospectos/{id}/plan-pagos-pdf`
  - Archivo: `plan-pagos-{id}.pdf`

---

### 4. **Reportes de Administración**
**Archivo:** `app/admin/reportes/page.tsx`

#### Función:
- **`handleExport()`** (Línea 199)
  - Formato: PDF, Excel o CSV
  - Nota: Implementación pendiente (console.log)

**Componente:** `components/admin/reports.tsx`
- **`handleExport()`** (Línea 127)
  - Tipos:
    - `asesores` → Reporte de asesores
    - `leads` → Reporte de leads
    - `conversiones` → Reporte de conversiones
  - Endpoint: `/api/reports/export`

---

### 5. **Ranking Académico**
**Archivo:** `app/academico/ranking/page.tsx`

#### Función:
- **Descarga de ranking** (Línea 199)
  - Endpoint: Probablemente `/api/ranking/download`
  - Archivo: `ranking_academico_{timestamp}.pdf`

---

### 6. **Conciliación Bancaria**
**Archivo:** `app/finanzas/conciliacion/conciliacion-client.tsx`

#### Función:
- **Exportar conciliados** (Línea 821-830)
  - Endpoint: `/api/conciliacion/export-conciliados`
  - Formato: PDF
  - Archivo: `conciliados_{fecha}.pdf`

---

### 7. **Reportes de Matrícula**
**Archivo:** `app/admin/reportes-matricula/page.tsx`

#### Funciones:
- **Exportar reporte de matrícula** (Línea 537-595)
  - Endpoint: `/api/administracion/reportes-matricula/exportar`
  - Formatos: PDF, Excel, CSV
  - Niveles:
    - `complete`: Completo
    - `summary`: Resumen
    - `data`: Solo datos
  - **Advertencia:** Límite de 10,000 registros para PDF

---

### 8. **Reportes de Graduaciones**
**Archivo:** `app/admin/reporte-graduaciones/page.tsx`

#### Función:
- **Exportar graduaciones** (Línea 185)
  - Endpoint: `/api/administracion/reportes-graduaciones/exportar`
  - Formatos: PDF, Excel

---

### 9. **Reportes Avanzados**
**Archivo:** `app/reportes-avanzados/page.tsx`

#### Funciones:
- **Botón de exportar** (Línea 664-683)
  - Formatos: Excel, PDF, CSV
  - Nota: Implementación pendiente (UI diseñado)

---

## 📂 Vistas Blade (Templates PDF)

### Backend Views:
1. **`resources/views/pdf/ficha-inscripcion.blade.php`**
   - Ficha completa del prospecto

2. **`resources/views/pdf/plan-pagos.blade.php`**
   - Plan de pagos con cuotas

3. **`resources/views/pdf/contrato.blade.php`**
   - Contrato de confidencialidad con firmas

4. **`resources/views/pdf/report-summary.blade.php`**
   - Resumen financiero

5. **`resources/views/pdf/reporte-asesores.blade.php`**
   - Rendimiento por asesor

6. **`resources/views/pdf/reporte-leads.blade.php`**
   - Estadísticas de leads

7. **`resources/views/pdf/reporte-conversiones.blade.php`**
   - Análisis de conversiones

8. **`resources/views/pdf/reporte-graduaciones.blade.php`**
   - Reporte de graduaciones

9. **`resources/views/exports/conciliados-pdf.blade.php`**
   - Pagos conciliados

10. **`resources/views/exports/accesos-pdf.blade.php`**
    - Logs de accesos al sistema

11. **`resources/views/reportes-matricula.blade.php`** (presumible)
    - Reporte de matrícula mensual

---

## 🔧 Tecnologías Utilizadas

### Backend:
- **Librería:** `barryvdh/laravel-dompdf` v3.1
- **DomPDF:** Motor de generación de PDFs desde HTML
- **Configuración:** 
  - Papel: Letter (8.5" x 11")
  - Orientación: Portrait (vertical) o Landscape (horizontal)
  - Fuente: Arial, sans-serif

### Frontend:
- **Generación cliente:** Algunas páginas usan generadores de PDF en el cliente (jsPDF o similar)
- **Descargas:** Blob + `<a>` download attribute

---

## 🎨 Logos y Branding

### Logos Disponibles:
Ubicados en: `blue_atlas_backend/resources/views/recursos/`

1. **Logos-02.png** - Logo azul oscuro (formal, corporativo)
2. **Logos-04.png** - Logo dorado (elegante, ceremonial)
3. **Logos-04(1).png** - Logo dorado alternativo
4. **Logos_Mesa de trabajo 1.png** - Logo azul oscuro alternativo
5. **Logos_Mesa de trabajo 1(2).png** - Logo dorado alternativo

### Distribución de Logos por Reporte:

#### Logo Azul (Logos-02.png) - Documentos Formales/Corporativos:
- ✅ Contrato de Confidencialidad (`pdf/contrato.blade.php`)
- ✅ Ficha de Inscripción (`pdf/ficha-inscripcion.blade.php`)
- ✅ Plan de Pagos (`pdf/plan-pagos.blade.php`)
- ✅ Reporte de Accesos (`exports/accesos-pdf.blade.php`)
- ✅ Reporte de Conciliados (`exports/conciliados-pdf.blade.php`)
- ✅ Reporte de Asesores (`pdf/reporte-asesores.blade.php`) - Con filtro blanco
- ✅ Reporte de Leads (`pdf/reporte-leads.blade.php`) - Con filtro blanco
- ✅ Reporte de Conversiones (`pdf/reporte-conversiones.blade.php`) - Con filtro blanco
- ✅ Resumen Financiero (`pdf/report-summary.blade.php`)
- ✅ Historial Académico (`exports/historial-academico-pdf.blade.php`) - Con filtro blanco

#### Logo Dorado (Logos-04.png) - Documentos Ceremoniales/Académicos:
- ✅ Reporte de Matrícula (`pdf/reportes-matricula.blade.php`)
- ✅ Reporte de Graduaciones (`exports/graduaciones-pdf.blade.php`)
- ✅ Ranking Académico (`pdf/ranking-report.blade.php`)

### Implementación Técnica:
```php
// Logo estándar (azul o dorado según documento)
<img src="{{ public_path('recursos/Logos-02.png') }}" alt="American School of Management">

// Logo con filtro blanco (para fondos oscuros/gradientes)
<img src="{{ public_path('recursos/Logos-02.png') }}" 
     alt="American School of Management" 
     style="filter: brightness(0) invert(1);">
```

**Nota:** El filtro `brightness(0) invert(1)` convierte el logo a blanco, ideal para headers con gradientes oscuros.

---

## 📊 Resumen por Categoría

| Categoría | Cantidad | Controladores |
|-----------|----------|---------------|
| **Prospectos/Inscripciones** | 3 | ProspectoController |
| **Finanzas** | 4 | ReportsController, ReconciliationController, EstudiantePerfilController |
| **Administración** | 4 | AdministracionController |
| **Seguridad** | 1 | SeguridadAccesosController |
| **Académico** | 1 | RankingController |
| **Frontend (React)** | 10+ | Múltiples componentes |

---

## 🚀 Endpoints API para Descargar PDFs

```
GET /api/prospectos/{id}/ficha-pdf
GET /api/prospectos/{id}/plan-pagos-pdf
GET /api/prospectos/{id}/contrato-pdf
GET /api/reports/export
GET /api/administracion/reportes-matricula/exportar
GET /api/administracion/reportes-graduaciones/exportar
GET /api/conciliacion/export-conciliados
GET /api/conciliacion/export-transacciones-conciliados
GET /api/seguridad/accesos/reporte
GET /api/ranking/download
GET /api/estudiantes/{id}/estado-cuenta-pdf
```

---

## ⚠️ Consideraciones de Rendimiento

### PDFs con Límites:
- **Accesos:** Máximo 500 registros
- **Graduaciones:** Si > 500 registros → Múltiples PDFs en ZIP
- **Matrícula:** Advertencia si > 10,000 registros

### Alternativas:
- Para datasets grandes: **Excel** o **CSV**
- Para reportes complejos: **Background Jobs** (Jobs en Laravel)

---

## 📝 Notas Adicionales

1. **Firma Digital:** Los contratos usan **base64** para embeber imágenes de firmas en el PDF
2. **Estilos:** Inline CSS en las vistas Blade para compatibilidad con DomPDF
3. **Logs:** Todos los PDFs generan logs en Laravel (`Log::info`)
4. **Caché:** Algunos reportes pueden usar caché de Laravel para optimizar consultas
5. **Seguridad:** Los endpoints de descarga verifican autenticación y permisos

---

**Fecha de generación:** 2 de diciembre de 2025  
**Sistema:** Blue Atlas Dashboard - ASM Prolink
