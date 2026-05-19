USE TinyDesk_SQL;
GO
-- Valida que no se pueda modificar la fecha de inicio.
CREATE TRIGGER tr_Proyecto_InvalidarModificacionFechaInicio ON PROYECTO
AFTER UPDATE
AS
BEGIN
	IF UPDATE(FechaInicio)
	BEGIN
		RAISERROR('La fecha de inicio del proyecto no puede ser modificada.', 16, 1);
		ROLLBACK TRANSACTION;
	END
END;
GO