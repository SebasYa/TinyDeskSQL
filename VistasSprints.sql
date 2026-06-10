USE TinyDesk_SQL;
GO

-- Vista de sprints detallados - 

CREATE VIEW vw_Sprints_detallados
AS
SELECT
    S.Id AS [SPRINT ID],
    S.Numero AS [Numero Sprint],
    S.FechaInicio,
    S.FechaFin,
    DATEDIFF(DAY, S.FechaInicio, S.FechaFin) AS [Dias Transcurridos],

    CASE 
       WHEN E.EsFinal = 1 THEN 100
       WHEN GETDATE() < S.FechaInicio THEN 0
       WHEN GETDATE() > S.FechaFin THEN 100
       ELSE (DATEDIFF(DAY, S.FechaInicio, GETDATE()) * 100) / NULLIF(DATEDIFF(DAY, S.FechaInicio, S.FechaFin), 0)
       END AS [Progreso],

    E.Nombre AS Estado,
    P.Nombre AS Proyecto,
    A.Nombre AS Area, 
    CASE
        WHEN S.Activo = 1 THEN 'Activo'
        ELSE 'Inactivo'
    END AS Activo

FROM SPRINT AS S
INNER JOIN PROYECTO AS P ON S.IdProyecto = P.Id
INNER JOIN AREA AS A ON S.IdArea = A.Id
INNER JOIN ESTADO AS E ON S.IdEstado = E.Id
GO

