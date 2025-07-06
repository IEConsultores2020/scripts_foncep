--PROCEDURE PR_LLENAR_TABLA_ANEXOS


--  CURSOR cur_anexos  IS
SELECT a.codigo,
       a.descripcion,
       a.tabla_detalle,
       c.tipo_ra_ogt,
       c.codigo_opget
  FROM rh_lm_centros_costo a, rh_lm_ra_cc b, rh_lm_ra_cc_ogt c
 WHERE a.codigo = b.cc
   AND b.ra = c.ra
   AND b.transaccion = c.transaccion
   AND b.cc = c.cc
   AND b.ra = 1 --un_tipo_ra
   AND c.grupo_ra = 5 --un_grupo_ra
   and tabla_detalle LIKE '%ENTIDAD%'
   --tabla_detalle = CESANTIAS, ENTIDAD, BENEFICIARIOS, EMBARGO, 
   ;

  --CURSOR cur_nxp (un_nro_ra  NUMBER)     IS
    SELECT nfuncionario, SUM(valor) valor
	    FROM rh_t_lm_valores a, rh_lm_cuenta b
	   WHERE b.stipo_funcionario =   a.stipofuncionario
	     AND b.sconcepto         =   a.sconcepto
	     AND a.periodo           =   '30-JUN-2025' --una_fecha_final
	     AND a.ntipo_nomina      =   0 --un_tipo_nomina	
       AND a.sdevengado       IN   (0,1)
	     AND a.nro_ra            =   14 --un_nro_ra	
	     AND b.scompania         =   206 --una_compania
	     AND b.tipo_ra           =   1 --un_tipo_ra
	     AND b.grupo_ra         IN  ('5') --un_grupo_ra)
	     AND b.ncierre           =   1
	     -- RQ2523-2005   05/12/2005
       AND   b.dfecha_inicio_vig <= '30-JUN-2025'
       AND  (b.dfecha_final_vig  >= '30-JUN-2025' OR b.dfecha_final_vig IS NULL)
       -- Fin RQ2523
      Having Sum(valor) <> 0
	  GROUP BY nfuncionario;


--trae datos basicos persona tipo_documento, numero_identificacion, nombres, primer_apellido, segundo_apellido 
 mi_persona_type:=pk_detalle_anexos_ra.fn_detalle_personas (mi_funcionario, mi_err);

 /*FUNCTION FN_DETALLE_FUNCIONARIO (un_funcionario NUMBER, mi_err  OUT NUMBER) RETURN funcionario_type IS
     CURSOR   c_funcionario IS*/
      SELECT forma_pago, codigo_banco, tipo_cuenta, cuenta_bancaria
      FROM   rh_funcionario
      WHERE  personas_interno in (651,652,588)
;   --    numero_identificacion in (1030592799,79693028) --651, 652

/*
FORMA_PAGO;CODIGO_BANCO;TIPO_CUENTA;CUENTA_BANCARIA
A;1074;A;14188453679
A;558;A;1260000000192
*/

    --CURSOR   c_banco(un_cod_banco  VARCHAR2) IS
      SELECT codigo, cod_superbancaria
      FROM   rh_entidad
      WHERE  (tipo  LIKE '%BANC%' OR tipo LIKE '%CORPORACION%')
      AND    codigo in  (1074,558) --un_cod_banco
      ;
      /*
 CODIGO;COD_SUPERBANCARIA
1074;7
558;558
*/


mi_id_tercero:=fn_asociar_tercero_ra(mi_tabla_detalle, NULL, mi_funcionario, mi_err);

 mi_persona_type:=pk_detalle_anexos_ra.fn_detalle_personas (mi_funcionario, mi_err);


--------------------------------------
----EMBARGOS
--------------------------------------


--OPEN cur_embargos(mi_cc, un_nro_ra);
--  CURSOR cur_embargos (un_cc NUMBER, un_nro_ra  NUMBER) IS
SELECT a.stercero, a.nfuncionario, a.sdescuento, SUM(valor) valor
  FROM rh_t_lm_valores a, rh_lm_cuenta b, rh_lm_centros_costo c
 WHERE b.stipo_funcionario = a.stipofuncionario
   AND b.sconcepto = a.sconcepto
   AND b.cc = c.codigo
   AND a.periodo = '30-jun-2025' --una_fecha_final
   AND a.ntipo_nomina = 0 --un_tipo_nomina
   AND a.sdevengado IN (0, 1)
 --  AND a.nro_ra = 14 --un_nro_ra
   AND b.scompania = 206 --una_compania
   AND b.tipo_ra = 1 --un_tipo_ra
   AND b.grupo_ra IN ('5') --un_grupo_ra)
   AND b.ncierre = 1
      -- RQ2523-2005   05/12/2005
   AND b.dfecha_inicio_vig <= '30-jun-2025' --una_fecha_final
   AND (b.dfecha_final_vig >= '30-jun-2025' OR b.dfecha_final_vig IS NULL)
      -- Fin RQ2523  
   AND b.cc = 6 --6 EMBARGO% un_cc
 GROUP BY stercero, a.nfuncionario, a.sdescuento;

/*
 "STERCERO","NFUNCIONARIO","SDESCUENTO","VALOR"
"5818",588,6,-650000
"2979",588,5,-650000
*/

mi_embargo_type        pk_detalle_anexos_ra.embargo_type;    
   TYPE embargo_type IS RECORD
        (mi_cod_benef_pago       NUMBER(10),
         mi_tipo_doc_benef_pago  VARCHAR2(30),
         mi_nro_doc_benef_pago   VARCHAR2(20),
         mi_nombre               VARCHAR2(200),
         mi_nro_proceso          VARCHAR2(20),
         mi_forma_pago           VARCHAR2(30),
         mi_banco                VARCHAR2(10),
         mi_tipo_cuenta          VARCHAR2(30),
         mi_numero_cuenta        VARCHAR2(30),
         mi_concepto             VARCHAR2(30)); 
--mi_embargo_type:=pk_detalle_anexos_ra.fn_detalle_embargos(mi_tercero, mi_funcionario, mi_sdescuento, mi_err);
/* FUNCTION FN_DETALLE_EMBARGOS (un_beneficiario VARCHAR2, un_funcionario NUMBER, 
                                un_acto_adm VARCHAR2, mi_err OUT NUMBER) RETURN embargo_type IS
                                */
   --CURSOR c_embargo IS
    SELECT b.codigo,
           b.tipo_documento,
           b.numero_documento,
           b.nombres || b.apellidos,
           -- RQ371-2008		09-01-2009
           -- a.identificacion_descuento,
           a.proceso,
           -- Fin RQ371-2008
           a.forma_pago,
           a.banco,
           a.tipo_cuenta,
           a.numero_cuenta,
           a.concepto
    FROM   rh_descuentos_f a, rh_embargos_beneficiario b
    WHERE  b.codigo            = a.cod_benef_pago
    AND    a.beneficiario      IN (5818,2979) --un_beneficiario
    AND    a.funcionario       = 588 --un_funcionario
    AND    a.numero_descuento  IN (6,5) --un_acto_adm;
/*
"CODIGO","TIPO_DOCUMENTO","NUMERO_DOCUMENTO","B.NOMBRES||B.APELLIDOS",                                      "PROCESO",              "FORMA_PAGO","BANCO","TIPO_CUENTA","NUMERO_CUENTA","CONCEPTO"
17,"COD_JUZGADO",       "110012041722","JUZGADO VEINTIDOS CIVIL MUNICIPAL DE DESCONGESTION DE MINIMA CUANTIA","1400302220240127500","B",        "01",     "JUDICIAL",   "110012041022","EJECUTIVO"
45,"COD_JUZGADO",       "110012041067","JUZGADO SESENTA Y SIETE CIVIL MUNICIPAL DE BOGOTA",                     "400306720250021300","B",       "01",     "JUDICIAL",   "110012041067","EJECUTIVO"
*/
33513

  -- mi_demandante_type:=pk_detalle_anexos_ra.fn_detalle_demandante(mi_tercero, mi_funcionario, mi_sdescuento, mi_err);
  -- FUNCTION FN_DETALLE_DEMANDANTE (un_beneficiario VARCHAR2, un_funcionario NUMBER, 
   --                               un_acto_adm VARCHAR2, mi_err OUT NUMBER) RETURN demandante_type IS
 
  --CURSOR c_demandante IS
    SELECT b.codigo,
           b.tipo_documento,
           b.numero_documento, 
           b.nombres || ' ' || b.apellidos
    FROM   rh_descuentos_f a, rh_embargos_beneficiario b
    WHERE  b.codigo            = a.demandante
    AND    a.beneficiario      IN (5818,2979) --= un_beneficiario
    AND    a.funcionario       = 588 --un_funcionario
    AND    a.numero_descuento  IN (6,5) --= un_acto_adm;
/*
"CODIGO","TIPO_DOCUMENTO","NUMERO_DOCUMENTO","B.NOMBRES||''||B.APELLIDOS"
42,     "NIT",          "860034313",        "BANCO DAVIVIENDA SA "
44,     "NIT",          "860034594",        "SCOTIABANK COLPATRIA SA "
*/


--mi_persona_type:=pk_detalle_anexos_ra.fn_detalle_personas (mi_funcionario, mi_err);



--mi_beneficiario_type:=pk_detalle_anexos_ra.fn_detalle_beneficiarios(TO_NUMBER(mi_tercero), mi_err);
 
-- FUNCTION FN_DETALLE_BENEFICIARIOS(un_beneficiario NUMBER, mi_err   OUT  NUMBER)  RETURN beneficiarios_type IS
    
  --  CURSOR   c_beneficiario IS
      SELECT codigo_beneficiario, tipo_documento_beneficiario, numero_identificacion_benefici,
             beneficiario, forma_pago, cod_banco, tipo_cuenta, cuenta_bancaria
      FROM   rh_beneficiarios
      WHERE  codigo_beneficiario IN (5818,2979) -- = un_beneficiario;

/*
"CODIGO_BENEFICIARIO","TIPO_DOCUMENTO_BENEFICIARIO","NUMERO_IDENTIFICACION_BENEFICI","BENEFICIARIO","FORMA_PAGO","COD_BANCO","TIPO_CUENTA","CUENTA_BANCARIA"
2979,               "COD_JUZGADO",                  "110012041722","JUZGADO VEINTIDOS CIVIL MUNICIPAL DE DESCONGESTION","B","","",""
5818,               "COD_JUZGADO",                  "110012041067","JUZGADO SESENTA Y SIETE CIVIL MUNICIPAL DE BOGOTA","B","","",""
*/

/*mi_id_tercero:=fn_asociar_tercero_ra('DESCUENTOS', NULL, mi_embargo_type.mi_cod_benef_pago, mi_err);
FUNCTION FN_ASOCIAR_TERCERO_RA (una_tabla    VARCHAR2,
                                un_tipo      VARCHAR2,
                                un_codigo    VARCHAR2,
                                mi_err  OUT  NUMBER) RETURN NUMBER IS
  ELSIF una_tabla = 'BENEFICIARIOS' THEN
  	 BEGIN*/
  	   SELECT id_tercero,beneficiarios --INTO mi_tercero
  	   FROM   rh_terceros
  	   WHERE  esquema       = 'RH' 
  	   AND    beneficiarios in (5818,2979) --= un_codigo;                          

/*
"ID_TERCERO","BENEFICIARIOS"
277019,2979
412876,5818
*/

/*       
mi_id_ogt:=pk_ogt_bd_crear_ra.fn_existe_proveedor(mi_id_tercero,SYSDATE);        
  FUNCTION FN_EXISTE_PROVEEDOR(UN_ID    OGT_PROVEEDORES_RA.ID%TYPE
   ) RETURN NUMBER IS*/

 SELECT COUNT(*)
-- INTO   MI_CUANTOS
 FROM   OGT_PROVEEDORES_RA
 WHERE  ID in (277109) --= UN_ID;
 
 IF MI_CUANTOS = 0 THEN
  BEGIN
   SELECT ID_PROVEEDORES
   FROM   OGT_PROVEEDORES_TERCEROS
   WHERE  ID_TERCEROS in (277109,412876) --UN_ID
   ;

 END IF;


   mi_id_tercero:=fn_asociar_tercero_ra('DESCUENTOS', NULL, mi_demandante_type.mi_cod_ddte, mi_err);
  42,44
  
   mi_id_ogt:=pk_ogt_bd_crear_ra.fn_existe_proveedor(mi_id_tercero);
   FUNCTION FN_ASOCIAR_TERCERO_RA (una_tabla    VARCHAR2,
                                un_tipo      VARCHAR2,
                                un_codigo    VARCHAR2,
                                mi_err  OUT  NUMBER) RETURN NUMBER IS

  mi_tercero    NUMBER:=NULL;

BEGIN
  mi_err:=0;
   ....
  ELSIF embargos_benef, una_tabla = 'DESCUENTOS' THEN
     BEGIN
  	   SELECT embargos_benef, id_tercero --INTO mi_tercero
  	   FROM   rh_terceros
  	   WHERE  esquema        = 'RH'
  	   AND    embargos_benef in (42,44) --
       ;un_codigo;
  	 EXCEPTION
	     WHEN OTHERS THEN
	       pr_despliega_mensaje('AL_STOP_1', SUBSTR(SQLERRM,1,120));
         mi_err:=1;
  	 END;

/*
"EMBARGOS_BENEF","ID_TERCERO"
42,49
44,190597
  */

--sino tabla detalle
     /* IF mi_tabla_detalle LIKE '%NOMBRE%' OR
         mi_tabla_detalle = 'ENTIDAD_BENEFICIARIOS' THEN
        mi_consulta := mi_consulta || 'a.sconcepto, ';
      END IF;*/
SELECT  * -- a.stercero, SUM(valor) valor, SUM(valor_saldo) valor_saldo
                      FROM     rh_t_lm_valores a, rh_lm_cuenta b, rh_lm_centros_costo c
                      WHERE    b.stipo_funcionario =  a.stipofuncionario
                      AND      b.sconcepto         =  a.sconcepto
                      AND      b.cc                =  c.codigo
                      AND      valor <> 0
                      AND      trunc(a.periodo)    =  '30-JUN-2025' --una_fecha_final''
                      AND      a.ntipo_nomina      =  0
                      AND      a.sdevengado   IN (0,1)

                      AND   a.nro_ra            = 14
                     AND b.scompania  = 206
                     
                      AND   b.tipo_ra           =  1
                      AND   b.grupo_ra          IN ('5')
                      AND   b.ncierre           =  1
                      AND   b.dfecha_inicio_vig <= '30-JUN-2025'
                      AND  (b.dfecha_final_vig  >= '30-JUN-2025' OR b.dfecha_final_vig IS NULL) 
                      -- Fin RQ2523
                      AND      b.cc                =  mi_cc
;
                    /*
                     IF mi_tabla_detalle LIKE '%NOMBRE%' OR
                    GROUP BY
         mi_tabla_detalle = 'ENTIDAD_BENEFICIARIOS' THEN
        mi_consulta := mi_consulta || ' GROUP BY a.sconcepto, a.stercero';
      ELSE
        mi_consulta := mi_consulta || ' GROUP BY a.stercero';
      END IF;*/


      SELECT a.codigo,
       a.descripcion,
       a.tabla_detalle,
       c.tipo_ra_ogt,
       c.codigo_opget
  FROM rh_lm_centros_costo a, rh_lm_ra_cc b, rh_lm_ra_cc_ogt c
 WHERE a.codigo = b.cc
   AND b.ra = c.ra
   AND b.transaccion = c.transaccion
   AND b.cc = c.cc
   AND b.ra = 1 --un_tipo_ra
   AND c.grupo_ra = 5 --un_grupo_ra
   and tabla_detalle NOT LIKE '%NOMINA%'
   and tabla_detalle NOT LIKE '%CESANTIAS%'
   and tabla_detalle NOT LIKE '%EMBARGO%'
   --tabla_detalle = CESANTIAS, ENTIDAD, BENEFICIARIOS, EMBARGO, 
   ;


