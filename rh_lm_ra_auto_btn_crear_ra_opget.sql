--pr_llenar_ra
 CURSOR  c_ra  IS
    SELECT nro_ra, nro_ra_opget, vigencia, vigencia_presupuesto, numero_compromiso, aprobacion
    FROM   rh_lm_ra
    WHERE  scompania              = 206 --:parameter.p_compania
    AND    tipo_ra                = 1 --:parameter.p_tipo_ra
    AND    grupo_ra               = 5 --:parameter.p_grupo_ra
    AND    dfecha_inicial_periodo = '01/JAN/2026' --:parameter.p_fecha_inicial
    AND    dfecha_final_periodo   = '31/JAN/2026' --:parameter.p_fecha_final
    AND    ntipo_nomina           = 0 --:parameter.p_tipo_nomina



--pr_llenar_tabla_imputacion
  --CURSOR c_imputacion IS
    SELECT a.ano_pac,
           a.mes_pac,
           b.interno_rubro,
           b.disponibilidad,
           b.valor_bruto,
           b.registro_presupuestal,
           b.valor_rp
    FROM   rh_lm_ra a, rh_lm_ra_presupuesto b
    WHERE  a.scompania              = b.compania
    AND    a.vigencia               = b.vigencia
    AND    a.vigencia_presupuesto   = b.vigencia_presupuesto
    AND    a.unidad_ejecutora       = b.unidad_ejecutora
    AND    a.nro_ra                 = b.nro_ra
    AND    a.scompania              = 206 --una_compania
    AND    a.vigencia               = 2026 --una_vigencia
    AND    a.vigencia_presupuesto   = 2026 --una_vigencia_presupuesto
    AND    a.unidad_ejecutora       = '01' una_unidad_ejecutora
    AND    a.nro_ra                 = 1 --un_nro_ra
    AND    a.tipo_ra                = 1 --un_tipo_ra
    AND    a.grupo_ra               = 5 --un_grupo_ra
    AND    a.ntipo_nomina           = 1 -un_tipo_nomina
    AND    a.dfecha_inicial_periodo = una_fecha_inicial
    AND    a.dfecha_final_periodo   = una_fecha_final;

select * from rh_lm_ra_presupuesto
where compania = 206    
  and vigencia_presupuesto = 2026
order by vigencia desc


--pr_llenar_tabla_cc

--pr_llenar_tabla_anexos

--pr_llenar_tabla_fte


--pk_oget_db_crear_ra.pr_crear_ra
select to_char(fecha_diligenciamiento,'dd/mm/yyyy'), fecha_diligenciamiento
from ogt_documento_pago
where vigencia = 2026
and entidad= 206
and unidad_ejecutora = '01'
and tipo_documento = 'RA'
and consecutivo=1
--and fecha_diligenciamiento='05-FEB-26'
and to_char(fecha_diligenciamiento,'dd/mm/yyyy')='30/01/2026' --'05/02/2026'  --to_date('05/feb/2026','dd/mmm/yyyy')
--ogt_documento_pago no registra datos ;


--05-feb-2026
update ogt_documento_pago
set fecha_diligenciamiento=to_date('05/02/2026','dd/mm/yyyy')
where vigencia = 2026
and entidad= 206
and unidad_ejecutora = '01'
and tipo_documento = 'RA'
and consecutivo=1
and to_char(fecha_diligenciamiento,'dd/mm/yyyy')='30/01/2026'
;

commit;

declare
  num number;
begin  
 num := PK_SECUENCIAL.FN_TRAER_CONSECUTIVO
          ('OPGET','OGT_RA',2026,206 ,'01');

  dbms_output.put_line('num: ' || num);
end;

select *
from binconsecutivo
where grupo = 'OPGET'
and nombre = 'OGT_RA'
and vigencia = 2026
and codigo_compania = 206

--1. pr_validar_imputacion_pre


--2. pr_llenar_ra

--3. pr_llenar_tabla_imputacion
 llena mi_Tbl_imputacion_Ogt con:
  CURSOR c_imputacion IS
    SELECT a.ano_pac,
           a.mes_pac,
           b.interno_rubro,
           b.disponibilidad,
           b.valor_bruto,
           b.registro_presupuestal,
           b.valor_rp
   -- SELECT *           
    FROM   rh_lm_ra a, rh_lm_ra_presupuesto b
    WHERE  a.scompania              = b.compania
    AND    a.vigencia               = b.vigencia
    AND    a.vigencia_presupuesto   = b.vigencia_presupuesto
    AND    a.unidad_ejecutora       = b.unidad_ejecutora
    AND    a.nro_ra                 = b.nro_ra
    AND    a.scompania              = 206   --una_compania
    AND    a.vigencia               = 2026  --una_vigencia
    AND    a.vigencia_presupuesto   = 2026  --una_vigencia_presupuesto
    AND    a.unidad_ejecutora       = '01'  --una_unidad_ejecutora
    AND    a.nro_ra                 = 3     --un_nro_ra
    AND    a.tipo_ra                = 1     --un_tipo_ra
    AND    a.grupo_ra               = 5     --un_grupo_ra
    AND    a.ntipo_nomina           = 0     --un_tipo_nomina
    AND    a.dfecha_inicial_periodo = '01/FEB/2026'    --una_fecha_inicial
    AND    a.dfecha_final_periodo   = '28/FEB/2026'      --una_fecha_final
    ;

--4 pr_llenar_tabla_cc
  CURSOR c_cc IS
  	SELECT a.codigo, a.descripcion, a.codigo_maestro, c.tipo_ra_ogt, c.codigo_opget
      FROM rh_lm_centros_costo a, rh_lm_ra_cc b, rh_lm_ra_cc_ogt c
     WHERE a.codigo   = b.cc
       AND b.ra       = c.ra
       AND b.transaccion = c.transaccion
       AND b.cc       = c.cc
       AND b.ra       = 1 --un_tipo_ra
       AND c.grupo_ra = '5' --un_grupo_ra
       and a.codigo=1
       ;

    --Verificaciones
    select * from rh_lm_centros_costo
    where codigo=1
    ;       

    select * from rh_lm_ra_cc
    where cc=1
    ;

    select * from rh_lm_ra_cc_ogt c
    where transaccion=0
    and cc=1
    and ra=1 and grupo_ra=5
    ;

  CURSOR c_cc_ra (un_cc NUMBER) IS
	  SELECT b.cc, SUM(a.valor) valor
	  FROM   rh_t_lm_valores a, rh_lm_cuenta b
	  WHERE  b.stipo_funcionario = a.stipofuncionario
	  AND    b.sconcepto         = a.sconcepto
	  AND    a.periodo           = '28/FEB/2026'  --una_fecha_final
	  AND    a.ntipo_nomina      = 0    --un_tipo_nomina
	  AND    a.nro_ra            = 3    --un_nro_ra
	  AND    b.scompania         = 206  --una_compania
	  AND    b.tipo_ra           = 1    --un_tipo_ra
	  AND    b.grupo_ra          IN ('5' /*un_grupo_ra*/)
	  AND    b.ncierre           = 1
	  AND    b.cc                = 1 -- un_cc
	  -- RQ2523-2005   05/12/2005
    AND   b.dfecha_inicio_vig <= '28/FEB/2026' --una_fecha_final
    AND  (b.dfecha_final_vig  >= '28/FEB/2026' /*una_fecha_final*/ OR b.dfecha_final_vig IS NULL)
    group by b.cc;

--5. pr_llenar_tabla_anexos



--6. pr_ogt_bd_crear_ra.pr_crear_ra

