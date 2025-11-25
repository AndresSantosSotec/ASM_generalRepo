# 📊 Sistema de Dashboard Dinámico - Métricas Financieras y Académicas

## 🎯 Descripción General

Sistema completo de dashboard con métricas dinámicas que permite calcular y visualizar indicadores financieros y académicos en tiempo real, con filtros personalizables y optimización de performance mediante cache.

---

## 🏗️ Arquitectura del Sistema

### Backend (Laravel)

#### 1. **DashboardMetricsService.php**
Servicio principal que maneja toda la lógica de negocio para calcular métricas.

**Ubicación:** `app/Services/DashboardMetricsService.php`

**Métricas Calculadas:**
- ✅ Ingresos mensuales
- ✅ Tasa de morosidad
- ✅ Recaudación pendiente
- ✅ Estudiantes activos (desde Moodle)
- ✅ Estudiantes inactivos
- ✅ Nuevas inscripciones
- ✅ Total facturado/pagado/pendiente
- ✅ Variaciones respecto al período anterior

**Características:**
- Cache automático de 5 minutos
- Consultas SQL optimizadas
- Soporte para filtros dinámicos (mes, año, rango de fechas, programa, asesor)
- Integración con Moodle para datos académicos

#### 2. **DashboardMetricsController.php**
Controlador REST API que expone los endpoints.

**Ubicación:** `app/Http/Controllers/Api/DashboardMetricsController.php`

**Endpoints Disponibles:**

```php
GET /api/dashboard/metrics
// Obtener métricas con filtros dinámicos
// Parámetros: month, year, from, to, programa_id, asesor_id

GET /api/dashboard/metrics/by-programa
// Obtener métricas agrupadas por programa

GET /api/dashboard/metrics/monthly-comparison
// Comparación de últimos 12 meses

POST /api/dashboard/metrics/clear-cache
// Limpiar cache manualmente
```

---

### Frontend (Next.js + React)

#### 1. **DashboardFilters.tsx**
Componente de filtros dinámicos reutilizable.

**Ubicación:** `components/dashboard/DashboardFilters.tsx`

**Características:**
- Filtro por mes/año
- Rango de fechas personalizado
- Filtros opcionales de programa y asesor
- Validación automática
- Botón de reseteo

**Uso:**
```tsx
<DashboardFilters
  onFiltersChange={(filters) => setFilters(filters)}
  showProgramaFilter={true}
  showAsesorFilter={false}
  programas={[...]}
/>
```

#### 2. **MetricCard.tsx**
Tarjeta reutilizable para mostrar cualquier métrica.

**Ubicación:** `components/dashboard/MetricCard.tsx`

**Características:**
- Muestra valor con formato automático
- Badge de variación con colores (verde/rojo/gris)
- Iconos personalizables
- Prefijos y sufijos (Q, %, etc.)
- Animaciones de carga

**Uso:**
```tsx
<MetricCard
  title="Ingresos Mensuales"
  value={137883}
  variation={-3.4}
  icon={DollarSign}
  prefix="Q"
  description="vs mes anterior"
/>
```

#### 3. **useMetrics Hook**
Hook personalizado con SWR para manejo de datos.

**Ubicación:** `hooks/useMetrics.ts`

**Características:**
- Cache automático (5 minutos)
- Revalidación inteligente
- Retry automático en caso de error
- Deduplicación de requests
- Refresh manual

**Uso:**
```tsx
const { metrics, isLoading, isError, refresh } = useMetrics({
  month: 11,
  year: 2025
})
```

#### 4. **Página de Dashboard**
Ejemplo completo de implementación.

**Ubicación:** `app/finanzas/dashboard-dinamico/page.tsx`

---

## 🚀 Cómo Usar

### 1. Backend Setup

**Verificar conexiones de BD en `.env`:**
```env
# Conexión principal (PostgreSQL/MySQL)
DB_CONNECTION=pgsql
DB_DATABASE=tu_database

# Conexión Moodle (MySQL)
DB2_CONNECTION=mysql
DB2_DATABASE=u853667523_moodle
```

**Correr migraciones si es necesario:**
```bash
php artisan migrate
```

**Probar endpoint:**
```bash
curl http://localhost:8000/api/dashboard/metrics?month=11&year=2025
```

### 2. Frontend Setup

**Instalar dependencias (si no están):**
```bash
npm install swr date-fns react-day-picker
```

**Probar dashboard:**
```
http://localhost:3000/finanzas/dashboard-dinamico
```

---

## 📊 Ejemplos de Uso

### Obtener métricas del mes actual
```typescript
const { metrics } = useMetrics({
  month: 11,
  year: 2025
})
```

### Obtener métricas de un rango de fechas
```typescript
const { metrics } = useMetrics({
  from: '2025-11-01',
  to: '2025-11-21'
})
```

### Filtrar por programa
```typescript
const { metrics } = useMetrics({
  month: 11,
  year: 2025,
  programa_id: 5
})
```

### Comparación mensual
```typescript
const { months } = useMonthlyComparison()
// Retorna array con últimos 12 meses
```

---

## ⚡ Performance y Optimización

### Cache en Backend
- **Duración:** 5 minutos por defecto
- **Estrategia:** Cache por combinación de filtros
- **Limpiar cache:** `POST /api/dashboard/metrics/clear-cache`

### Cache en Frontend (SWR)
- **Deduplicación:** 1 minuto
- **Revalidación automática:** 5 minutos
- **Retry en error:** 3 intentos

### Consultas SQL Optimizadas
```sql
-- Ejemplo: Estudiantes activos con índices
SELECT COUNT(DISTINCT u.id)
FROM mdl_user_enrolments ue
JOIN mdl_user u ON u.id = ue.userid
WHERE u.username REGEXP '^asm[0-9]{4}[0-9]+$'
  AND ue.status = 0
  AND MONTH(FROM_UNIXTIME(ue.timecreated)) = 11
  AND YEAR(FROM_UNIXTIME(ue.timecreated)) = 2025
```

**Optimizaciones aplicadas:**
- ✅ Índices en columnas de fecha
- ✅ Joins optimizados
- ✅ Filtros en WHERE antes de JOIN
- ✅ COUNT(DISTINCT) en lugar de subconsultas

---

## 🔧 Personalización

### Agregar Nueva Métrica

#### Backend (DashboardMetricsService.php)
```php
private function getMiNuevaMetrica(array $params): float
{
    $query = DB::table('mi_tabla')
        ->whereNull('deleted_at');
    
    $this->applyDateFilters($query, $params, 'fecha_columna');
    
    return $query->sum('monto');
}

// Agregar en getMetrics():
'miNuevaMetrica' => $this->getMiNuevaMetrica($params),
```

#### Frontend (useMetrics.ts)
```typescript
export interface MetricsData {
  // ... métricas existentes
  miNuevaMetrica: number
}
```

#### Mostrar en Dashboard
```tsx
<MetricCard
  title="Mi Nueva Métrica"
  value={metrics?.miNuevaMetrica || 0}
  icon={IconoPersonalizado}
  prefix="Q"
/>
```

---

## 📈 Ejemplo de Respuesta API

```json
{
  "success": true,
  "data": {
    "ingresosMensuales": 137883,
    "ingresosMesAnterior": 142800,
    "tasaMorosidad": 0.6,
    "tasaMorosidadAnterior": -10.2,
    "recaudacionPendiente": 0,
    "recaudacionPendienteAnterior": 0,
    "estudiantesActivos": 793,
    "estudiantesActivosAnterior": 814,
    "nuevasInscripciones": 45,
    "estudiantesInactivos": 12,
    "totalFacturado": 250000,
    "totalPagado": 137883,
    "totalPendiente": 112117,
    "variaciones": {
      "ingresos": -3.44,
      "morosidad": 11.76,
      "recaudacion": 0,
      "estudiantes": -2.58
    },
    "timestamp": "2025-11-21T10:30:00.000000Z"
  },
  "filters": {
    "month": 11,
    "year": 2025
  }
}
```

---

## 🐛 Troubleshooting

### El dashboard no carga
1. Verificar que el backend esté corriendo
2. Revisar console de navegador para errores
3. Verificar que las rutas API estén registradas: `php artisan route:list | grep metrics`

### Métricas incorrectas
1. Limpiar cache: `POST /api/dashboard/metrics/clear-cache`
2. Verificar conexiones de BD en `.env`
3. Revisar logs de Laravel: `storage/logs/laravel.log`

### Performance lenta
1. Agregar índices a tablas:
```sql
CREATE INDEX idx_pagos_fecha ON pagos(fecha_pago);
CREATE INDEX idx_cuotas_vencimiento ON cuotas(fecha_vencimiento);
CREATE INDEX idx_ep_created ON estudiantes_programas(created_at);
```

2. Revisar cache Redis (si disponible)
3. Aumentar duración de cache en `DashboardMetricsService.php`

---

## 📝 Notas Importantes

- ✅ El sistema es **totalmente dinámico** - se puede agregar cualquier métrica sin cambiar la estructura
- ✅ **Cache inteligente** previene sobrecarga del servidor
- ✅ **Componentes reutilizables** en todo el sistema
- ✅ **Filtros flexibles** - mes, rango, programa, asesor
- ✅ **Optimizado para producción** con SWR y Laravel Cache
- ✅ **Escalable** - soporta millones de registros con índices correctos

---

## 🎨 Próximas Mejoras

- [ ] Gráficas interactivas con Recharts
- [ ] Exportar a PDF/Excel
- [ ] Comparación entre períodos visualizada
- [ ] Alertas automáticas cuando métricas caen
- [ ] Dashboard personalizable por usuario
- [ ] Métricas en tiempo real con WebSockets

---

## 👨‍💻 Contacto y Soporte

Para dudas o mejoras del sistema, contactar al equipo de desarrollo.

**Última actualización:** Noviembre 2025
