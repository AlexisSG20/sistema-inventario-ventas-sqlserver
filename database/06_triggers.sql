/*
    Proyecto: Sistema de Inventario y Ventas con SQL Server
    Archivo: 06_triggers.sql
    Descripción:
    Triggers para auditoría automática de cambios en el stock.
*/

USE InventarioVentasDB;
GO

-- =========================================================
-- TRIGGER: trg_auditar_cambios_stock
-- Descripción:
-- Registra automáticamente los cambios de cantidad en la tabla Stock
-- cuando se actualiza el stock de un producto en una tienda.
-- =========================================================
CREATE OR ALTER TRIGGER trg_auditar_cambios_stock
ON Stock
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO AuditoriaStock
    (
        stock_id,
        producto_id,
        tienda_id,
        cantidad_anterior,
        cantidad_nueva,
        accion
    )
    SELECT
        i.stock_id,
        i.producto_id,
        i.tienda_id,
        d.cantidad AS cantidad_anterior,
        i.cantidad AS cantidad_nueva,
        'UPDATE' AS accion
    FROM inserted i
    INNER JOIN deleted d
        ON i.stock_id = d.stock_id
    WHERE i.cantidad <> d.cantidad;
END;
GO