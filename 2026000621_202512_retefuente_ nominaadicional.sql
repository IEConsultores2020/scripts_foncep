select *
from rh_personas
where numero_identificacion=1049606827
--607


--cursor retefteperiodo(un_nro_ra NUMBER) IS
    SELECT sum(retencion) retencion,
           SUM(base) BASE,
           sum(asignacion) asignacion
      from (SELECT * --0 retencion, abs(SUM(valor)) base, 0 Asignacion
              FROM rh_t_lm_valores a
             WHERE a.periodo            = to_date('20251231','YYYYMMDD') --una_fecha_final
               AND a.ntipo_nomina       = 0         --un_tipo_nomina
               --AND nvl(a.nro_ra,30)      = 30 --un_nro_ra
               AND (a.sdevengado IN (0)
                   OR (a.sdevengado = 1 and variable_valor like 'NDV%'))
               
            union
            SELECT abs(SUM(valor)) retencion, 0 base, 0 Asignacion
              FROM rh_t_lm_valores a
             WHERE a.periodo            = to_date('20251231','YYYYMMDD') --una_fecha_final
               AND a.ntipo_nomina       = 0 --un_tipo_nomina
               AND a.sdevengado IN (1)
               AND SCONCEPTO LIKE 'RET%FUENTE%'
               AND a.nro_ra             = 27 --un_nro_ra
            UNION
            SELECT 0 retencion, 0 base, sum(ndcampo4) Asignacion
              FROM RH_HISTORICO_NOMINA
             WHERE nhash = 1128917309
               AND dfechaefectiva       >= '20251201'
                   --to_char(una_fecha_inicial, 'yyyymm') || '01'
               AND dfechaefectiva       <= '20251231' --to_char(una_fecha_final, 'yyyymmdd')
               and nretroactivo = 0
               and ntipoconcepto = 1
               AND nfuncionario in
                   (select nfuncionario
                      from RH_T_LM_VALORES
                     where nro_ra       = 30 --un_nro_ra
                       AND PERIODO      = to_date('20251231','YYYYMMDD')) /*una_fecha_final*/
                       )
                       ;

select ntipo_nomina, sdevengado, sconcepto, stercero, valor, variable_valor,regimen
from rh_t_lm_valores
where periodo = to_date('20251231','YYYYMMDD')         
and nfuncionario=607
order by nro_ra
and ntipo_nomina=0

and nro_ra=30              ;

select *
from  rh_historico_nomina
where dinicioperiodo = 20251201
and dfinalperiodo = 20251231
and nfuncionario=607
and ncorrida=1;

select *
from rh_personas
where numero_identificacion=1049606827
--607

select *
from v_consulta_nomina
where func_deducido=607
and dinicioperiodo=20251201
and dfinalperiodo=20251231
and nombre='RETENCION FUENTE';


select *
from rh_historico_nomina
where nfuncionario=607
and 20251201 between dinicioperiodo and dfinalperiodo 
and dinicioperiodo >= 20250000
and nhash = 2091789934
order by dinicioperiodo desc
;

select *
from rh_t_lm_valores
where nfuncionario=607
and periodo = to_date('20251231','YYYYMMDD')
and sconcepto='CAPORTES'
;

select *
from rh_concepto
where nombre like '%SINDICATO%' --'%RETEN%FUE%';
--RETENCION FUENTE  2091789934
--SINDICATO         3479908289
;

-------------------------------------------------------------------------------
----Diagnóstico del error:
-------------------------------------------------------------------------------

     
SELECT a.stercero, SUM(valor) valor, SUM(valor_saldo) valor_saldo
  FROM rh_t_lm_valores a, rh_lm_cuenta b, rh_lm_centros_costo c
 WHERE b.stipo_funcionario = a.stipofuncionario
   AND b.sconcepto = a.sconcepto
   AND b.cc = c.codigo
   AND a.periodo =
       TO_DATE('31-12-2025 12:00:00 AM', 'DD-MM-YYYY HH:MI:SS AM')
   AND a.ntipo_nomina = 1
   AND a.sdevengado IN (0, 1)
   AND c.codigo not IN (2, 3, 4)
   AND a.nro_ra = 6
   AND b.scompania = '206'
   AND b.tipo_ra = '1'
   AND b.grupo_ra IN ('5')
   AND b.ncierre = 1
   AND b.dfecha_inicio_vig <=
       TO_DATE('31-12-2025 12:00:00 AM', 'DD-MM-YYYY HH:MI:SS AM')
   AND (b.dfecha_final_vig >=
       TO_DATE('31-12-2025 12:00:00 AM', 'DD-MM-YYYY HH:MI:SS AM') OR
       b.dfecha_final_vig IS NULL)
   AND b.cc = 5
 GROUP BY a.stercero
 ;

pk_detalle_anexos_ra.fn_detalle_beneficiarios(TO_NUMBER(607), mi_err);   

  SELECT codigo_beneficiario, tipo_documento_beneficiario, numero_identificacion_benefici,
             beneficiario, forma_pago, cod_banco, tipo_cuenta, cuenta_bancaria
      FROM   rh_beneficiarios
      WHERE  codigo_beneficiario = 5422 -- 607;      
      