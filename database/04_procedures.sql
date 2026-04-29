/*
    Proyecto: Sistema de Inventario y Ventas con SQL Server
    Archivo: 04_procedures.sql
    Descripción:
    Procedimientos almacenados para operaciones de negocio:
    movimientos de inventario, registro de ventas y anulación de ventas.
*/

USE InventarioVentasDB;
GO

-- =========================================================
-- PROCEDURE: sp_registrar_movimiento_inventario
-- Descripción:
-- Registra un movimiento de inventario y actualiza el stock del producto
-- en una tienda específica.
--
-- Tipos permitidos:
-- ENTRADA: aumenta stock
-- SALIDA : disminuye stock
-- AJUSTE : reemplaza el stock actual por una nueva cantidad
-- =========================================================
CREATE OR ALTER PROCEDURE sp_registrar_movimiento_inventario
    @producto_id INT,
    @tienda_id INT,
    @usuario_id INT,
    @tipo_movimiento VARCHAR(20),
    @cantidad INT,
    @motivo VARCHAR(255),
    @referencia VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @stock_actual INT;
    DECLARE @stock_nuevo INT;

    -- Validar tipo de movimiento
    IF @tipo_movimiento NOT IN ('ENTRADA', 'SALIDA', 'AJUSTE')
    BEGIN
        RAISERROR('Tipo de movimiento inválido. Use ENTRADA, SALIDA o AJUSTE.', 16, 1);
        RETURN;
    END;

    -- Validar cantidad
    IF @cantidad <= 0
    BEGIN
        RAISERROR('La cantidad debe ser mayor a cero.', 16, 1);
        RETURN;
    END;

    -- Validar existencia del producto
    IF NOT EXISTS (SELECT 1 FROM Productos WHERE producto_id = @producto_id AND estado = 1)
    BEGIN
        RAISERROR('El producto no existe o está inactivo.', 16, 1);
        RETURN;
    END;

    -- Validar existencia de la tienda
    IF NOT EXISTS (SELECT 1 FROM Tiendas WHERE tienda_id = @tienda_id AND estado = 1)
    BEGIN
        RAISERROR('La tienda no existe o está inactiva.', 16, 1);
        RETURN;
    END;

    -- Validar existencia del usuario
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE usuario_id = @usuario_id AND estado = 1)
    BEGIN
        RAISERROR('El usuario no existe o está inactivo.', 16, 1);
        RETURN;
    END;

    -- Obtener stock actual
    SELECT @stock_actual = cantidad
    FROM Stock
    WHERE producto_id = @producto_id
      AND tienda_id = @tienda_id;

    -- Si no existe stock para ese producto/tienda, se crea con cero
    IF @stock_actual IS NULL
    BEGIN
        INSERT INTO Stock (producto_id, tienda_id, cantidad)
        VALUES (@producto_id, @tienda_id, 0);

        SET @stock_actual = 0;
    END;

    -- Calcular nuevo stock
    IF @tipo_movimiento = 'ENTRADA'
        SET @stock_nuevo = @stock_actual + @cantidad;

    IF @tipo_movimiento = 'SALIDA'
        SET @stock_nuevo = @stock_actual - @cantidad;

    IF @tipo_movimiento = 'AJUSTE'
        SET @stock_nuevo = @cantidad;

    -- Validar que el stock no quede negativo
    IF @stock_nuevo < 0
    BEGIN
        RAISERROR('No se puede realizar el movimiento porque el stock quedaría negativo.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Actualizar stock
        UPDATE Stock
        SET 
            cantidad = @stock_nuevo,
            fecha_actualizacion = SYSDATETIME()
        WHERE producto_id = @producto_id
          AND tienda_id = @tienda_id;

        -- Registrar movimiento
        INSERT INTO MovimientosInventario
        (
            producto_id,
            tienda_id,
            usuario_id,
            tipo_movimiento,
            cantidad,
            motivo,
            referencia
        )
        VALUES
        (
            @producto_id,
            @tienda_id,
            @usuario_id,
            @tipo_movimiento,
            @cantidad,
            @motivo,
            @referencia
        );

        COMMIT TRANSACTION;

        SELECT 
            'Movimiento registrado correctamente' AS mensaje,
            @producto_id AS producto_id,
            @tienda_id AS tienda_id,
            @tipo_movimiento AS tipo_movimiento,
            @stock_actual AS stock_anterior,
            @stock_nuevo AS stock_nuevo;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @mensaje_error NVARCHAR(4000);
        SET @mensaje_error = ERROR_MESSAGE();

        RAISERROR(@mensaje_error, 16, 1);
    END CATCH;
END;
GO

-- =========================================================
-- PROCEDURE: sp_registrar_venta
-- Descripción:
-- Registra una venta de un solo producto, valida stock disponible,
-- calcula subtotal, IGV y total, descuenta stock y registra el movimiento
-- de inventario asociado.
-- =========================================================
CREATE OR ALTER PROCEDURE sp_registrar_venta
    @cliente_id INT = NULL,
    @tienda_id INT,
    @usuario_id INT,
    @producto_id INT,
    @cantidad INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @precio_unitario DECIMAL(10,2);
    DECLARE @subtotal DECIMAL(10,2);
    DECLARE @igv DECIMAL(10,2);
    DECLARE @total DECIMAL(10,2);
    DECLARE @stock_actual INT;
    DECLARE @venta_id INT;

    -- Validar cantidad
    IF @cantidad <= 0
    BEGIN
        RAISERROR('La cantidad vendida debe ser mayor a cero.', 16, 1);
        RETURN;
    END;

    -- Validar cliente si fue enviado
    IF @cliente_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM Clientes WHERE cliente_id = @cliente_id AND estado = 1)
    BEGIN
        RAISERROR('El cliente no existe o está inactivo.', 16, 1);
        RETURN;
    END;

    -- Validar tienda
    IF NOT EXISTS (SELECT 1 FROM Tiendas WHERE tienda_id = @tienda_id AND estado = 1)
    BEGIN
        RAISERROR('La tienda no existe o está inactiva.', 16, 1);
        RETURN;
    END;

    -- Validar usuario
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE usuario_id = @usuario_id AND estado = 1)
    BEGIN
        RAISERROR('El usuario no existe o está inactivo.', 16, 1);
        RETURN;
    END;

    -- Validar producto y obtener precio
    SELECT @precio_unitario = precio_venta
    FROM Productos
    WHERE producto_id = @producto_id
      AND estado = 1;

    IF @precio_unitario IS NULL
    BEGIN
        RAISERROR('El producto no existe o está inactivo.', 16, 1);
        RETURN;
    END;

    -- Obtener stock actual
    SELECT @stock_actual = cantidad
    FROM Stock
    WHERE producto_id = @producto_id
      AND tienda_id = @tienda_id;

    IF @stock_actual IS NULL
    BEGIN
        RAISERROR('No existe stock registrado para este producto en esta tienda.', 16, 1);
        RETURN;
    END;

    -- Validar stock suficiente
    IF @stock_actual < @cantidad
    BEGIN
        RAISERROR('Stock insuficiente para registrar la venta.', 16, 1);
        RETURN;
    END;

    -- Calcular importes
    SET @subtotal = @precio_unitario * @cantidad;
    SET @igv = ROUND(@subtotal * 0.18, 2);
    SET @total = @subtotal + @igv;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insertar cabecera de venta
        INSERT INTO Ventas
        (
            cliente_id,
            tienda_id,
            usuario_id,
            subtotal,
            igv,
            total
        )
        VALUES
        (
            @cliente_id,
            @tienda_id,
            @usuario_id,
            @subtotal,
            @igv,
            @total
        );

        SET @venta_id = SCOPE_IDENTITY();

        -- Insertar detalle de venta
        INSERT INTO VentaDetalle
        (
            venta_id,
            producto_id,
            cantidad,
            precio_unitario,
            subtotal
        )
        VALUES
        (
            @venta_id,
            @producto_id,
            @cantidad,
            @precio_unitario,
            @subtotal
        );

        -- Descontar stock
        UPDATE Stock
        SET 
            cantidad = cantidad - @cantidad,
            fecha_actualizacion = SYSDATETIME()
        WHERE producto_id = @producto_id
          AND tienda_id = @tienda_id;

        -- Registrar movimiento de inventario por venta
        INSERT INTO MovimientosInventario
        (
            producto_id,
            tienda_id,
            usuario_id,
            tipo_movimiento,
            cantidad,
            motivo,
            referencia
        )
        VALUES
        (
            @producto_id,
            @tienda_id,
            @usuario_id,
            'SALIDA',
            @cantidad,
            'Salida por venta registrada',
            CONCAT('VENTA-', @venta_id)
        );

        COMMIT TRANSACTION;

        SELECT 
            'Venta registrada correctamente' AS mensaje,
            @venta_id AS venta_id,
            @producto_id AS producto_id,
            @cantidad AS cantidad,
            @precio_unitario AS precio_unitario,
            @subtotal AS subtotal,
            @igv AS igv,
            @total AS total;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @mensaje_error NVARCHAR(4000);
        SET @mensaje_error = ERROR_MESSAGE();

        RAISERROR(@mensaje_error, 16, 1);
    END CATCH;
END;
GO

-- =========================================================
-- PROCEDURE: sp_anular_venta
-- Descripción:
-- Anula una venta registrada, devuelve el stock de los productos vendidos
-- y registra movimientos de inventario tipo ENTRADA por la anulación.
-- =========================================================
CREATE OR ALTER PROCEDURE sp_anular_venta
    @venta_id INT,
    @usuario_id INT,
    @motivo VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @estado_venta VARCHAR(20);
    DECLARE @tienda_id INT;

    -- Validar venta
    SELECT 
        @estado_venta = estado,
        @tienda_id = tienda_id
    FROM Ventas
    WHERE venta_id = @venta_id;

    IF @estado_venta IS NULL
    BEGIN
        RAISERROR('La venta no existe.', 16, 1);
        RETURN;
    END;

    IF @estado_venta = 'ANULADA'
    BEGIN
        RAISERROR('La venta ya se encuentra anulada.', 16, 1);
        RETURN;
    END;

    -- Validar usuario
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE usuario_id = @usuario_id AND estado = 1)
    BEGIN
        RAISERROR('El usuario no existe o está inactivo.', 16, 1);
        RETURN;
    END;

    -- Validar motivo
    IF LTRIM(RTRIM(ISNULL(@motivo, ''))) = ''
    BEGIN
        RAISERROR('Debe ingresar un motivo para anular la venta.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Cambiar estado de la venta
        UPDATE Ventas
        SET estado = 'ANULADA'
        WHERE venta_id = @venta_id;

        -- Devolver stock por cada producto vendido
        UPDATE s
        SET 
            s.cantidad = s.cantidad + vd.cantidad,
            s.fecha_actualizacion = SYSDATETIME()
        FROM Stock s
        INNER JOIN VentaDetalle vd
            ON s.producto_id = vd.producto_id
        WHERE vd.venta_id = @venta_id
          AND s.tienda_id = @tienda_id;

        -- Registrar movimientos de inventario por devolución de stock
        INSERT INTO MovimientosInventario
        (
            producto_id,
            tienda_id,
            usuario_id,
            tipo_movimiento,
            cantidad,
            motivo,
            referencia
        )
        SELECT
            vd.producto_id,
            @tienda_id,
            @usuario_id,
            'ENTRADA',
            vd.cantidad,
            CONCAT('Anulación de venta: ', @motivo),
            CONCAT('ANULACION-VENTA-', @venta_id)
        FROM VentaDetalle vd
        WHERE vd.venta_id = @venta_id;

        COMMIT TRANSACTION;

        SELECT 
            'Venta anulada correctamente' AS mensaje,
            @venta_id AS venta_id,
            @tienda_id AS tienda_id,
            @motivo AS motivo;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @mensaje_error NVARCHAR(4000);
        SET @mensaje_error = ERROR_MESSAGE();

        RAISERROR(@mensaje_error, 16, 1);
    END CATCH;
END;
GO