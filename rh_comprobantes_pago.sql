 	Insert into rh_reportes_nomina
  (NFUNCIONARIO     ,
	NESNOVEDAD       ,
	NHASH            ,
	SACTOADMI        ,
	SPROCESO         ,
	NCORRIDA         ,
	NCORRIDA_INTERNA ,
	DINICIOPERIODO   ,
	DFINALPERIODO    ,
	NDURACION        ,
	DFECHAREGISTRO   ,
	DFECHANOVEDAD    ,
	DFECHAEFECTIVA   ,
	DFECHAFINAL      ,
	BRECHAZADO       ,
	BESDEFINITIVO    ,
	NTIPOCONCEPTO    ,
	NDCAMPO0         ,
	NDCAMPO1         ,
	NDCAMPO2         ,
	NDCAMPO3         ,
	NDCAMPO4         ,
	NDCAMPO5         ,
	NDCAMPO6         ,
	NDCAMPO7         ,
	NDCAMPO8         ,
	NDCAMPO9         ,
	NDCAMPO10        ,
	NDCAMPO11        ,
	NDCAMPO12        ,
	NDCAMPO13        ,
	NDCAMPO14        ,
	NDCAMPO15        ,
	NRETROACTIVO     ,
	INFORMATIVO      ,
	USER_SESS)
  select NFUNCIONARIO     ,
		NESNOVEDAD       ,
		NHASH            ,
		SACTOADMI        ,
		SPROCESO         ,
		NCORRIDA         ,
		NCORRIDA_INTERNA ,
		DINICIOPERIODO   ,
		DFINALPERIODO    ,
		NDURACION        ,
		DFECHAREGISTRO   ,
		DFECHANOVEDAD    ,
		DFECHAEFECTIVA   ,
		DFECHAFINAL      ,
		BRECHAZADO       ,
		BESDEFINITIVO    ,
		NTIPOCONCEPTO    ,
		NDCAMPO0         ,
		NDCAMPO1         ,
		NDCAMPO2         ,
		NDCAMPO3         ,
		NDCAMPO4         ,
		NDCAMPO5         ,
		NDCAMPO6         ,
		NDCAMPO7         ,
		NDCAMPO8         ,
		NDCAMPO9         ,
		NDCAMPO10        ,
		NDCAMPO11        ,
		NDCAMPO12        ,
		NDCAMPO13        ,
		NDCAMPO14        ,
		NDCAMPO15        ,
		NRETROACTIVO     ,
		INFORMATIVO      ,
		USERENV('SESSIONID') 
  from  rh_historico_nomina, rh_funcionario
  where nfuncionario = personas_interno
  and dInicioperiodo >= :P_Fecha_Inicial
  and   dFinalPeriodo <= :P_Fecha_Final
  and   nCorrida = :P_Corrida
--  and estado_funcionario not in (3,7)  /* RETIRADO, LIQUIDADO*/
  and tipo_funcionario <> 8            /* PENSIONADOS */
 -- and nfuncionario = :P_PERSONA
  and nHash not in (121164364,121290711,3216194822,121652650)
  
SELECT DISTINCT(UPPER(his_nom.sproceso)) proceso,
       his_nom.nfuncionario, his_nom.nesnovedad, his_nom.nhash, 
       his_nom.dfechaefectiva, his_nom.dfechanovedad, 
       per.primer_apellido||' '||per.segundo_apellido||' '|| per.nombres nombre_fun,  
       per.numero_identificacion, 
       decode(depe.centro_costo,NULL,(select nvl(max(rh_dependencias.centro_costo),'999999')
                                      from rh_dependencias,rh_posiciones pos,rh_movimientos_planta, rh_concepto conc
                                      where rh_movimientos_planta.funcionario = his_nom.nfuncionario
                                        and rh_movimientos_planta.posicion_anterior = pos.secuencia
                                        and pos.codigo_compania = rh_dependencias.codigo_compania
                                        and pos.codigo_dependencia = rh_dependencias.codigo_dependencia
                                         AND (pos.cargo_fecha_inicial <=To_date(to_char(:P_FECHA_INICIAL), 'YYYYMMDD')
                                         AND  pos.fecha_final is null or pos.fecha_final >= To_date(to_char(:P_FECHA_INICIAL), 'YYYYMMDD'))
                                         and rh_movimientos_planta.fecha_inicial = (select max(mov.fecha_inicial) 
                                                                                     from rh_movimientos_planta mov
                                                                                    where mov.funcionario = his_nom.nfuncionario )
                                                              ),depe.centro_costo) as centro_costo, 
       fun.cuenta_bancaria, 
      decode(depe.codigo_dependencia,NULL,(select nvl(max(rh_dependencias.codigo_dependencia),'999999')
                                             from rh_dependencias,rh_posiciones,rh_movimientos_planta
                                            where rh_movimientos_planta.funcionario = his_nom.nfuncionario
                                             and rh_movimientos_planta.posicion_anterior = rh_posiciones.secuencia
                                             and rh_posiciones.codigo_compania = rh_dependencias.codigo_compania
                                             and rh_posiciones.codigo_dependencia = rh_dependencias.codigo_dependencia
                                             and rh_movimientos_planta.fecha_inicial = (select max(mov.fecha_inicial) 
                                                                                         from rh_movimientos_planta mov
                                           				             where mov.funcionario = his_nom.nfuncionario
                                                                          )),depe.codigo_dependencia) as codigo_dependencia,
     conc.orden orden
--
  FROM rh_reportes_nomina his_nom, rh_personas per, rh_dependencias depe,  rh_posiciones pos, rh_funcionario fun, rh_concepto conc
  WHERE per.interno_persona    = fun.personas_interno
   AND per.interno_persona    = his_nom.nfuncionario
   AND ( fun.codigo_compania  = pos.codigo_compania(+)
   AND fun.personas_interno   = pos.funcionario(+)
   AND pos.codigo_dependencia = depe.codigo_dependencia(+)
   AND fun.personas_interno   =  his_nom.nfuncionario )
   AND his_nom.ntipoconcepto IN (1,2,3,4)
   AND his_nom.nesnovedad = 0 
   AND his_nom.brechazado = 0
   AND  conc.codigo_hash = nHash
   AND (his_nom.ntipoconcepto In (2, 3) Or his_nom.nretroactivo = (Select Nvl(Min(ndCampo0), 0)
	From rh_historico_nomina
	Where nFuncionario = his_nom.nfuncionario and nHash = 812839052
	And dInicioPeriodo <= :P_FECHA_INICIAL
	And dFinalPeriodo >= :P_FECHA_FINAL))
   AND his_nom.ncorrida_interna = 0
   AND his_nom.dinicioperiodo >= :P_FECHA_INICIAL
   AND his_nom.dfinalperiodo <=  :P_FECHA_FINAL
   AND his_nom.user_sess	 =  USERENV('SESSIONID')
  AND his_NOM.nfuncionario = NVL(:P_PERSONA,his_NOM.nfuncionario)
 ORDER BY  centro_costo,codigo_dependencia,nombre_fun, orden
