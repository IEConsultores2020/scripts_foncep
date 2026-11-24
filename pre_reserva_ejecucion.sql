/*
Parametros:
p_mes:      12
p_vigencia: (2009..2026)
p_compania: 206
p_unidad:   01
p_nivel:    3
*/


SELECT pr_1.vigencia,
       codigo_compania,
       codigo_unidad_ejecutora,
       pr_1.interno,
       vCmprmso,
       vSaldoRP,
       PK_PR_CONSOLIDADOS_RESERVAS.fn_pre_GirosMes(pr_1.vigencia,
                                                   codigo_compania,
                                                   codigo_unidad_ejecutora,
                                                   :p_mes,
                                                   pr_1.interno) total_giros_mes,
       PK_PR_CONSOLIDADOS_RESERVAS.fn_pre_GirosAcumulados(pr_1.vigencia,
                                                          codigo_compania,
                                                          codigo_unidad_ejecutora,
                                                          :p_mes,
                                                          vSaldoRP,
                                                          pr_1.interno) total_giros_acum,
       (PR_NIVEL1.codigo || '-' || PR_NIVEL2.codigo || '-' ||
       PR_NIVEL3.codigo || '-' || PR_NIVEL4.codigo || '-' ||
       PR_NIVEL5.codigo || '-' || PR_NIVEL6.codigo || '-' ||
       PR_NIVEL7.codigo || '-' || PR_NIVEL8.codigo) cadena,
       PR_NIVEL1.codigo cadena_nivel1,
       (PR_NIVEL1.codigo || '-' || PR_NIVEL2.codigo) cadena_nivel2,
       (PR_NIVEL1.codigo || '-' || PR_NIVEL2.codigo || '-' ||
       PR_NIVEL3.codigo) cadena_nivel3,
       (PR_NIVEL1.codigo || '-' || PR_NIVEL2.codigo || '-' ||
       PR_NIVEL3.codigo || '-' || PR_NIVEL4.codigo) cadena_nivel4,
       (PR_NIVEL1.codigo || '-' || PR_NIVEL2.codigo || '-' ||
       PR_NIVEL3.codigo || '-' || PR_NIVEL4.codigo || '-' ||
       PR_NIVEL5.codigo) cadena_nivel5,
       (PR_NIVEL1.codigo || '-' || PR_NIVEL2.codigo || '-' ||
       PR_NIVEL3.codigo || '-' || PR_NIVEL4.codigo || '-' ||
       PR_NIVEL5.codigo || '-' || PR_NIVEL6.codigo) cadena_nivel6,
       (PR_NIVEL1.codigo || '-' || PR_NIVEL2.codigo || '-' ||
       PR_NIVEL3.codigo || '-' || PR_NIVEL4.codigo || '-' ||
       PR_NIVEL5.codigo || '-' || PR_NIVEL6.codigo || '-' ||
       PR_NIVEL7.codigo) cadena_nivel7,
       (PR_NIVEL1.codigo || '-' || PR_NIVEL2.codigo || '-' ||
       PR_NIVEL3.codigo || '-' || PR_NIVEL4.codigo || '-' ||
       PR_NIVEL5.codigo || '-' || PR_NIVEL6.codigo || '-' ||
       PR_NIVEL7.codigo || '-' || PR_NIVEL8.codigo) cadena_nivel8,
       PR_NIVEL1.descripcion descripcion_nivel1,
       PR_NIVEL2.descripcion descripcion_nivel2,
       PR_NIVEL3.descripcion descripcion_nivel3,
       PR_NIVEL4.descripcion descripcion_nivel4,
       PR_NIVEL5.descripcion descripcion_nivel5,
       PR_NIVEL6.descripcion descripcion_nivel6,
       PR_NIVEL7.descripcion descripcion_nivel7,
       PR_NIVEL8.descripcion descripcion_nivel8,
       PR_RUBRO.descripcion,
       PR_NIVEL1.codigo codigo_nivel1,
       PR_NIVEL2.codigo codigo_nivel2,
       PR_NIVEL3.codigo codigo_nivel3,
       PR_NIVEL4.codigo codigo_nivel4,
       PR_NIVEL5.codigo codigo_nivel5,
       PR_NIVEL6.codigo codigo_nivel6,
       PR_NIVEL7.codigo codigo_nivel7,
       PR_NIVEL8.codigo codigo_nivel8
      /* ;

select *       */
  FROM (SELECT pr.vigencia,
               pr.codigo_compania,
               codigo_unidad_ejecutora,
               pr.interno,
               SUM(vCmprmso) vCmprmso,
               (SUM(vSaldo)) vSaldoRP
          FROM (SELECT de.vigencia vigencia,
                       de.codigo_compania codigo_compania,
                       de.codigo_unidad_ejecutora codigo_unidad_ejecutora,
                       de.rubro_interno interno,
                       'COM' tipo,
                       2 orden,
                       ma.fecha_registro fecha,
                       TO_CHAR(ma.numero_registro) nDoc,
                       NVL(ma.tipo_compromiso || '-' ||
                           TO_CHAR(ma.numero_compromiso) || '-' || co.objeto,
                           'TEMPO') detalle,
                       0 consecutivo_orden,
                       de.valor vCmprmso,
                       pk_pr_compromisos.fn_pre_saldo_rp_fc(:p_vigencia - 1,
                                                            :p_compania,
                                                            :p_unidad,
                                                            ma.numero_registro,
                                                            ma.numero_disponibilidad,
                                                            de.rubro_interno,
                                                            TO_DATE(TO_CHAR('31-12-' ||
                                                                            (:p_vigencia - 1)),
                                                                    'DD-MM-YYYY')) Vsaldo
                  FROM PR_COMPROMISOS             co,
                       PR_REGISTRO_PRESUPUESTAL   ma,
                       PR_REGISTRO_DISPONIBILIDAD de
                 WHERE co.vigencia = ma.vigencia
                   AND co.codigo_compania = ma.codigo_compania
                   AND co.codigo_unidad_ejecutora =
                       ma.codigo_unidad_ejecutora
                   AND co.numero_registro = ma.numero_registro
                   AND co.numero_compromiso = ma.numero_compromiso
                   AND co.tipo_compromiso = ma.tipo_compromiso
                   and ma.vigencia = de.vigencia
                   AND ma.codigo_compania = de.codigo_compania
                   AND ma.codigo_unidad_ejecutora =
                       de.codigo_unidad_ejecutora
                   AND ma.numero_registro = de.numero_registro
                   AND ma.numero_disponibilidad = de.numero_disponibilidad
                   AND co.vigencia = (:p_vigencia - 1)
                   AND co.codigo_compania = :p_compania
                   AND co.codigo_unidad_ejecutora = :p_unidad) pr
         WHERE pr.VIGENCIA = (:p_vigencia - 1)
           AND pr.CODIGO_COMPANIA = :p_compania
           AND pr.CODIGO_UNIDAD_EJECUTORA = :p_unidad
         GROUP BY pr.vigencia,pr.codigo_compania,pr.codigo_unidad_ejecutora,pr.interno) pr_1,
       PR_RUBRO,PR_NIVEL1,PR_NIVEL2,PR_NIVEL3,PR_NIVEL4,PR_NIVEL5,PR_NIVEL6,PR_NIVEL7,PR_NIVEL8
 WHERE pr_1.VIGENCIA = PR_RUBRO.VIGENCIA
   AND pr_1.INTERNO = PR_RUBRO.INTERNO
   AND PR_RUBRO.vigencia = PR_NIVEL1.vigencia
   AND PR_RUBRO.interno_nivel1 = PR_NIVEL1.interno
   AND PR_RUBRO.tipo_plan = PR_NIVEL1.tipo_plan
   AND PR_RUBRO.vigencia = PR_NIVEL2.vigencia
   AND PR_RUBRO.interno_nivel2 = PR_NIVEL2.interno
   AND PR_RUBRO.tipo_plan = PR_NIVEL2.tipo_plan
   AND PR_RUBRO.vigencia = PR_NIVEL3.vigencia
   AND PR_RUBRO.interno_nivel3 = PR_NIVEL3.interno
   AND PR_RUBRO.tipo_plan = PR_NIVEL3.tipo_plan
   AND PR_RUBRO.vigencia = PR_NIVEL4.vigencia
   AND PR_RUBRO.interno_nivel4 = PR_NIVEL4.interno
   AND PR_RUBRO.tipo_plan = PR_NIVEL4.tipo_plan
   AND PR_RUBRO.vigencia = PR_NIVEL5.vigencia
   AND PR_RUBRO.interno_nivel5 = PR_NIVEL5.interno
   AND PR_RUBRO.tipo_plan = PR_NIVEL5.tipo_plan
   AND PR_RUBRO.vigencia = PR_NIVEL6.vigencia
   AND PR_RUBRO.interno_nivel6 = PR_NIVEL6.interno
   AND PR_RUBRO.tipo_plan = PR_NIVEL6.tipo_plan
   AND PR_RUBRO.vigencia = PR_NIVEL7.vigencia
   AND PR_RUBRO.interno_nivel7 = PR_NIVEL7.interno
   AND PR_RUBRO.tipo_plan = PR_NIVEL7.tipo_plan
   AND PR_RUBRO.vigencia = PR_NIVEL8.vigencia
   AND PR_RUBRO.interno_nivel8 = PR_NIVEL8.interno
   AND PR_RUBRO.tipo_plan = PR_NIVEL8.tipo_plan
   AND NOT EXISTS
 (SELECT BINTABLAS.RESULTADO
          FROM BINTABLAS
         WHERE BINTABLAS.GRUPO = 'PREDIS'
           AND BINTABLAS.NOMBRE = 'CODIGOS_NIVEL'
           AND (BINTABLAS.ARGUMENTO = 'RESER_PRESUPUESTALES_N3' OR
               BINTABLAS.ARGUMENTO = 'RESERVAS_FUNCIONAMIENTO' OR
               BINTABLAS.ARGUMENTO = 'RESERVAS_DEUDA' OR
               BINTABLAS.ARGUMENTO = 'PASIVOS_EXIGIBLES_N3' OR
               BINTABLAS.ARGUMENTO = 'PASIVOS_EXIGIBLES_FUNCIONA_N3' OR /*3-1-5*/ -- Inicio modificación - RQ2013-555  -  17/06/2013
               BINTABLAS.ARGUMENTO = 'PASIVOS_DEUDA' /*3-2-7*/ -- Fin modificación - RQ2013-555  -  17/06/2013
               )
           AND ((:p_vigencia - 1 >= TO_NUMBER(TO_CHAR(vig_inicial, 'YYYY')) AND
               vig_final IS NULL) OR (:p_vigencia - 1 BETWEEN
               TO_NUMBER(TO_CHAR(vig_inicial, 'YYYY')) AND
               TO_NUMBER(TO_CHAR(vig_final, 'YYYY'))))
           AND RESULTADO = (PR_NIVEL1.CODIGO || '-' || PR_NIVEL2.CODIGO || '-' ||
               PR_NIVEL3.CODIGO))
   AND
      
       pr_1.vigencia = :p_vigencia - 1
   AND pr_1.CODIGO_COMPANIA = :p_compania
   AND pr_1.CODIGO_UNIDAD_EJECUTORA = :p_unidad
   AND pr_1.vSaldoRP <> 0
   AND PR_NIVEL1.codigo = :p_nivel1
