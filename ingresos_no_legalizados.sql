/*
Se identifica errores para los siguientes casos: 56898, 56904, 56944 (está última es una acta nueva a las reportadas en este GLPI).
56898
Mensaje provisional para prueba:El numero de cuenta existe en SISLA y valor NO coinciden.Para la entidad ALCALDIA DE BUCARAMANGA.
56904:
Mensaje provisional para prueba:El numero de cuenta existe en SISLA y valor NO coinciden.Para la entidad GOBERNACIONAL BOLIVAR - FONDO TERRITORIAL DE PENSIONES"
56944:
Mensaje provisional para prueba:El numero de cuenta existe en SISLA y valor NO coinciden.Para la entidad GOBERNACIONAL DEL HUILA - FONDO TERRITORIAL DE PENSIONES"
El origen del mensaje es en la ejecución de la función:
56896  No se puede Legalizar el acta: 56896. Legalización cancelada.
*/

/*
ACTA    VALOR OGT   VALOR SISLA
56896   437565      437565           legalizado ok. Estado = 'LE'
*/

--Consulta en opget para obtener las cuentas de cobro y valor
select numero_legal,
       numero_sisla,
       fecha_soporte,
       fecha,
       valor
  from ogt_detalle_documento dd,
       ogt_documento d1
 where dd.doc_numero = d1.numero
   and dd.doc_tipo = d1.tipo
   --and tipo_legal = mi_tipo_acta
   and numero_legal in ( '56898',
                         '56904',
                         '56944' )
   and numero_sisla is not null;
           

--Consulta usada en sisla en el paquete:
--pk_sl_interfaz_opget_cp.pr_actualiza_interfaz_opget_cp
select 'S',
       id_cuenta_cobro,
       fac.vlr_total,
       fac.saldo
  from sl_cuenta_cobro_cp_2017 fac
 where id_cuenta_cobro in  --p_cuenta_cobro_volante;
  ( 2025001273,
                            2025001272,
                            2025001283 );

--Si primera consulta valor <> fac.saldo no legaliza el acta