# Sistema de Inventario y Ventas con SQL Server

Proyecto de base de datos relacional desarrollado en **SQL Server / T-SQL**, orientado a simular un caso empresarial de control de ventas, stock e inventario para una empresa retail.

El objetivo del proyecto es demostrar el diseño e implementación de una base de datos profesional con tablas relacionadas, restricciones, datos de prueba, vistas, procedimientos almacenados, funciones, triggers, índices, consultas operativas, consultas de reportes, evidencias, diagrama entidad-relación y documentación técnica.

---

## Caso de negocio

Una empresa retail de tecnología necesita controlar sus productos, clientes, tiendas, ventas y movimientos de inventario.

El sistema permite registrar productos por categoría y proveedor, controlar el stock por tienda, registrar ventas, descontar inventario automáticamente, anular ventas devolviendo stock y mantener trazabilidad de los cambios realizados.

---

## Objetivos del proyecto

- Diseñar una base de datos relacional normalizada.
- Implementar tablas con claves primarias, claves foráneas y restricciones.
- Cargar datos iniciales realistas para pruebas.
- Crear vistas para consultas operativas y reportes.
- Crear procedimientos almacenados para procesos de negocio.
- Crear funciones para cálculos reutilizables.
- Crear triggers para auditoría automática.
- Crear índices para mejorar consultas frecuentes.
- Crear consultas SQL para operaciones diarias y reportes gerenciales.
- Documentar el proyecto con estructura profesional para GitHub.

---

## Tecnologías utilizadas

- SQL Server
- T-SQL
- SQL Server Management Studio
- dbdiagram.io
- Git
- GitHub

---

## Estructura del proyecto

```txt
sistema-inventario-ventas-sqlserver/
│
├── database/
│   ├── 01_schema.sql
│   ├── 02_seed.sql
│   ├── 03_views.sql
│   ├── 04_procedures.sql
│   ├── 05_functions.sql
│   ├── 06_triggers.sql
│   └── 07_indexes.sql
│
├── queries/
│   ├── consultas_operativas.sql
│   └── consultas_reportes.sql
│
├── docs/
│   ├── diagrama-er.png
│   ├── documentacion_tecnica.pdf
│   └── capturas/
│       ├── 01-tablas-creadas.png
│       ├── 02-vistas-procedures-functions.png
│       ├── 03-registro-venta.png
│       ├── 04-trigger-auditoria-stock.png
│       └── 05-consultas-reportes.png
│
├── README.md
└── .gitignore
```

---

## Documentación técnica

La documentación técnica completa del proyecto está disponible en PDF:

[Ver documentación técnica](docs/documentacion_tecnica.pdf)

El documento resume el caso de negocio, arquitectura lógica, modelo de datos, scripts implementados, procesos de negocio, reglas aplicadas, consultas y evidencias del proyecto.

---

## Módulos principales

### Catálogo

Incluye la gestión base de:

- Categorías
- Proveedores
- Productos

### Comercial

Incluye el registro de:

- Clientes
- Ventas
- Detalle de ventas

### Inventario

Incluye el control de:

- Tiendas
- Stock por tienda
- Movimientos de inventario

### Auditoría

Incluye el registro automático de cambios en stock mediante triggers.

---

## Tablas principales

- `Categorias`
- `Proveedores`
- `Productos`
- `Clientes`
- `Tiendas`
- `Usuarios`
- `Stock`
- `Ventas`
- `VentaDetalle`
- `MovimientosInventario`
- `AuditoriaStock`

---

## Diagrama entidad-relación

El modelo relacional fue diagramado con **dbdiagram.io** para representar las entidades principales, claves primarias, claves foráneas y relaciones entre tablas.

![Diagrama ER](docs/diagrama-er.png)

---

## Scripts de base de datos

### `01_schema.sql`

Crea la base de datos `InventarioVentasDB` y todas las tablas principales del sistema.

Incluye:

- Primary keys
- Foreign keys
- Constraints
- Valores por defecto
- Campos de estado
- Campos de fecha

### `02_seed.sql`

Inserta datos iniciales para simular una empresa retail.

Incluye:

- Categorías
- Proveedores
- Tiendas
- Usuarios
- Clientes
- Productos
- Stock inicial
- Movimientos iniciales de inventario

### `03_views.sql`

Crea vistas para facilitar consultas operativas y reportes.

Vistas creadas:

- `vw_stock_productos`
- `vw_movimientos_inventario`
- `vw_resumen_productos`
- `vw_ventas_detalle`
- `vw_resumen_ventas_tienda`

### `04_procedures.sql`

Crea procedimientos almacenados para procesos de negocio.

Procedimientos creados:

- `sp_registrar_movimiento_inventario`
- `sp_registrar_venta`
- `sp_anular_venta`

### `05_functions.sql`

Crea funciones escalares para cálculos reutilizables.

Funciones creadas:

- `fn_calcular_margen_unitario`
- `fn_calcular_porcentaje_margen`
- `fn_obtener_estado_stock`

### `06_triggers.sql`

Crea trigger de auditoría para registrar cambios automáticos en el stock.

Trigger creado:

- `trg_auditar_cambios_stock`

### `07_indexes.sql`

Crea índices para mejorar consultas frecuentes.

Índices creados:

- `IX_Productos_CodigoSKU`
- `IX_Stock_Producto_Tienda`
- `IX_Ventas_FechaVenta`
- `IX_Ventas_Tienda_Estado`
- `IX_VentaDetalle_Producto`
- `IX_MovimientosInventario_Producto_Tienda_Fecha`
- `IX_Clientes_Documento`

---

## Procesos de negocio implementados

### Registro de movimiento de inventario

El procedimiento `sp_registrar_movimiento_inventario` permite registrar:

- Entradas de inventario
- Salidas de inventario
- Ajustes de stock

También valida:

- Producto existente
- Tienda existente
- Usuario existente
- Cantidad válida
- Stock no negativo

### Registro de venta

El procedimiento `sp_registrar_venta` permite registrar una venta de un producto.

El proceso realiza:

- Validación de cliente, tienda, usuario y producto.
- Validación de stock disponible.
- Cálculo de subtotal, IGV y total.
- Registro de cabecera de venta.
- Registro de detalle de venta.
- Descuento automático de stock.
- Registro automático de movimiento de inventario tipo `SALIDA`.

### Anulación de venta

El procedimiento `sp_anular_venta` permite anular una venta registrada.

El proceso realiza:

- Validación de venta existente.
- Cambio de estado a `ANULADA`.
- Devolución automática de stock.
- Registro automático de movimiento de inventario tipo `ENTRADA`.
- Conservación del historial de la venta.

---

## Auditoría de stock

El sistema cuenta con un trigger que registra automáticamente los cambios de stock en la tabla `AuditoriaStock`.

Cada vez que se actualiza la cantidad de stock, se guarda:

- Producto
- Tienda
- Cantidad anterior
- Cantidad nueva
- Acción realizada
- Fecha de auditoría

Esto permite mantener trazabilidad sobre los cambios de inventario.

---

## Consultas incluidas

### Consultas operativas

Archivo:

```txt
queries/consultas_operativas.sql
```

Incluye consultas para:

- Stock actual por tienda y producto.
- Productos con stock bajo o sin stock.
- Búsqueda de cliente por documento.
- Movimientos recientes de inventario.
- Historial de movimientos por producto.
- Ventas registradas y anuladas.
- Auditoría de cambios de stock.

### Consultas de reportes

Archivo:

```txt
queries/consultas_reportes.sql
```

Incluye consultas para:

- Resumen de ventas por tienda.
- Ventas por estado.
- Productos vendidos por cantidad.
- Stock valorizado por tienda.
- Margen unitario y porcentaje de margen.
- Resumen de stock por categoría.
- Alertas de stock.
- Movimientos por tipo.
- Auditoría de cambios por producto.

---

## Evidencias del proyecto

### Tablas creadas en SQL Server

![Tablas creadas](docs/capturas/01-tablas-creadas.png)

### Vistas, procedimientos y funciones

![Vistas, procedimientos y funciones](docs/capturas/02-vistas-procedures-functions.png)

### Registro de ventas

![Registro de ventas](docs/capturas/03-registro-venta.png)

### Auditoría automática de stock

![Auditoría automática de stock](docs/capturas/04-trigger-auditoria-stock.png)

### Consultas de reportes

![Consultas de reportes](docs/capturas/05-consultas-reportes.png)

---

## Orden de ejecución

Ejecutar los scripts en SQL Server Management Studio en el siguiente orden:

```txt
1. database/01_schema.sql
2. database/02_seed.sql
3. database/03_views.sql
4. database/04_procedures.sql
5. database/05_functions.sql
6. database/06_triggers.sql
7. database/07_indexes.sql
```

Luego se pueden ejecutar las consultas:

```txt
queries/consultas_operativas.sql
queries/consultas_reportes.sql
```

---

## Ejemplo de uso

Registrar una venta:

```sql
EXEC sp_registrar_venta
    @cliente_id = 1,
    @tienda_id = 1,
    @usuario_id = 2,
    @producto_id = 1,
    @cantidad = 1;
```

Anular una venta:

```sql
EXEC sp_anular_venta
    @venta_id = 1,
    @usuario_id = 3,
    @motivo = 'Cliente solicitó anulación de la compra';
```

Consultar stock actual:

```sql
SELECT *
FROM vw_stock_productos
ORDER BY tienda, producto;
```

Consultar ventas detalladas:

```sql
SELECT *
FROM vw_ventas_detalle
ORDER BY fecha_venta DESC;
```

Consultar auditoría de stock:

```sql
SELECT TOP 10
    a.fecha_auditoria,
    t.nombre AS tienda,
    p.codigo_sku,
    p.nombre AS producto,
    a.cantidad_anterior,
    a.cantidad_nueva,
    a.accion
FROM AuditoriaStock a
INNER JOIN Productos p
    ON a.producto_id = p.producto_id
INNER JOIN Tiendas t
    ON a.tienda_id = t.tienda_id
ORDER BY a.fecha_auditoria DESC;
```

---

## Reglas de negocio aplicadas

- No se permite vender productos sin stock suficiente.
- El stock no puede quedar negativo.
- Las ventas anuladas no se eliminan físicamente.
- La anulación de una venta devuelve el stock.
- Toda modificación de stock queda registrada en auditoría.
- El precio de venta se guarda en el detalle de venta para conservar el histórico.
- Los reportes comerciales consideran solo ventas registradas.

---

## Estado del proyecto

Proyecto funcional para portafolio.

Avance actual:

- Modelo relacional implementado.
- Datos iniciales cargados.
- Vistas creadas.
- Procedimientos almacenados implementados.
- Funciones implementadas.
- Trigger de auditoría implementado.
- Índices creados.
- Consultas operativas y de reportes creadas.
- Capturas de evidencia agregadas.
- Diagrama entidad-relación agregado.
- Documentación técnica PDF agregada.

Mejoras futuras opcionales:

- Registrar ventas con múltiples productos en una sola ejecución.
- Agregar métodos de pago y comprobantes de venta.
- Agregar transferencias entre tiendas.
- Agregar compras a proveedores.
- Cargar más datos históricos para reportes mensuales.
- Conectar la base de datos a Power BI.
- Implementar roles y permisos de seguridad.

---

## Autor

**Alexis Suasnabar**

Proyecto desarrollado como parte de un portafolio profesional orientado a roles junior de SQL, bases de datos, análisis de datos y business intelligence.
