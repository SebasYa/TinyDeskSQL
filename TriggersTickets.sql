USE TinyDesk_SQL;
GO
-- validar creacion de ticket
CREATE TRIGGER tr_Ticket_ValidarCreacion ON TICKET
AFTER INSERT
AS
BEGIN
	IF EXISTS (
		SELECT I.Id
		FROM inserted AS I
		INNER JOIN SPRINT AS S ON S.Id = I.IdSprint
		INNER JOIN PROYECTO AS P ON P.Id = S.IdProyecto
		INNER JOIN ESTADO AS EstadoProyecto ON P.IdEstado = EstadoProyecto.Id
		INNER JOIN ESTADO AS EstadoSprint ON S.IdEstado = EstadoSprint.Id
		WHERE S.Activo = 0
		OR P.Activo = 0
        OR S.FechaFin IS NOT NULL
		OR EstadoProyecto.EsFinal = 1
		OR EstadoSprint.EsFinal = 1
	)
	BEGIN
		RAISERROR('No se puede crear un ticket relacionado a un sprint o proyecto inactivo o finalizado.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END

	IF EXISTS (
		SELECT I.Id
		FROM inserted AS I
		INNER JOIN USUARIO AS U ON U.Id = I.IdUsuario
		WHERE U.Activo = 0
	)
	BEGIN
		RAISERROR('No se puede asignar un ticket a un usuario inactivo.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END

	IF EXISTS (
		SELECT I.Id
		FROM inserted AS I
		INNER JOIN SPRINT AS S ON S.Id = I.IdSprint
		WHERE I.FechaInicio < S.FechaInicio
	)
	BEGIN
		RAISERROR('La fecha de inicio del ticket no puede ser anterior a la fecha de inicio del sprint.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END

	IF EXISTS (
		SELECT I.Id
		FROM inserted AS I
		INNER JOIN USUARIO AS U ON U.Id = I.IdUsuario
		INNER JOIN SPRINT AS S ON S.Id = I.IdSprint
		WHERE U.IdArea <> S.IdArea
	)
	BEGIN
		RAISERROR('No se puede asignar un ticket a un usuario de un área distinta a la del sprint.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END
END
GO

-- Valida que no se pueda modificar la fecha de inicio.
CREATE TRIGGER tr_Ticket_ModificarFechas ON TICKET
AFTER UPDATE
AS
BEGIN
    IF EXISTS (
		SELECT 1
		FROM inserted I
		INNER JOIN deleted D ON D.Id = I.Id
		WHERE I.FechaInicio <> D.FechaInicio
	)
    BEGIN
		RAISERROR('La fecha de inicio del ticket no debe modificarse.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END
END
