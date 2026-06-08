USE TinyDesk_SQL;
GO

-- Vista de usuarios detallados
CREATE VIEW vw_Usuarios_Detallados
AS
SELECT
    U.Id AS [Usuario ID],
    U.NombreUsuario AS Username,
    U.Apellido + ', ' + U.Nombre AS [Nombre Completo],

    CASE
        WHEN U.Activo = 1 THEN 'Activo'
        ELSE 'Inactivo'
    END AS Estado,

    R.Nombre AS Rol,

    CASE
        WHEN R.PermisoEscritura = 1 THEN 'Lectura y escritura'
        ELSE 'Solo lectura'
    END AS TipoPermiso,

    A.Nombre AS Area

FROM USUARIO AS U
INNER JOIN ROL AS R ON U.IdRol = R.Id
INNER JOIN AREA AS A ON U.IdArea = A.Id;
GO

-- Usuarios Activos
CREATE VIEW vw_Usuarios_Activos
AS
SELECT
    *
FROM vw_Usuarios_Detallados
WHERE Estado = 1;
GO

