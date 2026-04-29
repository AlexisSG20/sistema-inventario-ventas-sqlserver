/*
    Proyecto: Sistema de Inventario y Ventas con SQL Server
    Archivo: 02_seed.sql
    Descripción:
    Inserción de datos iniciales para simular una empresa retail con productos,
    clientes, tiendas, usuarios y stock inicial.
*/

USE InventarioVentasDB;
GO

-- =========================================================
-- CATEGORÍAS
-- =========================================================
INSERT INTO Categorias (nombre, descripcion)
VALUES
('Laptops', 'Computadoras portátiles para uso personal y empresarial'),
('Componentes', 'Partes internas para computadoras y equipos de escritorio'),
('Periféricos', 'Accesorios como teclados, mouse, audífonos y cámaras'),
('Monitores', 'Pantallas para oficina, gaming y diseño'),
('Almacenamiento', 'Discos duros, SSD y memorias externas');
GO

-- =========================================================
-- PROVEEDORES
-- =========================================================
INSERT INTO Proveedores (razon_social, ruc, telefono, email, direccion)
VALUES
('Tech Import Perú S.A.C.', '20601234561', '987654321', 'ventas@techimport.pe', 'Av. Argentina 1200, Lima'),
('Distribuidora Andina Digital S.R.L.', '20509876542', '976543210', 'contacto@andinadigital.pe', 'Jr. Arequipa 450, Huancayo'),
('Soluciones Hardware Global S.A.C.', '20456789123', '965432109', 'comercial@hardwareglobal.pe', 'Av. La Marina 980, Lima');
GO

-- =========================================================
-- TIENDAS
-- =========================================================
INSERT INTO Tiendas (nombre, ciudad, direccion, telefono)
VALUES
('Tienda Central Lima', 'Lima', 'Av. Garcilaso de la Vega 1200', '014567890'),
('Sucursal Huancayo', 'Huancayo', 'Av. Real 850', '064345678'),
('Sucursal Arequipa', 'Arequipa', 'Calle Mercaderes 320', '054234567');
GO

-- =========================================================
-- USUARIOS
-- =========================================================
INSERT INTO Usuarios (tienda_id, nombres, apellidos, email, rol)
VALUES
(1, 'Carlos', 'Ramírez Torres', 'carlos.ramirez@empresa.pe', 'ADMIN'),
(1, 'María', 'Fernández López', 'maria.fernandez@empresa.pe', 'VENDEDOR'),
(2, 'Luis', 'Quispe Huamán', 'luis.quispe@empresa.pe', 'VENDEDOR'),
(2, 'Ana', 'Salazar Rojas', 'ana.salazar@empresa.pe', 'ALMACEN'),
(3, 'Jorge', 'Mamani Flores', 'jorge.mamani@empresa.pe', 'VENDEDOR');
GO

-- =========================================================
-- CLIENTES
-- =========================================================
INSERT INTO Clientes (tipo_documento, numero_documento, nombres, apellidos, telefono, email, direccion)
VALUES
('DNI', '71234567', 'Andrea', 'Paredes Molina', '987111222', 'andrea.paredes@gmail.com', 'Lima'),
('DNI', '73456789', 'Miguel', 'Torres Salinas', '987222333', 'miguel.torres@gmail.com', 'Huancayo'),
('DNI', '75678912', 'Lucía', 'Vargas Ríos', '987333444', 'lucia.vargas@gmail.com', 'Arequipa'),
('CE', 'CE123456', 'Renato', 'Gómez Silva', '987444555', 'renato.gomez@gmail.com', 'Lima'),
('RUC', '10456789123', 'Inversiones Norte', NULL, '987555666', 'contacto@inversionesnorte.pe', 'Trujillo');
GO

-- =========================================================
-- PRODUCTOS
-- =========================================================
INSERT INTO Productos 
(categoria_id, proveedor_id, codigo_sku, nombre, descripcion, precio_compra, precio_venta, stock_minimo)
VALUES
(1, 1, 'LAP-LEN-001', 'Laptop Lenovo IdeaPad 15', 'Laptop Core i5, 8GB RAM, 512GB SSD', 2100.00, 2799.00, 3),
(1, 1, 'LAP-HP-002', 'Laptop HP Pavilion 14', 'Laptop Core i5, 16GB RAM, 512GB SSD', 2400.00, 3199.00, 3),
(2, 3, 'COM-RAM-001', 'Memoria RAM 16GB DDR4', 'Módulo de memoria RAM para laptop o PC', 120.00, 189.00, 10),
(2, 3, 'COM-MB-001', 'Placa Madre B550', 'Placa madre compatible con procesadores AMD Ryzen', 390.00, 559.00, 4),
(3, 2, 'PER-TEC-001', 'Teclado Mecánico RGB', 'Teclado mecánico con iluminación RGB', 95.00, 169.00, 8),
(3, 2, 'PER-MOU-001', 'Mouse Gamer 7200 DPI', 'Mouse óptico gamer con botones programables', 45.00, 89.00, 10),
(4, 1, 'MON-LG-001', 'Monitor LG 24 pulgadas', 'Monitor Full HD IPS para oficina', 430.00, 699.00, 5),
(4, 1, 'MON-SAM-002', 'Monitor Samsung 27 pulgadas', 'Monitor curvo Full HD para productividad', 620.00, 949.00, 4),
(5, 3, 'ALM-SSD-001', 'SSD Kingston 1TB', 'Unidad de estado sólido 1TB SATA', 210.00, 329.00, 8),
(5, 3, 'ALM-HDD-001', 'Disco Duro Externo 2TB', 'Disco duro externo USB 3.0', 230.00, 359.00, 6);
GO

-- =========================================================
-- STOCK INICIAL POR TIENDA
-- =========================================================
INSERT INTO Stock (producto_id, tienda_id, cantidad)
VALUES
(1, 1, 8),  (1, 2, 4),  (1, 3, 3),
(2, 1, 6),  (2, 2, 3),  (2, 3, 2),
(3, 1, 25), (3, 2, 18), (3, 3, 15),
(4, 1, 10), (4, 2, 5),  (4, 3, 4),
(5, 1, 20), (5, 2, 16), (5, 3, 12),
(6, 1, 30), (6, 2, 22), (6, 3, 18),
(7, 1, 12), (7, 2, 7),  (7, 3, 5),
(8, 1, 9),  (8, 2, 5),  (8, 3, 4),
(9, 1, 18), (9, 2, 14), (9, 3, 10),
(10, 1, 15), (10, 2, 10), (10, 3, 8);
GO

-- =========================================================
-- MOVIMIENTOS INICIALES DE INVENTARIO
-- =========================================================
INSERT INTO MovimientosInventario 
(producto_id, tienda_id, usuario_id, tipo_movimiento, cantidad, motivo, referencia)
VALUES
(1, 1, 4, 'ENTRADA', 8, 'Carga inicial de inventario', 'INI-001'),
(1, 2, 4, 'ENTRADA', 4, 'Carga inicial de inventario', 'INI-002'),
(2, 1, 4, 'ENTRADA', 6, 'Carga inicial de inventario', 'INI-003'),
(3, 1, 4, 'ENTRADA', 25, 'Carga inicial de inventario', 'INI-004'),
(5, 2, 4, 'ENTRADA', 16, 'Carga inicial de inventario', 'INI-005'),
(9, 3, 4, 'ENTRADA', 10, 'Carga inicial de inventario', 'INI-006');
GO