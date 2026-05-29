USE TinyDesk_SQL;
GO
-- Crear Ticket Rapido
CREATE PROCEDURE Sp_CrearTicketRapido(
    @Descripcion VARCHAR(150),
    @IdPrioridad INT,
	@IdUsuario INT,
    @IdSprint INT
)
AS BEGIN

    DECLARE @IdEstado INT;
    SET @IdEstado = (SELECT Id FROM ESTADO WHERE Nombre = 'Pendiente');

    INSERT INTO Ticket(FechaInicio, Descripcion, IdPrioridad, IdUsuario, IdEstado, IdSprint)
    VALUES(CAST(GETDATE() AS DATE), @Descripcion, @IdPrioridad, @IdUsuario, @IdEstado, @IdSprint);

END
GO

-- Cambiar estado Ticket
CREATE PROCEDURE Sp_CambiarEstadoTicket(
    @IdTicket INT,
    @IdEstado INT
)
AS BEGIN
    DECLARE @EsFinal BIT;
    SET @EsFinal = (SELECT EsFinal FROM ESTADO WHERE Id = @IdEstado);

    IF(@EsFinal IS NULL)
    BEGIN
        RAISERROR('El estado indicado no existe.', 16, 1);
        RETURN;
    END;

    IF(@EsFinal = 0)
    BEGIN
        UPDATE Ticket SET IdEstado = @IdEstado WHERE Id = @IdTicket;
    END;

    IF(@EsFinal = 1)
    BEGIN
        UPDATE Ticket 
        SET IdEstado = @IdEstado, 
            FechaFin = CAST(GETDATE() AS DATE) 
        WHERE Id = @IdTicket;
    END;
END
GO