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
select * from OGT_DOCUMENTO_PAGO
where vigencia = 2026
and entidad= 206
and unidad_ejecutora = '01'
and tipo_documento = 'RA'
--ogt_documento_pago no registra datos ;


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