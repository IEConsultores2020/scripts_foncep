 select interno_persona
from rh_personas
where numero_identificacion in (1049606827);

    select *
    from rh_t_lm_valores
    where  ntipo_nomina = 1 and periodo='31/dec/2025' and nro_ra =27
    and nfuncionario = 607
    and variable_valor = 'NDD-CCOOPERATIVA';

 delete rh_t_lm_valores
 where  ntipo_nomina = 1 and periodo='31/dec/2025' and nro_ra =27
 and nfuncionario = 607
 and valor =68700
 and variable_valor = 'NDD-CCOOPERATIVA';

 update rh_t_lm_valores
 set valor = valor + 68700
 where  ntipo_nomina = 1 and periodo='31/dec/2025' and nro_ra =27
 and nfuncionario = 607
 and valor = -137400
 and variable_valor = 'NDD-CCOOPERATIVA';

 commit;


     select *
    from rh_t_lm_valores
    where  ntipo_nomina = 1 and periodo='31/dec/2025' and nro_ra =27
    and nfuncionario = 607
   -- and valor =67963
     and variable_valor = 'NDD-CSINDICATO';

      update rh_t_lm_valores
 set valor = valor + 67963
 where  ntipo_nomina = 1 and periodo='31/dec/2025' and nro_ra =27
 and nfuncionario = 607
 and valor = -135926
 and variable_valor = 'NDD-CSINDICATO';

  delete rh_t_lm_valores
 where  ntipo_nomina = 1 and periodo='31/dec/2025' and nro_ra =27
 and nfuncionario = 607
 and valor =67963
 and variable_valor = 'NDD-CSINDICATO';

 commit;