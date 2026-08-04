---ra en opget
--Cursor de la RA, los mismos datos con que se trabajaran
  CURSOR  c_ra  IS
    SELECT nro_ra, nro_ra_opget, vigencia, vigencia_presupuesto, numero_compromiso, aprobacion
    FROM   rh_lm_ra
    WHERE  scompania              = 206
    AND    tipo_ra                = 1
    AND    grupo_ra               = '5'
    AND    dfecha_inicial_periodo = '01/JUL/2026'
    AND    dfecha_final_periodo   = '31/JUL/2026'
    AND    ntipo_nomina           = 0
    ORDER BY vigencia_presupuesto;            


--Creo tabla backup
create table rh_t_lm_valores_202607ra16nom as
SELECT *
FROM    
RH_T_LM_VALORES
WHERE
    EXTRACT(YEAR FROM PERIODO) = 2026
    and periodo = '31/JUL/2026' 
    and stipofuncionario = 'PLANTA' 
    and ntipo_nomina=0
    and nro_ra = 16;


--Verifica la tabla backup (terminada en 202607ra16nom y la origina tenga los mismos datos)
select count(1), sum(valor) from rh_t_lm_valores --_202607ra16nom
WHERE
    EXTRACT(YEAR FROM PERIODO) = 2026
    and periodo = '31/JUL/2026' 
    and stipofuncionario = 'PLANTA' 
    and ntipo_nomina=0
    and nro_ra = 16; 
--commit;
/*
PROD    613349323	729
backp   613349323	729
*/

--Prerequisito: Debe tener alojado en algún lugar estos datos originales antes de actualizar terceros.
--Borra de rh_t_lm_valores
delete 
RH_T_LM_VALORES
WHERE
    EXTRACT(YEAR FROM PERIODO) = 2026
    and periodo = '31/JUL/2026' 
    and stipofuncionario = 'PLANTA' 
    and ntipo_nomina=0
    and nro_ra = 16;

--Restaura los datos del backup a rh_t_lm_valores
insert into rh_t_lm_valores (PERIODO,NTIPO_NOMINA,STIPOFUNCIONARIO,NFUNCIONARIO,
SDEVENGADO,SCONCEPTO,STERCERO,SDESCUENTO,VALOR,VALOR_SALDO,INDICE_TABLA,VARIABLE_VALOR,
CONTRAPARTIDA,REGIMEN,CC,PROYECTO,NRO_RA,CODIGO_PPTO_RESERVA,NRO_RP,VIGENCIA,FFECHA_INGRESO,
BENEFICIARIO
)
select PERIODO,NTIPO_NOMINA,STIPOFUNCIONARIO,NFUNCIONARIO,
SDEVENGADO,SCONCEPTO,STERCERO,SDESCUENTO,VALOR,VALOR_SALDO,INDICE_TABLA,VARIABLE_VALOR,
CONTRAPARTIDA,REGIMEN,CC,PROYECTO,NRO_RA,CODIGO_PPTO_RESERVA,NRO_RP,VIGENCIA,FFECHA_INGRESO,
BENEFICIARIO
from rh_t_lm_valores_202607ra16nom

---Verifica relación del backup con la cargada
select PERIODO,NTIPO_NOMINA,STIPOFUNCIONARIO,NFUNCIONARIO,
SDEVENGADO,SCONCEPTO,STERCERO,SDESCUENTO,VALOR,VALOR_SALDO,INDICE_TABLA,VARIABLE_VALOR,
CONTRAPARTIDA,REGIMEN,CC,PROYECTO,NRO_RA,CODIGO_PPTO_RESERVA,NRO_RP,VIGENCIA,FFECHA_INGRESO,
BENEFICIARIO
from rh_t_lm_valores_202607ra16nom b, rh_t_lm_valores v
WHERE
    EXTRACT(YEAR FROM b.PERIODO) = 2026
    and b.periodo = '31/JUL/2026' 
    and b.stipofuncionario = 'PLANTA' 
    and b.ntipo_nomina=0
    and b.nro_ra = 16
    and b.periodo = v.periodo
    and b.stipofuncionario=v.stipofuncionario
    and b.nro_ra=v.nro_ra
    and b.periodo = v.periodo
    and b.nfuncionario=v.nfuncionario
    and b.sdevengado = v.sdevengado
    and b.sconcepto = v.sconcepto
    and b.stercero = v.stercero
    ;
