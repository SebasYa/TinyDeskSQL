USE TinyDesk_SQL;
GO

-- Vista de tickets detallados
CREATE VIEW vw_Tickets_Detallados
AS
SELECT
    T.Id AS [Ticket ID],
    T.Descripcion AS Descripcion,
    T.FechaInicio AS [Fecha de Inicio],
    T.FechaFin AS [Fecha Finalizado],

    CASE
        WHEN T.FechaFin IS NOT NULL THEN DATEDIFF(DAY, T.FechaInicio, T.FechaFin)
        ELSE NULL
    END AS [Tiempo hasta Finalizarlo],

    CASE
        WHEN T.FechaFin IS NULL THEN DATEDIFF(DAY, T.FechaInicio, GETDATE())
        ELSE NULL
    END AS [Dias Abierto],

    CASE
        WHEN T.FechaFin IS NOT NULL THEN 'Finalizado'
        ELSE 'En curso'
    END AS SituacionTemporal,

    CASE
        WHEN T.Activo = 1 THEN 'Activo'
        ELSE 'Inactivo'
    END AS EstadoActivoTicket,

    P.Nombre AS Prioridad,
    E.Nombre AS Estado,
    U.Apellido + ', ' + U.Nombre AS [Usuario Asignado],
    U.Activo AS [Usuario Activo],
    AUsuario.Nombre AS [Area Usuario],
    R.Nombre AS [Rol Usuario],

    S.NumeroSprint AS [Sprint Numero],
    S.Activo AS SprintActivo,

    PR.Nombre AS Proyecto,
    PR.Descripcion AS DescripcionProyecto,
    PR.FechaInicio AS FechaInicioProyecto,
    PR.FechaFin AS FechaFinProyecto,
    PR.Activo AS ProyectoActivo

FROM TICKET AS T
INNER JOIN PRIORIDAD AS P ON T.IdPrioridad = P.Id
INNER JOIN ESTADO AS E ON T.IdEstado = E.Id
INNER JOIN USUARIO AS U ON T.IdUsuario = U.Id
INNER JOIN ROL AS R ON U.IdRol = R.Id
INNER JOIN AREA AS AUsuario ON U.IdArea = AUsuario.Id
INNER JOIN SPRINT AS S ON T.IdSprint = S.Id
INNER JOIN PROYECTO AS PR ON S.IdProyecto = PR.Id;
GO