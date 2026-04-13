select periodo,  sum(valor)
from rh_t_lm_valores
where extract(year from periodo) = 2026
   and stipofuncionario = 'PLANTA' 
group by periodo
order by  1
;

select 
   /*
    scompania              comp,  
    vigencia               vige,
    grupo_ra               gra,*/
    vigencia_presupuesto   vpto,
    -- unidad_ejecutora       ue,
    -- ano_pac                apac,
    ntipo_nomina           tnom,
    --mes_pac                mpac,
    --dfecha_inicial_periodo  fecha_ini,
    tipo_compromiso        tc,
    numero_compromiso      nc,
    nro_ra                 nra,
    nro_ra_opget           nra_ogt,
    case tipo_ra
        when '1' then '1 - nomina'
        when '2' then '2 - seguridad social'
        when '3' then '3 - cesantias'
        when '4' then '4 - cesantias fondos'
        else tipo_ra
    end tipo_de_ra ,
    dfecha_inicial_periodo dfecini,
    dfecha_final_periodo   dfecfin,
    aprobacion             a,
    actualizado_contab     ac,
    gen_cxp_opget          gcxp,
    contabilizado          ctdo,
    contabilizar           ctar 
from rh_lm_ra 
where scompania = 206 
    and extract(year from dfecha_inicial_periodo) = 2026
order by
    dfecha_inicial_periodo desc,
    tipo_ra asc;

select  
        pr_1.vigencia,
        codigo_compania,
       codigo_unidad_ejecutora,       
        pr_1.interno,
        vcmprmso,
        vsaldorp,
pk_pr_consolidados_reservas.fn_pre_girosmes(pr_1.vigencia ,codigo_compania ,codigo_unidad_ejecutora , :p_mes ,pr_1.interno ) total_giros_mes,
pk_pr_consolidados_reservas.fn_pre_girosacumulados(pr_1.vigencia ,codigo_compania ,codigo_unidad_ejecutora , :p_mes ,vsaldorp ,pr_1.interno) total_giros_acum,
        (pr_nivel1.codigo||'-'||
        pr_nivel2.codigo||'-'||
        pr_nivel3.codigo||'-'||
        pr_nivel4.codigo||'-'||
        pr_nivel5.codigo||'-'||
        pr_nivel6.codigo||'-'||
        pr_nivel7.codigo||'-'||
        pr_nivel8.codigo) cadena,
        pr_nivel1.codigo cadena_nivel1,
        (pr_nivel1.codigo||'-'||pr_nivel2.codigo) cadena_nivel2,
        (pr_nivel1.codigo||'-'||pr_nivel2.codigo||'-'||pr_nivel3.codigo) cadena_nivel3,
        (pr_nivel1.codigo||'-'||pr_nivel2.codigo||'-'||pr_nivel3.codigo||'-'||pr_nivel4.codigo) cadena_nivel4,
        (pr_nivel1.codigo||'-'||pr_nivel2.codigo||'-'||pr_nivel3.codigo||'-'||pr_nivel4.codigo||'-'||pr_nivel5.codigo) cadena_nivel5,
        (pr_nivel1.codigo||'-'||pr_nivel2.codigo||'-'||pr_nivel3.codigo||'-'||pr_nivel4.codigo||'-'||pr_nivel5.codigo||'-'||pr_nivel6.codigo) cadena_nivel6,
(pr_nivel1.codigo||'-'||pr_nivel2.codigo||'-'||pr_nivel3.codigo||'-'||pr_nivel4.codigo||'-'||pr_nivel5.codigo||'-'||pr_nivel6.codigo||'-'||pr_nivel7.codigo) cadena_nivel7,
(pr_nivel1.codigo||'-'||pr_nivel2.codigo||'-'||pr_nivel3.codigo||'-'||pr_nivel4.codigo||'-'||pr_nivel5.codigo||'-'||pr_nivel6.codigo||'-'||pr_nivel7.codigo||'-'||pr_nivel8.codigo) cadena_nivel8,
       pr_nivel1.descripcion descripcion_nivel1,
       pr_nivel2.descripcion descripcion_nivel2,
       pr_nivel3.descripcion descripcion_nivel3,
       pr_nivel4.descripcion descripcion_nivel4,
       pr_nivel5.descripcion descripcion_nivel5,
       pr_nivel6.descripcion descripcion_nivel6,
       pr_nivel7.descripcion descripcion_nivel7,
       pr_nivel8.descripcion descripcion_nivel8,
        pr_rubro.descripcion,
pr_nivel1.codigo codigo_nivel1,
pr_nivel2.codigo codigo_nivel2,
pr_nivel3.codigo codigo_nivel3,
pr_nivel4.codigo codigo_nivel4,
pr_nivel5.codigo codigo_nivel5,
pr_nivel6.codigo codigo_nivel6,
pr_nivel7.codigo codigo_nivel7,
pr_nivel8.codigo codigo_nivel8
from (
select 
               pr.vigencia    ,
              pr.codigo_compania,
              codigo_unidad_ejecutora    ,
               pr.interno     ,
               sum(vcmprmso) vcmprmso   ,
               (sum(vsaldo))   vsaldorp
 from
    (
  select
        de.vigencia                     vigencia    ,
        de.codigo_compania              codigo_compania,
        de.codigo_unidad_ejecutora      codigo_unidad_ejecutora    ,
        de.rubro_interno                interno     ,
        'com'                           tipo        ,
        2                               orden       ,
        ma.fecha_registro               fecha       ,
        to_char( ma.numero_registro )
                                        ndoc        ,
        nvl(ma.tipo_compromiso || '-'|| to_char( ma.numero_compromiso )|| '-' || co.objeto,'tempo')    detalle,
       0    consecutivo_orden,
        de.valor                        vcmprmso    ,
       pk_pr_compromisos.fn_pre_saldo_rp_fc (:p_vigencia-1,
                          :p_compania,
                          :p_unidad,
                          ma.numero_registro,
                          ma.numero_disponibilidad,
                          de.rubro_interno,                                               to_date(to_char('31-12-'||(:p_vigencia-1)),'dd-mm-yyyy'))vsaldo
      from
        pr_compromisos                  co,
        pr_registro_presupuestal        ma          ,
        pr_registro_disponibilidad      de
      where
         co.vigencia = ma.vigencia                    
        and co.codigo_compania = ma.codigo_compania              
        and co.codigo_unidad_ejecutora = ma.codigo_unidad_ejecutora   
        and co.numero_registro    = ma.numero_registro  
        and co.numero_compromiso = ma.numero_compromiso  
        and co.tipo_compromiso = ma.tipo_compromiso  
        and ma.vigencia = de.vigencia                
        and ma.codigo_compania = de.codigo_compania            
        and ma.codigo_unidad_ejecutora = de.codigo_unidad_ejecutora   
        and ma.numero_registro = de.numero_registro       
        and ma.numero_disponibilidad = de.numero_disponibilidad    
        and co.vigencia                = ( :p_vigencia-1)
        and co.codigo_compania         =  :p_compania
        and co.codigo_unidad_ejecutora =  :p_unidad
    )   pr	
  where
    pr.vigencia            =   ( :p_vigencia-1)  and
    pr.codigo_compania     =  :p_compania  and
    pr.codigo_unidad_ejecutora = :p_unidad  
   group by     pr.vigencia    ,
              pr.codigo_compania,
              pr.codigo_unidad_ejecutora    ,
              pr.interno
   )  pr_1, pr_rubro,pr_nivel1, pr_nivel2, pr_nivel3,
pr_nivel4, pr_nivel5,
pr_nivel6, pr_nivel7, pr_nivel8
where pr_1.vigencia=pr_rubro.vigencia and
pr_1.interno=pr_rubro.interno and
pr_rubro.vigencia = pr_nivel1.vigencia and
pr_rubro.interno_nivel1 = pr_nivel1.interno and
pr_rubro.tipo_plan = pr_nivel1.tipo_plan and
pr_rubro.vigencia = pr_nivel2.vigencia and
pr_rubro.interno_nivel2 = pr_nivel2.interno and
pr_rubro.tipo_plan = pr_nivel2.tipo_plan and
pr_rubro.vigencia = pr_nivel3.vigencia and
pr_rubro.interno_nivel3 = pr_nivel3.interno and
pr_rubro.tipo_plan = pr_nivel3.tipo_plan and
pr_rubro.vigencia = pr_nivel4.vigencia and
pr_rubro.interno_nivel4 = pr_nivel4.interno and
pr_rubro.tipo_plan = pr_nivel4.tipo_plan and
pr_rubro.vigencia = pr_nivel5.vigencia and
pr_rubro.interno_nivel5 = pr_nivel5.interno and
pr_rubro.tipo_plan = pr_nivel5.tipo_plan and
pr_rubro.vigencia = pr_nivel6.vigencia and
pr_rubro.interno_nivel6 = pr_nivel6.interno and
pr_rubro.tipo_plan = pr_nivel6.tipo_plan and
pr_rubro.vigencia = pr_nivel7.vigencia and
pr_rubro.interno_nivel7 = pr_nivel7.interno and
pr_rubro.tipo_plan = pr_nivel7.tipo_plan and
pr_rubro.vigencia = pr_nivel8.vigencia and
pr_rubro.interno_nivel8 = pr_nivel8.interno and
pr_rubro.tipo_plan = pr_nivel8.tipo_plan and
--pr_rubro.descripcion = 'Gastos de personal' and
not exists (select bintablas.resultado 
              from bintablas 
                 where bintablas.grupo = 'predis' and 
                          bintablas.nombre = 'codigos_nivel' and 
                         (bintablas.argumento = 'reser_presupuestales_n3' or   
                          bintablas.argumento = 'reservas_funcionamiento' or 
                          bintablas.argumento = 'reservas_deuda' or
                          bintablas.argumento = 'pasivos_exigibles_n3' or
                          bintablas.argumento = 'pasivos_exigibles_funciona_n3' or  /*3-1-5*/  -- inicio modificación - rq2013-555  -  17/06/2013
                          bintablas.argumento = 'pasivos_deuda'   /*3-2-7*/   -- fin modificación - rq2013-555  -  17/06/2013
                                                                                               ) and 
                         ((:p_vigencia-1 >= to_number(to_char(vig_inicial,'yyyy')) and vig_final is null) or 
                          (:p_vigencia-1 between to_number(to_char(vig_inicial,'yyyy')) and to_number(to_char(vig_final,'yyyy')))) 
                          and resultado = (pr_nivel1.codigo||'-'||pr_nivel2.codigo||'-'||pr_nivel3.codigo)) and 
 
pr_1.vigencia = :p_vigencia-1 and
pr_1.codigo_compania     =  :p_compania  and
pr_1.codigo_unidad_ejecutora = :p_unidad and  
pr_1.vsaldorp <> 0 and
pr_nivel1.codigo = :p_nivel1 
;

select *
from pr_rubro
wh

select 
pk_pr_consolidados_reservas.fn_pre_girosmes(:vigencia ,:compania ,:unidad_ejecutora , :p_mes ,pr_1.interno ) total_giros_mes,
 pk_pr_consolidados_reservas.fn_pre_girosacumulados(:vigencia ,:compania ,:unidad_ejecutora , :p_mes ,vsaldorp ,pr_1.interno) total_giros_acum,
;



  select
        de.vigencia                     vigencia    ,
        de.codigo_compania              codigo_compania,
        de.codigo_unidad_ejecutora      codigo_unidad_ejecutora    ,
        de.rubro_interno                interno     ,
        'com'                           tipo        ,
        2                               orden       ,
        ma.fecha_registro               fecha       ,
        to_char( ma.numero_registro )
                                        ndoc        ,
        nvl(ma.tipo_compromiso || '-'|| to_char( ma.numero_compromiso )|| '-' || co.objeto,'tempo')    detalle,
       0    consecutivo_orden,
        de.valor                        vcmprmso    ,
       pk_pr_compromisos.fn_pre_saldo_rp_fc (:p_vigencia-1,
                          :p_compania,
                          :p_unidad,
                          ma.numero_registro,
                          ma.numero_disponibilidad,
                          de.rubro_interno,                                               to_date(to_char('31-12-'||(:p_vigencia-1)),'dd-mm-yyyy'))vsaldo
      from
        pr_compromisos                  co,
        pr_registro_presupuestal        ma          ,
        pr_registro_disponibilidad      de,
      where
         co.vigencia = ma.vigencia                    
        and co.codigo_compania = ma.codigo_compania              
        and co.codigo_unidad_ejecutora = ma.codigo_unidad_ejecutora   
        and co.numero_registro    = ma.numero_registro  
        and co.numero_compromiso = ma.numero_compromiso  
        and co.tipo_compromiso = ma.tipo_compromiso  
        and ma.vigencia = de.vigencia                
        and ma.codigo_compania = de.codigo_compania            
        and ma.codigo_unidad_ejecutora = de.codigo_unidad_ejecutora   
        and ma.numero_registro = de.numero_registro       
        and ma.numero_disponibilidad = de.numero_disponibilidad    
        and co.vigencia                = ( :p_vigencia-1)
        and co.codigo_compania         =  :p_compania
        and co.codigo_unidad_ejecutora =  :p_unidad
        and        pk_pr_compromisos.fn_pre_saldo_rp_fc (:p_vigencia-1,
                          :p_compania,
                          :p_unidad,
                          ma.numero_registro,
                          ma.numero_disponibilidad,
                          de.rubro_interno,                                               to_date(to_char('31-12-'||(:p_vigencia-1)),'dd-mm-yyyy')) > 0;

    select 
       pk_pr_compromisos.fn_pre_saldo_rp_fc (:p_vigencia-1,
                          :p_compania,
                          :p_unidad,
                          ma.numero_registro,
                          ma.numero_disponibilidad,
                          de.rubro_interno,                                               to_date(to_char('31-12-'||(:p_vigencia-1)),'dd-mm-yyyy'))                          
                          ;


    select vr.descripcion, vr.interno_rubro, de.*, pk_pr_compromisos.fn_pre_saldo_rp_fc (:p_vigencia-1,
                            :p_compania,
                            :p_unidad,
                            ma.numero_registro,
                            ma.numero_disponibilidad,
                            de.rubro_interno,
                            to_date(to_char('31-12-'||(:p_vigencia-1)),'dd-mm-yyyy')) saldo                 
    from  pr_compromisos                  co,
        pr_registro_presupuestal        ma          ,
        pr_registro_disponibilidad      de,
        pr_v_rubros                     vr
    where  co.vigencia = ma.vigencia                    
        and co.codigo_compania = ma.codigo_compania              
        and co.codigo_unidad_ejecutora = ma.codigo_unidad_ejecutora   
        and co.numero_registro    = ma.numero_registro  
        and co.numero_compromiso = ma.numero_compromiso  
        and co.tipo_compromiso = ma.tipo_compromiso  
        and ma.vigencia = de.vigencia                
        and ma.codigo_compania = de.codigo_compania            
        and ma.codigo_unidad_ejecutora = de.codigo_unidad_ejecutora   
        and ma.numero_registro = de.numero_registro       
        and ma.numero_disponibilidad = de.numero_disponibilidad    
        and co.vigencia                = ( :p_vigencia-1)
        and co.codigo_compania         =  :p_compania
        and co.codigo_unidad_ejecutora =  :p_unidad
        and vr.interno_rubro = de.rubro_interno
        and vr.vigencia = de.vigencia
        and codigo_nivel1||'-'||codigo_nivel2||'-'||codigo_nivel3 = '2-1-01'
        and pk_pr_compromisos.fn_pre_saldo_rp_fc (:p_vigencia-1,
                            :p_compania,
                            :p_unidad,
                            ma.numero_registro,
                            ma.numero_disponibilidad,
                            de.rubro_interno,
                            to_date(to_char('31-12-'||(:p_vigencia-1)),'dd-mm-yyyy'))   > 0
