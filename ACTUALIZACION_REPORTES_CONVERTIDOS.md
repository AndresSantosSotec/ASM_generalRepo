# Actualización: Reportes - Convertidos = Inscritos

## 📋 Cambios Realizados

### 1. **Lógica de Negocio**
Se actualizó la definición de "Convertido" para que coincida con la realidad del negocio:

**ANTES:**
- Convertido = prospecto con `status = 'convertido'`

**AHORA:**
- **Convertido = Inscrito** = prospecto que tiene registro en la tabla `estudiante_programa`

### 2. **Backend - ReportsController.php**

#### advisorStats()
```php
// Convertidos = prospectos con registro en estudiante_programa
DB::raw('COUNT(DISTINCT CASE WHEN estudiante_programa.id IS NOT NULL THEN prospectos.id END) as leads_convertidos')
```

#### leadStats()
```php
// Convertidos = prospectos con registro en estudiante_programa
$convertidos = (clone $query)->whereHas('programas')->count();
```

#### conversionStats()
```php
// Convertidos = prospectos con registro en estudiante_programa
$totalConvertidos = (clone $query)->whereHas('programas')->count();
```

### 3. **Ajuste de Estados**
Se actualizaron los estados para coincidir con los valores reales en la base de datos:

**Estados en DB:**
- `Inscrito` (2854 registros)
- `En seguimiento` (1 registro)

**Actualización en código:**
```php
// ANTES (minúsculas)
'asignado', 'contactado', 'seguimiento', 'convertido', 'inscrito'

// AHORA (PascalCase)
'Asignado', 'Contactado', 'Seguimiento', 'En seguimiento', 'Convertido', 'Inscrito'
```

### 4. **Templates PDF Actualizados**

#### reporte-asesores.blade.php
- Subtítulo: "Análisis detallado de desempeño y conversión **(Convertidos = Inscritos)**"
- Tarjeta: "Convertidos" → **"Inscritos"**
- Tarjeta: "Tasa Conversión" → **"Tasa Inscripción"**
- Columna tabla: "Convertidos" → **"Inscritos"**
- Columna tabla: "Tasa Conv." → **"Tasa Insc."**

#### reporte-leads.blade.php
- Subtítulo: "Análisis de prospectos por estado **(Convertidos = Inscritos)**"
- Tarjeta: "Convertidos" → **"Inscritos"** (icono ✅ → 🎓)

#### reporte-conversiones.blade.php
- Título: "Reporte de Conversiones" → **"Reporte de Conversiones e Inscripciones"**
- Subtítulo: "Análisis de tasas de cierre" → **"Análisis de tasas de inscripción"**
- Highlight: "TASA DE CONVERSIÓN GLOBAL" → **"TASA DE INSCRIPCIÓN GLOBAL"**
- Mensaje: "convertidos de X prospectos" → **"inscritos de X prospectos"**
- Tarjeta: "Convertidos" → **"Inscritos"** (icono ✅ → 🎓)
- Tabla: "Conversiones por Programa" → **"Inscripciones por Programa"**
- Columna: "Convertidos" → **"Inscritos"**

### 5. **Frontend - reports.tsx**
- Botones: "Exportar" → **"Descargar PDF"** (3 tabs)

## 📊 Resultados de Prueba

### advisorStats()
```json
{
  "advisor_id": 10,
  "advisor_name": "Pablo Admin",
  "total_leads": 2709,
  "leads_asignados": 2709,
  "leads_contactados": 2709,
  "leads_convertidos": 2708,  // ← Cuenta registros en estudiante_programa
  "tasa_conversion": 99.96,
  "interacciones_total": 5
}
```

### leadStats()
```json
{
  "total": 2855,
  "nuevos": 0,
  "en_seguimiento": 1,
  "contactados": 0,
  "convertidos": 2854,  // ← whereHas('programas')
  "no_interesados": 0,
  "por_programa": [...]
}
```

### conversionStats()
```json
{
  "total_prospectos": 2855,
  "total_convertidos": 2854,  // ← whereHas('programas')
  "tasa_conversion": 99.96,
  "por_programa": [
    {
      "programa": "Bachelor of Business Administration",
      "prospectos": 1466,
      "convertidos": 1466,  // ← COUNT(estudiante_programa.prospecto_id)
      "tasa": 100
    }
  ]
}
```

## ✅ Validación

✅ **advisorStats()**: Calcula correctamente inscritos usando LEFT JOIN con `estudiante_programa`
✅ **leadStats()**: Cuenta convertidos usando `whereHas('programas')`
✅ **conversionStats()**: Calcula tasa de inscripción por programa
✅ **Templates PDF**: Textos actualizados a "Inscritos" e "Inscripción"
✅ **Frontend**: Botones dicen "Descargar PDF"

## 🎯 Impacto

- ✅ **Precisión**: Los reportes ahora reflejan la realidad del negocio
- ✅ **Claridad**: Terminología consistente (Inscritos vs Convertidos)
- ✅ **Relaciones**: Usa correctamente la relación `Prospecto → EstudiantePrograma`
- ✅ **Estados**: Coincide con valores reales en PostgreSQL

## 📝 Notas Técnicas

### Relación Utilizada
```php
// Prospecto.php
public function programas()
{
    return $this->hasMany(EstudiantePrograma::class, 'prospecto_id');
}
```

### Query Principal
```php
// LEFT JOIN para incluir prospectos sin inscripción
->leftJoin('estudiante_programa', 'prospectos.id', '=', 'estudiante_programa.prospecto_id')

// Cuenta solo los que tienen registro
DB::raw('COUNT(DISTINCT CASE WHEN estudiante_programa.id IS NOT NULL THEN prospectos.id END) as leads_convertidos')
```

### Alternativa con Eloquent
```php
// Usando relación de Eloquent
$convertidos = Prospecto::whereHas('programas')->count();
```

## 🚀 Próximos Pasos

1. Probar descarga de PDFs desde el frontend
2. Validar con diferentes rangos de fechas
3. Verificar rendimiento con datasets grandes
4. Agregar caché si es necesario
