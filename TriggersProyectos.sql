USE TinyDesk_SQL;
GO
-- Valida que la fecha de inicio no sea inferior a la fecha actual.
CREATE TRIGGER tr_Proyecto_ValidarFechaInicio ON PROYECTO
AFTER INSERT
AS
BEGIN
	IF(
		SELECT COUNT(*)
		FROM inserted
		WHERE FechaInicio < CAST(GETDATE() AS DATE)
	) > 0
	BEGIN
	RAISERROR('La fecha de inicio del proyecto no puede ser anterior a la fecha actual.', 16, 1);
	ROLLBACK TRANSACTION;
	END
END;
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