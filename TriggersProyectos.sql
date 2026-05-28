USE TinyDesk_SQL;
GO
-- Valida que no se pueda modificar la fecha de inicio.
CREATE TRIGGER tr_Proyecto_InvalidarModificacionFechaInicio ON PROYECTO
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
		RAISERROR('La fecha de inicio del proyecto no puede ser modificada.', 16, 1);
		ROLLBACK TRANSACTION;
	END
END;
