/*
    Proyecto: Sistema de Inventario y Ventas con SQL Server
    Archivo: 03_views.sql
    Descripción:
    Creación de vistas para consultas operativas y reportes de negocio.
*/

USE InventarioVentasDB;
GO

-- =========================================================
-- VISTA: vw_stock_productos
-- Descripción:
-- Muestra el stock actual de productos por tienda, incluyendo categoría,
-- proveedor, precios y estado de alerta según stock mínimo.
-- =========================================================
CREATE OR ALTER VIEW vw_stock_productos AS
SELECT
    s.stock_id,
    t.tienda_id,
    t.nombre AS tienda,
    t.ciudad,
    p.producto_id,
    p.codigo_sku,
    p.nombre AS producto,
    c.nombre AS categoria,
    pr.razon_social AS proveedor,
    s.cantidad AS stock_actual,
    p.stock_minimo,
    CASE
        WHEN s.cantidad = 0 THEN 'SIN STOCK'
        WHEN s.cantidad <= p.stock_minimo THEN 'STOCK BAJO'
        ELSE 'STOCK OK'
    END AS estado_stock,
    p.precio_compra,
    p.precio_venta,
    s.fecha_actualizacion
FROM Stock s
INNER JOIN Productos p
    ON s.producto_id = p.producto_id
INNER JOIN Categorias c
    ON p.categoria_id = c.categoria_id
LEFT JOIN Proveedores pr
    ON p.proveedor_id = pr.proveedor_id
INNER JOIN Tiendas t
    ON s.tienda_id = t.tienda_id;
GO

-- =========================================================
-- VISTA: vw_movimientos_inventario
-- Descripción:
-- Muestra los movimientos de inventario con información del producto,
-- tienda y usuario responsable.
-- =========================================================
CREATE OR ALTER VIEW vw_movimientos_inventario AS
SELECT
    mi.movimiento_id,
    mi.fecha_movimiento,
    mi.tipo_movimiento,
    mi.cantidad,
    mi.motivo,
    mi.referencia,
    t.nombre AS tienda,
    t.ciudad,
    p.codigo_sku,
    p.nombre AS producto,
    c.nombre AS categoria,
    u.nombres + ' ' + u.apellidos AS usuario_responsable,
    u.rol
FROM MovimientosInventario mi
INNER JOIN Productos p
    ON mi.producto_id = p.producto_id
INNER JOIN Categorias c
    ON p.categoria_id = c.categoria_id
INNER JOIN Tiendas t
    ON mi.tienda_id = t.tienda_id
INNER JOIN Usuarios u
    ON mi.usuario_id = u.usuario_id;
GO

-- =========================================================
-- VISTA: vw_resumen_productos
-- Descripción:
-- Resume el stock total por producto considerando todas las tiendas.
-- =========================================================
CREATE OR ALTER VIEW vw_resumen_productos AS
SELECT
    p.producto_id,
    p.codigo_sku,
    p.nombre AS producto,
    c.nombre AS categoria,
    pr.razon_social AS proveedor,
    SUM(s.cantidad) AS stock_total,
    p.stock_minimo,
    p.precio_compra,
    p.precio_venta,
    (p.precio_venta - p.precio_compra) AS margen_unitario,
    CASE
        WHEN SUM(s.cantidad) = 0 THEN 'SIN STOCK'
        WHEN SUM(s.cantidad) <= p.stock_minimo THEN 'STOCK BAJO'
        ELSE 'STOCK OK'
    END AS estado_stock_general
FROM Productos p
INNER JOIN Categorias c
    ON p.categoria_id = c.categoria_id
LEFT JOIN Proveedores pr
    ON p.proveedor_id = pr.proveedor_id
INNER JOIN Stock s
    ON p.producto_id = s.producto_id
GROUP BY
    p.producto_id,
    p.codigo_sku,
    p.nombre,
    c.nombre,
    pr.razon_social,
    p.stock_minimo,
    p.precio_compra,
    p.precio_venta;
GO

-- =========================================================
-- VISTA: vw_ventas_detalle
-- Descripción:
-- Muestra las ventas con su detalle, cliente, tienda, vendedor y producto.
-- Esta vista quedará lista para cuando insertemos ventas mediante procedures.
-- =========================================================
CREATE OR ALTER VIEW vw_ventas_detalle AS
SELECT
    v.venta_id,
    v.fecha_venta,
    v.estado AS estado_venta,
    t.nombre AS tienda,
    t.ciudad,
    u.nombres + ' ' + u.apellidos AS vendedor,
    ISNULL(cl.nombres + ' ' + ISNULL(cl.apellidos, ''), 'Cliente no registrado') AS cliente,
    cl.tipo_documento,
    cl.numero_documento,
    p.codigo_sku,
    p.nombre AS producto,
    c.nombre AS categoria,
    vd.cantidad,
    vd.precio_unitario,
    vd.subtotal AS subtotal_detalle,
    v.subtotal AS subtotal_venta,
    v.igv,
    v.total
FROM Ventas v
INNER JOIN Tiendas t
    ON v.tienda_id = t.tienda_id
INNER JOIN Usuarios u
    ON v.usuario_id = u.usuario_id
LEFT JOIN Clientes cl
    ON v.cliente_id = cl.cliente_id
INNER JOIN VentaDetalle vd
    ON v.venta_id = vd.venta_id
INNER JOIN Productos p
    ON vd.producto_id = p.producto_id
INNER JOIN Categorias c
    ON p.categoria_id = c.categoria_id;
GO

-- =========================================================
-- VISTA: vw_resumen_ventas_tienda
-- Descripción:
-- Resume las ventas por tienda. Por ahora no mostrará datos hasta insertar ventas.
-- =========================================================
CREATE OR ALTER VIEW vw_resumen_ventas_tienda AS
SELECT
    t.tienda_id,
    t.nombre AS tienda,
    t.ciudad,
    COUNT(v.venta_id) AS cantidad_ventas,
    SUM(v.subtotal) AS subtotal_total,
    SUM(v.igv) AS igv_total,
    SUM(v.total) AS venta_total
FROM Tiendas t
LEFT JOIN Ventas v
    ON t.tienda_id = v.tienda_id
    AND v.estado = 'REGISTRADA'
GROUP BY
    t.tienda_id,
    t.nombre,
    t.ciudad;
GO