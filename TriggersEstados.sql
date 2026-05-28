USE TinyDesk_SQL;
GO

-- No modificar estados que pertenecen al sistema de manera default.
CREATE TRIGGER tr_Estado_NoModificarSistema
ON ESTADO
AFTER UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1
		FROM deleted
		WHERE EsSistema = 1
	)
	BEGIN
		RAISERROR('No se pueden modificar estados del sistema.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END;
END;