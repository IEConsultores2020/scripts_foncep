CREATE OR REPLACE PACKAGE pk_sl_pcp_usuarios AS

    -- 1. Define un tipo RECORD basado en la tabla SL_PCP_USUARIOS
    --    Esto crea una estructura que contiene todas las columnas de la tabla
    TYPE sl_pcp_usuarios_rec IS RECORD (
        id                 SL_PCP_USUARIOS.ID%TYPE,
        usuario            SL_PCP_USUARIOS.USUARIO%TYPE,
        nombre_usuario     SL_PCP_USUARIOS.NOMBRE_USUARIO%TYPE,
        clave              SL_PCP_USUARIOS.CLAVE%TYPE,
        fecha_creacion     SL_PCP_USUARIOS.FECHA_CREACION%TYPE,
        estado             SL_PCP_USUARIOS.ESTADO%TYPE,
        usuario_creacion   SL_PCP_USUARIOS.USUARIO_CREACION%TYPE,
        usuario_actualiza  SL_PCP_USUARIOS.USUARIO_ACTUALIZA%TYPE,
        fecha_actualiza    SL_PCP_USUARIOS.FECHA_ACTUALIZA%TYPE,
        tipo_usuario       SL_PCP_USUARIOS.TIPO_USUARIO%TYPE,
        inicializa_clave   SL_PCP_USUARIOS.INICIALIZA_CLAVE%TYPE,
        centro_costo       SL_PCP_USUARIOS.CENTRO_COSTO%TYPE
    );

    -- Operación CREATE: Recibe un registro completo para insertar
    FUNCTION create_usuario(
        usuario            SL_PCP_USUARIOS.USUARIO%TYPE,
        nombre_usuario     SL_PCP_USUARIOS.NOMBRE_USUARIO%TYPE,
        clave              SL_PCP_USUARIOS.CLAVE%TYPE,
        estado             SL_PCP_USUARIOS.ESTADO%TYPE,
        tipo_usuario       SL_PCP_USUARIOS.TIPO_USUARIO%TYPE,
        inicializa_clave   SL_PCP_USUARIOS.INICIALIZA_CLAVE%TYPE,
        centro_costo       SL_PCP_USUARIOS.CENTRO_COSTO%TYPE
    ) RETURN NUMBER;

    -- Operación READ: Recibe el ID y retorna un registro completo
    PROCEDURE read_usuario(
        p_id             IN SL_PCP_USUARIOS.ID%TYPE,
        p_usuario_data   OUT sl_pcp_usuarios_rec
    );

    -- Operación UPDATE: Recibe el ID y un registro con los datos a actualizar
    PROCEDURE update_usuario(
        p_id              IN SL_PCP_USUARIOS.ID%TYPE,
        --usuario           IN SL_PCP_USUARIOS.USUARIO%TYPE,
        nombre_usuario    IN SL_PCP_USUARIOS.NOMBRE_USUARIO%TYPE,
        estado            IN SL_PCP_USUARIOS.ESTADO%TYPE,
        tipo_usuario      IN SL_PCP_USUARIOS.TIPO_USUARIO%TYPE,
        inicializa_clave  IN SL_PCP_USUARIOS.INICIALIZA_CLAVE%TYPE,
        centro_costo      IN SL_PCP_USUARIOS.CENTRO_COSTO%TYPE
    );

    -- Operación DELETE (no necesita un registro, solo el ID)
    PROCEDURE delete_usuario(
        p_id IN SL_PCP_USUARIOS.ID%TYPE
    );

    -- Función de Sign In (no necesita un registro para este propósito específico)
    FUNCTION signin(
        p_usuario IN SL_PCP_USUARIOS.USUARIO%TYPE,
        p_clave   IN SL_PCP_USUARIOS.CLAVE%TYPE
    ) RETURN NUMBER;

    -- Placeholder for signout procedure, if needed
    -- PROCEDURE signout(
    --     p_usuario IN SL_PCP_USUARIOS.USUARIO%TYPE
    -- );

END pk_sl_pcp_usuarios;
/

---

CREATE OR REPLACE PACKAGE BODY pk_sl_pcp_usuarios AS

    -- Implementación de CREATE
    FUNCTION create_usuario(
        usuario            IN SL_PCP_USUARIOS.USUARIO%TYPE,
        nombre_usuario     IN SL_PCP_USUARIOS.NOMBRE_USUARIO%TYPE,
        clave              IN SL_PCP_USUARIOS.CLAVE%TYPE,
        estado             IN SL_PCP_USUARIOS.ESTADO%TYPE,
        tipo_usuario       IN SL_PCP_USUARIOS.TIPO_USUARIO%TYPE,
        inicializa_clave   IN SL_PCP_USUARIOS.INICIALIZA_CLAVE%TYPE,
        centro_costo       IN SL_PCP_USUARIOS.CENTRO_COSTO%TYPE
    ) RETURN NUMBER IS
        user_id NUMBER;
    BEGIN
        INSERT INTO SL_PCP_USUARIOS (
            USUARIO, NOMBRE_USUARIO, CLAVE, FECHA_CREACION, ESTADO,
            USUARIO_CREACION, USUARIO_ACTUALIZA, FECHA_ACTUALIZA, TIPO_USUARIO,
            INICIALIZA_CLAVE, CENTRO_COSTO
        ) VALUES (
            usuario,
            nombre_usuario,
            clave,
            sysdate, --p_usuario_data.fecha_creacion,
            estado,
            user, --p_usuario_data.usuario_creacion,
            null, --p_usuario_data.usuario_actualiza,
            null, --p_usuario_data.fecha_actualiza,
            tipo_usuario,
            inicializa_clave,
            centro_costo
        );

        RETURN SL_PCP_USUARIOS_SEQ.CURRVAL;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN -1;
    END create_usuario;

    -- Implementación de READ
    PROCEDURE read_usuario(
        p_id             IN SL_PCP_USUARIOS.ID%TYPE,
        p_usuario_data   OUT sl_pcp_usuarios_rec
    ) IS
    BEGIN
        SELECT ID, USUARIO, NOMBRE_USUARIO, CLAVE, FECHA_CREACION, ESTADO,
               USUARIO_CREACION, USUARIO_ACTUALIZA, FECHA_ACTUALIZA, TIPO_USUARIO,
               INICIALIZA_CLAVE, CENTRO_COSTO
          INTO p_usuario_data.id,
               p_usuario_data.usuario,
               p_usuario_data.nombre_usuario,
               p_usuario_data.clave,
               p_usuario_data.fecha_creacion,
               p_usuario_data.estado,
               p_usuario_data.usuario_creacion,
               p_usuario_data.usuario_actualiza,
               p_usuario_data.fecha_actualiza,
               p_usuario_data.tipo_usuario,
               p_usuario_data.inicializa_clave,
               p_usuario_data.centro_costo
          FROM SL_PCP_USUARIOS
         WHERE ID = p_id;
    END read_usuario;

    -- Implementación de UPDATE
    PROCEDURE update_usuario(
        p_id              IN SL_PCP_USUARIOS.ID%TYPE,
        --usuario           IN SL_PCP_USUARIOS.USUARIO%TYPE,
        nombre_usuario    IN SL_PCP_USUARIOS.NOMBRE_USUARIO%TYPE,
        estado            IN SL_PCP_USUARIOS.ESTADO%TYPE,
        tipo_usuario      IN SL_PCP_USUARIOS.TIPO_USUARIO%TYPE,
        inicializa_clave  IN SL_PCP_USUARIOS.INICIALIZA_CLAVE%TYPE,
        centro_costo      IN SL_PCP_USUARIOS.CENTRO_COSTO%TYPE
    ) IS
    BEGIN
        UPDATE SL_PCP_USUARIOS
           SET NOMBRE_USUARIO     = nombre_usuario,
               ESTADO             = estado,
               USUARIO_ACTUALIZA  = user, --p_usuario_data.usuario_actualiza,
               FECHA_ACTUALIZA    = sysdate, --p_usuario_data.fecha_actualiza,
               TIPO_USUARIO       = tipo_usuario,
               INICIALIZA_CLAVE   = inicializa_clave,
               CENTRO_COSTO       = centro_costo
         WHERE ID = p_id;
    END update_usuario;

    -- Implementación de DELETE
    PROCEDURE delete_usuario(
        p_id IN SL_PCP_USUARIOS.ID%TYPE
    ) IS
    BEGIN
        DELETE FROM SL_PCP_USUARIOS
         WHERE ID = p_id;
    END delete_usuario;

    -- Implementación de SIGNIN
    FUNCTION signin(
        p_usuario IN SL_PCP_USUARIOS.USUARIO%TYPE,
        p_clave   IN SL_PCP_USUARIOS.CLAVE%TYPE
    ) RETURN NUMBER IS
        v_user_id SL_PCP_USUARIOS.ID%TYPE;
    BEGIN
        SELECT ID
          INTO v_user_id
          FROM SL_PCP_USUARIOS
         WHERE USUARIO = p_usuario
           AND CLAVE   = p_clave -- Considera almacenar contraseñas hasheadas y usar una función de verificación de hash
           AND ESTADO  = 'ACTIVO'; -- Asumiendo que 'ACTIVO' es un estado válido

        RETURN v_user_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL; -- O un valor específico para indicar usuario/contraseña incorrectos
        WHEN TOO_MANY_ROWS THEN
            -- Esto no debería ocurrir si USUARIO es único, pero es buena práctica manejarlo
            RETURN NULL;
        WHEN OTHERS THEN
            -- Manejo de otros errores inesperados
            RAISE;
    END signin;

END pk_sl_pcp_usuarios;
/

CREATE OR REPLACE PUBLIC SYNONYM SL_PCP_USUARIOS FOR SL.SL_PCP_USUARIOS;

CREATE ROLE PCP_ADMIN;

GRANT CREATE SESSION TO PCP_ADMIN; -- Obligatorio para conectarse a la BD
GRANT CREATE TABLE TO PCP_ADMIN; -- Para un desarrollador
GRANT CREATE PROCEDURE TO PCP_ADMIN;

GRANT SELECT, INSERT, UPDATE, DELETE ON SL_PCP_USUARIOS TO PCP_ADMIN;
GRANT EXECUTE ON pk_sl_pcp_usuarios TO PCP_ADMIN;
GRANT PCP_ADMIN to PORTALP;

CREATE SEQUENCE SL_PCP_USUARIOS_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

CREATE OR REPLACE TRIGGER SL_TR_B_I_SL_PCP_USUARIOS
BEFORE INSERT ON SL_PCP_USUARIOS
FOR EACH ROW
BEGIN
	SELECT SL_PCP_USUARIOS_SEQ.NEXTVAL
    INTO :NEW.ID FROM dual;
END;
/

drop trigger sl_tr_b_i_sl_usuarios_pcp;
