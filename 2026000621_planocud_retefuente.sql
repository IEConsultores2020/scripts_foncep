 /* datos de retencion */
--  cursor retefteperiodo(un_nro_ra NUMBER) IS
    SELECT sum(retencion) retencion,
           SUM(base) BASE,
           sum(asignacion) asignacion
      from (SELECT 0 retencion, abs(SUM(valor)) base, 0 Asignacion
              FROM rh_t_lm_valores a
             WHERE a.periodo      = :una_fecha_final
               AND a.ntipo_nomina = :un_tipo_nomina
               AND (a.sdevengado IN (0)
                   OR (a.sdevengado = 1 and variable_valor like 'NDV%'))
               AND a.nro_ra       = :un_nro_ra
            union
            SELECT distinct a.ntipo_nomina, a.periodo --abs(SUM(valor)) retencion, 0 base, 0 Asignacion
              FROM rh_t_lm_valores a
             WHERE --a.periodo      = :una_fecha_final
              -- AND a.ntipo_nomina = :un_tipo_nomina
              -- AND a.sdevengado IN (1)
              --AND 
              SCONCEPTO LIKE 'RET%FUENTE%'
              order by 2 desc
               AND a.nro_ra       = :un_nro_ra
            UNION
            SELECT 0 retencion, 0 base, sum(ndcampo4) Asignacion
              FROM RH_HISTORICO_NOMINA
             WHERE nhash = 1128917309
               AND dfechaefectiva >= :una_fecha_inicial --to_char(:una_fecha_inicial, 'yyyymm') || '01'
               AND dfechaefectiva <= :una_fecha_final
               and nretroactivo = 0
               and ntipoconcepto = 1
               AND nfuncionario in
                   (select nfuncionario
                      from RH_T_LM_VALORES
                     where /*nro_ra   = :un_nro_ra
                       AND*/ periodo  = to_date(:una_fecha_final,'YYYYMMDD')
                       and nfuncionario=607 ));


select *
from rh_personas
where numero_identificacion=1049606827
--int 607
;

select *
from rh_tipos_acto_nove
where nombre like '%RETE%FUENTE%'
--9931  1902983255
;

select *
from rh_historico_nomina
where  nfuncionario=607
and nhash = 1902983255
and dinicioperiodo = 20251201 
and ndcampo0 >= 1576000
;

select *
from v_consulta_nomina
where func_deducido = 607
and dinicioperiodo = 20251201 
and nombre = 'RETENCION FUENTE'
;