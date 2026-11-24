/*
2026003688 GENERACION RA OPGET Nomina 202610
*/

SELECT * --/*nfuncionario,*/ sconcepto, sum(valor)
FROM  RH_T_LM_VALORES
WHERE
    EXTRACT(YEAR FROM PERIODO) = 2026
    and periodo = '31/OCT/2026' 
    and stipofuncionario = 'PLANTA' 
    and ntipo_nomina=0
    and nro_ra = 22   
    --and sconcepto IN ('SENA','ICBF','CAJA')
    and nfuncionario =510
--GROUP BY nfuncionario,   SCONCEPTO,    VARIABLE_VALOR *
;

    select b.codigo,
           b.tipo_documento,
           b.numero_documento,
           b.nombres || ' ' || b.apellidos
      from rh_descuentos_f a, rh_embargos_beneficiario b
     where b.codigo = a.demandante
       and a.beneficiario = 413839
       and a.funcionario = 658
       and a.numero_descuento = 2;

select *
from rh_embargos_beneficiario
where length(nombres) > 40;

 select b.codigo,
           b.tipo_documento,
           b.numero_documento,
           b.nombres || ' ' || b.apellidos
      from rh_descuentos_f a, rh_embargos_beneficiario b
     where b.codigo = a.demandante
       and a.beneficiario = 413839
       and a.funcionario = 658
       and a.numero_descuento = 2;

select nombres, length(nombres)
from 
--update 
rh_embargos_beneficiario
--set nombres =  substr(nombres,1,39)
where codigo=57
--JUZGADO 3 CIVIL MUNICIPAL VILLAVICENCIO META
order by 1
--commit

select *
from trc_informacion_basica
where id = 413839
and ib_primer_nombre = REGEXP_REPLACE(ib_primer_nombre, '[[:cntrl:]]', '')

  select b.codigo,
           b.tipo_documento,
           b.numero_documento,
           b.nombres || ' ' || b.apellidos,
           a.funcionario,
           a.beneficiario,
           a.numero_descuento
      from rh_descuentos_f a, rh_embargos_beneficiario b
     where b.codigo = a.demandante
      -- and a.beneficiario = 413989
       and a.funcionario in (646,658 )
       ;

begin
  pr_rh_demandante(646,2992,1);
  pr_rh_demandante(658,5818,1);
  pr_rh_demandante(658,413839,2);
end;
