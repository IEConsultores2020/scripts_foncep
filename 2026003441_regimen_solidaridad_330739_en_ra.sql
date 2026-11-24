/* Buen día, en perno en la nómina de septiembre al servidor publico 
Ferney Leornardo Velasquez cc 79817420 (657), en septiembre se le descontaron $99.600 de Regimen de Solidaridad, 
sin embargo en el archivo plano que se sube al operador de la plinilla figura en ceros este aporte, 
*/

select *
from rh_concepto
where nombre like '%PENSION%' --'%REGIMEN SOLIDARIDAD%'

;

select *
from rh_historico_nomina
where nfuncionario=657
and dinicioperiodo>=20260901 and dfinalperiodo<=20260930
and nhash in (843347602 -- INFO_APORTEREGIMENSOLIDARIDAD
            , 3168394695) -- INFO_NO_APORTAPENSION
            ;

select *
from rh_t_lm_valores
where periodo = '30-sep-26'
and (/*sconcepto = 'APORTEREGIMENSOLIDARIDAD'
or*/ variable_valor = 'NDD-APORTEPENSION')
and nfuncionario=657
;398169
 99600

/*Se valida paquete
PK_RH_AUTOLIQ_2388.FN_FORMATO_TEXTO_T2;
Cursor c_fun Is*/
	Select Distinct funcionario
	From RH_R2388_DETALLE
	Where CODIGO_COMPANIA = 206
      And ANHO = 2026
      And MES = '09'
      And TIPO_PLANILLA = 'E'
      And FECHA_PAGO = '01-OCT-26' --una_fecha;
      and funcionario=657
      ;
      
declare
    mi_linea number := 2;
    mi_total number := 0;
    mi_msg varchar2(4000);
begin

    PK_RH_AUTOLIQ_2388.fn_linea_pl_fun(una_compania => 206, 
                                   un_anho => 2026, 
                                   un_mes => 9,
                                   un_tipo_pl => 'E',
                                   una_fecha => 9,
                                   un_func => 657,
                                   un_indCorr => ' ',
                                   una_linea => mi_linea,
                                   un_total  => mi_total,
                                   un_msg  => mi_msg);
    dbms_output.put_line('Linea: ' || mi_linea || ' Total: ' || mi_total || ' Mensaje: ' || mi_msg);
end;                                   

Cursor c_pensionado Is
        Select ndcampo0
        From rh_historico_nomina_hoy
        Where nfuncionario = 657
        And nhash = 1008197514  -- INFO_NO_APORTAPENSION
        And besdefinitivo = 1
        And bRechazado = 0
        And nesnovedad = 1
        And nRetroactivo = 0
                And trunc(dfechaefectiva / 100, 0) <= 2026 * 100 + 9
        Order by dfechaefectiva Desc;

lpad(r_act.FSP_SOL,9,0)        

Cursor c_act (var_fun Number)Is
	Select *
	From RH_R2388_DETALLE
	Where CODIGO_COMPANIA = 206
      And ANHO = 2026
      And MES = 09
      And TIPO_PLANILLA = 'E'
      And FECHA_PAGO = '01-OCT-26' --una_fecha;
	  And Funcionario = 657
	  And Substr(NOVEDAD, 7, 6) = '000000' And Substr(NOVEDAD, 1, 1) = '0';

--PK_RH_AUTOLIQ_2388.PR_CARGAR_APORTES      

Select nfuncionario, nhash, -- TIPO_DOCUMENTO, NUMERO_IDENTIFICACION, NOMBRES, PRIMER_APELLIDO, SEGUNDO_APELLIDO,
		DFECHAEFECTIVA, DFECHAFINAL, DFECHANOVEDAD, NDCAMPO0 IBC_ARL, NDCAMPO1 IBC_CCF,
		NDCAMPO2 IBC_OTROS, NDCAMPO3 DIAS_ARL, NDCAMPO4 DIAS_CCF, NDCAMPO5 TARIFA_ARL, NDCAMPO6 TOTAL_ARL,
		NDCAMPO7 TOTAL_CCF, NDCAMPO8 TOTAL_SENA, NDCAMPO9 TOTAL_ICBF, NDCAMPO10 TOTAL_ESAP, NDCAMPO11 TOTAL_MEN,
		NDCAMPO12 PORC_PARAF, NDCAMPO13 SALARIO, dfecharegistro
	From rh_historico_nomina_hoy
	where --nhash = 854032720 -- INFO_PLANILLA_ENT
	--and dfechanovedad = 20260930 --nvl(fFPrincipal, var_finmes)
	and dfechaefectiva between 20260901 and 20260930
    and nfuncionario = 657
    order by dfechanovedad desc
	and trunc(dfecharegistro/100) = 202609 -- La fecha de pago debe corresponder a la fecha del proceso (planillas de ajustes)
	--and nfuncionario = 657
    And brechazado = 0
	and DFECHAEFECTIVA = 20260901
    order by 1 desc
;

Select nfuncionario, nhash, 
		DFECHAEFECTIVA, DFECHAFINAL, DFECHANOVEDAD, NDCAMPO0 IBC_ARL, NDCAMPO1 IBC_CCF,
		NDCAMPO2 IBC_OTROS, NDCAMPO3 DIAS_ARL, NDCAMPO4 DIAS_CCF, NDCAMPO5 TARIFA_ARL, NDCAMPO6 TOTAL_ARL,
		NDCAMPO7 TOTAL_CCF, NDCAMPO8 TOTAL_SENA, NDCAMPO9 TOTAL_ICBF, NDCAMPO10 TOTAL_ESAP, NDCAMPO11 TOTAL_MEN,
		NDCAMPO12 PORC_PARAF, NDCAMPO13 SALARIO, dfecharegistro
	From rh_historico_nomina_hoy
	where dfechanovedad = 20260930 
	and dfechaefectiva between 20260901 and 20260930
    and nfuncionario = 657
    order by dfechanovedad desc

select *
from rh_historico_hoy
where nfuncionario = 657
and dinicioperiodo=20260901 and dfinalperiodo=20260930
;
