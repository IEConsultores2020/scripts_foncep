--                                                              FORMA DESCUENTO             DESPRENDIBLE    HISTORICO NOMINA
--Henry Cruz Quintero                   79496995    550       NO REGISTRA PAGO EN MAYO      NO REGISTRA
--Marleny del Socorro Alvaréz Lara      51968992    106       FINALIZO EN 25-04-2025        
--Gustavo Calderon Padilla              80039413    219       NO REGISTRA PAGO EN MAYO      NO REGISTRA

select *
from RH_PERSONAS
where NUMERO_IDENTIFICACION in (79496995,51968992,80039413)
;

select *
from rh_t_lm_valores
where periodo = '31/MAY/25'
and nfuncionario in (550,106,219)
and variable_valor = 'NDD-CCOOPERATIVA'
;

