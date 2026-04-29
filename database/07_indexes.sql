/*
    Proyecto: Sistema de Inventario y Ventas con SQL Server
    Archivo: 07_indexes.sql
    Descripción:
    Índices para mejorar consultas frecuentes de ventas, stock,
    productos y movimientos de inventario.
*/

USE InventarioVentasDB;
GO

-- =========================================================
-- ÍNDICE: Productos por SKU
-- Uso:
-- Búsquedas frecuentes de productos por código SKU.
-- =========================================================
IF NOT EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = 'IX_Productos_CodigoSKU'
      AND object_id = OBJECT_ID('Productos')
)
BEGIN
    CREATE INDEX IX_Productos_CodigoSKU
    ON Productos (codigo_sku);
END;
GO

-- =========================================================
-- ÍNDICE: Stock por producto y tienda
-- Uso:
-- Validación rápida de stock disponible por producto y tienda.
-- =========================================================
IF NOT EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = 'IX_Stock_Producto_Tienda'
      AND object_id = OBJECT_ID('Stock')
)
BEGIN
    CREATE INDEX IX_Stock_Producto_Tienda
    ON Stock (producto_id, tienda_id);
END;
GO

-- =========================================================
-- ÍNDICE: Ventas por fecha
-- Uso:
-- Reportes por rango de fechas.
-- =========================================================
IF NOT EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = 'IX_Ventas_FechaVenta'
      AND object_id = OBJECT_ID('Ventas')
)
BEGIN
    CREATE INDEX IX_Ventas_FechaVenta
    ON Ventas (fecha_venta);
END;
GO

-- =========================================================
-- ÍNDICE: Ventas por tienda y estado
-- Uso:
-- Reportes por tienda y ventas registradas/anuladas.
-- =========================================================
IF NOT EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = 'IX_Ventas_Tienda_Estado'
      AND object_id = OBJECT_ID('Ventas')
)
BEGIN
    CREATE INDEX IX_Ventas_Tienda_Estado
    ON Ventas (tienda_id, estado);
END;
GO

-- =========================================================
-- ÍNDICE: Detalle de venta por producto
-- Uso:
-- Análisis de productos vendidos.
-- =========================================================
IF NOT EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = 'IX_VentaDetalle_Producto'
      AND object_id = OBJECT_ID('VentaDetalle')
)
BEGIN
    CREATE INDEX IX_VentaDetalle_Producto
    ON VentaDetalle (producto_id);
END;
GO

-- =========================================================
-- ÍNDICE: Movimientos por producto, tienda y fecha
-- Uso:
-- Historial de entradas/salidas por producto y tienda.
-- =========================================================
IF NOT EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = 'IX_MovimientosInventario_Producto_Tienda_Fecha'
      AND object_id = OBJECT_ID('MovimientosInventario')
)
BEGIN
    CREATE INDEX IX_MovimientosInventario_Producto_Tienda_Fecha
    ON MovimientosInventario (producto_id, tienda_id, fecha_movimiento);
END;
GO

-- =========================================================
-- ÍNDICE: Clientes por documento
-- Uso:
-- Búsqueda rápida de clientes por tipo y número de documento.
-- =========================================================
IF NOT EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = 'IX_Clientes_Documento'
      AND object_id = OBJECT_ID('Clientes')
)
BEGIN
    CREATE INDEX IX_Clientes_Documento
    ON Clientes (tipo_documento, numero_documento);
END;
GO