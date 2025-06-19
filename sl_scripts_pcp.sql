CREATE OR REPLACE PACKAGE pkg_sl_usuario_pcp AS
    -- CRUD operations for SL_USUARIO_PCP
    PROCEDURE create_usuario(
        p_id                 IN SL_USUARIO_PCP.ID%TYPE,
        p_usuario            IN SL_USUARIO_PCP.USUARIO%TYPE,
        p_nombre_usuario     IN SL_USUARIO_PCP.NOMBRE_USUARIO%TYPE,
        p_clave              IN SL_USUARIO_PCP.CLAVE%TYPE,
        p_fecha_creacion     IN SL_USUARIO_PCP.FECHA_CREACION%TYPE,
        p_estado             IN SL_USUARIO_PCP.ESTADO%TYPE,
        p_usuario_creacion   IN SL_USUARIO_PCP.USUARIO_CREACION%TYPE,
        p_usuario_actualiza  IN SL_USUARIO_PCP.USUARIO_ACTUALIZA%TYPE,
        p_fecha_actualiza    IN SL_USUARIO_PCP.FECHA_ACTUALIZA%TYPE,
        p_tipo_usuario       IN SL_USUARIO_PCP.TIPO_USUARIO%TYPE,
        p_inicializa_clave   IN SL_USUARIO_PCP.INICIALIZA_CLAVE%TYPE,
        p_centro_costo       IN SL_USUARIO_PCP.CENTRO_COSTO%TYPE
    );

    PROCEDURE read_usuario(
        p_id                 IN SL_USUARIO_PCP.ID%TYPE,
        p_usuario            OUT SL_USUARIO_PCP.USUARIO%TYPE,
        p_nombre_usuario     OUT SL_USUARIO_PCP.NOMBRE_USUARIO%TYPE,
        p_clave              OUT SL_USUARIO_PCP.CLAVE%TYPE,
        p_fecha_creacion     OUT SL_USUARIO_PCP.FECHA_CREACION%TYPE,
        p_estado             OUT SL_USUARIO_PCP.ESTADO%TYPE,
        p_usuario_creacion   OUT SL_USUARIO_PCP.USUARIO_CREACION%TYPE,
        p_usuario_actualiza  OUT SL_USUARIO_PCP.USUARIO_ACTUALIZA%TYPE,
        p_fecha_actualiza    OUT SL_USUARIO_PCP.FECHA_ACTUALIZA%TYPE,
        p_tipo_usuario       OUT SL_USUARIO_PCP.TIPO_USUARIO%TYPE,
        p_inicializa_clave   OUT SL_USUARIO_PCP.INICIALIZA_CLAVE%TYPE,
        p_centro_costo       OUT SL_USUARIO_PCP.CENTRO_COSTO%TYPE
    );

    PROCEDURE update_usuario(
        p_id                 IN SL_USUARIO_PCP.ID%TYPE,
        p_usuario            IN SL_USUARIO_PCP.USUARIO%TYPE,
        p_nombre_usuario     IN SL_USUARIO_PCP.NOMBRE_USUARIO%TYPE,
        p_clave              IN SL_USUARIO_PCP.CLAVE%TYPE,
        p_fecha_creacion     IN SL_USUARIO_PCP.FECHA_CREACION%TYPE,
        p_estado             IN SL_USUARIO_PCP.ESTADO%TYPE,
        p_usuario_creacion   IN SL_USUARIO_PCP.USUARIO_CREACION%TYPE,
        p_usuario_actualiza  IN SL_USUARIO_PCP.USUARIO_ACTUALIZA%TYPE,
        p_fecha_actualiza    IN SL_USUARIO_PCP.FECHA_ACTUALIZA%TYPE,
        p_tipo_usuario       IN SL_USUARIO_PCP.TIPO_USUARIO%TYPE,
        p_inicializa_clave   IN SL_USUARIO_PCP.INICIALIZA_CLAVE%TYPE,
        p_centro_costo       IN SL_USUARIO_PCP.CENTRO_COSTO%TYPE
    );

    PROCEDURE delete_usuario(
        p_id IN SL_USUARIO_PCP.ID%TYPE
    );

    FUNCTION signin(
    p_usuario IN SL_USUARIO_PCP.USUARIO%TYPE,
    p_clave   IN SL_USUARIO_PCP.CLAVE%TYPE
    ) RETURN NUMBER;

    -- Placeholder for signout procedure, if needed
    -- PROCEDURE signout(
    --     p_usuario IN SL_USUARIO_PCP.USUARIO%TYPE
    -- );
END pkg_sl_usuario_pcp;
/

CREATE OR REPLACE PACKAGE BODY pkg_sl_usuario_pcp AS

    PROCEDURE create_usuario(
        p_id                 IN SL_USUARIO_PCP.ID%TYPE,
        p_usuario            IN SL_USUARIO_PCP.USUARIO%TYPE,
        p_nombre_usuario     IN SL_USUARIO_PCP.NOMBRE_USUARIO%TYPE,
        p_clave              IN SL_USUARIO_PCP.CLAVE%TYPE,
        p_fecha_creacion     IN SL_USUARIO_PCP.FECHA_CREACION%TYPE,
        p_estado             IN SL_USUARIO_PCP.ESTADO%TYPE,
        p_usuario_creacion   IN SL_USUARIO_PCP.USUARIO_CREACION%TYPE,
        p_usuario_actualiza  IN SL_USUARIO_PCP.USUARIO_ACTUALIZA%TYPE,
        p_fecha_actualiza    IN SL_USUARIO_PCP.FECHA_ACTUALIZA%TYPE,
        p_tipo_usuario       IN SL_USUARIO_PCP.TIPO_USUARIO%TYPE,
        p_inicializa_clave   IN SL_USUARIO_PCP.INICIALIZA_CLAVE%TYPE,
        p_centro_costo       IN SL_USUARIO_PCP.CENTRO_COSTO%TYPE
    ) IS
    BEGIN
        INSERT INTO SL_USUARIO_PCP (
            ID, USUARIO, NOMBRE_USUARIO, CLAVE, FECHA_CREACION, ESTADO,
            USUARIO_CREACION, USUARIO_ACTUALIZA, FECHA_ACTUALIZA, TIPO_USUARIO,
            INICIALIZA_CLAVE, CENTRO_COSTO
        ) VALUES (
            p_id, p_usuario, p_nombre_usuario, p_clave, p_fecha_creacion, p_estado,
            p_usuario_creacion, p_usuario_actualiza, p_fecha_actualiza, p_tipo_usuario,
            p_inicializa_clave, p_centro_costo
        );
    END create_usuario;

    PROCEDURE read_usuario(
        p_id                 IN SL_USUARIO_PCP.ID%TYPE,
        p_usuario            OUT SL_USUARIO_PCP.USUARIO%TYPE,
        p_nombre_usuario     OUT SL_USUARIO_PCP.NOMBRE_USUARIO%TYPE,
        p_clave              OUT SL_USUARIO_PCP.CLAVE%TYPE,
        p_fecha_creacion     OUT SL_USUARIO_PCP.FECHA_CREACION%TYPE,
        p_estado             OUT SL_USUARIO_PCP.ESTADO%TYPE,
        p_usuario_creacion   OUT SL_USUARIO_PCP.USUARIO_CREACION%TYPE,
        p_usuario_actualiza  OUT SL_USUARIO_PCP.USUARIO_ACTUALIZA%TYPE,
        p_fecha_actualiza    OUT SL_USUARIO_PCP.FECHA_ACTUALIZA%TYPE,
        p_tipo_usuario       OUT SL_USUARIO_PCP.TIPO_USUARIO%TYPE,
        p_inicializa_clave   OUT SL_USUARIO_PCP.INICIALIZA_CLAVE%TYPE,
        p_centro_costo       OUT SL_USUARIO_PCP.CENTRO_COSTO%TYPE
    ) IS
    BEGIN
        SELECT USUARIO, NOMBRE_USUARIO, CLAVE, FECHA_CREACION, ESTADO,
               USUARIO_CREACION, USUARIO_ACTUALIZA, FECHA_ACTUALIZA, TIPO_USUARIO,
               INICIALIZA_CLAVE, CENTRO_COSTO
          INTO p_usuario, p_nombre_usuario, p_clave, p_fecha_creacion, p_estado,
               p_usuario_creacion, p_usuario_actualiza, p_fecha_actualiza, p_tipo_usuario,
               p_inicializa_clave, p_centro_costo
          FROM SL_USUARIO_PCP
         WHERE ID = p_id;
    END read_usuario;

    PROCEDURE update_usuario(
        p_id                 IN SL_USUARIO_PCP.ID%TYPE,
        p_usuario            IN SL_USUARIO_PCP.USUARIO%TYPE,
        p_nombre_usuario     IN SL_USUARIO_PCP.NOMBRE_USUARIO%TYPE,
        p_clave              IN SL_USUARIO_PCP.CLAVE%TYPE,
        p_fecha_creacion     IN SL_USUARIO_PCP.FECHA_CREACION%TYPE,
        p_estado             IN SL_USUARIO_PCP.ESTADO%TYPE,
        p_usuario_creacion   IN SL_USUARIO_PCP.USUARIO_CREACION%TYPE,
        p_usuario_actualiza  IN SL_USUARIO_PCP.USUARIO_ACTUALIZA%TYPE,
        p_fecha_actualiza    IN SL_USUARIO_PCP.FECHA_ACTUALIZA%TYPE,
        p_tipo_usuario       IN SL_USUARIO_PCP.TIPO_USUARIO%TYPE,
        p_inicializa_clave   IN SL_USUARIO_PCP.INICIALIZA_CLAVE%TYPE,
        p_centro_costo       IN SL_USUARIO_PCP.CENTRO_COSTO%TYPE
    ) IS
    BEGIN
        UPDATE SL_USUARIO_PCP
           SET USUARIO            = p_usuario,
               NOMBRE_USUARIO     = p_nombre_usuario,
               CLAVE              = p_clave,
               FECHA_CREACION     = p_fecha_creacion,
               ESTADO             = p_estado,
               USUARIO_CREACION   = p_usuario_creacion,
               USUARIO_ACTUALIZA  = p_usuario_actualiza,
               FECHA_ACTUALIZA    = p_fecha_actualiza,
               TIPO_USUARIO       = p_tipo_usuario,
               INICIALIZA_CLAVE   = p_inicializa_clave,
               CENTRO_COSTO       = p_centro_costo
         WHERE ID = p_id;
    END update_usuario;

    PROCEDURE delete_usuario(
        p_id IN SL_USUARIO_PCP.ID%TYPE
    ) IS
    BEGIN
        DELETE FROM SL_USUARIO_PCP
         WHERE ID = p_id;
    END delete_usuario;

FUNCTION signin(
    p_usuario IN SL_USUARIO_PCP.USUARIO%TYPE,
    p_clave   IN SL_USUARIO_PCP.CLAVE%TYPE
) RETURN NUMBER IS
    v_count NUMBER := 0;
BEGIN
    SELECT COUNT(*)
      INTO v_count
      FROM SL_USUARIO_PCP
     WHERE USUARIO = p_usuario
       AND CLAVE = p_clave
       AND ESTADO = 'A'; -- Assuming 'A' means active

    IF v_count > 0 THEN
        RETURN 1; -- Success
    ELSE
        RETURN 0; -- Failure
    END IF;
END signin;

END pkg_sl_usuario_pcp;
/

CREATE OR REPLACE PUBLIC SYNONYM SL_USUARIO_PCP FOR SL.SL_USUARIO_PCP;

CREATE ROLE PCP_ADMIN;

GRANT CREATE SESSION TO PCP_ADMIN; -- Obligatorio para conectarse a la BD
GRANT CREATE TABLE TO PCP_ADMIN; -- Para un desarrollador
GRANT CREATE PROCEDURE TO PCP_ADMIN;

GRANT SELECT, INSERT, UPDATE, DELETE ON SL_USUARIO_PCP TO PCP_ADMIN;
GRANT EXECUTE ON pkg_sl_usuario_pcp TO PCP_ADMIN;
GRANT PCP_ADMIN to PORTALP;

