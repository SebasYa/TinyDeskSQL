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
		LEFT JOIN ESTADO AS E ON I.IdEstado = E.Id
		WHERE E.Id IS NULL
	)
	BEGIN
		RAISERROR('El estado asignado no existe.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END

	IF EXISTS (
		SELECT I.Id
		FROM inserted AS I
		INNER JOIN SPRINT AS S ON S.Id = I.IdSprint
		INNER JOIN ESTADO AS E ON S.IdEstado = E.Id
		WHERE S.Activo = 0
        OR S.FechaFin IS NOT NULL
		OR E.EsFinal = 1
	)
	BEGIN
		RAISERROR('No se puede crear un ticket relacionado a un sprint inactivo o finalizado.', 16, 1);
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

	IF EXISTS (
		SELECT I.Id
		FROM inserted AS I
		LEFT JOIN PRIORIDAD AS P ON I.IdPrioridad = P.Id
		WHERE P.Id IS NULL
	)
	BEGIN
		RAISERROR('La prioridad asignada no existe.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END
END
GO

-- Valida que no se pueda modificar la fecha de inicio.
CREATE TRIGGER tr_Ticket_ModificarFechas ON TICKET
AFTER UPDATE
AS BEGIN
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
GO

-- Rollbacks al reasignar usuario a un ticket
CREATE TRIGGER tr_Ticket_ReasignarUsuario ON TICKET
AFTER UPDATE
AS BEGIN
	IF EXISTS(
		SELECT 1
		FROM inserted I
		LEFT JOIN Usuario AS U ON I.IdUsuario = U.Id
		WHERE U.Id IS NULL
	)
	BEGIN
		RAISERROR('El Usuario asignado no existe.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END

	IF EXISTS(
		SELECT 1
		FROM inserted I
		INNER JOIN Usuario AS U ON I.IdUsuario = U.Id
		WHERE U.Activo = 0
	)
	BEGIN
		RAISERROR('No se puede asignar un ticket a un Usuario inactivo.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END
END

-- No permitir modificar ticket con un estado esFinal=1
-- CREATE TRIGGER Tr_Ticket_ModificarTickerFinalizado ON ticket
-- AFTER UPDATE
-- AS BEGIN
-- 	IF EXISTS(
-- 		SELECT 1
-- 		FROM deleted D
-- 		INNER JOIN ESTADO E ON D.IdEstado = E.Id
-- 		WHERE E.esFinal = 1
-- 	)
-- 	BEGIN
-- 		RAISERROR('No se puede modificar un ticket finalizado.', 16, 1);
-- 		ROLLBACK TRANSACTION;
-- 		RETURN;
-- 	END
-- END