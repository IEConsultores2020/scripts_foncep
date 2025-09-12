  pr_lov_compromisos_vigencia(mi_ra_vig_type.mi_vigencia, 2025
                              :parameter.p_compania,      206
                              :parameter.p_unidad,        01
                              :parameter.p_tipo_ra,       1
                              :parameter.p_grupo_ra,      5
                              :parameter.p_fecha_final,   '30/jun/2025'
                              :parameter.p_tipo_nomina,   0
                              mi_ra_vig_type.mi_nro_ra);  14


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

----
SELECT UNIQUE PR_COMPROMISOS. * /*PR_COMPROMISOS.numero_compromiso,PR_COMPROMISOS.objeto,PR_COMPROMISOS.tipo_compromiso,
                                             PR_REGISTRO_PRESUPUESTAL.numero_registro, PR_REGISTRO_PRESUPUESTAL.numero_disponibilidad*/
                                 FROM PR_COMPROMISOS,PR_REGISTRO_PRESUPUESTAL
                                 WHERE PR_COMPROMISOS.vigencia = 2025 /*una_vigencia*/ AND
                                 PR_COMPROMISOS.codigo_compania = 206 /*un_codigo_compania*/ AND
                                 PR_COMPROMISOS.codigo_unidad_ejecutora = '01' /*un_codigo_unidad*/ AND
                                 PR_COMPROMISOS.tipo_compromiso IN ('01' /*un_tipo_compromiso*/) AND
                                 PR_COMPROMISOS.vigencia = PR_REGISTRO_PRESUPUESTAL.vigencia AND
                                 PR_COMPROMISOS.codigo_compania = PR_REGISTRO_PRESUPUESTAL.codigo_compania AND
                                 PR_COMPROMISOS.codigo_unidad_ejecutora = PR_REGISTRO_PRESUPUESTAL.codigo_unidad_ejecutora AND
                                 PR_COMPROMISOS.numero_registro = PR_REGISTRO_PRESUPUESTAL.numero_registro AND
                                 PR_REGISTRO_PRESUPUESTAL.estado <>  'ANULADO' /*mi_estado*/  AND
                                 PR_REGISTRO_PRESUPUESTAL.numero_registro = 455
                                 ; 
----                                                              
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
     pr_asignar_imputacion_vigencia (una_compania,                        206
                                     una_vigencia,                        2025
                                     una_unidad_ejecutora,                01
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


select r.DESCRIPCION, p.* --sum(p.valor_rp), sum(p.valor_bruto)
from rh_lm_ra_presupuesto p, pr_rubro r
where p.compania=206
and p.vigencia= 2025
and p.unidad_ejecutora='01'
--and p.nro_ra=14
and p.registro_presupuestal=326
and p.disponibilidad=12
and p.vigencia = r.vigencia
and p.interno_rubro = r.interno;

select *
from pr_registro_presupuestal rp
where numero_registro=326
and numero_disponibilidad=12;

select *
from pr_rubro
;

 select *
  from ogt_anexo_nomina
 where vigencia = 2025
   and consecutivo = 14
   and codigo_centro_costos in ( 5,
                                 1285,
                                 1267 );

SELECT *
FROM RH_LM_RA_AUTO


pr_asignar_imputacion_vigencia()