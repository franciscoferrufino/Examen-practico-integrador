/* ============================================================================
   UNIVERSIDAD AMERICANA (UAM) - INGENIERÍA DE SISTEMAS
   SERVICIOS WEB - EXAMEN PRÁCTICO INTEGRADOR (SEGUNDO CORTE)
   Caso: Sistema de préstamo de equipos tecnológicos para TecnoUAM
   Motor: Microsoft SQL Server (T-SQL)
   Archivo: database/init-tecnouam.sql
   ============================================================================ */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Crear la base de datos TecnoUAM si no existe
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'TecnoUAM')
BEGIN
    CREATE DATABASE [TecnoUAM];
    PRINT 'Base de datos [TecnoUAM] creada exitosamente.';
END
ELSE
BEGIN
    PRINT 'La base de datos [TecnoUAM] ya existe.';
END
GO

USE [TecnoUAM];
GO

-- 2. Crear login y usuario de aplicación para conexión JDBC desde Spring Boot
USE [master];
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = N'tecnouam_user')
BEGIN
    CREATE LOGIN [tecnouam_user] WITH PASSWORD = N'TecnoUAM_2026!', DEFAULT_DATABASE = [TecnoUAM], CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF;
    PRINT 'Login [tecnouam_user] creado.';
END
ELSE
BEGIN
    ALTER LOGIN [tecnouam_user] WITH PASSWORD = N'TecnoUAM_2026!', CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF;
    ALTER LOGIN [tecnouam_user] ENABLE;
    PRINT 'Login [tecnouam_user] actualizado y habilitado.';
END
GO

USE [TecnoUAM];
GO

IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = N'tecnouam_user')
BEGIN
    CREATE USER [tecnouam_user] FOR LOGIN [tecnouam_user];
END
ALTER ROLE [db_owner] ADD MEMBER [tecnouam_user];
GO

-- 3. Tabla de Usuarios (Seguridad Spring Security + JWT + BCrypt)
IF OBJECT_ID(N'dbo.usuarios', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.usuarios (
        id BIGINT IDENTITY(1,1) NOT NULL,
        username NVARCHAR(60) NOT NULL,
        password NVARCHAR(255) NOT NULL,
        nombre_completo NVARCHAR(120) NOT NULL,
        rol NVARCHAR(20) NOT NULL,
        CONSTRAINT PK_usuarios PRIMARY KEY (id),
        CONSTRAINT UQ_usuarios_username UNIQUE (username),
        CONSTRAINT CK_usuarios_rol CHECK (rol IN (N'ADMIN', N'USER'))
    );
    PRINT 'Tabla [dbo.usuarios] creada.';
END
GO

-- 4. Tabla de Equipos Tecnológicos
IF OBJECT_ID(N'dbo.equipos', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.equipos (
        id BIGINT IDENTITY(1,1) NOT NULL,
        codigo_patrimonial NVARCHAR(50) NOT NULL,
        nombre NVARCHAR(150) NOT NULL,
        tipo NVARCHAR(50) NOT NULL,
        estado NVARCHAR(20) NOT NULL,
        CONSTRAINT PK_equipos PRIMARY KEY (id),
        CONSTRAINT UQ_equipos_codigo_patrimonial UNIQUE (codigo_patrimonial),
        CONSTRAINT CK_equipos_tipo CHECK (tipo IN (N'Computadora portátil', N'Proyector', N'Tableta')),
        CONSTRAINT CK_equipos_estado CHECK (estado IN (N'DISPONIBLE', N'PRESTADO'))
    );
    PRINT 'Tabla [dbo.equipos] creada.';
END
GO

-- 5. Tabla de Préstamos de Equipos
IF OBJECT_ID(N'dbo.prestamos', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.prestamos (
        id BIGINT IDENTITY(1,1) NOT NULL,
        equipo_id BIGINT NOT NULL,
        nombre_solicitante NVARCHAR(150) NOT NULL,
        fecha_prestamo DATE NOT NULL,
        fecha_devolucion_prevista DATE NOT NULL,
        fecha_devolucion_real DATE NULL,
        estado NVARCHAR(20) NOT NULL,
        CONSTRAINT PK_prestamos PRIMARY KEY (id),
        CONSTRAINT FK_prestamos_equipo FOREIGN KEY (equipo_id) REFERENCES dbo.equipos (id),
        CONSTRAINT CK_prestamos_estado CHECK (estado IN (N'ACTIVO', N'DEVUELTO')),
        CONSTRAINT CK_prestamos_fechas CHECK (fecha_devolucion_prevista >= fecha_prestamo)
    );
    PRINT 'Tabla [dbo.prestamos] creada.';
END
GO

-- 6. Índice único filtrado para impedir a nivel de motor dos préstamos ACTIVOS del mismo equipo
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'UX_prestamos_equipo_activo' AND object_id = OBJECT_ID(N'dbo.prestamos'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_prestamos_equipo_activo
    ON dbo.prestamos (equipo_id)
    WHERE estado = N'ACTIVO';
    PRINT 'Índice único filtrado [UX_prestamos_equipo_activo] creado.';
END
GO

-- 7. Datos iniciales reproducibles (Equipos y Préstamos iniciales)
IF NOT EXISTS (SELECT 1 FROM dbo.equipos WHERE codigo_patrimonial = N'UAM-LAP-001')
BEGIN
    INSERT INTO dbo.equipos (codigo_patrimonial, nombre, tipo, estado) VALUES
    (N'UAM-LAP-001', N'Laptop Dell Latitude 5540 Core i7', N'Computadora portátil', N'DISPONIBLE'),
    (N'UAM-LAP-002', N'MacBook Air M2 13 Pulgadas', N'Computadora portátil', N'PRESTADO'),
    (N'UAM-PRO-001', N'Proyector Epson PowerLite E20 3400L', N'Proyector', N'DISPONIBLE'),
    (N'UAM-PRO-002', N'Proyector BenQ MH560 Full HD', N'Proyector', N'DISPONIBLE'),
    (N'UAM-TAB-001', N'iPad Air 5ta Generación 64GB', N'Tableta', N'DISPONIBLE'),
    (N'UAM-TAB-002', N'Samsung Galaxy Tab S9 FE', N'Tableta', N'PRESTADO');
    PRINT 'Equipos iniciales insertados.';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.prestamos)
BEGIN
    DECLARE @idLap002 BIGINT = (SELECT id FROM dbo.equipos WHERE codigo_patrimonial = N'UAM-LAP-002');
    DECLARE @idTab002 BIGINT = (SELECT id FROM dbo.equipos WHERE codigo_patrimonial = N'UAM-TAB-002');
    DECLARE @idPro001 BIGINT = (SELECT id FROM dbo.equipos WHERE codigo_patrimonial = N'UAM-PRO-001');

    -- Préstamo histórico ya DEVUELTO sobre UAM-PRO-001 (el equipo está DISPONIBLE)
    IF @idPro001 IS NOT NULL
    BEGIN
        INSERT INTO dbo.prestamos (equipo_id, nombre_solicitante, fecha_prestamo, fecha_devolucion_prevista, fecha_devolucion_real, estado)
        VALUES (@idPro001, N'MSc. Roberto Blandón (Aula B-204)', '2026-10-20', '2026-10-22', '2026-10-22', N'DEVUELTO');
    END

    -- Préstamo ACTIVO sobre UAM-LAP-002 (el equipo está PRESTADO)
    IF @idLap002 IS NOT NULL
    BEGIN
        INSERT INTO dbo.prestamos (equipo_id, nombre_solicitante, fecha_prestamo, fecha_devolucion_prevista, fecha_devolucion_real, estado)
        VALUES (@idLap002, N'Ing. María Fernanda Solís (Lab Redes)', '2026-10-27', '2026-10-30', NULL, N'ACTIVO');
    END

    -- Préstamo ACTIVO sobre UAM-TAB-002 (el equipo está PRESTADO)
    IF @idTab002 IS NOT NULL
    BEGIN
        INSERT INTO dbo.prestamos (equipo_id, nombre_solicitante, fecha_prestamo, fecha_devolucion_prevista, fecha_devolucion_real, estado)
        VALUES (@idTab002, N'Dr. Alejandro Vega (Auditorio Central)', '2026-10-28', '2026-10-31', NULL, N'ACTIVO');
    END

    PRINT 'Préstamos iniciales insertados.';
END
GO
