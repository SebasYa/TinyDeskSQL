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
    S.Numero AS [Sprint Numero],
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

-- Vista de tickets pendientes 
/*Esta vista mostrará únicamente los tickets que todavía no fueron finalizados.
Será útil para representar un tablero de trabajo donde se visualicen las tareas
pendientes o en curso.*/

CREATE VIEW vw_Tickets_pendientes
AS
SELECT
    T.Id AS [Ticket ID],
    S.Numero AS [Numero Sprint],
    T.FechaInicio,
    T.FechaFin,
    DATEDIFF(DAY, T.FechaInicio, T.FechaFin) AS [Dias Transcurridos],
    E.Nombre AS Estado,
    P.Nombre AS Proyecto,
    A.Nombre AS Area,
    PRI.Nombre AS Prioridad,
    CASE
        WHEN T.Activo = 1 THEN 'Activo'
        ELSE 'Inactivo'
    END AS Activo

FROM TICKET AS T
INNER JOIN ESTADO AS E ON T.IdEstado = E.Id
INNER JOIN SPRINT AS S ON T.IdSprint = S.Id
INNER JOIN PROYECTO AS P ON S.IdProyecto = P.Id
INNER JOIN AREA AS A ON S.IdArea = A.Id
INNER JOIN USUARIO AS U ON T.IdUsuario = U.Id
INNER JOIN PRIORIDAD AS PRI ON T.IdPrioridad = PRI.Id
WHERE E.EsFinal != 1 
GO

-- Vista promedioTicketsArea
CREATE VIEW vw_PromedioTicketsArea
AS SELECT U.Id,

          CAST(
            COUNT(T.Id) * 1.0 / COUNT(DISTINCT U.Id)
            AS DECIMAL(10, 2)
          ) AS PromedioTicketsArea,

          CAST(
            CASE 
                WHEN COUNT(T.Id) = 0 THEN 0
                ELSE SUM(
                    CASE
                        WHEN E.EsFinal = 1 THEN 1
                        ELSE 0
                    END
                ) * 1.0 / COUNT(T.Id)
            END
            AS DECIMAL(10, 2)
          ) AS PromedioFinalizadosArea

FROM Usuario AS U
LEFT JOIN Ticket AS T ON T.IdUsuario = U.Id AND T.Activo = 1
LEFT JOIN Estado AS E ON E.Id = T.IdEstado
GROUP BY U.IdArea;
GO