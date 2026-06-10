---------------Vistas Estado---------------------

CREATE VIEW vw_ProyectoEstado AS
SELECT P.Nombre, P.Descripcion,P.FechaInicio,P.FechaFin,P.Activo, E.Nombre AS Estado
FROM PROYECTO AS P
INNER JOIN ESTADO AS E
 ON P.IdEstado = E.Id;





