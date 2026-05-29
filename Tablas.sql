USE TinyDesk_SQL;
GO
/*----------------------
		TABLAS
------------------------*/
--CREACIÓN TABLA ÁREA
CREATE TABLE AREA 
(
	Id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	Nombre VARCHAR(30) NOT NULL UNIQUE
)
GO

--CREACIÓN TABLA ROL
CREATE TABLE ROL
(
	Id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	Nombre VARCHAR(30) NOT NULL UNIQUE,
	PermisoEscritura BIT NOT NULL
)
/*-------------------------------------------------------------------------------
				Se insetran filas obligatorias de manera default.
---------------------------------------------------------------------------------*/
IF NOT EXISTS (
	SELECT 1
	FROM ROL
	WHERE Nombre = 'Usuario'
)
BEGIN
	INSERT INTO ROL (Nombre, PermisoEscritura)
	VALUES ('Usuario', 0);
END

IF NOT EXISTS (
	SELECT 1
	FROM ROL
	WHERE Nombre = 'Admin'
)
BEGIN
	INSERT INTO ROL (Nombre, PermisoEscritura)
	VALUES ('Admin', 1);
END
/*-------------------------------------------------------------------------------
---------------------------------------------------------------------------------*/

GO
--CREACIÓN TABLA USUARIO
CREATE TABLE USUARIO
(
	Id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	NombreUsuario VARCHAR(30) NOT NULL UNIQUE,
	PasswordHash VARCHAR(200) NOT NULL,
	Nombre VARCHAR(30) NOT NULL,
	Apellido VARCHAR(30) NOT NULL,
	Activo BIT NOT NULL DEFAULT 1,
	IdRol INT NOT NULL,
	IdArea INT NOT NULL,

	FOREIGN KEY (IdRol) REFERENCES ROL(Id),
	FOREIGN KEY (IdArea) REFERENCES AREA(Id)
)
GO

--CREACION TABLA ESTADO
CREATE TABLE ESTADO
(
	Id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	Nombre VARCHAR(30) NOT NULL UNIQUE,
	EsFinal BIT NOT NULL DEFAULT 0,
	EsSistema BIT NOT NULL DEFAULT 0
)
GO
/*-------------------------------------------------------------------------------
				Se insetran filas obligatorias de manera default.
---------------------------------------------------------------------------------*/
IF NOT EXISTS (
	SELECT 1
	FROM ESTADO
	WHERE Nombre = 'Pendiente'
)
BEGIN
	INSERT INTO ESTADO (Nombre, EsFinal, EsSistema)
	VALUES ('Pendiente', 0, 1);
END

IF NOT EXISTS (
	SELECT 1
	FROM ESTADO
	WHERE Nombre = 'En Progreso'
)
BEGIN
	INSERT INTO ESTADO (Nombre, EsFinal, EsSistema)
	VALUES ('En Progreso', 0, 1);
END

IF NOT EXISTS (
	SELECT 1
	FROM ESTADO
	WHERE Nombre = 'Finalizado'
)
BEGIN
	INSERT INTO ESTADO (Nombre, EsFinal, EsSistema)
	VALUES ('Finalizado', 1, 1);
END
GO
/*-------------------------------------------------------------------------------
---------------------------------------------------------------------------------*/

--CREACION TABLA PRIORIDAD
CREATE TABLE PRIORIDAD
(
	Id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	Nombre VARCHAR(30) NOT NULL UNIQUE
)
GO

--CREACIÓN TABLA PROYECTO
CREATE TABLE PROYECTO
(
	Id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	Nombre VARCHAR(30) NOT NULL,
	Descripcion VARCHAR(250) NOT NULL,
	FechaInicio DATE NOT NULL CHECK(FechaInicio >= CAST(GETDATE() AS DATE)),
	FechaFin DATE,
	Activo BIT NOT NULL DEFAULT 1,
	IdEstado INT NOT NULL,
	
	CONSTRAINT CK_Proyecto_FechaFin CHECK (FechaFin IS NULL OR FechaFin >= FechaInicio),
	FOREIGN KEY (IdEstado) REFERENCES ESTADO(Id)
)
GO
--CREACIÓN TABLA SPRINT
CREATE TABLE SPRINT
(
	Id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	NumeroSprint INT NOT NULL,
	FechaInicio DATE NOT NULL CHECK(FechaInicio >= CAST(GETDATE() AS DATE)),
	FechaFin DATE,
	Activo BIT NOT NULL DEFAULT 1,
	IdProyecto INT NOT NULL,
	IdEstado INT NOT NULL,
	IdArea INT NOT NULL,

	CONSTRAINT CK_Sprint_FechaFin CHECK (FechaFin IS NULL OR FechaFin >= FechaInicio),

	FOREIGN KEY (IdProyecto) REFERENCES PROYECTO(Id),
	FOREIGN KEY (IdEstado) REFERENCES ESTADO(Id),
	FOREIGN KEY (IdArea) REFERENCES AREA(Id)
)
GO

--CREACIÓN TABLA TICKET
CREATE TABLE TICKET
(
	Id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	FechaInicio DATE NOT NULL CHECK(FechaInicio >= CAST(GETDATE() AS DATE)),
	FechaFin DATE,
	Descripcion VARCHAR(150) NOT NULL,
	Activo BIT NOT NULL DEFAULT 1,
	IdPrioridad INT NOT NULL,
	IdUsuario INT NOT NULL,
	IdEstado INT NOT NULL,
	IdSprint INT NOT NULL,

	CONSTRAINT CK_Ticket_FechaFin CHECK (FechaFin IS NULL OR FechaFin >= FechaInicio),

	FOREIGN KEY (IdPrioridad) REFERENCES PRIORIDAD(Id),
	FOREIGN KEY (IdUsuario) REFERENCES USUARIO(Id),
	FOREIGN KEY (IdEstado) REFERENCES ESTADO(Id),
	FOREIGN KEY (IdSprint) REFERENCES SPRINT(Id)
)
GO

/*----------------------
		VISTAS
------------------------*/

