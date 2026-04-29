/*
    Proyecto: Sistema de Inventario y Ventas con SQL Server
    Archivo: 05_functions.sql
    Descripción:
    Funciones escalares para cálculos reutilizables de negocio.
*/

USE InventarioVentasDB;
GO

-- =========================================================
-- FUNCTION: fn_calcular_margen_unitario
-- Descripción:
-- Calcula la diferencia entre precio de venta y precio de compra.
-- =========================================================
CREATE OR ALTER FUNCTION fn_calcular_margen_unitario
(
    @precio_compra DECIMAL(10,2),
    @precio_venta DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @margen DECIMAL(10,2);

    SET @margen = @precio_venta - @precio_compra;

    RETURN @margen;
END;
GO

-- =========================================================
-- FUNCTION: fn_calcular_porcentaje_margen
-- Descripción:
-- Calcula el porcentaje de margen sobre el precio de venta.
-- Fórmula:
-- ((precio_venta - precio_compra) / precio_venta) * 100
-- =========================================================
CREATE OR ALTER FUNCTION fn_calcular_porcentaje_margen
(
    @precio_compra DECIMAL(10,2),
    @precio_venta DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @porcentaje DECIMAL(10,2);

    IF @precio_venta <= 0
        SET @porcentaje = 0;
    ELSE
        SET @porcentaje = ((@precio_venta - @precio_compra) / @precio_venta) * 100;

    RETURN @porcentaje;
END;
GO

-- =========================================================
-- FUNCTION: fn_obtener_estado_stock
-- Descripción:
-- Devuelve el estado del stock según cantidad actual y stock mínimo.
-- =========================================================
CREATE OR ALTER FUNCTION fn_obtener_estado_stock
(
    @stock_actual INT,
    @stock_minimo INT
)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @estado VARCHAR(20);

    IF @stock_actual = 0
        SET @estado = 'SIN STOCK';
    ELSE IF @stock_actual <= @stock_minimo
        SET @estado = 'STOCK BAJO';
    ELSE
        SET @estado = 'STOCK OK';

    RETURN @estado;
END;
GO