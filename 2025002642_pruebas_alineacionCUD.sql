
select --distinct extract(month from rra.dfecha_inicial_periodo) --, 
    op.*
from rh_lm_ra rra,
    (select pr_v_orden_pago_regis_predis.vigencia, 
        pr_v_orden_pago_regis_predis.codigo_compania, 
        pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora,
        pr_v_orden_pago_regis_predis.numero_disponibilidad,
        pr_v_orden_pago_regis_predis.numero_orden, 
        pr_v_orden_pago_regis_predis.numero_registro, 
        pr_v_orden_pago_regis_predis.consecutivo_orden, 
        pr_v_orden_pago_regis_predis.sistema, 
        pr_v_orden_de_pago_predis.origen, 
        pr_v_orden_de_pago_predis.fecha_orden ,
        pr_v_orden_de_pago_predis.fecha_registro, 
        pr_v_orden_de_pago_predis.tipo_pago, 
        pr_v_orden_de_pago_predis.estado, 
        pr_v_orden_de_pago_predis.objeto, 
        pr_v_orden_de_pago_predis.numero_relacion, 
        pr_v_orden_de_pago_predis.tipo_documento, 
        pr_v_orden_de_pago_predis.numero_documento,
        pr_v_orden_de_pago_predis.codigo_entidad, 
        pr_v_orden_de_pago_predis.digito_verificacion, 
        pr_v_orden_de_pago_predis.id_interno, 
        pr_v_orden_de_pago_predis.id_limay, 
        pr_v_orden_pago_regis_predis.rubro_interno,
        pr_v_orden_pago_regis_predis.valor
        --,    NVL(SUM(NVL(pr_v_orden_pago_regis_predis.valor, 0)), 0) total   --INTO mi_valor_op
      --select *
      from --PR_comun.PR_ORDEN_DE_PAGO_REGISTRO 
            pr_v_orden_pago_regis_predis, 
           --PR_comun.PR_ORDEN_DE_PAGO 
           pr_v_orden_de_pago_predis
     where pr_v_orden_pago_regis_predis.vigencia =
           pr_v_orden_de_pago_predis.vigencia
       and pr_v_orden_pago_regis_predis.codigo_compania =
           pr_v_orden_de_pago_predis.codigo_compania
       and pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora =
           pr_v_orden_de_pago_predis.codigo_unidad_ejecutora
       and pr_v_orden_pago_regis_predis.numero_registro =
           pr_v_orden_de_pago_predis.numero_registro
       and pr_v_orden_pago_regis_predis.numero_disponibilidad =
           pr_v_orden_de_pago_predis.numero_disponibilidad
       and pr_v_orden_pago_regis_predis.numero_orden =
           pr_v_orden_de_pago_predis.numero_orden
       and pr_v_orden_pago_regis_predis.consecutivo_orden =
           pr_v_orden_de_pago_predis.consecutivo_orden
       and pr_v_orden_pago_regis_predis.vigencia = :vigencia
       and pr_v_orden_pago_regis_predis.codigo_compania = :codigo_compania
       and pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora =
           :codigo_unidad_ejecutora
       and pr_v_orden_pago_regis_predis.rubro_interno in
       --between  1387 and 1390 en 20025. between 1831 and 1834 en 2026--:rubro_interno
       (select interno_rubro
        from pr_v_rubros
        where vigencia=:vigencia
        and descripcion in ('Aportes a la seguridad social en pensiones públicas',
        'Aportes a la seguridad social en pensiones privadas',
        'Aportes a la seguridad social en salud pública',
        'Aportes a la seguridad social en salud privada')
        )
       and TO_CHAR(pr_v_orden_de_pago_predis.fecha_registro, 'YYYY') =
           :vigencia
       and TO_NUMBER(TO_CHAR(pr_v_orden_de_pago_predis.fecha_registro, 'MM')) =
           TO_NUMBER(:P_MES)
       and pr_v_orden_de_pago_predis.ESTADO <> 'ANULADO') op
where rra.scompania=206
and rra.vigencia=op.vigencia
and rra.scompania= op.codigo_compania
and op.codigo_unidad_ejecutora = '01'
and rra.vigencia=op.vigencia
and instr(op.objeto,'[RA = '||rra.nro_ra||']',1) > 1 -- --= '[RA = 2]'
and rra.tipo_ra=2
and rra.ntipo_nomina=0
;

select *
from pr_v_rubros
where vigencia=2025
and descripcion in ('Aportes a la seguridad social en pensiones públicas',
'Aportes a la seguridad social en pensiones privadas',
'Aportes a la seguridad social en salud pública',
'Aportes a la seguridad social en salud privada')
and interno_rubro between 1831 and 1834 
;


select shd_pg_bintablas.fn_buscar_rdf('FECHA_INICIO','NOMINA','CUD','01/01/2026') RES,
to_date(nvl(shd_pg_bintablas.fn_buscar_rdf('FECHA_INICIO','NOMINA','CUD','01/01/2026'),'20250401'),'YYYYMMDD') fecha
from dual;

 GRANT SELECT
ON TRC.TRC_INFORMACION_BASICA
TO gecruz;

 CURSOR CResulBinTab (Var_Argumento Varchar2,
            Var_Grupo Varchar2,
            Var_Nombre Varchar2,
            Var_Vigencia DATE) IS
        SELECT * --Resultado 
        From BinTablas
        WHERE Grupo = 'NOMINA' AND
            Nombre = 'CUD' Var_Nombre AND
            Argumento = Var_Argumento AND
            Vig_Inicial <= Var_Vigencia AND
            (Vig_Final >= Var_Vigencia OR
            Vig_final IS NULL);


select *
from ogt_documento_pago 
where vigencia = 2026
and tipo_documento ='RA'
order by fecha_diligenciamiento;

select tipo_ra, fecha_desde, fecha_hasta, consecutivo, descripcion, fecha_radicacion, fecha_aprobacion, estado, numero_compromiso, ind_aprobado
from ogt_relacion_autorizacion
where vigencia = 2026
and tipo_documento='RA'
and unidad_ejecutora='01'
order by fecha_desde, fecha_hasta, fecha_aprobacion

grant select on rh_lm_ra to ogt_comun;
grant select on rh_lm_ra to ogt;


select 
    :agno, :mes,
    ogt_pk_predis.Ogt_Fn_aportesemp_Mes(:agno, '206', '01', :mes, 1804) AEM,
    ogt_pk_predis.Ogt_Fn_aportespagemp_Mes(:agno, '206', '01', :mes, 1804) APEM,
    ogt_pk_predis.Ogt_Fn_Valor_Mes(:agno, '206', '01', :mes, 1804) VM,
    ogt_pk_predis.OGT_FN_VALOR_ACUM(:agno, '206', '01', :mes, 1804) VA
from dual;


select * --descripcion
from pr_v_rubros
--  where descripcion like '%Sueldo%sico%'
where  interno_rubro = 1804
and vigencia       = 2026;



GRANT EXECUTE ON OGT_PK_PREDIS TO OGT_OP_PREDIS;
GRANT EXECUTE ON OGT_PK_PREDIS TO OGT_SOLO_CONSULTA;
GRANT EXECUTE ON OGT_PK_PREDIS TO OGT_SOPORTE;
GRANT EXECUTE ON OGT_PK_PREDIS TO PR_ADMIN;
GRANT EXECUTE ON OGT_PK_PREDIS TO PR_CONSULTA;
GRANT EXECUTE ON OGT_PK_PREDIS TO PR_CONSULTA_INVERSION;
GRANT EXECUTE ON OGT_PK_PREDIS TO PR_CONTABILIDAD;
GRANT EXECUTE ON OGT_PK_PREDIS TO PR_CONTABILIDAD_ADMIN;
GRANT EXECUTE ON OGT_PK_PREDIS TO PR_CONTABILIZACIONES;
GRANT EXECUTE ON OGT_PK_PREDIS TO PR_DIRECTIVO;
GRANT EXECUTE ON OGT_PK_PREDIS TO PR_ENT_CAPTURA;
GRANT EXECUTE ON OGT_PK_PREDIS TO PR_ENT_CAPTURA_NO_ADMIN;
GRANT EXECUTE ON OGT_PK_PREDIS TO PR_ENT_CONTROL;
GRANT EXECUTE ON OGT_PK_PREDIS TO PR_INFORMES;
