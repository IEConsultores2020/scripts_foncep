--creacion
set serveroutput on
Declare
    mi_user_id number;
begin
    mi_user_id := pk_sl_pcp_usuarios.create_usuario(
            usuario            => 'pruebaftv2@hotmail.com',
            nombre_usuario     => 'pruebaftv',
            clave              => '1234',
            tipo_usuario       => '1',
            usuario_creacion   => 1,
            centro_costo       => 1
    );

    dbms_output.put_line('id creado '|| mi_user_id);
end;
/
set serveroutput off

--leer usuario o get
set serveroutput on
declare
  mi_user_id NUMBER := 3 ;--asigne el que devolvio anterior
  mi_usuario_data pk_sl_pcp_usuarios.sl_pcp_usuarios_rec;
begin
  
  pk_sl_pcp_usuarios.READ_USUARIO(P_ID  => mi_user_id,
                                  P_USUARIO_DATA => mi_usuario_data);
  dbms_output.put_line('usuario_id '||mi_usuario_data.id);
  dbms_output.put_line('usuario '||mi_usuario_data.usuario);                                  
end;
/
set serveroutput off

--signin usuario
set serveroutput on
declare
  mi_user_id NUMBER := 3 ;--asigne el que devolvio anterior
begin
  
  mi_user_id := pk_sl_pcp_usuarios.signin(
      usuario            => 'pruebaftv2@hotmail.com',
      clave              => '1234');
  dbms_output.put_line('Conectado como '||mi_user_id);                                 
end;
/
set serveroutput off

--Borrar usuario
set serveroutput on
declare
  mi_user_id NUMBER := 3 ;--asigne el que devolvio anterior
begin
  
  pk_sl_pcp_usuarios.delete_usuario(P_ID  => mi_user_id);
  dbms_output.put_line('Borrado');                                 
end;
/
set serveroutput off


select * from SL_PCP_USUARIOS



--Cambiar sequencia con mas
SELECT MAX(ID) FROM SL_PCP_USUARIOS;
ALTER SEQUENCE SL_PCP_USUARIOS_SEQ RESTART START WITH 45;