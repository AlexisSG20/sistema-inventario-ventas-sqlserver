/*
    Proyecto: Sistema de Inventario y Ventas con SQL Server
    Archivo: consultas_operativas.sql
    Descripción:
    Consultas operativas para revisión diaria de stock, productos,
    clientes, ventas y movimientos de inventario.
*/

USE InventarioVentasDB;
GO

-- =========================================================
-- 1. Consultar stock actual por tienda y producto
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
ORDER BY tienda, producto;
GO

-- =========================================================
-- 2. Consultar productos con stock bajo o sin stock
-- =========================================================
SELECT
    tienda,
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
-- 3. Buscar cliente por documento
-- =========================================================
SELECT
    cliente_id,
    tipo_documento,
    numero_documento,
    nombres,
    apellidos,
    telefono,
    email,
    estado
FROM Clientes
WHERE tipo_documento = 'DNI'
  AND numero_documento = '73456789';
GO

-- =========================================================
-- 4. Consultar movimientos recientes de inventario
-- =========================================================
SELECT TOP 20
    fecha_movimiento,
    tipo_movimiento,
    cantidad,
    motivo,
    referencia,
    tienda,
    codigo_sku,
    producto,
    usuario_responsable
FROM vw_movimientos_inventario
ORDER BY fecha_movimiento DESC;
GO

-- =========================================================
-- 5. Consultar historial de movimientos de un producto en una tienda
-- =========================================================
SELECT
    fecha_movimiento,
    tipo_movimiento,
    cantidad,
    motivo,
    referencia,
    tienda,
    codigo_sku,
    producto,
    usuario_responsable
FROM vw_movimientos_inventario
WHERE codigo_sku = 'PER-TEC-001'
  AND tienda = 'Sucursal Huancayo'
ORDER BY fecha_movimiento DESC;
GO

-- =========================================================
-- 6. Consultar ventas registradas y anuladas
-- =========================================================
SELECT
    venta_id,
    fecha_venta,
    estado_venta,
    tienda,
    vendedor,
    cliente,
    codigo_sku,
    producto,
    cantidad,
    precio_unitario,
    subtotal_detalle,
    igv,
    total
FROM vw_ventas_detalle
ORDER BY fecha_venta DESC;
GO

-- =========================================================
-- 7. Consultar ventas anuladas
-- =========================================================
SELECT
    venta_id,
    fecha_venta,
    estado_venta,
    tienda,
    vendedor,
    cliente,
    producto,
    cantidad,
    total
FROM vw_ventas_detalle
WHERE estado_venta = 'ANULADA'
ORDER BY fecha_venta DESC;
GO

-- =========================================================
-- 8. Consultar auditoría de cambios de stock
-- =========================================================
SELECT TOP 20
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
GO