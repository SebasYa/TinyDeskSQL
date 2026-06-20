USE TinyDesk_SQL;
GO
-- Crear Ticket Rapido
CREATE PROCEDURE Sp_CrearTicketRapido(
    @Descripcion VARCHAR(150),
    @IdPrioridad INT,
	@IdUsuarioAsignado INT,
    @IdUsuarioCreador INT,
    @IdSprint INT
)
AS BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM USUARIO AS U
        INNER JOIN ROL AS R ON U.IdRol = R.Id
        WHERE U.Id = @IdUsuarioCreador
          AND U.Activo = 1
          AND R.PermisoEscritura = 1
    )
    BEGIN
        RAISERROR('El usuario que esta creando el ticket no existe, está inactivo o no tiene permiso de escritura.', 16, 1);
        RETURN;
    END;

    DECLARE @IdEstado INT;
    SET @IdEstado = (SELECT Id FROM ESTADO WHERE Nombre = 'Pendiente');
    IF @IdEstado IS NULL
    BEGIN
        RAISERROR('No existe el estado Pendiente.', 16, 1);
        RETURN;
    END;

    INSERT INTO Ticket(FechaInicio, Descripcion, IdPrioridad, IdUsuario, IdEstado, IdSprint)
    VALUES(CAST(GETDATE() AS DATE), @Descripcion, @IdPrioridad, @IdUsuarioAsignado, @IdEstado, @IdSprint);

END
GO

-- Cambiar estado Ticket
CREATE PROCEDURE Sp_CambiarEstadoTicket(
    @IdTicket INT,
    @IdEstado INT,
    @IdUsuarioModificador INT
)
AS BEGIN
    DECLARE @EsFinal BIT;
    DECLARE @IdUsuarioAsignado INT;
    DECLARE @TienePermisoEscritura BIT;

    SELECT @IdUsuarioAsignado = IdUsuario
    FROM TICKET
    WHERE Id = @IdTicket;

    IF @IdUsuarioAsignado IS NULL
    BEGIN
        RAISERROR('El ticket indicado no existe.', 16, 1);
        RETURN;
    END;

    SELECT @EsFinal = EsFinal
    FROM ESTADO
    WHERE Id = @IdEstado;

    IF @EsFinal IS NULL
    BEGIN
        RAISERROR('El estado indicado no existe.', 16, 1);
        RETURN;
    END;

    SELECT @TienePermisoEscritura = R.PermisoEscritura
    FROM USUARIO AS U
    INNER JOIN ROL AS R ON U.IdRol = R.Id
    WHERE U.Id = @IdUsuarioModificador
      AND U.Activo = 1;

    IF @TienePermisoEscritura IS NULL
    BEGIN
        RAISERROR('El usuario que realiza la acción no existe o está inactivo.', 16, 1);
        RETURN;
    END;

    IF @TienePermisoEscritura = 0 AND @IdUsuarioModificador <> @IdUsuarioAsignado
    BEGIN
        RAISERROR('El usuario sin permiso de escritura solo puede cambiar el estado de tickets asignados a él.', 16, 1);
        RETURN;
    END;

    IF @EsFinal = 1
    BEGIN
        UPDATE TICKET
        SET IdEstado = @IdEstado,
            FechaFin = CAST(GETDATE() AS DATE)
        WHERE Id = @IdTicket;
    END;
    ELSE
    BEGIN
        UPDATE TICKET
        SET IdEstado = @IdEstado,
            FechaFin = NULL
        WHERE Id = @IdTicket;
    END;
END
GO

-- Crear Sprint.  CAMBIO -> NUMERO DE SPRINT SE GENERA AUTOMATICAMENTE SEGUN EL PROYECTO: COUNT + 1 WHERE IDPROYECTO=@ID
CREATE PROCEDURE Sp_CrearSprint(
    @FechaInicio DATE,
    @FechaFin DATE,
    @Activo BIT,
    @IdProyecto INT,
    @IdArea INT
)
AS BEGIN
    DECLARE @IdEstado INT;
    SET @IdEstado = (SELECT Id FROM ESTADO WHERE Nombre = 'Pendiente');

    IF @IdEstado IS NULL
    BEGIN
        RAISERROR('El estado "Pendiente" no existe en la base de datos.', 16, 1);
        RETURN;
    END
    DECLARE @NumeroSprint INT;
    SET @NumeroSprint = (
        SELECT COUNT(*) + 1
        FROM SPRINT
        WHERE IdProyecto = @IdProyecto
    )
    INSERT INTO SPRINT(Numero,FechaInicio ,FechaFin,Activo, IdProyecto,IdEstado,IdArea)
    VALUES(@NumeroSprint,@FechaInicio,@FechaFin,@Activo,@IdProyecto,@IdEstado,@IdArea);
END
GO

--Reasignar Ticket  (REVISAR y modificar)
CREATE PROCEDURE Sp_ReasignarTicket(
    @IdTicket INT,
    @IdUsuarioAsignado INT,
    @IdUsuarioModificador INT
)
AS BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM USUARIO AS U
        INNER JOIN ROL AS R ON U.IdRol = R.Id
        WHERE U.Id = @IdUsuarioModificador
          AND U.Activo = 1
          AND R.PermisoEscritura = 1
    )
    BEGIN
        RAISERROR('El usuario no tiene permiso para reasignar tickets.', 16, 1);
        RETURN;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM TICKET
        WHERE Id = @IdTicket
    )
    BEGIN
        RAISERROR('El ticket indicado no existe.', 16, 1);
        RETURN;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM USUARIO
        WHERE Id = @IdUsuarioAsignado
    )
    BEGIN
        RAISERROR('El usuario indicado no existe.', 16, 1);
        RETURN;
    END;

    UPDATE TICKET
    SET IdUsuario = @IdUsuarioAsignado
    WHERE Id = @IdTicket;
END
GO

-- Crear Proyecto
CREATE PROCEDURE Sp_CrearProyecto(
    @Nombre VARCHAR(50),
    @Descripcion VARCHAR(150),
    @FechaInicio DATE,
    @FechaFin DATE
)
AS BEGIN
    DECLARE @IdEstado INT;
    SET @IdEstado = (SELECT Id FROM ESTADO WHERE Nombre = 'Pendiente');

    IF @IdEstado IS NULL
    BEGIN
        RAISERROR('El estado es inv�lido.', 16, 1);
        RETURN;
    END

    INSERT INTO Proyecto(Nombre, Descripcion,FechaInicio ,FechaFin,Activo,IdEstado)
    VALUES(@Nombre,@Descripcion,@FechaInicio,@FechaFin,1,@IdEstado);

END
GO

-- Cerrar Ticket
-- CREATE PROCEDURE Sp_CerrarTicket(
--     @IdTicket INT
-- )
-- AS BEGIN
--     DECLARE @IdEstado INT;
--     DECLARE @IdEstadoActual INT;
--     SET @IdEstado = (SELECT Id FROM ESTADO WHERE Nombre = 'Finalizado');
--     IF @IdEstado IS NULL
--     BEGIN
--         RAISERROR('No existe el estado Finalizado.',16,1);
--         RETURN;
--     END
--     SET @IdEstadoActual = (SELECT IdEstado FROM Ticket WHERE Id = @IdTicket);
--         IF @IdEstadoActual IS NULL
--     BEGIN
--         RAISERROR('El ticket no existe.',16,1);
--         RETURN;
--     END
--     IF(@IdEstado = @IdEstadoActual)
--     BEGIN
--         RAISERROR('El ticket fue finalizado anteriormente.', 16, 1);
--         RETURN;
--     END;
--     UPDATE Ticket SET IdEstado = @IdEstado, FechaFin = CAST(GETDATE() AS DATE) WHERE Id = @IdTicket;
-- END
-- GO


---FALTAN ALGUN SP DE REPORTE---
--EJEMPLO TICKET COMPLETADO POR USUARIO
--TICKETS CERRADOS
--SPRINTS COMPLETADOS POR AREA

--SP REPORTE TICKET-USUARIO
CREATE PROCEDURE Sp_ReporteTicketsUsuario_VS_Area
(
    @IdUsuario INT
)
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM USUARIO
        WHERE Id = @IdUsuario
    )
    BEGIN
        RAISERROR('El usuario indicado no existe.', 16, 1);
        RETURN;
    END;

    SELECT
        U.Id AS IdUsuario,
        U.Apellido + ', ' + U.Nombre AS NombreCompleto,
        U.NombreUsuario AS Alias,
        A.Nombre AS Area,
        R.Nombre AS Rol,

        COUNT(T.Id) AS TotalTickets,

        SUM(
            CASE
                WHEN E.EsFinal = 1 THEN 1
                ELSE 0
            END
        ) AS TicketsFinalizados,

        SUM(
            CASE
                WHEN E.EsFinal = 0 THEN 1
                ELSE 0
            END
        ) AS TicketsPendientes,

        CAST(
            CASE
                WHEN COUNT(T.Id) = 0 THEN 0
                ELSE SUM(
                    CASE
                        WHEN E.EsFinal = 1 THEN 1
                        ELSE 0
                    END
                ) * 100.0 / COUNT(T.Id)
            END
            AS DECIMAL(10,2)
        ) AS PorcentajeFinalizados,

        PA.PromedioTicketsArea,

        CAST(
            COUNT(T.Id) - PA.PromedioTicketsArea
            AS DECIMAL(10,2)
        ) AS DiferenciaTicketsContraPromedioArea,

        PA.PromedioFinalizadosArea

    FROM USUARIO AS U
    INNER JOIN AREA AS A ON U.IdArea = A.Id
    INNER JOIN ROL AS R ON U.IdRol = R.Id
    LEFT JOIN TICKET AS T ON T.IdUsuario = U.Id AND T.Activo = 1
    LEFT JOIN ESTADO AS E ON T.IdEstado = E.Id

    INNER JOIN (SELECT U3.IdArea, 
                       CAST(
                            COUNT(T3.Id) * 1.0 / COUNT(DISTINCT U3.Id)
                            AS DECIMAL(10,2)
                        ) AS PromedioTicketsArea,
                        CAST(
                            CASE
                                WHEN COUNT(T3.Id) = 0 THEN 0
                                ELSE SUM(
                                    CASE
                                        WHEN E3.EsFinal = 1 THEN 1
                                        ELSE 0
                                    END) * 1.0 / COUNT(T3.Id)
                        END
                        AS DECIMAL(10,2)
                        ) AS PromedioFinalizadosArea
            FROM USUARIO AS U3
            LEFT JOIN TICKET AS T3 ON T3.IdUsuario = U3.Id AND T3.Activo = 1
            LEFT JOIN ESTADO AS E3 ON T3.IdEstado = E3.Id
            GROUP BY U3.IdArea
        ) AS PA ON PA.IdArea = U.IdArea

    WHERE U.Id = @IdUsuario
    GROUP BY
        A.Nombre,
        U.Id,
        U.Apellido,
        U.Nombre,
        U.NombreUsuario,
        R.Nombre,
        PA.PromedioTicketsArea,
        PA.PromedioFinalizadosArea;
END;
GO