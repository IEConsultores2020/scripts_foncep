SELECT SECUENCIAL
FROM     BINCONSECUTIVO
WHERE   GRUPO = 'OPGET'
    AND NOMBRE = 'ACTA_LEGAL_ID'
    AND VIGENCIA = '0000'
    AND CODIGO_COMPANIA = '000'
    AND CODIGO_UNIDAD_EJECUTORA = '00'
    ;

    SELECT NUMERO FROM OGT_DOCUMENTO
    ORDER BY 1 DESC
    ;

AND VIG_INICIAL <= SYSDATE
AND (VIG_FINAL IS NULL OR VIG_FINAL >= SYSDATE)
;

select *
from RH_PERSONAS
where numero_identificacion = 40030681 
    --interno_persona = 11
;


select * from rh_maestro_personas
where nfuncionario in 
(select * --interno_persona, numero_identificacion, nombres, primer_apellido, segundo_apellido
 from rh_personas
--where nombres ='DIANA MARCELA' and primer_apellido='SANABRIA'
where --numero_identificacion in (52116283)) --651, 652
--or 
interno_persona IN (519,614)   --  20730522
--649 --1030575813
;

select *
from rh_personas
where interno_persona in (11) --20730522, 52876090
nombres like 'MARGARITA%' --numero_identificacion= 79693028
;

select *
from pr_rubro
where interno = 1547
;

select *
from rh_concepto
where nombre like '%PAGO  APORTE CAJA DE COMPENSACION FAMILIAR%'
;
select hn.*
from 
--delete 
rh_historico_nomina hn
where hn.nfuncionario=633
and nhash like '1994%'
and hn.dinicioperiodo = 20260401
and sproceso = 'NEWNOVELTIES'
and hn.ncorrida=1   1994
;



select *
from bintablas
where grupo='SISLA' AND nombre='GRAFICOS'
;

select * from rh_conceptos;

select * from pr_apropiacion
where vigencia=2016
;


select *
from rh_concepto   
where codigo_hash = 2091789934
;

    select *
    from rh_concepto
    where nombre_corto like '%ICBF%' --121290711
    ;

    select *
    from rh_tipos_acto_nove
    where nombre = 'INFO_PLANILLA_ENTIDAD' --854032720
    --'INFOAPORTEPARAF' --543977345

    select *
    from rh_historico_nomina
    where nhash=543977345 and dinicioperiodo>=20260101 and dfinalperiodo<=20260131
    and nfuncionario=33
    ;

    select interno_persona,  coalesce(libreta_militar,'99999')
    from rh_personas
    where coalesce(libreta_militar,'99999') like '1%_6%';

SELECT parameter, value 
FROM nls_session_parameters 
WHERE parameter IN ('NLS_DATE_FORMAT', 'NLS_NUMERIC_CHARACTERS');
NLS_NUMERIC_CHARACTERS	.,
NLS_DATE_FORMAT	DD-MON-RR



select *
from usuarios_compania
where usuario='NYROA'
;

     select *
        from ogt_centro_costos
        where entidad         =  :una_entidad
        and unidad_ejecutora  = :una_unidad_ejecutora
        and vigencia          = :una_vigencia
        and extract(month from fecha_desde) = :un_mes
        --and consecutivo=10
        and codigo_centro_costos IN (5, 1285, 1267)
        and exists (select 1 from ogt_relacion_autorizacion b
                where b.consecutivo = ogt_centro_costos.consecutivo
                  and b.entidad = ogt_centro_costos.entidad
                  and b.tipo_documento = ogt_centro_costos.tipo_documento
                  and b.unidad_ejecutora = ogt_centro_costos.unidad_ejecutora
                  and b.vigencia = ogt_centro_costos.vigencia
                  and b.tipo_ra = ogt_centro_costos.tipo_ra
                  and b.ind_aprobado = :mi_valor_uno
                  and substr(b.estado, 4, 1) = :mi_estado_uno
        );


select *
--update
 ogt_relacion_autorizacion
set  fecha_aprobacion = '31-DEC-2025'
where vigencia=2025 and numero_compromiso=21
and consecutivo=33

commit;

select *
        from ogt_centro_costos
        where entidad         =  una_entidad
        and unidad_ejecutora  = una_unidad_ejecutora
        and vigencia          = una_vigencia
        and extract(month from fecha_desde) = un_mes
        --and consecutivo=10
        and codigo_centro_costos IN (5, 1285, 1267)
        and exists (select 1 from ogt_relacion_autorizacion b
                where b.consecutivo = ogt_centro_costos.consecutivo
                  and b.entidad = ogt_centro_costos.entidad
                  and b.tipo_documento = ogt_centro_costos.tipo_documento
                  and b.unidad_ejecutora = ogt_centro_costos.unidad_ejecutora
                  and b.vigencia = ogt_centro_costos.vigencia
                  and b.tipo_ra = ogt_centro_costos.tipo_ra
                  and b.ind_aprobado = mi_valor_uno
                  and substr(b.estado, 4, 1) = mi_estado_uno
                  );


select id,
                                   nro_referencia_pago,
                                   estado,
                                   centro_costo
                             from sl_pcp_encabezado
                             where estado in ('PAG','REG')
                             and  extract(year from fecha_sistema) > 2025
                             and nro_referencia_pago = nvl(:p_nro_referencia,nro_referencia_pago);                   



----------------------------------seguimiento

select id,
nro_referencia_pago,
estado,
centro_costo
from sl_pcp_encabezado
where estado in ('PAG','REG')
and  extract(year from fecha_sistema) > 2025
and nro_referencia_pago = nvl(:p_nro_referencia,nro_referencia_pago)
;

select id,
                                   id_encabezado,
                                   codigo_entidad,
                                   id_cuenta_cobro,
                                   saldo_cuenta_cobro,
                                   valor_capital,
                                   valor_intereses,
                                   fecha_sistema
                                                    from sl_pcp_cuenta_cobro
                             where id_encabezado in (
                               select id
                                 from sl_pcp_encabezado
                                where nro_referencia_pago = :p_nro_referencia_pago
                                and valor_capital > 0
                            );



select max(numero), max(to_number(numero))
from  ogt_documento
where /*tipo='XYZ'
and*/ extract(year from fecha) = 2026
--and numero<1000000
;


insert into  ogt_documento (
                        numero,
                        tipo,
                        estado,
                        fecha,
                        fecha_emision_titulo,
                        ter_id_receptor,
                        unte_codigo,
                        bin_tipo_cuenta,
                        bin_tipo_titulo,
                        cuba_numero,
                        usuario_elaboro,
                        usuario_reviso,
                        numero_soporte,
                        tipo_soporte,
                        fecha_compra_titulo,
                        fecha_soporte,
                        numero_timbre,
                        numero_legal,
                        tipo_legal
                     ) values (1000018,       -- :mi_numero_documento, 
                              'XYZ',        -- mi_tipo_documento,
                              'RE',         --p_estado,
                              to_date('29-10-26','DD-MM-YYYY'),  --mi_fecha_pago,             --sysdate,
                              null,          --trunc(mi_fecha_pago,'mm'), --trunc(sysdate,'mm'),
                              49,           --p_rec_pago.id_banco,
                              'FINANCIERO', --mi_unte_codigo,
                              'FD',         --mi_bin_tipo_cuenta,
                              null,
                              '482800043630',  --mi_cuba_numero,
                              'OGT',           --p_usuario,
                              'OGT',          --p_usuario,
                              60059,         --p_acta_numero,
                              'NCR',        --mi_tipo_soporte,
                               to_date('29-10-26','DD-MM-YYYY'),  --p_rec_pago.fecha_autorizacion,
                               to_date('29-10-26','DD-MM-YYYY'),  --p_rec_pago.fecha_autorizacion,
                              2026,         --mi_vigencia,
                              60059,        --p_acta_numero,
                              'ALE'   -- p_acta_tipo 
                              );                            

select *
from  ogt_documento
where tipo='XYZ'      
and extract(year from fecha) = 2026
--and numero_legal >= 60059
order by to_number(numero) desc
;

--rollback

select * from rh_funcionario;

--Traer cuentas de cobro
select id,
       id_encabezado,
       codigo_entidad,
       id_cuenta_cobro,
       saldo_cuenta_cobro,
       valor_capital,
       valor_intereses,
       fecha_sistema
  from sl_pcp_cuenta_cobro
 where id_encabezado in (select id
                           from sl_pcp_encabezado
                          where nro_referencia_pago = '2026000526'
                            and valor_capital > 0);

--Traer Liquidaciones
--open p_ref_cursor for 
select id,
       id_det_cuenta_cobro,
       id_factura,
       interno_persona,
       fecha_periodo_ini,
       fecha_periodo_fin,
       saldo_factura,
       valor_capital,
       valor_interes,
       fecha_sistema,
       estado
  from sl_pcp_liquidaciones
 where id_det_cuenta_cobro = 3 --p_id_det_cuenta_cobro
   and valor_capital > 0;


 select id
        from ogt_concepto_tesoreria
       where descripcion = --'CAUSACION INTERESES CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA'; --'00-02-37-19-00-00-00'
       'RECAUDO INTERESES CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA' 



--tabla mi_clase_info DETALLE_PENSIONADO
--mi_tipo_info  TERCERO_PENSIONADO
 SELECT tercero_pensionado
FROM ogt_DETALLE_PENSIONADO
 WHERE doc_numero     = '1000011'  
  AND doc_tipo       = 'XYZ'  
   AND id_ingreso     = '628429' AND -- '628446'   AND 
   cote_id        = '00-02-37-19-00-00-00'   --25422
                    --'00-02-37-18-00-00-00'
;


-----------------------------------------
--l1

select tercero_pensionado
  from ogt_detalle_pensionado
 where doc_numero = '1000012'
   and doc_tipo = 'XYZ'
   and id_ingreso = '628458'
   and cote_id = '00-02-37-19-00-00-00';

select ter_id_origen
  from ogt_detalle_documento
 where doc_numero = '1000012'
   and doc_tipo = 'XYZ'
   and ter_id_destino = 53
   and cote_id = '00-02-37-19-00-00-00'
   ;

select ter_id
  from ogt_ingreso
 where id = 628458
   and cote_id = '00-02-37-19-00-00-00'
   ;

select ter_id
  from ogt_ingreso
 where id = 628458
   and cote_id = '00-02-37-19-00-00-00'
   ;

select numero_timbre
  from ogt_documento
 where numero_legal = '60071'
   and tipo = 'XYZ'
   and rownum = 1;

--other sql

select numero_timbre
  from ogt_documento
 where numero_legal = '60071'
   and tipo = 'XYZ'
   and rownum = 1
   ;


select tipo_doc_legalizacion
  from ogt_ingreso
 where id = 628458;

 update ogt_ingreso where tiop_id = 1726
 where id=628458
 ;

---l1


select tercero_pensionado
  from ogt_detalle_pensionado
 where doc_numero = '1000012'
   and doc_tipo = 'XYZ'
   and id_ingreso = '628457'
   and cote_id = '00-02-37-18-00-00-00';

select *
from rh_historico_nomina
;

select ter_id_origen
  from ogt_detalle_documento
 where doc_numero = '1000012'
   and doc_tipo = 'XYZ'
   and ter_id_destino = 53
   and cote_id = '00-02-37-18-00-00-00';

   
select *  --ter_id_origen
  from ogt_detalle_documento
 where doc_numero = '1000012'
   and doc_tipo = 'XYZ'
   and ter_id_destino = 53
   and cote_id = '00-02-37-19-00-00-00'
   ;

select descripcion
  from ogt_concepto_tesoreria
 where id = '00-02-37-18-00-00-00';

select numero_timbre
  from ogt_documento
 where numero_legal = '60071'
   and tipo = 'XYZ'
   and rownum = 1;

select numero_legal
  from ogt_documento
 where numero_legal = '60071'
   and tipo = 'XYZ'
   and rownum = 1;

select tipo_doc_legalizacion
  from ogt_ingreso
 where id = 628457;

select tipo_legal
  from ogt_documento
 where numero_legal = '60071'
   and tipo = 'XYZ'
   and rownum = 1;

---l3

SELECT TIPO_LEGAL FROM ogt_DOCUMENTO  WHERE numero_LEGAL = '60071'   AND tipo   = 'XYZ'AND ROWNUM = 1;

--...rec_id  628455 , 628454, 628453,  628452... 628444


---Al tratar de legalizar ingreso 628444 




     CURSOR cur_informacion_nula IS
     SELECT * --nvl(valor,'XXX') valor,atr_nombre,clmo_nombre
     FROM   ogt_info_ing
     WHERE  ing_id=628477;


       select * --id, ing_id, entidad_pptal 
       from   ogt_ingreso 
         where ing_id = 628477 ---num_doc_legalizacion = mi_numero_acta
         ;

::-- cursor cur_val_aportes_empleado_mes is
      select distinct extract(month from rra.dfecha_inicial_periodo) mes_aportes
      from rh_lm_ra rra,
        (select pr_v_orden_pago_regis_predis.vigencia, 
            pr_v_orden_pago_regis_predis.codigo_compania, 
            pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora,
            pr_v_orden_pago_regis_predis.numero_disponibilidad,
            pr_v_orden_pago_regis_predis.numero_orden, 
            pr_v_orden_pago_regis_predis.numero_registro, 
            pr_v_orden_pago_regis_predis.consecutivo_orden, 
            pr_v_orden_de_pago_predis.fecha_registro, 
            pr_v_orden_de_pago_predis.estado, 
            pr_v_orden_de_pago_predis.objeto, 
            pr_v_orden_pago_regis_predis.valor
          --select */
          from pr_v_orden_pago_regis_predis, 
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
          and pr_v_orden_pago_regis_predis.vigencia = :una_vigencia
          and pr_v_orden_pago_regis_predis.codigo_compania = :una_entidad
          and pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora = :una_unidad_ejecutora
          and pr_v_orden_pago_regis_predis.rubro_interno in
          --between  1387 and 1390 en 20025. between 1831 and 1834 en 2026--:rubro_interno
          (select interno_rubro
            from pr_v_rubros
            where vigencia= :una_vigencia
            and descripcion in ('Aportes a la seguridad social en pensiones públicas',
            'Aportes a la seguridad social en pensiones privadas',
            'Aportes a la seguridad social en salud pública',
            'Aportes a la seguridad social en salud privada')
            )
          and TO_CHAR(pr_v_orden_de_pago_predis.fecha_registro, 'YYYY') = :una_vigencia
          and TO_NUMBER(TO_CHAR(pr_v_orden_de_pago_predis.fecha_registro, 'MM')) =
              TO_NUMBER(:un_mes)
          and pr_v_orden_de_pago_predis.ESTADO <> 'ANULADO') op
      where rra.scompania=:una_entidad
      and rra.vigencia=op.vigencia
      and rra.scompania= op.codigo_compania
      and op.codigo_unidad_ejecutora = :una_unidad_ejecutora
      and rra.vigencia=op.vigencia
 --     and instr(op.objeto,'[RA = '||rra.nro_ra||']',1) > 1 -- --ej:  '[RA = 2]'
 --     and rra.tipo_ra=2
  --    and rra.ntipo_nomina=0   ---no se tienen en cuenta nominas adicionales, es decir con valor 1
      ;         

  select * 
  from ogt_relacion_autorizacion b
  where b.vigencia= :una_vigencia
  and b.entidad= :una_entidad
  and b.unidad_ejecutora= :una_unidad_ejecutora
  --and b.tipo_ra=2
  and b.mes = :un_mes
order by tipo_ra;

select *
from pr_v_rubros
where vigencia=2026
and upper(descripcion) like '%SERVICIOS DE CONSULTORÍA EN GESTIÓN ESTRATÉGICA%'
and codigo_nivel1||'-'||codigo_nivel2||'-'||codigo_nivel3 = '2-1-02';



select *
from trc.trc_informacion_basica();