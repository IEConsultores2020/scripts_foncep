select * --interno
  from pr_rubro
 where vigencia = 2025
   and interno = 1491
   and descripcion like 'Serv%arq%';

select *
  from ogt_registro_presupuestal
 where vigencia_presupuesto = 2025
   and rubro_interno = 1491
   and valor_registro is not null;

select *
  from ogt_disponibilidad;

select *
  from pr_anulaciones
 where vigencia = 2025
   and codigo_compania = 206
   and codigo_unidad_ejecutora = '01'
   and documento_anulado = 'CDP'
   and numero_ofico;


select *
  from bintablas
 where grupo = 'PREDIS'
   and nombre = 'ESTADO_CDP'
   and
                      --argumento = mi_estado AND
    vig_inicial <= sysdate
   and ( vig_final >= sysdate
    or vig_final is null );