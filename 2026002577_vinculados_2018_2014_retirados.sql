                                            Dependencia CargoNivel  Cargo   CargoGrado
/*
2026002577 Buenas tardes me permito solicitar la generación de un reporte con "nombre, cedula y cargo" de los funcionarios vinculados al FONCEP durante el periodo entre el 1 de julio de 2018 y el 31 de enero de 2024 y que actualmente se encuentren como retirados.       
*/

select /*distinct nom.funcionario,*/ p.nombres||' '||p.primer_apellido||' '||p.segundo_apellido nombre,
   p.numero_identificacion cedula, nom.cargo denominacion, nom.codigo_cargo, nom.grado, nom.nivel,
  nom.fecha_efectividad fecha_nombramiento, ret.fecha_efectividad fecha_retiro --, cfecha_inicial, cfecha_final 
from rh_personas p,
    (select da.funcionario, da.valor posicion_planta, aa.fecha_acto,
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
      and aa.fecha_efectividad between '01/JUL/2018' and '31/DEC/2024'  

      --and aa.fecha_efectividad between c.fecha_inicial and nvl(c.fecha_final,aa.fecha_efectividad)
      order by 1
    ) nom,
    (  
      select da.funcionario, da.valor posicion_planta, aa.fecha_acto,
          'RETIRO' acto,  aa.fecha_efectividad
      from rh_detalle_acto da, rh_actos_administrativos aa
      where da.nombre_detalle='POSICION'
      and aa.secuencia=da.secuencia
      and da.tipo_acto = '100'
      --and da.funcionario=624
      and aa.fecha_efectividad between '01/JUL/2018' and '31/DEC/2024'
    ) ret
where p.interno_persona = nom.funcionario 
  and p.interno_persona = ret.funcionario 
  --and ret.funcionario=544
  --and p.numero_identificacion = 1116437848
  and nom.posicion_planta = ret.posicion_planta
  and nom.fecha_efectividad < ret.fecha_efectividad
  --and instr(nom.cargo,'*',1) =0
order by p.numero_identificacion, nom.fecha_efectividad, ret.fecha_efectividad
;


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
