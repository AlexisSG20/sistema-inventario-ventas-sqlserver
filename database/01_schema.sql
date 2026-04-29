/*
    Proyecto: Sistema de Inventario y Ventas con SQL Server
    Archivo: 01_schema.sql
    Descripción:
    Script de creación de la base de datos y tablas principales para un sistema
    empresarial de ventas e inventario.
*/

IF DB_ID('InventarioVentasDB') IS NOT NULL
BEGIN
    ALTER DATABASE InventarioVentasDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE InventarioVentasDB;
END;
GO

CREATE DATABASE InventarioVentasDB;
GO

USE InventarioVentasDB;
GO

-- =========================================================
-- TABLA: Categorias
-- =========================================================
CREATE TABLE Categorias (
    categoria_id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL,
    estado BIT NOT NULL DEFAULT 1,
    fecha_creacion DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

-- =========================================================
-- TABLA: Proveedores
-- =========================================================
CREATE TABLE Proveedores (
    proveedor_id INT IDENTITY(1,1) PRIMARY KEY,
    razon_social VARCHAR(150) NOT NULL,
    ruc CHAR(11) NOT NULL UNIQUE,
    telefono VARCHAR(20) NULL,
    email VARCHAR(120) NULL,
    direccion VARCHAR(255) NULL,
    estado BIT NOT NULL DEFAULT 1,
    fecha_creacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT CK_Proveedores_RUC CHECK (LEN(ruc) = 11)
);
GO

-- =========================================================
-- TABLA: Productos
-- =========================================================
CREATE TABLE Productos (
    producto_id INT IDENTITY(1,1) PRIMARY KEY,
    categoria_id INT NOT NULL,
    proveedor_id INT NULL,
    codigo_sku VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    descripcion VARCHAR(255) NULL,
    precio_compra DECIMAL(10,2) NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    stock_minimo INT NOT NULL DEFAULT 5,
    estado BIT NOT NULL DEFAULT 1,
    fecha_creacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Productos_Categorias 
        FOREIGN KEY (categoria_id) REFERENCES Categorias(categoria_id),

    CONSTRAINT FK_Productos_Proveedores 
        FOREIGN KEY (proveedor_id) REFERENCES Proveedores(proveedor_id),

    CONSTRAINT CK_Productos_PrecioCompra CHECK (precio_compra >= 0),
    CONSTRAINT CK_Productos_PrecioVenta CHECK (precio_venta >= 0),
    CONSTRAINT CK_Productos_StockMinimo CHECK (stock_minimo >= 0)
);
GO

-- =========================================================
-- TABLA: Clientes
-- =========================================================
CREATE TABLE Clientes (
    cliente_id INT IDENTITY(1,1) PRIMARY KEY,
    tipo_documento VARCHAR(10) NOT NULL,
    numero_documento VARCHAR(20) NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NULL,
    telefono VARCHAR(20) NULL,
    email VARCHAR(120) NULL,
    direccion VARCHAR(255) NULL,
    estado BIT NOT NULL DEFAULT 1,
    fecha_registro DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT UQ_Clientes_Documento UNIQUE (tipo_documento, numero_documento),
    CONSTRAINT CK_Clientes_TipoDocumento CHECK (tipo_documento IN ('DNI', 'CE', 'RUC'))
);
GO

-- =========================================================
-- TABLA: Tiendas
-- =========================================================
CREATE TABLE Tiendas (
    tienda_id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    ciudad VARCHAR(80) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    telefono VARCHAR(20) NULL,
    estado BIT NOT NULL DEFAULT 1,
    fecha_creacion DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

-- =========================================================
-- TABLA: Usuarios
-- =========================================================
CREATE TABLE Usuarios (
    usuario_id INT IDENTITY(1,1) PRIMARY KEY,
    tienda_id INT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    rol VARCHAR(30) NOT NULL,
    estado BIT NOT NULL DEFAULT 1,
    fecha_creacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Usuarios_Tiendas 
        FOREIGN KEY (tienda_id) REFERENCES Tiendas(tienda_id),

    CONSTRAINT CK_Usuarios_Rol CHECK (rol IN ('ADMIN', 'VENDEDOR', 'ALMACEN'))
);
GO

-- =========================================================
-- TABLA: Stock
-- =========================================================
CREATE TABLE Stock (
    stock_id INT IDENTITY(1,1) PRIMARY KEY,
    producto_id INT NOT NULL,
    tienda_id INT NOT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    fecha_actualizacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Stock_Productos 
        FOREIGN KEY (producto_id) REFERENCES Productos(producto_id),

    CONSTRAINT FK_Stock_Tiendas 
        FOREIGN KEY (tienda_id) REFERENCES Tiendas(tienda_id),

    CONSTRAINT UQ_Stock_Producto_Tienda UNIQUE (producto_id, tienda_id),
    CONSTRAINT CK_Stock_Cantidad CHECK (cantidad >= 0)
);
GO

-- =========================================================
-- TABLA: Ventas
-- =========================================================
CREATE TABLE Ventas (
    venta_id INT IDENTITY(1,1) PRIMARY KEY,
    cliente_id INT NULL,
    tienda_id INT NOT NULL,
    usuario_id INT NOT NULL,
    fecha_venta DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    estado VARCHAR(20) NOT NULL DEFAULT 'REGISTRADA',
    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
    igv DECIMAL(10,2) NOT NULL DEFAULT 0,
    total DECIMAL(10,2) NOT NULL DEFAULT 0,

    CONSTRAINT FK_Ventas_Clientes 
        FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id),

    CONSTRAINT FK_Ventas_Tiendas 
        FOREIGN KEY (tienda_id) REFERENCES Tiendas(tienda_id),

    CONSTRAINT FK_Ventas_Usuarios 
        FOREIGN KEY (usuario_id) REFERENCES Usuarios(usuario_id),

    CONSTRAINT CK_Ventas_Estado CHECK (estado IN ('REGISTRADA', 'ANULADA')),
    CONSTRAINT CK_Ventas_Subtotal CHECK (subtotal >= 0),
    CONSTRAINT CK_Ventas_IGV CHECK (igv >= 0),
    CONSTRAINT CK_Ventas_Total CHECK (total >= 0)
);
GO

-- =========================================================
-- TABLA: VentaDetalle
-- =========================================================
CREATE TABLE VentaDetalle (
    venta_detalle_id INT IDENTITY(1,1) PRIMARY KEY,
    venta_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_VentaDetalle_Ventas 
        FOREIGN KEY (venta_id) REFERENCES Ventas(venta_id),

    CONSTRAINT FK_VentaDetalle_Productos 
        FOREIGN KEY (producto_id) REFERENCES Productos(producto_id),

    CONSTRAINT CK_VentaDetalle_Cantidad CHECK (cantidad > 0),
    CONSTRAINT CK_VentaDetalle_PrecioUnitario CHECK (precio_unitario >= 0),
    CONSTRAINT CK_VentaDetalle_Subtotal CHECK (subtotal >= 0)
);
GO

-- =========================================================
-- TABLA: MovimientosInventario
-- =========================================================
CREATE TABLE MovimientosInventario (
    movimiento_id INT IDENTITY(1,1) PRIMARY KEY,
    producto_id INT NOT NULL,
    tienda_id INT NOT NULL,
    usuario_id INT NOT NULL,
    tipo_movimiento VARCHAR(20) NOT NULL,
    cantidad INT NOT NULL,
    motivo VARCHAR(255) NOT NULL,
    referencia VARCHAR(100) NULL,
    fecha_movimiento DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_MovimientosInventario_Productos 
        FOREIGN KEY (producto_id) REFERENCES Productos(producto_id),

    CONSTRAINT FK_MovimientosInventario_Tiendas 
        FOREIGN KEY (tienda_id) REFERENCES Tiendas(tienda_id),

    CONSTRAINT FK_MovimientosInventario_Usuarios 
        FOREIGN KEY (usuario_id) REFERENCES Usuarios(usuario_id),

    CONSTRAINT CK_MovimientosInventario_Tipo CHECK (tipo_movimiento IN ('ENTRADA', 'SALIDA', 'AJUSTE')),
    CONSTRAINT CK_MovimientosInventario_Cantidad CHECK (cantidad > 0)
);
GO

-- =========================================================
-- TABLA: AuditoriaStock
-- =========================================================
CREATE TABLE AuditoriaStock (
    auditoria_id INT IDENTITY(1,1) PRIMARY KEY,
    stock_id INT NOT NULL,
    producto_id INT NOT NULL,
    tienda_id INT NOT NULL,
    cantidad_anterior INT NOT NULL,
    cantidad_nueva INT NOT NULL,
    accion VARCHAR(20) NOT NULL,
    fecha_auditoria DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO