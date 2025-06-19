select b.sconcepto, b.scuenta, b.GRUPO_RA, b.TIPO_RA, b.cc --, c.* --c.codigo, c.DESCRIPCION, 
   --b.DFECHA_INICIO_VIG, b.DFECHA_FINAL_VIG
from rh_lm_cuenta b, rh_lm_centros_costo c
where b.cc = c.codigo
and b.STIPO_FUNCIONARIO='PLANTA'
and b.DFECHA_INICIO_VIG <= sysdate and nvl(b.DFECHA_FINAL_VIG,sysdate)>=sysdate
and b.tipo_ra = 1
--and b.SCUENTA like 'NDD%'
order by b.cc
;

/*EXEC_SQL.PARSE mi_consulta
create table rh_lm_centros_costo20250508 
create table rh_lm_centros_costo20250514 as (select * from rh_lm_centros_costo)
*/

select * /*DISTINCT(TABLA_DETALLE)*/ from rh_lm_centros_costo
/*where codigo_alterno = 'PASIVO-NOMINAPORPAGAR'
or descripcion like '%CESANTIAS%'
---TABLA_DETALLE= 'PERSONAS' */
ORDER BY codigo --codigo in (1,2)
;

 select * --SCONCEPTO, SCUENTA, CC, '      ' CUENTA_SAP
 from RH_LM_CUENTA
 where SCONCEPTO = 'CCOOPERATIVA'
 dfecha_final_
 where stipo_funcionario = 'PLANTA'
 and sysdate between DFECHA_INICIO_VIG and NVL(DFECHA_FINAL_VIG, sysdate)
 and tipo_ra = 1
 AND grupo_ra = 5
	 and scompania = '206'
   and cc = 7
 --and scuenta like 'NDD%'
 ORDER BY cc
 ;

SELECT *
FROM BINTABLAS
WHERE GRUPO='NOMINA'
AND NOMBRE = 'RA_CC_TABLA_DETALLE'
--and 'TRO ENTIDAD' IN (grupo, nombre, argumento, resultado)
;

	--CURSOR c_validar_ra IS
    SELECT cc.* --CC.RA, CC.CC
    FROM RH_LM_RA_CC CC
         ,(SELECT DISTINCT TIPO_RA, CC
           FROM   RH_LM_CUENTA
           WHERE  CC IS NOT NULL
          ) CTA
    WHERE CTA.CC IS NULL
    AND CC.CC = CTA.CC(+)
    AND CC.RA = CTA.TIPO_RA(+)
    AND CC.RA NOT IN (1,2);
;

select * from rh_lm_ra_cc
;


select b.cc,  c.cuenta_sap, a.stercero, SUM(valor) valor, SUM(valor_saldo) valor_saldo
from rh_t_lm_valores a, rh_lm_cuenta b, rh_lm_centros_costo c
where stipo_funcionario = a.stipofuncionario and
b.sconcepto = a.sconcepto and
b.cc = c.codigo and a.periodo =to_date('31-05-2025 12:00:00 AM','DD-MM-YYYY HH:MI:SS AM') and
a.ntipo_nomina = 0 AND a.sdevengado IN (0,1) AND
C.CODIGO NOT IN (2,3,4,5) AND A.NRO_RA = 9 AND B.SCOMPANIA = '206' AND
b.tipo_ra = '1' AND b.grupo_ra in ('5') AND b.ncierre = 1 
AND b.dfecha_inicio_vig <= to_date('31-05-2025 12:00:00 AM','DD-MM-YYYY HH:MI:SS AM') and
(b.dfecha_final_vig >= to_date('31-05-2025 12:00:00 AM','DD-MM-YYYY HH:MI:SS AM') 
 OR b.dfecha_final_vig IS NULL)  AND b.cc = 2 --in (1,2,3,4,5,6,7,12,13)
 group by a.stercero, b.cc, c.cuenta_sap
 order by b.cc, a.stercero;


select distinct t.sconcepto, t.variable_valor, --t.cc,  
		STIPO_FUNCIONARIO, c.sconcepto, c.SCUENTA --, c.cc
from ( select distinct sconcepto, variable_valor, cc
		from rh_t_lm_valores 
		where extract(year from periodo) >= 2024
		and sconcepto not like 'PROV%' ) t,	 rh_lm_cuenta C
where  t.SCONCEPTO=c.SCONCEPTO 
and stipo_funcionario='PLANTA'
order by 1,2
;


select *
from rh_lm_cuenta
where sconcepto like '%NOMINA%PAG%'
;

select 
from RH_LM_CENTROS_COSTO cc
group by cc.CODIGO 
;


--RA, CUENTA CONTABLES, CENTROS COSTO
select distinct a.sconcepto,  b.cc, b.SCUENTA , c.CODIGO_MAESTRO
from rh_t_lm_valores a, 
	RH_LM_CUENTA b , 	RH_LM_CENTROS_COSTO C
where b.sconcepto = a.sconcepto
AND b.cc = c.codigo
and b.tipo_ra = '1'
and b.STIPO_FUNCIONARIO='PLANTA'
and extract(year from periodo) > 2021
order by 1;

--RA VS. CC
select distinct a.sconcepto,  b.cc, b.SCUENTA , c.CODIGO_MAESTRO
from rh_t_lm_valores a, 
	RH_LM_CUENTA b , 	RH_LM_CENTROS_COSTO C
where b.sconcepto = a.sconcepto
AND b.cc = c.codigo
and b.tipo_ra = '1'
and b.STIPO_FUNCIONARIO='PLANTA'
and extract(year from periodo) > 2021
order by 1;

--RA VS. CUENTAS CONTABLES
select distinct a.sconcepto,  b.*
from rh_t_lm_valores a, 
	RH_LM_CUENTA b 
where b.sconcepto = a.sconcepto
and b.tipo_ra = '1'
and b.STIPO_FUNCIONARIO='PLANTA'
and extract(year from periodo) > 2023
order by 1;


SET SERVEROUTPUT ON;
declare
     mensaje varchar2(3000):='select a.stercero, sum(valor) from rh_t_lm_valores a, rh_lm_cuenta b, rh_lm_centros_costo c where a.cuenta = b.cuenta and a.tercero = b.tercero';
BEGIN
	WHILE LENGTH(MENSAJE)>0 LOOP
		IF LENGTH(MENSAJE)>40 THEN
			dbms_output.put_line(substr(MENSAJE,1,40)||'..');
			MENSAJE := SUBSTR(MENSAJE,-1*(LENGTH(MENSAJE)-40));
		ELSE
			dbms_output.put_line(MENSAJE||';');
			MENSAJE := '';
		END IF;
	END LOOP;
  
END;
/ 
SET SERVEROUTPUT OFF;


select *
from TRC_INFORMACION_BASICA
where id in (2949,
3109,
3110)
;

SET SERVEROUTPUT ON;
DECLARE
	v_ssql 		VARCHAR2(32767) ;
	---mi_cursor   EXEC_SQL.CURSTYPE;
	
BEGIN
	v_ssql :=
	'select a.stercero, b.cc, SUM(valor) valor, SUM(valor_saldo) valor_saldo '||
	'from rh_t_lm_valores a, rh_lm_cuenta b, rh_lm_centros_costo c '||
	'where stipo_funcionario = a.stipofuncionario and '||
	'b.sconcepto = a.sconcepto and '||
	'b.cc = c.codigo and a.periodo =to_date(''30-04-2025 12:00:00 AM'',''DD-MM-YYYY HH:MI:SS AM'') and '||
	'a.ntipo_nomina = 0 AND a.sdevengado IN (0,1) AND '||
	'C.CODIGO NOT IN (2,3,4,5) AND A.NRO_RA = 8 AND B.SCOMPANIA = ''206'' AND '||
	'b.tipo_ra = ''1'' AND b.grupo_ra in (''5'') AND b.ncierre = 1  '||
	'AND b.dfecha_inicio_vig <= to_date(''30-04-2025 12:00:00 AM'',''DD-MM-YYYY HH:MI:SS AM'') and '||
	'(b.dfecha_final_vig >= to_date(''30-04-2025 12:00:00 AM'',''DD-MM-YYYY HH:MI:SS AM'')  '||
	' OR b.dfecha_final_vig IS NULL)  AND b.cc = 7 '||
	' group by a.stercero, b.cc '||
	' order by b.cc, a.stercero ';
	dbms_output.put_line('SQL: ' || v_ssql);
	EXECUTE IMMEDIATE v_ssql;
	--EXECUTE EXEC_SQL.

	/*EXEC_SQL.PARSE(EXEC_SQL.DEFAULT_CONNECTION,
                           mi_cursor,
                           mi_consulta,
                           exec_sql.V7);*/
END;
/
SET SERVEROUTPUT OFF;

 -- CURSOR cur_anexos(un_cc number) IS
    SELECT b.codigo,
           b.descripcion,
           'SAP' || a.archivo_plano,
           b.tabla_detalle
      FROM rh_lm_ra_cc a, rh_lm_centros_costo b
     WHERE a.ra = 1 --un_tipo_ra
      and a.cc in (7,8) --un_cc
       AND a.cc = b.codigo
	   ;

 cursor reg40(un_nro_ra NUMBER) is
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
     WHERE VIGENCIA = 2025
       AND NRO_RA = 8;	   


EXEC_SQL.parse 
SELECT   a.stercero, SUM(valor) valor, SUM(valor_saldo) valor_saldo 
FROM     rh_t_lm_valores a, rh_lm_cuenta b, rh_lm_centros_costo c 
WHERE    b.stipo_funcionario =  a.stipofuncionario AND      
b.sconcepto         =  a.sconcepto AND      
b.cc                =  c.codigo AND      
a.periodo           =  TO_DATE('31-05-2025 12:00:00 AM','DD-MM-YYYY HH:MI:SS AM') 
AND     a.ntipo_nomina      =  0 AND  a.sdevengado IN (0,1)  
AND      c.codigo    not  IN (2,3,4,5)  AND a.nro_ra    = 8 
AND b.scompania =  '206' AND b.tipo_ra   =  '1' AND b.grupo_ra IN ('5') 
AND  b.ncierre =  1  
AND b.dfecha_inicio_vig <= TO_DATE('31-05-2025 12:00:00 AM','DD-MM-YYYY HH:MI:SS AM')  
AND (b.dfecha_final_vig  >= TO_DATE('31-05-2025 12:00:00 AM','DD-MM-YYYY HH:MI:SS AM') 
	OR b.dfecha_final_vig IS NULL)  
	AND      b.cc =  7 GROUP BY a.stercero	   ;


 CURSOR c_ra IS
    SELECT nro_ra, aprobacion
      FROM rh_lm_ra
     WHERE scompania = una_compania
       AND tipo_ra = 1 --un_tipo_ra
       AND grupo_ra = 5b--un_grupo_ra
       AND dfecha_inicial_periodo = to_date('20250501',una_fecha_inicial
       AND dfecha_final_periodo = una_fecha_final
       AND ntipo_nomina = un_tipo_nomina;


SELECT *
FROM all_source
WHERE /*owner = 'RH' -- Replace with the actual schema owner
  AND*/ name = 'EXEC_SQL'
  AND type = 'PACKAGE'
ORDER BY line;



select *
 from 
 --update 
 rh_lm_centros_costo
-- set codigo = 7
 where codigo=99;


 select *
 from rh_lm_cuenta
 where cc=7
 ;


--CURSOR c_ra IS
SELECT nro_ra, aprobacion
      FROM rh_lm_ra
     WHERE scompania = 206 --una_compania
       AND tipo_ra = 1 --un_tipo_ra
       AND grupo_ra = 5 ---un_grupo_ra
       AND dfecha_inicial_periodo = to_date('20250501','yyyymmdd') --una_fecha_inicial
       AND dfecha_final_periodo = to_date('20250531','yyyymmdd') --una_fecha_final
       AND ntipo_nomina = 0 --un_tipo_nomina
       ;

  CURSOR cur_anexos(un_cc number) IS
    SELECT b.codigo,
           length (b.codigo||'-'||b.descripcion||','||
           'SAP' || a.archivo_plano||','||
           b.tabla_detalle)
      FROM rh_lm_ra_cc a, rh_lm_centros_costo b
     WHERE a.ra = 1 --un_tipo_ra
       and a.cc <= 8 --un_cc
       /*--FTV PRUEBA 202405
          AND a.cc  =   7  --*/
       AND a.cc = b.codigo;       


--Cursor rubros(un_nro_ra NUMBER) is
    SELECT DISTINCT a.sconcepto, B.CC RUBRO, b.grupo_ra
      FROM RH_T_LM_VALORES     a,
           RH_LM_CUENTA        b,
           --RH_LM_CENTROS_COSTO L,
           RH_FUNCIONARIO f
     WHERE b.stipo_funcionario = a.stipofuncionario
       AND a.periodo = to_date('20250531','yyyymmdd') --una_fecha_final
       AND a.ntipo_nomina = 0 --un_tipo_nomina
       AND a.sdevengado IN (0, 1)
       AND a.nro_ra = 9 --un_nro_ra
       AND b.scompania = 206 --una_compania
       AND b.tipo_ra = 1 --un_tipo_ra
       AND b.ncierre = 1
       and tipo_ra = 0 --un_tipo_ra
       /*--PRUEBAS 2022
            and       a.nfuncionario IN (3428) --*/
       AND b.dfecha_inicio_vig <= to_date('20250531','yyyymmdd') --una_fecha_final
       AND (b.dfecha_final_vig >= to_date('20250531','yyyymmdd') OR --una_fecha_final OR
           b.dfecha_final_vig IS NULL)
       AND f.Personas_interno = a.nFuncionario
    UNION
    SELECT DISTINCT a.sconcepto, B.CC RUBRO, b.grupo_ra
      FROM RH_T_LM_VALORES     a,
           RH_LM_CUENTA        b,
           --RH_LM_CENTROS_COSTO L,
           RH_FUNCIONARIO f
     WHERE b.stipo_funcionario = a.stipofuncionario
     /*PRUEBAS
          AND      b.sconcepto         =   a.sconcepto --*/
       AND a.periodo = to_date('20250531','yyyyMMDD') --una_fecha_final
       AND a.ntipo_nomina = 0 --un_tipo_nomina
       AND a.sdevengado IN (2, 4)
       AND a.nro_ra = 9 --un_nro_ra
       AND b.scompania = 206 --una_compania
       AND b.tipo_ra = 1 --un_tipo_ra
       AND b.ncierre = 1
       and tipo_ra = 1 --un_tipo_ra
          /*--PRUEBAS 2022
            and       a.nfuncionario IN (4966,4946) --*/
       AND b.dfecha_inicio_vig <= to_date('20250531','yyyyMMDD') --una_fecha_final
       AND (b.dfecha_final_vig >= to_date('20250531','yyyyMMDD') /*una_fecha_final*/ OR
           b.dfecha_final_vig IS NULL)
       AND f.Personas_interno = a.nFuncionario
    ;       


select max(descripcion) nombrecc
      from rh_lm_centros_costo
     where codigo = 8;

select cuenta_Sap from RH_LM_CENTROS_COSTO a where     


 SELECT DISTINCT a.sconcepto, B.CC RUBRO, b.grupo_ra
      FROM RH_T_LM_VALORES     a,
           RH_LM_CUENTA        b,
           --RH_LM_CENTROS_COSTO L,
           RH_FUNCIONARIO f
     WHERE b.stipo_funcionario = a.stipofuncionario
       AND a.periodo = to_date('20250531','yyyymmdd') --una_fecha_final
       AND a.ntipo_nomina = 0 --un_tipo_nomina
       AND a.sdevengado IN (0, 1)
       AND a.nro_ra = 9 --un_nro_ra
       AND b.scompania = 206 --una_compania
       AND b.tipo_ra = 1 --un_tipo_ra
       AND b.ncierre = 0
       and tipo_ra = 0 --un_tipo_ra
       /*--PRUEBAS 2022
            and       a.nfuncionario IN (3428) --*/
       AND b.dfecha_inicio_vig <= to_date('20250531','yyyymmdd') --una_fecha_final
       AND (b.dfecha_final_vig >= to_date('20250531','yyyymmdd') OR --una_fecha_final OR
           b.dfecha_final_vig IS NULL)
       AND f.Personas_interno = a.nFuncionario
;

SELECT distinct sconcepto
FROM RH_T_LM_VALORES a
WHERE a.periodo = to_date('20250531','yyyymmdd')
AND a.ntipo_nomina = 0 --un_tipo_nomina
AND a.sdevengado IN (0, 1)
AND a.nro_ra = 9 --un_nro_ra
AND VARIABLE_VALOR LIKE 'NDD%'
;


SELECT DISTINCT B.SCONCEPTO, B.CC RUBRO, b.grupo_ra
      FROM 
           RH_LM_CUENTA        b
     WHERE b.stipo_funcionario = 'PLANTA'
       AND b.scompania = 206 --una_compania
       AND b.tipo_ra = 1 --un_tipo_ra
       AND b.ncierre = 1
       and tipo_ra =1 -- un_tipo_ra
       AND b.dfecha_inicio_vig <= to_date('20250531','yyyymmdd') --una_fecha_final
       AND (b.dfecha_final_vig >= to_date('20250531','yyyymmdd') OR --una_fecha_final OR
           b.dfecha_final_vig IS NULL)
       AND B.CC IS NOT NULL
       AND B.SCONCEPTO IN ('APORTEFONDOGARANTIA',
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

