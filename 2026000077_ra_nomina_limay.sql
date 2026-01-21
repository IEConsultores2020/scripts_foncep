
SELECT * --DISTINCT SCOMPANIA,TIPO_RA,GRUPO_RA,NTIPO_NOMINA,DFECHA_FINAL_PERIODO,APROBACION,ACTUALIZADO_CONTAB,CONTABILIZADO,CONTABILIZAR
FROM bintablas b,
(SELECT DISTINCT SCOMPANIA,TIPO_RA,GRUPO_RA,NTIPO_NOMINA,DFECHA_FINAL_PERIODO,APROBACION,ACTUALIZADO_CONTAB,
 CONTABILIZADO,CONTABILIZAR
 FROM RH_LM_RA R
 WHERE APROBACION  =   'S'
 AND TIPO_RA IN('1','2','4')  
 AND 0 = (SELECT COUNT(1) FROM RH_LM_RA R1 
          WHERE R1.SCOMPANIA = R.SCOMPANIA 
            AND R1.VIGENCIA = R.VIGENCIA 
            AND R1.TIPO_RA = R.TIPO_RA 
            AND R1.NTIPO_NOMINA = R.NTIPO_NOMINA 
            AND R1.DFECHA_INICIAL_PERIODO = R.DFECHA_INICIAL_PERIODO 
            AND R1.NRO_RA_OPGET IS NULL)) n
WHERE b.grupo = 'NOMINA'
  AND b.nombre = 'RELACIONAUTORIZACION_GRUPOS_RA'
  --AND instr(b.argumento, n.grupo_ra) > 0 
  AND b.vig_inicial <= sysdate
  AND (b.vig_final IS NULL OR b.vig_final >= sysdate)
  AND b.resultado <> 'CONCEJALES'  
  and SCOMPANIA = 206
AND DFECHA_FINAL_PERIODO = '31/DEC/2025'
;

--CURSOR cur_aportes_parafiscales IS
select stercero,
       variable_valor,
       contrapartida,
       sum(valor) valor
  from rh_t_lm_valores
 where periodo = '31/DEC/2025' --una_fecha_final
   and ntipo_nomina = 0 --- un_tipo_nomina
   and sdevengado = 2
   and sconcepto <> 'CFAVIDI' --mi_concepto  
 group by stercero,
          variable_valor,
          contrapartida
 order by contrapartida,
          stercero;

52912	APORTESPARAFISCALES-PLANTA-CAJAS	APORTESPARAFISCALES-PASIVO-APORTE CCF	34193000
72	APORTESPARAFISCALES-PLANTA-ICBF	APORTESPARAFISCALES-PASIVO-APORTE ICBF	25645700
69	APORTESPARAFISCALES-PLANTA-SENA	APORTESPARAFISCALES-PASIVO-APORTE SENA	17098300
57	FAVIDI-PASIVOFAVIDI-COMISION	FAVIDI-FAVIDI-FAVIDI	191412
57	FAVIDI-PAGOFAVIDI-COMISION	FAVIDI-PASIVOFAVIDI-COMISION	191412         

      --Registra informaciÃ³n adicional a nivel de cuenta
      rh_pg_lm_transaccion.pr_infadicional_cuenta( mi_transaccion       => 2,    
                                                   mi_variable_cta      =>'APORTESPARAFISCALES-PLANTA-CAJAS',
                                                   mi_Resultado_Limay   => 1,
                                                   mi_id_valor          => NULL,
                                                   mi_Tabla_IA_Fija     Ver word
                                                   NULL,
                                                   mi_tercero           52912,  
                                                   un_grupo_ra,
                                                   mi_mensaje_err);

  CURSOR cur_ajustes IS
          SELECT stipofuncionario,
                 nfuncionario,
                 stercero,
                 variable_valor,
                 contrapartida,
                 SUM(valor) valor,
                 SUM(valor_saldo) valor_saldo
              --   select count(1)
            FROM rh_t_lm_valores
           WHERE periodo          = '31/DEC/2025' --una_fecha_final
             AND ntipo_nomina     = 0 --un_tipo_nomina
             AND sdevengado       = 0 --mi_devengado                         ------   0
             AND contrapartida    LIKE '%PASIVO%'
        GROUP BY stipofuncionario,
                 nfuncionario,
                 stercero,
                 variable_valor,
                 contrapartida;                                                   

 WHERE periodo          = TO_DATE('31-12-2025','DD-MM-YYYY')
                                AND ntipo_nomina     = 0
                                AND stipofuncionario = 'PLANTA'
                                AND nfuncionario     = 636
                                 AND sdevengado       = 0
                                AND variable_valor   = 'NDV-PLANTA-PRIMANAVIDAD'
                                
                                573
                                601
                                588
                                614
                                632
                                579
44
634
605
43
219
581
595
588
599
615
45
630
20
648
61
624


rh_pg_lm_transaccion.pr_procesar_nomina

-------------------------------------

 WHERE periodo          = TO_DATE('31-12-2025','DD-MM-YYYY')
                                AND ntipo_nomina     = 0
                                AND stipofuncionario = 'PLANTA'
                                AND nfuncionario     = 624
                                 AND sdevengado       = 0
                                AND variable_valor   = 'NDV-PLANTA-CESANTIAS'
                                
                                
   mi_hizo_movimiento  :=  TRUE;
        mi_id_valor         :=  pk_lm_transaccion.fn_agregar_valor( un_id_inicial,
                                                                    mi_cuenta_interna_cxp,
                                                                    'co',
                                                                    0, --credito
                                                                    mi_valor_cxp_cre);
        IF mi_id_valor = 0 THEN
           /* verificaciÃ³n obligatoria de errores de LIMAY*/
           mi_mensaje_err  :=  'Error al agregar valor ' || substr(pk_lm_transaccion.fn_ultimo_error,1,200);
           RETURN;
        END IF;
        --Registra informaciÃ³n adicional a nivel de cuenta
        rh_pg_lm_transaccion.pr_infadicional_cuenta( una_transaccion,         12
                                                     mi_variable_cxp,         'PASIVO-CESANTIAS FNA'
                                                     un_id_inicial,           -3
                                                     mi_id_valor,             -2
                                                     una_InfAdicional_Fija,   
                                                     una_condicion,
                                                     un_tercero,
                                                     un_grupo_ra,
                                                     mi_mensaje_err);                                
                                                     

SELECT clase_limay, tipo_limay, tabla, columna, valor_defecto, condicion
FROM rh_lm_cuenta_ia
WHERE transaccion = 12
AND cuenta = 'PASIVO-CESANTIAS FNA'
;

  select *
  from rh_funcionario
  where personas_interno in (624,61) --numero_identificacion = 1049606827  id_tercero 411295 id rh 624

  id tercero 612   FONDO NACIONAL DEL AHORRO

    pk_lm_transaccion.fn_agregar_info_de_valor( 
                                un_id_inicial, 1
                               un_id_valor,    -1
                                mi_reg_ia_cuenta.clase_limay,  TERCERO
                                mi_reg_ia_cuenta.tipo_limay,   GENERAL
                               mi_valor_ia);     6112                           
                               
select *
  from rh_lm_det_grp_funcionario
 WHERE scompania = 206         -- mi_compania
   AND sGtipo = 'FUNCIONARIO'  --mi_sgtipo
   AND instr(5 , stipo_funcionario) > 0
   AND sysdate BETWEEN dfecha_inicio_vig AND dfecha_final_vig
   AND ncierre = 1;
               
update rh_lm_det_grp_funcionario
set dfecha_final_vig = '31/DIC/2035'
where scompania = 206 
  and  sGtipo    = 'FUNCIONARIO' 
  and instr(5 /*un_grupo_ra*/,stipo_funcionario ) > 0;