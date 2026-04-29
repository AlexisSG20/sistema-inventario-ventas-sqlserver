/*
    Proyecto: Sistema de Inventario y Ventas con SQL Server
    Archivo: consultas_reportes.sql
    Descripción:
    Consultas de reportes para análisis comercial, inventario,
    márgenes, ventas y movimientos.
*/

USE InventarioVentasDB;
GO

-- =========================================================
-- 1. Resumen de ventas por tienda
-- =========================================================
SELECT
    tienda,
    ciudad,
    cantidad_ventas,
    ISNULL(subtotal_total, 0) AS subtotal_total,
    ISNULL(igv_total, 0) AS igv_total,
    ISNULL(venta_total, 0) AS venta_total
FROM vw_resumen_ventas_tienda
ORDER BY venta_total DESC;
GO

-- =========================================================
-- 2. Ventas por estado
-- =========================================================
SELECT
    estado AS estado_venta,
    COUNT(*) AS cantidad_ventas,
    SUM(total) AS total_ventas
FROM Ventas
GROUP BY estado
ORDER BY cantidad_ventas DESC;
GO

-- =========================================================
-- 3. Productos vendidos por cantidad
-- =========================================================
SELECT
    p.codigo_sku,
    p.nombre AS producto,
    c.nombre AS categoria,
    SUM(vd.cantidad) AS unidades_vendidas,
    SUM(vd.subtotal) AS subtotal_vendido
FROM VentaDetalle vd
INNER JOIN Ventas v
    ON vd.venta_id = v.venta_id
INNER JOIN Productos p
    ON vd.producto_id = p.producto_id
INNER JOIN Categorias c
    ON p.categoria_id = c.categoria_id
WHERE v.estado = 'REGISTRADA'
GROUP BY
    p.codigo_sku,
    p.nombre,
    c.nombre
ORDER BY unidades_vendidas DESC;
GO

-- =========================================================
-- 4. Stock valorizado por tienda
-- =========================================================
SELECT
    t.nombre AS tienda,
    t.ciudad,
    SUM(s.cantidad * p.precio_compra) AS valor_stock_costo,
    SUM(s.cantidad * p.precio_venta) AS valor_stock_venta,
    SUM(s.cantidad * (p.precio_venta - p.precio_compra)) AS margen_potencial
FROM Stock s
INNER JOIN Productos p
    ON s.producto_id = p.producto_id
INNER JOIN Tiendas t
    ON s.tienda_id = t.tienda_id
GROUP BY
    t.nombre,
    t.ciudad
ORDER BY valor_stock_venta DESC;
GO

-- =========================================================
-- 5. Margen unitario y porcentaje de margen por producto
-- =========================================================
SELECT
    codigo_sku,
    nombre AS producto,
    precio_compra,
    precio_venta,
    dbo.fn_calcular_margen_unitario(precio_compra, precio_venta) AS margen_unitario,
    dbo.fn_calcular_porcentaje_margen(precio_compra, precio_venta) AS porcentaje_margen
FROM Productos
ORDER BY porcentaje_margen DESC;
GO

-- =========================================================
-- 6. Resumen de stock por categoría
-- =========================================================
SELECT
    categoria,
    COUNT(DISTINCT producto_id) AS cantidad_productos,
    SUM(stock_actual) AS stock_total,
    SUM(stock_actual * precio_compra) AS valor_costo_total,
    SUM(stock_actual * precio_venta) AS valor_venta_total
FROM vw_stock_productos
GROUP BY categoria
ORDER BY valor_venta_total DESC;
GO

-- =========================================================
-- 7. Productos con alerta de stock por tienda
-- =========================================================
SELECT
    tienda,
    ciudad,
    codigo_sku,
    producto,
    categoria,
    stock_actual,
    stock_minimo,
    estado_stock
FROM vw_stock_productos
WHERE estado_stock IN ('STOCK BAJO', 'SIN STOCK')
ORDER BY tienda, stock_actual ASC;
GO

-- =========================================================
-- 8. Movimientos de inventario por tipo
-- =========================================================
SELECT
    tipo_movimiento,
    COUNT(*) AS cantidad_movimientos,
    SUM(cantidad) AS unidades_movidas
FROM MovimientosInventario
GROUP BY tipo_movimiento
ORDER BY cantidad_movimientos DESC;
GO

-- =========================================================
-- 9. Movimientos de inventario por tienda
-- =========================================================
SELECT
    tienda,
    ciudad,
    tipo_movimiento,
    COUNT(*) AS cantidad_movimientos,
    SUM(cantidad) AS unidades_movidas
FROM vw_movimientos_inventario
GROUP BY
    tienda,
    ciudad,
    tipo_movimiento
ORDER BY tienda, tipo_movimiento;
GO

-- =========================================================
-- 10. Auditoría de cambios de stock por producto
-- =========================================================
SELECT
    p.codigo_sku,
    p.nombre AS producto,
    t.nombre AS tienda,
    COUNT(a.auditoria_id) AS cantidad_cambios,
    MIN(a.fecha_auditoria) AS primera_modificacion,
    MAX(a.fecha_auditoria) AS ultima_modificacion
FROM AuditoriaStock a
INNER JOIN Productos p
    ON a.producto_id = p.producto_id
INNER JOIN Tiendas t
    ON a.tienda_id = t.tienda_id
GROUP BY
    p.codigo_sku,
    p.nombre,
    t.nombre
ORDER BY cantidad_cambios DESC;
GO