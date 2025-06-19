 --Cursor rubros(un_nro_ra NUMBER) is
 SELECT DISTINCT a.sconcepto, B.CC RUBRO, b.grupo_ra
      FROM RH_T_LM_VALORES     a,
           RH_LM_CUENTA        b
     WHERE b.stipo_funcionario = a.stipofuncionario
       AND b.stipo_funcionario = 'PLANTA'
       AND a.periodo = to_date('20250531','yyyymmdd') --una_fecha_final
       AND a.ntipo_nomina = 0 --un_tipo_nomina
       AND a.sdevengado IN (0, 1)
       AND a.nro_ra = 9 --un_nro_ra
       AND b.scompania = 206 --una_compania
       AND b.tipo_ra = 1 --un_tipo_ra
       AND b.ncierre = 1
       and tipo_ra = 1 --un_tipo_ra
       /*--PRUEBAS 2022
            and       a.nfuncionario IN (3428) --*/
       AND b.dfecha_inicio_vig <= to_date('20250531','yyyymmdd') --una_fecha_final
       AND (b.dfecha_final_vig >= to_date('20250531','yyyymmdd') OR --una_fecha_final OR
           b.dfecha_final_vig IS NULL)
       AND a.sconcepto in ('APORTEFONDOGARANTIA',
              'APORTEPENSION',
              'APORTEREGIMENSOLIDARIDAD',
              'APORTESALUD',
              'CAPORTEAFC',
              'CAPORTEAFP',
              'CAPORTES',
              'CLIBRANZA',
              'CPLANCOMPLEMENTARIO',
              'CSINDICATO',
              'RETENCIONFUENTE'
              )           
  ORDER BY 1              
;

   SELECT  * --STERCERO, SUM(VALOR) --DISTINCT SCONCEPTO
    FROM
        RH_T_LM_VALORES
    WHERE
        PERIODO = TO_DATE('20250531', 'YYYYMMDD')
        AND NTIPO_NOMINA = 0
        AND STIPOFUNCIONARIO = 'PLANTA'
        AND SCONCEPTO  IN ('CAPORTES') --,'CCOOPERATIVA','CLIBRANZA')
        AND STERCERO = 2720
     --GROUP BY STERCERO
      ;
      --  CLIBRANZA

SELECT *
FROM RH_LM_CUENTA
WHERE SCONCEPTO='CAPORTES'
;

--DESCARGARON 
--SINDICATOS, MEDICINA PREPAGADA, FONDO PENSIONES

  SELECT   a.stercero, SUM(valor) valor, SUM(valor_saldo) valor_saldo 
  FROM     rh_t_lm_valores a, rh_lm_cuenta b, rh_lm_centros_costo c 
  WHERE    b.stipo_funcionario =  a.stipofuncionario 
  AND      b.sconcepto         =  a.sconcepto 
  AND      b.cc                =  c.codigo 
  AND      a.periodo           =  TO_DATE('31-05-2025 12:00:00 AM','DD-MM-YYYY HH:MI:SS AM') 
  AND     a.ntipo_nomina      =  0 
  AND  a.sdevengado IN (0,1)  
  AND      c.codigo    not  IN (2,3,4)  AND a.nro_ra    = 9 
  AND b.scompania =  '206' 
  AND b.tipo_ra   =  '1' 
  AND b.grupo_ra IN ('5') 
  AND  b.ncierre =  1  
  AND b.dfecha_inicio_vig <= TO_DATE('31-05-2025 12:00:00 AM','DD-MM-YYYY HH:MI:SS AM')  
  AND (b.dfecha_final_vig  >= TO_DATE('31-05-2025 12:00:00 AM','DD-MM-YYYY HH:MI:SS AM') OR b.dfecha_final_vig IS NULL) 
   AND      b.cc =  5 GROUP BY a.stercero
  ;

    SELECT T.STERCERO, T.SCONCEPTO, SUM(T.VALOR)
    FROM
        RH_T_LM_VALORES T, RH_LM_CUENTA C
    WHERE
       T.PERIODO = TO_DATE('20250531', 'YYYYMMDD')
        AND T.NTIPO_NOMINA = 0
        AND T.STIPOFUNCIONARIO = 'PLANTA'
        --AND T.SCONCEPTO  IN ('CAPORTES','CCOOPERATIVA','CLIBRANZA')
        AND T.SCONCEPTO =C.SCONCEPTO
        AND c.scompania='206'
        AND c.tipo_ra = '1'
        AND c.grupo_ra IN ('5') 
        AND C.CC = 5
        AND  c.ncierre =  1  
        AND T.SCONCEPTO IN ('CAPORTES','CCOOPERATIVA','CLIBRANZA')
        --AND t.nfuncionario = 634
          AND c.dfecha_inicio_vig <= TO_DATE('31-05-2025 12:00:00 AM','DD-MM-YYYY HH:MI:SS AM')  
  AND (c.dfecha_final_vig  >= TO_DATE('31-05-2025 12:00:00 AM','DD-MM-YYYY HH:MI:SS AM') OR c.dfecha_final_vig IS NULL) 
  --ORDER BY NFUNCIONARIO DESC
  GROUP BY T.STERCERO, T.SCONCEPTO
;

select *
from rh_personas
where interno_persona = 634 --1120561376 --numero_identificacion = 1030575813 INT 649 ---52182471  INT 650
;

SELECT *
FROM RH_LM_CUENTA
;


SELECT lpad(cod_superbancaria, 3, 0) codigo_ach, rh_entidad.descripcion
      FROM RH_ENTIDAD
     WHERE /*codigo = un_banco
     AND*/ tipo = 'BANCO'
     and lpad(cod_superbancaria, 3, 0) = '000';


  --cursor reg40(un_nro_ra NUMBER) is
    select COMPANIA,
           VIGENCIA,
           CODIGO_CONCEPTO_CC,
           GRUPO_RA,
           CONCEPTO_RUBRO,
           CUENTA_DEBITO,
           CUENTA_CREDITO,
           STIPO_FUNCIONARIO,
           MES,
           VALOR_RUBRO,
           REGISTRO,
           POSPRES,
           NRO_RA
      from RH_LM_CUENTAS_RA
     WHERE VIGENCIA = 2025 --to_char(una_fecha_final, 'yyyy')
       AND NRO_RA = 14;
    /*--PRUEBAS
    AND CODIGO_CONCEPTO_CC=1 --*/

