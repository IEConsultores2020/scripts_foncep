                                            Dependencia CargoNivel  Cargo   CargoGrado
/*
2026003861 Me permito solicitar un reporte de todo lo devengado y deducido desde el mes de agosto de 2022 a la fecha, mes por mes, servidor por servidor, con fecha de ingreso y retiro, incluida la retención en la fuente. 
*/

select /*distinct nom.funcionario,*/ p.nombres||' '||p.primer_apellido||' '||p.segundo_apellido nombre,
   p.numero_identificacion cedula, /* nom.cargo denominacion, nom.codigo_cargo, nom.grado, nom.nivel,*/
  nom.fecha_efectividad fecha_nombramiento, ret.fecha_efectividad fecha_retiro, --, cfecha_inicial, cfecha_final 
  TRUNC(v.dinicioperiodo/100) FECHAMES,
        v.nombre,
        decode(v.devengado,'S',valor_deducido,0) "DEVENGADO",
        decode(v.devengado,'N',valor_deducido,0) "DEDUCIDO",
  es.resultado escala_salarial
 -- select count(1)
from rh_personas p
join rh_funcionario f on p.interno_persona=f.personas_interno
join  (select da.funcionario, da.valor posicion_planta, aa.fecha_acto,
          'NOMBRAMIENTO' acto,  aa.fecha_efectividad, aa.secuencia, 
          c.codigo_cargo, c.grado, c.nivel, c.descripcion cargo, c.fecha_inicial cfecha_inicial --, c.fecha_final cfecha_final
          --select *
      from rh_detalle_acto da, rh_actos_administrativos aa,  rh_posiciones p, 
          rh_cargo c
      where da.nombre_detalle='POSICION'
      and aa.secuencia=da.secuencia
      and da.tipo_acto = '010'
      and da.valor=p.secuencia
      and p.codigo_compania=206
      and p.cargo=c.codigo_cargo
      and p.cargo_grado=c.grado
      and p.cargo_nivel=c.nivel
      and p.cargo_fecha_inicial = c.fecha_inicial
      --and da.funcionario=544
      --and aa.fecha_efectividad  >=  '01/AUG/2022'

      --and aa.fecha_efectividad between c.fecha_inicial and nvl(c.fecha_final,aa.fecha_efectividad)
      order by 1
    ) nom on  p.interno_persona = nom.funcionario
    join 
    (  
      select da.funcionario, da.valor posicion_planta, aa.fecha_acto,
          'RETIRO' acto,  aa.fecha_efectividad
      from rh_detalle_acto da, rh_actos_administrativos aa
      where da.nombre_detalle='POSICION'
      and aa.secuencia=da.secuencia
      and da.tipo_acto = '100'
      --and da.funcionario=624
     -- and aa.fecha_efectividad >=  '01/AUG/2022' 
    ) ret on  p.interno_persona = ret.funcionario  and nom.posicion_planta = ret.posicion_planta
       and nom.fecha_efectividad < ret.fecha_efectividad
    join v_consulta_nomina v on p.interno_persona = v.func_deducido and dinicioperiodo >= 20220801 
    left join  bintablas es
        on es.grupo = 'NOMINA' and es.nombre like 'ESCALA SALARIAL%' and es.argumento='ACUERDO' and
        f.fecha_ingreso_entidad between es.vig_inicial and nvl(es.vig_final, sysdate)
order by p.numero_identificacion, nom.fecha_efectividad, ret.fecha_efectividad
;--13497


select *
from rh_posiciones
where secuencia=416

  SELECT * --Descripcion
      FROM rh_Cargo
     WHERE codigo_compania = 206
     AND descripcion='AUXILIAR ADMINISTRATIVO'
      AND codigo_cargo = 407
       AND grado  = 18
       AND nivel  = 5
       AND fecha_final IS NULL; 

           pk_rh_cardetalle_acto.pr_rh_nombre_cargo 
          (:rh_actos_administrativos.secuencia,
          'CARGO',
          'GRADO',
          'NIVEL', 
           mi_des_cargo);
