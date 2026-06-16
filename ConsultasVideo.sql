use TinyDesk_SQL;
GO

/* Estas vistas simplifican consultas con JOIN. 
   En vez de consultar muchas tablas separadas, puedo ver usuarios con rol y área, 
   proyectos con estado, sprints con proyecto y área, y tickets con prioridad, estado, usuario asignado, sprint y proyecto.
*/
SELECT * FROM vw_Usuarios_Detallados ORDER BY [Usuario ID];
SELECT * FROM vw_ProyectosActivos ORDER BY Nombre;
SELECT * FROM vw_Sprints_detallados ORDER BY [SPRINT ID];
SELECT * FROM vw_Tickets_Detallados ORDER BY [Ticket ID];
SELECT * FROM vw_Tickets_pendientes ORDER BY [Ticket ID];

/*
El reporte muestra la carga de tickets de un usuario, cuántos finalizó, 
cuántos tiene pendientes y compara su cantidad de tickets contra el promedio del área.
*/
DECLARE @IdSebas INT = (
    SELECT Id FROM USUARIO WHERE NombreUsuario = 'SebasYanni'
);

EXEC dbo.Sp_ReporteTicketsUsuario @IdUsuario = @IdSebas;
GO


/*
En este caso intento crear un ticket usando a Maxi como usuario creador. 
Maxi tiene rol Junior, y el rol Junior no tiene permiso de escritura. 
Por eso el procedimiento almacenado valida el permiso antes de insertar y rechaza la operación. 
Uso una transacción para que, si llegara a insertar algo, después se pueda deshacer
*/
BEGIN TRY
    BEGIN TRAN;

    DECLARE @Maxi INT = (SELECT Id FROM USUARIO WHERE NombreUsuario = 'MaxiBianchi');
    DECLARE @Sebas INT = (SELECT Id FROM USUARIO WHERE NombreUsuario = 'SebasYanni');
    DECLARE @Media INT = (SELECT Id FROM PRIORIDAD WHERE Nombre = 'Media');
    DECLARE @SprintBackend INT = (
        SELECT TOP 1 S.Id
        FROM SPRINT S
        INNER JOIN AREA A ON S.IdArea = A.Id
        WHERE A.Nombre = 'Backend'
    );

    EXEC dbo.Sp_CrearTicketRapido
        @Descripcion = 'Demo ticket creado por junior',
        @IdPrioridad = @Media,
        @IdUsuarioAsignado = @Sebas,
        @IdUsuarioCreador = @Maxi,
        @IdSprint = @SprintBackend;

    ROLLBACK;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    SELECT ERROR_MESSAGE() AS ResultadoEsperado;
END CATCH;
GO


/*
Se hace la misma operación, pero el usuario creador es Sebas. Sebas tiene rol Senior y permiso de escritura, 
entonces el procedimiento permite crear el ticket. El ticket queda asignado a Angel y se crea automáticamente en estado Pendiente. 
Después hago rollback para no dejar datos de demo cargados.
*/
BEGIN TRAN;

DECLARE @Sebas INT = (SELECT Id FROM USUARIO WHERE NombreUsuario = 'SebasYanni');
DECLARE @Angel INT = (SELECT Id FROM USUARIO WHERE NombreUsuario = 'AngelSimon');
DECLARE @Media INT = (SELECT Id FROM PRIORIDAD WHERE Nombre = 'Media');
DECLARE @SprintBackend INT = (
    SELECT TOP 1 S.Id
    FROM SPRINT S
    INNER JOIN AREA A ON S.IdArea = A.Id
    WHERE A.Nombre = 'Backend'
);

EXEC dbo.Sp_CrearTicketRapido
    @Descripcion = 'Demo ticket creado por senior',
    @IdPrioridad = @Media,
    @IdUsuarioAsignado = @Angel,
    @IdUsuarioCreador = @Sebas,
    @IdSprint = @SprintBackend;

SELECT TOP 1 *
FROM vw_Tickets_Detallados
WHERE Descripcion = 'Demo ticket creado por senior';

ROLLBACK;
GO


/*
En esta prueba intento reasignar un ticket que ya está finalizado. 
La operación pasa por el procedimiento de reasignación, pero el trigger sobre la tabla Ticket detecta 
que se está cambiando el usuario de un ticket cuyo estado anterior era final. 
Entonces cancela la transacción y evita modificar un ticket cerrado.
*/
BEGIN TRY
    BEGIN TRAN;

    DECLARE @TicketFinalizado INT = (
        SELECT Id FROM TICKET
        WHERE Descripcion = 'Crear vistas de reportes generales'
    );

    DECLARE @Sebas INT = (SELECT Id FROM USUARIO WHERE NombreUsuario = 'SebasYanni');
    DECLARE @Angel INT = (SELECT Id FROM USUARIO WHERE NombreUsuario = 'AngelSimon');

    EXEC dbo.Sp_ReasignarTicket
        @IdTicket = @TicketFinalizado,
        @IdUsuarioAsignado = @Sebas,
        @IdUsuarioModificador = @Angel;

    ROLLBACK;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    SELECT ERROR_MESSAGE() AS ResultadoEsperado;
END CATCH;
GO


/*
Este ticket pertenece a un sprint del área Backend. 
Marcelo pertenece al área Frontend. 
Aunque Sebas tiene permiso para reasignar, el trigger valida que el usuario asignado pertenezca al mismo área que el sprint. 
Como no coincide, rechaza la reasignación.
*/
BEGIN TRY
    BEGIN TRAN;

    DECLARE @TicketBackend INT = (
        SELECT Id FROM TICKET
        WHERE Descripcion = 'Corregir procedimientos almacenados principales'
    );

    DECLARE @Marcelo INT = (SELECT Id FROM USUARIO WHERE NombreUsuario = 'MarceloRearte');
    DECLARE @Sebas INT = (SELECT Id FROM USUARIO WHERE NombreUsuario = 'SebasYanni');

    EXEC dbo.Sp_ReasignarTicket
        @IdTicket = @TicketBackend,
        @IdUsuarioAsignado = @Marcelo,
        @IdUsuarioModificador = @Sebas;

    ROLLBACK;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    SELECT ERROR_MESSAGE() AS ResultadoEsperado;
END CATCH;
GO

/*
Esta prueba muestra una excepción controlada. 
Maxi es Junior y no tiene permiso de escritura general, por eso no puede crear ni reasignar tickets. 
Pero si el ticket está asignado a él, sí puede cambiar su estado. 
El procedimiento valida esa regla: si no tiene permiso de escritura, solamente le permite modificar el estado de tickets propios.
*/
BEGIN TRAN;

DECLARE @Sebas INT = (SELECT Id FROM USUARIO WHERE NombreUsuario = 'SebasYanni');
DECLARE @Maxi INT = (SELECT Id FROM USUARIO WHERE NombreUsuario = 'MaxiBianchi');
DECLARE @Media INT = (SELECT Id FROM PRIORIDAD WHERE Nombre = 'Media');
DECLARE @EnProgreso INT = (SELECT Id FROM ESTADO WHERE Nombre = 'En Progreso');
DECLARE @SprintBackend INT = (
    SELECT TOP 1 S.Id
    FROM SPRINT S
    INNER JOIN AREA A ON S.IdArea = A.Id
    WHERE A.Nombre = 'Backend'
);

EXEC dbo.Sp_CrearTicketRapido
    @Descripcion = 'Demo ticket asignado a junior',
    @IdPrioridad = @Media,
    @IdUsuarioAsignado = @Maxi,
    @IdUsuarioCreador = @Sebas,
    @IdSprint = @SprintBackend;

DECLARE @TicketDemo INT = (
    SELECT Id FROM TICKET
    WHERE Descripcion = 'Demo ticket asignado a junior'
);

EXEC dbo.Sp_CambiarEstadoTicket
    @IdTicket = @TicketDemo,
    @IdEstado = @EnProgreso,
    @IdUsuarioModificador = @Maxi;

SELECT *
FROM vw_Tickets_Detallados
WHERE [Ticket ID] = @TicketDemo;

ROLLBACK;
GO

/*
Este trigger protege la fecha de inicio del proyecto. 
La idea es mantener trazabilidad: una vez creado el proyecto, no se puede cambiar su fecha inicial. 
Al detectar el cambio, el trigger cancela la operación.
*/
BEGIN TRY
    BEGIN TRAN;

    UPDATE PROYECTO
    SET FechaInicio = DATEADD(DAY, 1, FechaInicio)
    WHERE Nombre = 'TiniDeskSQL';

    ROLLBACK;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    SELECT ERROR_MESSAGE() AS ResultadoEsperado;
END CATCH;
GO
/*
Este trigger funciona igual que el de proyecto, pero aplicado a tickets. 
La fecha de inicio se considera parte de la trazabilidad del ticket y no debería modificarse una vez cargada.
*/
BEGIN TRY
    BEGIN TRAN;

    UPDATE TICKET
    SET FechaInicio = DATEADD(DAY, 1, FechaInicio)
    WHERE Descripcion = 'Corregir procedimientos almacenados principales';

    ROLLBACK;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    SELECT ERROR_MESSAGE() AS ResultadoEsperado;
END CATCH;
GO