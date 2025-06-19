
----BTN ASIGNAR_COMPROMISOS
DECLARE

	TYPE ra_vig_type       IS RECORD
	    (mi_nro_ra         rh_lm_ra.nro_ra%TYPE,
	     mi_vigencia       rh_lm_ra.vigencia%TYPE);
  
  mi_ra_vig_type         ra_vig_type;

BEGIN
	mi_ra_vig_type.mi_nro_ra:=0;
  BEGIN
	  SELECT nro_ra, vigencia, ntipo_nomina --INTO mi_ra_vig_type
	  FROM   rh_lm_ra
	  WHERE  scompania              = 206 --:parameter.p_compania
	  AND    vigencia               = 2025 -- vigencia_presupuesto --para saber si hay RA para la vigencia
	  AND    unidad_ejecutora       = '01' --:parameter.p_unidad
	  AND    tipo_ra                = 1 --:parameter.p_tipo_ra
	  AND    grupo_ra               = 5 --:parameter.p_grupo_ra
	  AND    ntipo_nomina           = '0' --:parameter.p_tipo_nomina
	  AND    dfecha_inicial_periodo = '01-MAY-2025' --:parameter.p_fecha_inicial;
  EXCEPTION
    WHEN no_data_found THEN
      pr_despliega_mensaje('AL_STOP_1','No existe RA para la vigencia.');
      RETURN;
    WHEN OTHERS THEN
      pr_despliega_mensaje('AL_STOP_1','Ocurrió el error : ' || SUBSTR(SQLERRM,1,120));
      RETURN;
  END;
  IF mi_ra_vig_type.mi_nro_ra = 0 THEN
      pr_despliega_mensaje('AL_STOP_1','No existe RA para la vigencia.');
      RETURN;
  END IF;    
  pr_lov_compromisos_vigencia(mi_ra_vig_type.mi_vigencia,
                              :parameter.p_compania,
                              :parameter.p_unidad,
                              :parameter.p_tipo_ra,
                              :parameter.p_grupo_ra,
                              :parameter.p_fecha_final,
                              :parameter.p_tipo_nomina,
                              mi_ra_vig_type.mi_nro_ra);
EXCEPTION
	WHEN OTHERS THEN
	  pr_despliega_mensaje('AL_STOP_1','Ocurrió el error : ' || SUBSTR(SQLERRM,1,120));
END;

----pr_lov_compromisos_vigencia
PROCEDURE PR_LOV_COMPROMISOS_VIGENCIA (una_vigencia          NUMBER,
                                       una_compania          VARCHAR2,
                                       una_unidad_ejecutora  VARCHAR2,
                                       un_tipo_ra            VARCHAR2,
                                       un_grupo_ra           VARCHAR2,
                                       una_fecha_final       DATE,
                                       un_tipo_nomina        NUMBER,
                                       un_nro_ra             NUMBER) IS

--  Declara variables para el manejo del Record Gruop
  mi_rgname     VARCHAR2(40) := 'L_COMPR_VIG';
	mi_rgid       RecordGroup; 
	mi_gcid       GroupColumn; 
	mi_contador   NUMBER;
	mi_lovid      LOV;
	mi_ver_lov    BOOLEAN;

--  Declara variables con los nombres de las columnas del RecordGroup
  mi_rgcol1  VARCHAR2(50) := mi_rgname||'.numero_compromiso'; 
  mi_rgcol2  VARCHAR2(50) := mi_rgname||'.objeto';
  mi_rgcol3  VARCHAR2(50) := mi_rgname||'.tipo_compromiso';
  mi_rgcol4  VARCHAR2(50) := mi_rgname||'.numero_registro';
  mi_rgcol5  VARCHAR2(50) := mi_rgname||'.numero_disponibilidad';

--Variables packages de PREDIS  
  cur_compromisos     pk_pr_compromisos.cur_contratos_tipo;
  mis_compromisos     pk_pr_compromisos.TypRec_compromisos_tipo;
  mi_err              NUMBER;

BEGIN
	mi_err:=0;
	--  Verifica que no exista el record group 
  mi_rgid := Find_Group(mi_rgname); 
  IF Not Id_Null(mi_rgid) THEN
     Delete_Group(mi_rgid);
  END IF;
  mi_rgid := Create_Group(mi_rgname);  
  -- Adiciona las columnas al record group 
  mi_gcid := Add_Group_Column(mi_rgid, 'numero_compromiso',NUMBER_COLUMN); 
  mi_gcid := Add_Group_Column(mi_rgid, 'objeto',CHAR_COLUMN,200); 
  mi_gcid := Add_Group_Column(mi_rgid, 'tipo_compromiso',CHAR_COLUMN,30); 
  mi_gcid := Add_Group_Column(mi_rgid, 'numero_registro',NUMBER_COLUMN);
  mi_gcid := Add_Group_Column(mi_rgid, 'numero_disponibilidad',NUMBER_COLUMN); 
  mi_contador := 1;
  --Adiciona los tipos de compromisos creados como RA
	cur_compromisos:= pk_pr_compromisos.fn_pre_traer_compr_tipo(una_vigencia,
	                                                            una_compania,
	                                                            una_unidad_ejecutora,
	                                                            '01');  --Tipo de compromiso 'RA'
  LOOP
     FETCH cur_compromisos INTO  mis_compromisos.numero_compromiso,
                                 mis_compromisos.objeto,
                                 mis_compromisos.tipo_compromiso,
                                 mis_compromisos.numero_registro,
                                 mis_compromisos.numero_disponibilidad;
     EXIT WHEN cur_compromisos%NOTFOUND;
       Add_Group_Row(mi_rgid, END_OF_GROUP);
       Set_Group_Number_Cell(mi_rgcol1, mi_contador, mis_compromisos.numero_compromiso);
       Set_Group_Char_Cell(mi_rgcol2, mi_contador, mis_compromisos.objeto); 
       Set_Group_Char_Cell(mi_rgcol3, mi_contador, mis_compromisos.tipo_compromiso);
       Set_Group_Number_Cell(mi_rgcol4, mi_contador, mis_compromisos.numero_registro);
       Set_Group_Number_Cell(mi_rgcol5, mi_contador, mis_compromisos.numero_disponibilidad); 
       mi_contador := mi_contador + 1;
  END LOOP;
  --Adiciona los tipos de compromisos creados como Memorandos
	cur_compromisos:= pk_pr_compromisos.fn_pre_traer_compr_tipo(una_vigencia,
	                                                            una_compania,
	                                                            una_unidad_ejecutora,
	                                                            '59');  --Tipo de compromiso Memorando
  LOOP
     FETCH cur_compromisos INTO  mis_compromisos.numero_compromiso,
                                 mis_compromisos.objeto,
                                 mis_compromisos.tipo_compromiso,
                                 mis_compromisos.numero_registro,
                                 mis_compromisos.numero_disponibilidad;
     EXIT WHEN cur_compromisos%NOTFOUND;
       Add_Group_Row(mi_rgid, END_OF_GROUP);
       Set_Group_Number_Cell(mi_rgcol1, mi_contador, mis_compromisos.numero_compromiso);
       Set_Group_Char_Cell(mi_rgcol2, mi_contador, mis_compromisos.objeto); 
       Set_Group_Char_Cell(mi_rgcol3, mi_contador, mis_compromisos.tipo_compromiso);
       Set_Group_Number_Cell(mi_rgcol4, mi_contador, mis_compromisos.numero_registro);
       Set_Group_Number_Cell(mi_rgcol5, mi_contador, mis_compromisos.numero_disponibilidad); 
       mi_contador := mi_contador + 1;
  END LOOP;
  CLOSE cur_compromisos;  
	mi_LOVid:=FIND_LOV('L_COMPR_VIG');
	SET_LOV_PROPERTY(mi_LOVid, GROUP_NAME, mi_rgname);
  mi_ver_lov := SHOW_LOV(mi_LOVid);
	IF mi_ver_lov THEN
     pr_asignar_imputacion_vigencia (una_compania,
                                     una_vigencia,
                                     una_unidad_ejecutora,
                                     :b_buttom.tipo_compromiso_vig,
                                     :b_buttom.numero_compromiso_vig,
                                     un_tipo_ra,
                                     un_grupo_ra,
                                     una_fecha_final,
                                     un_tipo_nomina,
                                     un_nro_ra,
                                     mi_err);
  END IF;
EXCEPTION
	WHEN OTHERS THEN
		pr_despliega_mensaje('AL_STOP_1','Ocurrió el error : ' || SUBSTR(SQLERRM,1,120));
END;

--extracts
select pk_pr_compromisos.fn_pre_traer_compr_tipo(2025, --una_vigencia,
	                                        206, --una_compania,
	                                        '01', --una_unidad_ejecutora,
	                                        '59')
from dual;

 /* -----------------------------------------------------------------------------------------
  Funcion: fn_pre_traer_compr_tipo
  Descripcion: Devuelve un cursor con los contratos de un tipo de compromiso especifico
  Parametros: una_vigencia Vigencia
              un_codigo_compania Codigo de la Entidad
              un_codigo_unidad   Codigo de la unidad Ejecutora
              un_tipo_compromiso Cadena donde vienen los posibles tipos de compromisos manejados,
                                 separados por coma. Ejemplo: '01','02','03'
  ----------------------------------------------------------------------------------------   */
  FUNCTION fn_pre_traer_compr_tipo(una_vigencia NUMBER,un_codigo_compania VARCHAR2,un_codigo_unidad VARCHAR2,
  un_tipo_compromiso VARCHAR2) RETURN cur_contratos_tipo IS
  mi_cadena           VARCHAR2(500);
  mi_estado                     VARCHAR2(30);
  mi_cursor_contratos Pk_Pr_Compromisos.cur_contratos_tipo;
  BEGIN
  mi_estado := 'ANULADO';
  OPEN mi_cursor_contratos FOR SELECT UNIQUE PR_COMPROMISOS.numero_compromiso,PR_COMPROMISOS.objeto,PR_COMPROMISOS.tipo_compromiso,
                                             PR_REGISTRO_PRESUPUESTAL.numero_registro, PR_REGISTRO_PRESUPUESTAL.numero_disponibilidad
                                 FROM PR_COMPROMISOS,PR_REGISTRO_PRESUPUESTAL
                                 WHERE PR_COMPROMISOS.vigencia = 2025 /*una_vigencia*/ AND
                                 PR_COMPROMISOS.codigo_compania = 206 /*un_codigo_compania*/ AND
                                 PR_COMPROMISOS.codigo_unidad_ejecutora = '01' /*un_codigo_unidad*/ AND
                                -- PR_COMPROMISOS.tipo_compromiso IN ('59' /*un_tipo_compromiso*/) AND
                                 PR_COMPROMISOS.vigencia = PR_REGISTRO_PRESUPUESTAL.vigencia AND
                                 PR_COMPROMISOS.codigo_compania = PR_REGISTRO_PRESUPUESTAL.codigo_compania AND
                                 PR_COMPROMISOS.codigo_unidad_ejecutora = PR_REGISTRO_PRESUPUESTAL.codigo_unidad_ejecutora AND
                                 PR_COMPROMISOS.numero_registro = PR_REGISTRO_PRESUPUESTAL.numero_registro AND
                                 PR_REGISTRO_PRESUPUESTAL.estado <>  'ANULADO' AND /*mi_estado */ 
                                 PR_COMPROMISOS.objeto like '%NOMINA%'; -- Por solicitud de Fany Malagon
                                                                                    --con el fin de poder realizar el paralelo
                                                                                    --se comentarea lo correspondiente al estado
    RETURN(mi_cursor_contratos);
  END fn_pre_traer_compr_tipo;


  select *
  from bintablas
  where grupo = 'PREDIS'
  and nombre LIKE '%COMUN';


  select *
  from pr_comun.pk_pr_compromisos