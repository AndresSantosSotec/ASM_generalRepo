# 🔍 Guía de Verificación: Frontend Consumiendo Datos Reales

## ✅ Estado Actual de la Implementación

### 1. **Frontend YA está configurado para consumir datos reales** ✅

El archivo `page.tsx` tiene:

```typescript
// ✅ Import del servicio real
import { fetchReportesGraduaciones } from "@/services/reportesGraduaciones"

// ✅ Estados para datos reales
const [data, setData] = useState<ReportesGraduacionesResponse | null>(null)
const [loading, setLoading] = useState<boolean>(false)

// ✅ useEffect que carga datos automáticamente
useEffect(() => {
  loadData()
}, [year, period, program, searchTerm])

// ✅ Función que hace fetch al backend
const loadData = async () => {
  const response = await fetchReportesGraduaciones({
    anio: parseInt(year),
    periodo: period as any,
    programaId: program,
    search: searchTerm || undefined,
  })
  setData(response)
}
```

---

## 🧪 Cómo Verificar que Está Consumiendo Datos Reales

### Método 1: Consola del Navegador (DevTools)

1. **Abrir** `http://localhost:3000/admin/reporte-graduaciones`

2. **Presionar** `F12` para abrir DevTools

3. **Ir a la pestaña Console**

4. **Buscar estos logs**:
   ```
   🔄 Cargando datos de graduaciones... {anio: 2025, periodo: "all", ...}
   📡 API Request to /administracion/reportes-graduaciones {anio: 2025, ...}
   ✅ API Response: {filtros: {...}, graduados: {...}, estadisticas: {...}}
   📊 Total de graduados: X
   📈 Estadísticas: {...}
   ```

5. **Si ves estos logs** → ✅ Está consumiendo datos reales

6. **Si ves errores** → Revisa:
   - El backend está corriendo en `http://localhost:8000`
   - Tienes un token de autenticación válido en localStorage
   - El usuario tiene permisos para acceder al endpoint

---

### Método 2: Pestaña Network

1. **Abrir** DevTools → Pestaña **Network**

2. **Recargar** la página (`Ctrl+R`)

3. **Buscar** una petición llamada `reportes-graduaciones`

4. **Click** en esa petición

5. **Revisar**:
   - **Request URL**: Debe ser `http://localhost:8000/api/administracion/reportes-graduaciones?anio=2025&periodo=all&...`
   - **Status**: Debe ser `200` (verde)
   - **Response**: Debe contener datos JSON con `graduados`, `estadisticas`, etc.

6. **Si Status = 200** → ✅ Backend respondiendo correctamente

7. **Si Status = 401** → ❌ No estás autenticado (necesitas login)

8. **Si Status = 404** → ❌ Ruta no encontrada (verifica que el backend tenga la ruta)

9. **Si Status = 500** → ❌ Error en el backend (revisa logs de Laravel)

---

### Método 3: Indicador Visual en la UI

**He agregado un badge visual** que muestra el estado de los datos:

- **Badge Verde** "✓ Datos Reales del Backend" → Está consumiendo datos reales
- **Badge Amarillo** "⚠️ Mostrando datos de ejemplo" → Usando fallback
- **Badge Azul** "🔄 Cargando..." → Está haciendo fetch

**Ubicación**: Debajo del título "Reporte de Graduaciones"

---

## 🚀 Pasos para Probar

### 1. Iniciar Backend (Laravel)

```bash
cd d:\ASMProlink\blue_atlas_backend
php artisan serve
```

**Debe mostrar**: `Starting Laravel development server: http://127.0.0.1:8000`

---

### 2. Iniciar Frontend (Next.js)

```bash
cd d:\ASMProlink\blue-atlas-dashboard
npm run dev
```

**Debe mostrar**: `ready - started server on 0.0.0.0:3000, url: http://localhost:3000`

---

### 3. Verificar .env del Frontend

Archivo: `blue-atlas-dashboard\.env.local`

```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

**Si no existe**, créalo con ese contenido.

---

### 4. Autenticarse

1. Ir a `http://localhost:3000/login`
2. Ingresar credenciales válidas
3. Verificar que tengas un token en localStorage:
   - DevTools → Application → Local Storage → `http://localhost:3000`
   - Debe haber una clave `token` con un valor como `409|2263VjTlcYDb6tR5j2Gp...`

---

### 5. Ir a la Página de Reportes

```
http://localhost:3000/admin/reporte-graduaciones
```

**Deberías ver**:
- Badge verde "✓ Datos Reales del Backend" (si hay graduados)
- Tabla con graduados reales de la base de datos
- Estadísticas reales en las cards

---

## 🐛 Troubleshooting

### Problema: "No se encontraron graduados"

**Posibles causas**:

1. **No hay datos de graduados en la BD**
   
   Verifica en la base de datos:
   ```sql
   SELECT COUNT(*) 
   FROM estudiante_programa 
   WHERE fecha_fin <= NOW() 
     AND deleted_at IS NULL;
   ```

2. **Los filtros están muy restrictivos**
   
   Intenta:
   - Cambiar el año a años anteriores
   - Cambiar período a "Todo el año"
   - Cambiar programa a "Todos los programas"

3. **La fecha_fin está en el futuro**
   
   El backend solo considera graduados si `fecha_fin <= NOW()`. Verifica:
   ```sql
   SELECT nombre_completo, fecha_fin 
   FROM estudiante_programa ep
   JOIN prospectos p ON ep.prospecto_id = p.id
   WHERE fecha_fin <= NOW()
   LIMIT 10;
   ```

---

### Problema: Error 401 (Unauthorized)

**Solución**:
1. Hacer logout: `http://localhost:3000/logout`
2. Hacer login de nuevo
3. Verificar que el token se guardó en localStorage
4. Recargar la página de reportes

---

### Problema: Error 500 (Internal Server Error)

**Solución**:
1. Ver logs de Laravel:
   ```bash
   cd d:\ASMProlink\blue_atlas_backend
   Get-Content storage\logs\laravel.log -Tail 50
   ```

2. Buscar mensajes de error como:
   - "Class not found"
   - "Undefined property"
   - "SQL error"

3. Corregir el error según el mensaje

---

### Problema: No aparece nada (página en blanco)

**Solución**:
1. Abrir consola del navegador (F12)
2. Buscar errores en rojo
3. Verificar que Next.js esté corriendo
4. Verificar que no haya errores de TypeScript/compilación

---

## 📊 Ejemplo de Respuesta del Backend

Cuando el backend responde correctamente, devuelve esto:

```json
{
  "filtros": {
    "anio": 2025,
    "periodo": "all",
    "programaId": "all",
    "search": null,
    "rangoFechas": {
      "fechaInicio": "2025-01-01T00:00:00.000000Z",
      "fechaFin": "2025-12-31T23:59:59.999999Z",
      "descripcion": "Año completo 2025"
    }
  },
  "graduados": {
    "graduados": [
      {
        "id": 123,
        "prospectoId": 456,
        "nombre": "Juan Pérez",
        "carnet": "2021-001",
        "identificacion": "1234567890",
        "programa": "Maestría en Administración",
        "programaAbreviatura": "MBA",
        "fechaInicio": "2023-01-15",
        "fechaGraduacion": "2025-06-30",
        "duracionMeses": 18,
        "correo": "juan.perez@example.com",
        "telefono": "+502 1234-5678",
        "modalidad": "Virtual",
        "asesor": "Dr. Carlos Mendoza"
      }
    ],
    "paginacion": {
      "paginaActual": 1,
      "registrosPorPagina": 50,
      "total": 42,
      "totalPaginas": 1
    }
  },
  "estadisticas": {
    "totalGraduados": 42,
    "tiempoPromedioMeses": 18.5,
    "distribucionProgramas": [...],
    "distribucionModalidad": [...]
  },
  "historico": {...},
  "egresados": {...}
}
```

---

## ✅ Checklist Final

- [ ] Backend corriendo en `http://localhost:8000`
- [ ] Frontend corriendo en `http://localhost:3000`
- [ ] Archivo `.env.local` con `NEXT_PUBLIC_API_URL=http://localhost:8000`
- [ ] Usuario autenticado (token en localStorage)
- [ ] Hay datos de graduados en la base de datos
- [ ] Abrir DevTools → Console para ver logs
- [ ] Ver badge verde "✓ Datos Reales del Backend"
- [ ] Tabla muestra graduados reales
- [ ] Estadísticas coinciden con los datos de la BD

---

## 🎯 Resultado Esperado

Si todo está bien configurado, deberías ver:

1. **Badge verde** en el header
2. **Toast de éxito** con "X graduados encontrados"
3. **Tabla poblada** con datos reales
4. **Estadísticas correctas** en las cards
5. **Logs en console** mostrando la petición y respuesta del API

---

## 📝 Nota Importante

El frontend tiene un **fallback a datos de ejemplo** para que la UI se vea bien incluso sin backend. Esto es útil para desarrollo y demos.

**Orden de prioridad**:
1. Si hay datos reales del backend → Usa datos reales
2. Si no hay datos reales → Muestra datos de ejemplo
3. Siempre muestra un badge indicando qué tipo de datos se está mostrando

Esto asegura que la página SIEMPRE funcione, incluso si:
- El backend está caído
- No hay internet
- No hay graduados en la BD
- Hay errores de autenticación

---

**¿Necesitas ayuda adicional?** Revisa la consola del navegador y los logs del backend.
