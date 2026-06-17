USE TinyDesk_SQL;
GO

INSERT INTO AREA (Nombre)
VALUES
('Backend'),
('Frontend');

INSERT INTO ROL (Nombre, PermisoEscritura)
VALUES
('Senior', 1),
('Junior', 0),
('Team Leader', 1);

INSERT INTO PRIORIDAD (Nombre)
VALUES
('Urgente'),
('Alta'),
('Media'),
('Baja');

DECLARE @AreaBackend INT = (SELECT Id FROM AREA WHERE Nombre = 'Backend');
DECLARE @AreaFrontend INT = (SELECT Id FROM AREA WHERE Nombre = 'Frontend');

DECLARE @RolSenior INT = (SELECT Id FROM ROL WHERE Nombre = 'Senior');
DECLARE @RolJunior INT = (SELECT Id FROM ROL WHERE Nombre = 'Junior');
DECLARE @RolTeamLeader INT = (SELECT Id FROM ROL WHERE Nombre = 'Team Leader');

INSERT INTO USUARIO (NombreUsuario, PasswordHash, Nombre, Apellido, Activo, IdRol, IdArea)
VALUES
('SebasYanni', '123', 'Sebastian', 'Yanni', 1, @RolSenior, @AreaBackend),
('MarceloRearte', '123', 'Marcelo', 'Rearte', 1, @RolSenior, @AreaFrontend),
('MaxiBianchi', '123', 'Maximiliano', 'Bianchi', 1, @RolJunior, @AreaBackend),
('AngelSimon', '123', 'Angel', 'Simon', 1, @RolTeamLeader, @AreaBackend);

DECLARE @Pendiente INT = (SELECT Id FROM ESTADO WHERE Nombre = 'Pendiente');
DECLARE @EnProgreso INT = (SELECT Id FROM ESTADO WHERE Nombre = 'En Progreso');
DECLARE @Finalizado INT = (SELECT Id FROM ESTADO WHERE Nombre = 'Finalizado');

INSERT INTO PROYECTO (Nombre, Descripcion, FechaInicio, FechaFin, Activo, IdEstado)
VALUES
('TiniDeskSQL', 'Sistema de gestion de proyectos, sprints y tickets para Base de Datos II.',
 CAST(GETDATE() AS DATE), DATEADD(DAY, 45, CAST(GETDATE() AS DATE)), 1, @EnProgreso),
('UTN TP Final', 'Trabajo practico final integrador para presentar en la facultad.',
 CAST(GETDATE() AS DATE), DATEADD(DAY, 60, CAST(GETDATE() AS DATE)), 1, @Pendiente);

DECLARE @ProyectoTiny INT = (SELECT Id FROM PROYECTO WHERE Nombre = 'TiniDeskSQL');
DECLARE @ProyectoUTN INT = (SELECT Id FROM PROYECTO WHERE Nombre = 'UTN TP Final');

INSERT INTO SPRINT (Numero, FechaInicio, FechaFin, Activo, IdProyecto, IdEstado, IdArea)
VALUES
(1, CAST(GETDATE() AS DATE), NULL, 1, @ProyectoTiny, @EnProgreso, @AreaBackend),
(2, CAST(GETDATE() AS DATE), NULL, 1, @ProyectoTiny, @Pendiente, @AreaFrontend),
(1, CAST(GETDATE() AS DATE), NULL, 1, @ProyectoUTN, @Pendiente, @AreaBackend);

DECLARE @Sebas INT = (SELECT Id FROM USUARIO WHERE NombreUsuario = 'SebasYanni');
DECLARE @Marcelo INT = (SELECT Id FROM USUARIO WHERE NombreUsuario = 'MarceloRearte');
DECLARE @Angel INT = (SELECT Id FROM USUARIO WHERE NombreUsuario = 'AngelSimon');

DECLARE @Urgente INT = (SELECT Id FROM PRIORIDAD WHERE Nombre = 'Urgente');
DECLARE @Alta INT = (SELECT Id FROM PRIORIDAD WHERE Nombre = 'Alta');
DECLARE @Media INT = (SELECT Id FROM PRIORIDAD WHERE Nombre = 'Media');

DECLARE @SprintTinyBackend INT = (SELECT Id FROM SPRINT WHERE IdProyecto = @ProyectoTiny AND Numero = 1 AND IdArea = @AreaBackend);
DECLARE @SprintTinyFrontend INT = (SELECT Id FROM SPRINT WHERE IdProyecto = @ProyectoTiny AND Numero = 2 AND IdArea = @AreaFrontend);
DECLARE @SprintUTNBackend INT = (SELECT Id FROM SPRINT WHERE IdProyecto = @ProyectoUTN AND Numero = 1 AND IdArea = @AreaBackend);

INSERT INTO TICKET (FechaInicio, FechaFin, Descripcion, Activo, IdPrioridad, IdUsuario, IdEstado, IdSprint)
VALUES
(CAST(GETDATE() AS DATE), NULL, 'Corregir procedimientos almacenados principales', 1, @Urgente, @Sebas, @EnProgreso, @SprintTinyBackend),
(CAST(GETDATE() AS DATE), NULL, 'Validar integridad entre tickets, sprints y usuarios', 1, @Urgente, @Sebas, @Pendiente, @SprintTinyBackend),
(CAST(GETDATE() AS DATE), NULL, 'Preparar consultas para la demo final', 1, @Alta, @Sebas, @EnProgreso, @SprintUTNBackend),
(CAST(GETDATE() AS DATE), NULL, 'Revisar modelo relacional y claves foraneas', 1, @Alta, @Angel, @EnProgreso, @SprintTinyBackend),
(CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE), 'Crear vistas de reportes generales', 1, @Alta, @Angel, @Finalizado, @SprintUTNBackend),
(CAST(GETDATE() AS DATE), NULL, 'Definir criterios de prueba para tickets', 1, @Media, @Angel, @Pendiente, @SprintUTNBackend),
(CAST(GETDATE() AS DATE), NULL, 'Disenar pantalla de tablero de tickets', 1, @Alta, @Marcelo, @EnProgreso, @SprintTinyFrontend),
(CAST(GETDATE() AS DATE), NULL, 'Armar vista visual de proyectos activos', 1, @Media, @Marcelo, @Pendiente, @SprintTinyFrontend);



