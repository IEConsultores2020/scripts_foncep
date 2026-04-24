PACKAGE BODY OGT_PK_RA IS
/****************************************************************************/
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   TOTALIZA EL APORTE DEL EMPLEADO LOS ANEXOS DE UNA RA 
  -- PARAMETROS: VIGENCIA, ENTIDAD, UNIDAD, TIPO_DOCUMENTO, CONSECUTIVO, TIPO RA,  
  --            ,MES ,FECHA$DESDE, FECHA HASTA
/****************************************************************************/  
  FUNCTION OGT_FN_TOTAL_ANEXOS_NOMINA(UN_VIGENCIA         OGT_RELACION_AUTORIZACION.VIGENCIA%TYPE
                                     ,UN_ENTIDAD          OGT_RELACION_AUTORIZACION.ENTIDAD%TYPE
                                     ,UN_UNIDAD_EJECUTORA OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA%TYPE
                                     ,UN_TIPO_DOCUMENTO   OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO%TYPE
                                     ,UN_CONSECUTIVO      OGT_RELACION_AUTORIZACION.CONSECUTIVO%TYPE
                                     ,UN_TIPO_RA          OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE
                                     ,UN_MES              OGT_RELACION_AUTORIZACION.MES%TYPE
                                     ,UN_FECHA_DESDE      OGT_RELACION_AUTORIZACION.FECHA_DESDE%TYPE
                                     ) RETURN NUMBER AS
  	CURSOR C_TOTAL IS
  	  SELECT SUM(VALOR)
  	  FROM
  	  (
	    SELECT SUM(NVL(OGT_ANEXO_NOMINA.APORTE_EMPLEADO,0))  VALOR
  	  FROM   OGT_ANEXO_NOMINA
    	WHERE  OGT_ANEXO_NOMINA.VIGENCIA         = UN_VIGENCIA         
	    AND    OGT_ANEXO_NOMINA.ENTIDAD          = UN_ENTIDAD          
  	  AND    OGT_ANEXO_NOMINA.UNIDAD_EJECUTORA = UN_UNIDAD_EJECUTORA 
    	AND    OGT_ANEXO_NOMINA.TIPO_DOCUMENTO   = UN_TIPO_DOCUMENTO   
	    AND    OGT_ANEXO_NOMINA.CONSECUTIVO      = UN_CONSECUTIVO      
  	  AND    OGT_ANEXO_NOMINA.TIPO_RA          = UN_TIPO_RA          
    	AND    OGT_ANEXO_NOMINA.MES              = UN_MES              
	    AND    OGT_ANEXO_NOMINA.FECHA_DESDE      = UN_FECHA_DESDE      
	    UNION
 	    SELECT SUM(NVL(OGT_ANEXO_EMBARGO.APORTE_EMBARGO,0))  VALOR
  	  FROM   OGT_ANEXO_EMBARGO
    	WHERE  OGT_ANEXO_EMBARGO.VIGENCIA         = UN_VIGENCIA         
	    AND    OGT_ANEXO_EMBARGO.ENTIDAD          = UN_ENTIDAD          
  	  AND    OGT_ANEXO_EMBARGO.UNIDAD_EJECUTORA = UN_UNIDAD_EJECUTORA 
    	AND    OGT_ANEXO_EMBARGO.TIPO_DOCUMENTO   = UN_TIPO_DOCUMENTO   
	    AND    OGT_ANEXO_EMBARGO.CONSECUTIVO      = UN_CONSECUTIVO      
  	  AND    OGT_ANEXO_EMBARGO.TIPO_RA          = UN_TIPO_RA          
    	AND    OGT_ANEXO_EMBARGO.MES              = UN_MES              
	    AND    OGT_ANEXO_EMBARGO.FECHA_DESDE      = UN_FECHA_DESDE      
	    )
    	;
  	MI_TOTAL   NUMBER;
	BEGIN
	  OPEN C_TOTAL;
	  FETCH C_TOTAL INTO MI_TOTAL;
	  IF C_TOTAL%ISOPEN THEN
		  CLOSE C_TOTAL;
 		END IF;		  
	  RETURN(MI_TOTAL);	
	EXCEPTION 
		WHEN OTHERS THEN
			PR_DESPLIEGA_MENSAJE('AL_STOP_1','Se presento este error calculando el total de los anexos de la RA de nomina '||sqlerrm);
			RAISE FORM_TRIGGER_FAILURE;
	END OGT_FN_TOTAL_ANEXOS_NOMINA;  
/****************************************************************************/	
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   TOTALIZA EL APORTE PATRONAL LOS ANEXOS DE UNA RA 
  -- PARAMETROS: VIGENCIA, ENTIDAD, UNIDAD, TIPO_DOCUMENTO, CONSECUTIVO, TIPO RA,
  --            ,MES ,FECHA DESDE, FECHA HASTA
/****************************************************************************/  
  FUNCTION OGT_FN_TOTAL_ANEXOS_PATRONAL(UN_VIGENCIA         OGT_RELACION_AUTORIZACION.VIGENCIA%TYPE
                                       ,UN_ENTIDAD          OGT_RELACION_AUTORIZACION.ENTIDAD%TYPE
                                       ,UN_UNIDAD_EJECUTORA OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA%TYPE
                                       ,UN_TIPO_DOCUMENTO   OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO%TYPE
                                       ,UN_CONSECUTIVO      OGT_RELACION_AUTORIZACION.CONSECUTIVO%TYPE
                                       ,UN_TIPO_RA          OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE
                                       ,UN_MES              OGT_RELACION_AUTORIZACION.MES%TYPE
                                       ,UN_FECHA_DESDE      OGT_RELACION_AUTORIZACION.FECHA_DESDE%TYPE
                                       ) RETURN NUMBER AS
  	CURSOR C_TOTAL IS
	    SELECT SUM( NVL(OGT_ANEXO_PATRONAL.APORTE_PATRONAL,0)
								- NVL(OGT_ANEXO_PATRONAL.INCAPACIDAD,0)	                                                        
	              - NVL(OGT_ANEXO_PATRONAL.SALDO,0)                                          
	              )
  	  FROM   OGT_ANEXO_PATRONAL
    	WHERE  OGT_ANEXO_PATRONAL.VIGENCIA         = UN_VIGENCIA         
	    AND    OGT_ANEXO_PATRONAL.ENTIDAD          = UN_ENTIDAD          
  	  AND    OGT_ANEXO_PATRONAL.UNIDAD_EJECUTORA = UN_UNIDAD_EJECUTORA 
    	AND    OGT_ANEXO_PATRONAL.TIPO_DOCUMENTO   = UN_TIPO_DOCUMENTO   
	    AND    OGT_ANEXO_PATRONAL.CONSECUTIVO      = UN_CONSECUTIVO      
  	  AND    OGT_ANEXO_PATRONAL.TIPO_RA          = UN_TIPO_RA          
    	AND    OGT_ANEXO_PATRONAL.MES              = UN_MES              
	    AND    OGT_ANEXO_PATRONAL.FECHA_DESDE      = UN_FECHA_DESDE      
    	;
  	MI_TOTAL   NUMBER;
	BEGIN
	  OPEN C_TOTAL;
	  FETCH C_TOTAL INTO MI_TOTAL;
	  IF C_TOTAL%ISOPEN THEN
		  CLOSE C_TOTAL;
 		END IF;		  
	  RETURN(MI_TOTAL);	
	EXCEPTION 
		WHEN OTHERS THEN
			PR_DESPLIEGA_MENSAJE('AL_STOP_1','Se presento este error calculando el total de los anexos de la RA de aportes '||sqlerrm);
			RAISE FORM_TRIGGER_FAILURE;
	END OGT_FN_TOTAL_ANEXOS_PATRONAL;  
/****************************************************************************/	
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   EVALUA QUE EL VALOR PASADO SEA MAYOR O IGUAL QUE CERO
  -- PARAMETROS: VALOR
/****************************************************************************/  
  FUNCTION OGT_FN_MAYOR_IGUAL_CERO(UN_VALOR  OGT_ANEXO_PATRONAL.APORTE_EMPLEADO%TYPE
                                  ) RETURN BOOLEAN AS
  BEGIN
  	IF UN_VALOR > 0 THEN
  		RETURN(TRUE);
  	END IF;
  END;
/****************************************************************************/
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   TOTALIZA EL VALOR DE LAS RA DE NOMINA POR TERCERO 
  -- PARAMETROS: VIGENCIA, ENTIDAD, UNIDAD, TERCERO
/****************************************************************************/
  FUNCTION OGT_FN_SALDO_NOMINA(UN_VIGENCIA         OGT_RELACION_AUTORIZACION.VIGENCIA%TYPE
                              ,UN_ENTIDAD          OGT_RELACION_AUTORIZACION.ENTIDAD%TYPE
                              ,UN_UNIDAD_EJECUTORA OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA%TYPE
                              ,UN_TERCERO          OGT_ANEXO_PATRONAL.ID%TYPE
                              ) RETURN NUMBER AS
		CURSOR C_TOTAL IS
			SELECT SUM(NVL(OGT_ANEXO_NOMINA.APORTE_EMPLEADO,0))
			FROM   OGT_ANEXO_NOMINA
			WHERE  OGT_ANEXO_NOMINA.VIGENCIA         = UN_VIGENCIA         
			AND    OGT_ANEXO_NOMINA.ENTIDAD          = UN_ENTIDAD          
			AND    OGT_ANEXO_NOMINA.UNIDAD_EJECUTORA = UN_UNIDAD_EJECUTORA 
			AND    OGT_ANEXO_NOMINA.ID_PAGAR_A       = UN_TERCERO          
			;
  	MI_TOTAL   NUMBER;
	BEGIN
	  OPEN C_TOTAL;
	  FETCH C_TOTAL INTO MI_TOTAL;
	  IF C_TOTAL%ISOPEN THEN
		  CLOSE C_TOTAL;
 		END IF;		  
	  RETURN(MI_TOTAL);	
	EXCEPTION 
		WHEN OTHERS THEN
			PR_DESPLIEGA_MENSAJE('AL_STOP_1','Se presento este error calculando el saldo de la RA de nomina '||sqlerrm);
			RAISE FORM_TRIGGER_FAILURE;
	END OGT_FN_SALDO_NOMINA;  

/****************************************************************************/
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   TOTALIZA EL VALOR DE LAS RA PATRONAL POR TERCERO 
  -- PARAMETROS: VIGENCIA, ENTIDAD, UNIDAD, TERCERO
/****************************************************************************/  
  FUNCTION OGT_FN_SALDO_PATRONAL(UN_VIGENCIA         OGT_RELACION_AUTORIZACION.VIGENCIA%TYPE
                                ,UN_ENTIDAD          OGT_RELACION_AUTORIZACION.ENTIDAD%TYPE
                                ,UN_UNIDAD_EJECUTORA OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA%TYPE
                                ,UN_TERCERO          OGT_ANEXO_PATRONAL.ID%TYPE
                                ) RETURN NUMBER AS
		CURSOR C_TOTAL IS
			SELECT SUM(NVL(OGT_ANEXO_PATRONAL.APORTE_PATRONAL,0))
			FROM   OGT_ANEXO_PATRONAL
			WHERE  OGT_ANEXO_PATRONAL.VIGENCIA         = UN_VIGENCIA         
			AND    OGT_ANEXO_PATRONAL.ENTIDAD          = UN_ENTIDAD          
			AND    OGT_ANEXO_PATRONAL.UNIDAD_EJECUTORA = UN_UNIDAD_EJECUTORA 
			AND    OGT_ANEXO_PATRONAL.ID_PAGAR_A       = UN_TERCERO          
			;
  	MI_TOTAL   NUMBER;
	BEGIN
	  OPEN C_TOTAL;
	  FETCH C_TOTAL INTO MI_TOTAL;
	  IF C_TOTAL%ISOPEN THEN
		  CLOSE C_TOTAL;
 		END IF;		  
	  RETURN(MI_TOTAL);	
	EXCEPTION 
		WHEN OTHERS THEN
			PR_DESPLIEGA_MENSAJE('AL_STOP_1','Se presento este error calculando el saldo de la RA de aportes '||sqlerrm);
			RAISE FORM_TRIGGER_FAILURE;	  
	END OGT_FN_SALDO_PATRONAL;  
/****************************************************************************/
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   VERIFICA EL TOTAL DE UNA RA
  -- PARAMETROS: VALOR DISPONIBLE DE UNA RA
	--						 VALOR TOTAL DE LA IMPUTACION DE LA RA
  --						 VALOR TOTAL DE LA RA
  --						 RETORNA UN VALOR NUEMRICO
/****************************************************************************/  
	PROCEDURE PR_VALIDAR(UN_DISPONIBLE  NUMBER -- DISPONIBLE PREDIS
										 ,UN_REGISTRO    NUMBER -- VALOR REGISTRADO EN LA RA
										 ,UN_TOTAL_RA    NUMBER -- VALOR TOTAL DE LA RA 
										 ,UN_RESULTADO   IN OUT NUMBER  -- RETORNA EL RESULTADO
										 ) IS
	-- SI RETORNA 1 ES PORQUE NO EXISTE SUFICIENTE PRESUPUESTO
	-- SI RETORNA 2 ES PORQUE EL VALOR DE LA IMPUTACION NO CORRESPONDE A LA RA
	-- SI RETORNA 0 ESTA VALIDO EL VALOR DE PREDIS													 
	BEGIN    
		IF (NVL(UN_DISPONIBLE,0) - NVL(UN_REGISTRO,0)) < 0 THEN
  		UN_RESULTADO := 1;
		ELSIF NVL(UN_REGISTRO,0) <> NVL(UN_TOTAL_RA,0) THEN 
  		UN_RESULTADO := 2;
	 	ELSE   
  		UN_RESULTADO := 0;
	 	END IF;
	EXCEPTION 
		WHEN OTHERS THEN
			PR_DESPLIEGA_MENSAJE('AL_STOP_1','Se presento este error validando el disponible '||sqlerrm);
			RAISE FORM_TRIGGER_FAILURE;	 	
	END PR_VALIDAR;	

	/****************************************************************************/
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   VALIDAR PAC PARA UNA RA 
  -- PARAMETROS: UNA ENTIDAD
	--						 UNA UNIDAD
  --						 UNA VIGENCIA PREDIS
  --						 UNA VIGENCIA PAC
  --						 UN MES PAC
  --						 UN CONSECUTIVO DE RA
  --						 RETORNA UN MENSAJE
/****************************************************************************/  
	PROCEDURE PR_VALIDAR_PAC(UNA_ENTIDAD					OGT_RELACION_AUTORIZACION.ENTIDAD%TYPE
							            ,UNA_UNIDAD						OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA%TYPE
  						 						,UNA_VIGENCIA    			OGT_IMPUTACION.VIGENCIA%TYPE
  						 						,UN_CONSECUTIVO_RA		OGT_RELACION_AUTORIZACION.CONSECUTIVO%TYPE  						 						
  						 						,UN_TIPO_RA						OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE
  						 						,UN_MES								OGT_RELACION_AUTORIZACION.MES%TYPE
  						 						,UN_FECHA_DESDE				OGT_RELACION_AUTORIZACION.FECHA_DESDE%TYPE  						 						
  						 						,UN_RETORNO           IN OUT VARCHAR2
  						 						) IS
		MI_TOTAL    NUMBER(16,2)  := 0;
		MI_RUBRO    OGT_IMPUTACION.RUBRO_INTERNO%TYPE;
		MI_MES_PAC  OGT_IMPUTACION.MES_PAC%TYPE;
	  MI_ANO_PAC  OGT_IMPUTACION.ANO_PAC%TYPE;
		MI_TOTAL_A  NUMBER(16,2) := 0;
		MI_TOTAL_POR_A  NUMBER(16,2) := 0;		
		MI_REGISTRO    		OGT_REGISTRO_PRESUPUESTAL.REGISTRO%TYPE;		
		MI_DISPONIBILIDAD OGT_IMPUTACION.DISPONIBILIDAD%TYPE;
		MI_TOTAL_D  NUMBER(16,2) := 0;
		MI_TOTAL_PAC  NUMBER(16,2) := 0;
		MI_PAC  NUMBER(16,2) := 0;						
		MI_TOTAL_RA NUMBER(16,2) := 0;
		MI_TOTAL_R  NUMBER(16,2) := 0;
		MI_TOTAL_E  NUMBER(16,2) := 0;
		MI_TOTAL_G  NUMBER(16,2) := 0;		
		MI_TOTAL_POR_D  NUMBER(16,2) := 0;
		MI_TOTAL_POR_R  NUMBER(16,2) := 0;
		MI_TOTAL_POR_E  NUMBER(16,2) := 0;
		MI_TOTAL_POR_G  NUMBER(16,2) := 0;		
		MI_CANTIDAD       NUMBER := 0;		
		MI_TOTAL_RA_RP   NUMBER := 0;
		MI_TOTAL_POR_RUBRO  NUMBER := 0;
		MI_FECHA_DESDE     OGT_RELACION_AUTORIZACION.FECHA_DESDE%TYPE;
		MI_FECHA_HASTA     OGT_RELACION_AUTORIZACION.FECHA_HASTA%TYPE;
		CURSOR  C_RUBROS_RA IS
		SELECT O.RUBRO_INTERNO      RUBRO
					,O.MES_PAC            MES
					,O.ANO_PAC            ANO
		      ,O.DISPONIBILIDAD           DISPONIBILIDAD
		      ,P.REGISTRO                 REGISTRO
    FROM   OGT_IMPUTACION       			O
          ,OGT_REGISTRO_PRESUPUESTAL	P
    WHERE  P.DISPONIBILIDAD     = O.DISPONIBILIDAD
    AND    P.ENTIDAD            = O.ENTIDAD
    AND    P.UNIDAD_EJECUTORA   = O.UNIDAD_EJECUTORA
    AND    P.VIGENCIA           = O.VIGENCIA
    AND    P.CONSECUTIVO        = O.CONSECUTIVO
    AND    P.RUBRO_INTERNO      = O.RUBRO_INTERNO    
    AND    O.TIPO_DOCUMENTO     = MI_CON_TIPO_DOCUMENTO
    AND    O.ENTIDAD            = UNA_ENTIDAD
    AND    O.UNIDAD_EJECUTORA   = UNA_UNIDAD
    AND    O.VIGENCIA           = UNA_VIGENCIA
    AND    O.CONSECUTIVO        = UN_CONSECUTIVO_RA
    ;
  BEGIN

		-- EVALUA EL TOTAL DE LA RA
		MI_TOTAL_RA := NVL(OGT_PK_RA.OGT_FN_TOTAL_RA(UNA_VIGENCIA
															                      ,UNA_ENTIDAD          
                         														,UNA_UNIDAD
                         														,'RA'
                         														,UN_CONSECUTIVO_RA
                         														)
                       ,0);
                       
  	-- RECORRE LOS RUBROS DE LA RA 
  	OPEN C_RUBROS_RA;
  	LOOP 

  		FETCH C_RUBROS_RA INTO MI_RUBRO
  													,MI_MES_PAC
  													,MI_ANO_PAC
  													,MI_DISPONIBILIDAD
  													,MI_REGISTRO
  													;
  		EXIT WHEN C_RUBROS_RA%NOTFOUND;
  		
			BEGIN
		    SELECT SUM(NVL(CC.VALOR_REGISTRO,0))
		    INTO   MI_TOTAL_RA_RP
	  	  FROM   OGT_REGISTRO_PRESUPUESTAL       CC
	    	WHERE  CC.VIGENCIA         = MI_ANO_PAC
		    AND    CC.ENTIDAD          = UNA_ENTIDAD          
	  	  AND    CC.UNIDAD_EJECUTORA = UNA_UNIDAD 
	  	  AND    CC.RUBRO_INTERNO    = MI_RUBRO
	  	  AND    CC.DISPONIBILIDAD   = MI_DISPONIBILIDAD
	  	  AND    CC.REGISTRO         = MI_REGISTRO  	  	  	  	  	  
	    	AND    CC.TIPO_DOCUMENTO   = MI_CON_TIPO_DOCUMENTO
		    AND    CC.CONSECUTIVO      = UN_CONSECUTIVO_RA
	     	;
			EXCEPTION WHEN OTHERS THEN
				NULL;
			END;

      -- VERIFICAR LA FECHA INICIAL Y LA FECHA FINAL DE LA RA PARA DETERMINAR SI 
      -- EVALUAR PAC DE LA VIGENCIA O DE RESERVA O DE CUENTAS POR PAGAR
      IF UNA_VIGENCIA = TO_NUMBER(TO_CHAR(UN_FECHA_DESDE,'YYYY'))
      	 AND 
      	 UNA_VIGENCIA = TO_NUMBER(TO_CHAR(SYSDATE,'YYYY')) 
      	 THEN      
			  -- POBLAR EL VALOR DISPONIBLE POR PAC
			  -- ESTAMOS EN LA VIGENCIA ACTUAL
--	 	   	MI_TOTAL_R := PK_PAC_INICIAL.FN_PAC_DESPLIEGA_VALOR_MES(UNA_ENTIDAD
	 	   	MI_PAC := PK_PAC.FN_PAC_DESP_VALOR_MES(UNA_ENTIDAD
		 	                                       ,UNA_UNIDAD
	  	 	                                     ,MI_ANO_PAC
	    	 	                                   ,MI_RUBRO
	      	 	                                 ,MI_MES_PAC);   
      ELSIF UNA_VIGENCIA < TO_NUMBER(TO_CHAR(UN_FECHA_DESDE,'YYYY'))
      	    AND
      	    UNA_VIGENCIA = TO_NUMBER(TO_CHAR(SYSDATE,'YYYY'))-1 
      	    THEN      
			  -- SE DEBE VERIFICAR LA RESERVA
--	 	   	MI_TOTAL_R := PK_PAC_RESERVA.FN_PAC_VALOR_MES_RESERVA(UNA_ENTIDAD
	 	   	MI_PAC := PK_PAC_RESERVAS_BD.FN_PAC_VR_MES_RES(UNA_ENTIDAD
		 	                                       ,UNA_UNIDAD
	  	 	                                     ,MI_ANO_PAC
	    	 	                                   ,MI_RUBRO
	      	 	                                 ,MI_MES_PAC
	      	 	                                 ,MI_REGISTRO);   
      ELSIF UNA_VIGENCIA = TO_NUMBER(TO_CHAR(UN_FECHA_DESDE,'YYYY')) 
       	    AND
      	    UNA_VIGENCIA = TO_NUMBER(TO_CHAR(SYSDATE,'YYYY'))-1 
						THEN
			  -- SE DEBEN VERIFICAR LAS CUENTAS POR PAGAR
--	 	   	MI_TOTAL_R := PK_PAC_RESERVA.FN_PAC_VALOR_MES_CUENTA(UNA_ENTIDAD
					MI_PAC := PK_PAC_RESERVAS_BD.FN_PAC_VALOR_MES_CXP(UNA_ENTIDAD
		 	                                       ,UNA_UNIDAD
	  	 	                                     ,MI_ANO_PAC
	    	 	                                   ,MI_RUBRO
	      	 	                                 ,MI_MES_PAC
	      	 	                                 ,MI_REGISTRO);   
			END IF;
      MI_TOTAL_PAC := NVL(MI_TOTAL_PAC,0) + NVL(MI_PAC,0);
			MI_TOTAL := MI_TOTAL + NVL(MI_PAC,0);        	 	                                                                            
			MI_TOTAL_POR_RUBRO := NVL(MI_TOTAL_POR_RUBRO,0) + NVL(MI_PAC,0);        	 	                                                                            

	  	-- POBLA EL VALOR DE RA DILIGENCIADAS POR ESE RUBRO
		  OGT_PK_RA.PR_TOTAL_PAC_RUBRO(UNA_ENTIDAD					
								         	   	,UNA_UNIDAD						
		  						 						,MI_ANO_PAC
  								 						,MI_MES_PAC						
  							 							,MI_RUBRO							
  							 							,'D'
  							 							,MI_TOTAL_D);  							 							
			MI_TOTAL := MI_TOTAL - NVL(MI_TOTAL_D,0);        	 	                                                                              							 							
			MI_TOTAL_POR_RUBRO := MI_TOTAL_POR_RUBRO + NVL(MI_TOTAL_D,0);        	 	                                                                            
			MI_TOTAL_POR_D := NVL(MI_TOTAL_POR_D,0) + NVL(MI_TOTAL_D,0);        	 	                                                                            			
			
		  -- POBLA EL VALOR DE RA APROBADAS POR ESE RUBRO
		  OGT_PK_RA.PR_TOTAL_PAC_RUBRO(UNA_ENTIDAD					
								         	   	,UNA_UNIDAD						
		  						 						,MI_ANO_PAC
  								 						,MI_MES_PAC						
  							 							,MI_RUBRO							
  							 							,'A'
  							 							,MI_TOTAL_A);  							 							
			MI_TOTAL := MI_TOTAL - NVL(MI_TOTAL_A,0);        	 	                                                                              							 							
			MI_TOTAL_POR_RUBRO := MI_TOTAL_POR_RUBRO + NVL(MI_TOTAL_A,0);        	 	                                                                            
			MI_TOTAL_POR_A := NVL(MI_TOTAL_POR_A,0) + NVL(MI_TOTAL_A,0);        	 	                                                                            
			
		  -- POBLA EL VALOR DE RA ENVIADAS POR ESE RUBRO
		  OGT_PK_RA.PR_TOTAL_PAC_RUBRO(UNA_ENTIDAD					
								         	   	,UNA_UNIDAD						
		  						 						,MI_ANO_PAC
  								 						,MI_MES_PAC						
  							 							,MI_RUBRO							
  							 							,'E'
  							 							,MI_TOTAL_E);  							 							
			MI_TOTAL := MI_TOTAL - NVL(MI_TOTAL_E,0);        	 	                                                                              							 							
			MI_TOTAL_POR_RUBRO := MI_TOTAL_POR_RUBRO + NVL(MI_TOTAL_E,0);
			MI_TOTAL_POR_E := NVL(MI_TOTAL_POR_E,0) + NVL(MI_TOTAL_E,0);        	 	                                                                            			        	 	                                                                            
			
			-- POBLA EL VALOR DE RA RADICADAS POR ESE RUBRO
		  OGT_PK_RA.PR_TOTAL_PAC_RUBRO(UNA_ENTIDAD					
								         	   	,UNA_UNIDAD						
		  						 						,MI_ANO_PAC
  								 						,MI_MES_PAC						
  							 							,MI_RUBRO							
  							 							,'R'
  							 							,MI_TOTAL_R);  							 							
			MI_TOTAL := MI_TOTAL - NVL(MI_TOTAL_R,0);        	 	                                                                              							 							
			MI_TOTAL_POR_RUBRO := MI_TOTAL_POR_RUBRO + NVL(MI_TOTAL_R,0);        	 	                                                                            
			MI_TOTAL_POR_R := NVL(MI_TOTAL_POR_R,0) + NVL(MI_TOTAL_R,0);        	 	                                                                            
			
			-- POBLA EL VALOR DE RA GIRADAS POR ESE RUBRO
		  OGT_PK_RA.PR_TOTAL_PAC_RUBRO(UNA_ENTIDAD					
								         	   	,UNA_UNIDAD						
		  						 						,MI_ANO_PAC
  								 						,MI_MES_PAC						
  							 							,MI_RUBRO							
  							 							,'G'
  							 							,MI_TOTAL_G);  							 							
			MI_TOTAL := MI_TOTAL - NVL(MI_TOTAL_G,0);        	 	                                                                              							 							
			MI_TOTAL_POR_RUBRO := MI_TOTAL_POR_RUBRO + NVL(MI_TOTAL_G,0);        	 	                                                                            
			
	  	IF NVL(MI_TOTAL_POR_RUBRO,0) < NVL(MI_TOTAL_RA_RP,0) THEN
	 			MI_CANTIDAD := MI_CANTIDAD + 1;
	  	END IF; 	  		
  	END LOOP;
	  IF C_RUBROS_RA%ISOPEN THEN
		  CLOSE C_RUBROS_RA;
 		END IF;		  
  	IF MI_CANTIDAD > 0 OR NVL(MI_TOTAL,0) <= 0 THEN
 			UN_RETORNO := 'No tiene PAC para algunos rubros, disponible total '||NVL(MI_TOTAL,0)
 										||' Total PAC disponible '||NVL(MI_TOTAL_PAC,0) 			
 										||' Total RA Diligenciadas '||NVL(MI_TOTAL_POR_D,0)
 										||' Total RA Aprobadas '||NVL(MI_TOTAL_POR_A,0)
 										||' Total RA Enviadas '||NVL(MI_TOTAL_POR_E,0) 										
 										||' Total RA Radicadas '||NVL(MI_TOTAL_POR_R,0)
 										||' Total RA Giradas '||NVL(MI_TOTAL_POR_G,0)
 										||' Total RA '||NVL(MI_TOTAL_RA,0);  		  		
  	ELSE
  		UN_RETORNO := 'Si tiene PAC, disponible total '||NVL(MI_TOTAL,0)
 										||' Total PAC '||NVL(MI_TOTAL_PAC,0) 			  		
 										||' Total RA Diligenciadas '||NVL(MI_TOTAL_POR_D,0)
 										||' Total RA Aprobadas '||NVL(MI_TOTAL_POR_A,0)
 										||' Total RA Enviadas '||NVL(MI_TOTAL_POR_E,0) 										
 										||' Total RA Radicadas '||NVL(MI_TOTAL_POR_R,0)
 										||' Total RA Giradas '||NVL(MI_TOTAL_POR_G,0)
 										||' Total RA '||NVL(MI_TOTAL_RA,0);  		  		
  	END IF; 	
	EXCEPTION 
		WHEN OTHERS THEN
			PR_DESPLIEGA_MENSAJE('AL_STOP_1','Se presento este error validando PAC '||sqlerrm);
			RAISE FORM_TRIGGER_FAILURE;  	
  END PR_VALIDAR_PAC;
		
/****************************************************************************/
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   VALIDAR PREDIS PARA UNA RA 
  -- PARAMETROS: UNA ENTIDAD
	--						 UNA UNIDAD
  --						 UNA VIGENCIA PREDIS
  --						 UN CONSECUTIVO DE RA
  --						 RETORNA UN MENSAJE
/****************************************************************************/  
	PROCEDURE PR_VALIDAR_PREDIS(UNA_ENTIDAD					OGT_RELACION_AUTORIZACION.ENTIDAD%TYPE
								            ,UNA_UNIDAD						OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA%TYPE
  							 						,UNA_VIGENCIA_PREDIS	OGT_IMPUTACION.VIGENCIA_PRESUPUESTO%TYPE
  							 						,UN_CONSECUTIVO_RA		OGT_RELACION_AUTORIZACION.CONSECUTIVO%TYPE
  							 						,UN_RETORNO           IN OUT VARCHAR2
  							 						) IS
		MI_TOTAL 			    NUMBER(16,2)  := 0;  						 						
		MI_RUBRO    		  OGT_IMPUTACION.RUBRO_INTERNO%TYPE;
		MI_REGISTRO    		OGT_REGISTRO_PRESUPUESTAL.REGISTRO%TYPE;		
		MI_DISPONIBILIDAD OGT_IMPUTACION.DISPONIBILIDAD%TYPE;
		MI_TOTAL_A  			NUMBER(16,2) := 0;
		MI_TOTAL_D			  NUMBER(16,2) := 0;
		MI_TOTAL_RA				NUMBER(16,2) := 0;
		MI_TOTAL_R  			NUMBER(16,2) := 0;
		MI_TOTAL_E  			NUMBER(16,2) := 0;
		MI_TOTAL_G  			NUMBER(16,2) := 0;
		MI_TOTAL_POR_A  			NUMBER(16,2) := 0;
		MI_TOTAL_POR_D			  NUMBER(16,2) := 0;
		MI_TOTAL_POR_R  			NUMBER(16,2) := 0;
		MI_TOTAL_POR_E  			NUMBER(16,2) := 0;
		MI_TOTAL_POR_G  			NUMBER(16,2) := 0;
		MI_TOTAL_PR 			NUMBER(16,2) := 0;				
		MI_CANTIDAD       NUMBER := 0;
		MI_TOTAL_RA_RP    NUMBER := 0;
		MI_PREDIS         NUMBER := 0;		
		MI_TOTAL_POR_RUBRO  NUMBER:= 0;
 	 CURSOR  C_RUBROS_RA IS
		SELECT O.RUBRO_INTERNO      			RUBRO
		      ,O.DISPONIBILIDAD           DISPONIBILIDAD
		      ,P.REGISTRO                 REGISTRO
    FROM   OGT_IMPUTACION       			O
          ,OGT_REGISTRO_PRESUPUESTAL	P
    WHERE  O.DISPONIBILIDAD     = P.DISPONIBILIDAD
    AND    O.ENTIDAD            = P.ENTIDAD
    AND    O.TIPO_DOCUMENTO     = P.TIPO_DOCUMENTO    
    AND    O.UNIDAD_EJECUTORA   = P.UNIDAD_EJECUTORA
    AND    O.VIGENCIA           = P.VIGENCIA_PRESUPUESTO
    AND    O.VIGENCIA           = P.VIGENCIA
    AND    O.CONSECUTIVO        = P.CONSECUTIVO
    AND    O.TIPO_DOCUMENTO     = P.TIPO_DOCUMENTO
    AND    O.RUBRO_INTERNO      = P.RUBRO_INTERNO    
    AND    O.TIPO_DOCUMENTO     = MI_CON_TIPO_DOCUMENTO
    AND    O.ENTIDAD            = UNA_ENTIDAD
    AND    O.UNIDAD_EJECUTORA   = UNA_UNIDAD
    AND    O.VIGENCIA           = UNA_VIGENCIA_PREDIS
    AND    O.CONSECUTIVO        = UN_CONSECUTIVO_RA
    ;
  BEGIN
		-- EVALUA EL TOTAL DE LA RA
		MI_TOTAL_RA := NVL(OGT_PK_RA.OGT_FN_TOTAL_RA(UNA_VIGENCIA_PREDIS
															                      ,UNA_ENTIDAD          
                         														,UNA_UNIDAD
                         														,'RA'
                         														,UN_CONSECUTIVO_RA
                         														)
                       ,0);
  	-- RECORRE LOS RUBROS DE LA RA 
  	OPEN C_RUBROS_RA;
  	LOOP 
  		FETCH C_RUBROS_RA INTO MI_RUBRO
  													,MI_DISPONIBILIDAD
  													,MI_REGISTRO;
  		EXIT WHEN C_RUBROS_RA%NOTFOUND;
  		
			BEGIN
		    SELECT SUM(NVL(CC.VALOR_REGISTRO,0))
		    INTO   MI_TOTAL_RA_RP
	  	  FROM   OGT_REGISTRO_PRESUPUESTAL       CC
	    	WHERE  CC.VIGENCIA         = UNA_VIGENCIA_PREDIS         
		    AND    CC.ENTIDAD          = UNA_ENTIDAD          
	  	  AND    CC.UNIDAD_EJECUTORA = UNA_UNIDAD 
	  	  AND    CC.RUBRO_INTERNO    = MI_RUBRO
	  	  AND    CC.DISPONIBILIDAD   = MI_DISPONIBILIDAD
	  	  AND    CC.REGISTRO         = MI_REGISTRO  	  	  	  
	    	AND    CC.TIPO_DOCUMENTO   = MI_CON_TIPO_DOCUMENTO
		    AND    CC.CONSECUTIVO      = UN_CONSECUTIVO_RA
	     	;
			EXCEPTION WHEN OTHERS THEN
				NULL;
			END;
			
		  -- POBLAR EL VALOR DISPONIBLE POR PREDIS
  		MI_PREDIS := NULL;
/*			MI_PREDIS := PK_PRE_ORDEN_DE_PAGO.FN_PRE_SALDO_RP(UNA_VIGENCIA_PREDIS
																					,UNA_ENTIDAD
	 	                                      ,UNA_UNIDAD
  	 	                                    ,MI_REGISTRO
  	 	                                    ,MI_DISPONIBILIDAD
    	 	                                  ,MI_RUBRO);   
  */
    	MI_TOTAL_PR := NVL(MI_TOTAL_PR,0) + NVL(MI_PREDIS,0); 	                                 
			MI_TOTAL := MI_TOTAL + NVL(MI_PREDIS,0);        	 	                                                                            
			MI_TOTAL_POR_RUBRO := NVL(MI_PREDIS,0);

	  	-- POBLA EL VALOR DE RA DILIGENCIADAS POR ESE RUBRO
		  OGT_PK_RA.PR_TOTAL_PREDIS_RUBRO(UNA_ENTIDAD					
								         	   	,UNA_UNIDAD						
		  						 						,UNA_VIGENCIA_PREDIS
  							 							,MI_RUBRO							
  							 							,'D'
  							 							,MI_TOTAL_D);  							 							
			MI_TOTAL := MI_TOTAL - NVL(MI_TOTAL_D,0);        	 	                                                                              							 							
			MI_TOTAL_POR_RUBRO := MI_TOTAL_POR_RUBRO + NVL(MI_TOTAL_D,0);        	 	                                                                            
			MI_TOTAL_POR_D := NVL(MI_TOTAL_POR_D,0) + NVL(MI_TOTAL_D,0);        	 	                                                                            						
						
		  -- POBLA EL VALOR DE RA APROBADAS POR ESE RUBRO
		  OGT_PK_RA.PR_TOTAL_PREDIS_RUBRO(UNA_ENTIDAD					
								         	   	,UNA_UNIDAD						
		  						 						,UNA_VIGENCIA_PREDIS
  							 							,MI_RUBRO							
  							 							,'A'
  							 							,MI_TOTAL_A);  							 							
			MI_TOTAL := MI_TOTAL - NVL(MI_TOTAL_A,0);        	 	                                                                              							 							
			MI_TOTAL_POR_A := NVL(MI_TOTAL_POR_A,0) + NVL(MI_TOTAL_A,0);        	 	                                                                            									
			
	  	-- POBLA EL VALOR DE RA ENVIADAS POR ESE RUBRO
		  OGT_PK_RA.PR_TOTAL_PREDIS_RUBRO(UNA_ENTIDAD					
								         	   	,UNA_UNIDAD						
		  						 						,UNA_VIGENCIA_PREDIS
  							 							,MI_RUBRO							
  							 							,'E'
  							 							,MI_TOTAL_E);  							 							
			MI_TOTAL := MI_TOTAL - NVL(MI_TOTAL_E,0);        	 	                                                                              							 							
			MI_TOTAL_POR_E := NVL(MI_TOTAL_POR_E,0) + NVL(MI_TOTAL_E,0);        	 	                                                                            						
			MI_TOTAL_POR_RUBRO := MI_TOTAL_POR_RUBRO + NVL(MI_TOTAL_E,0);        	 	                                                                            
						
	  	-- POBLA EL VALOR DE RA RADICADAS POR ESE RUBRO
		  OGT_PK_RA.PR_TOTAL_PREDIS_RUBRO(UNA_ENTIDAD					
								         	   	,UNA_UNIDAD						
		  						 						,UNA_VIGENCIA_PREDIS
  							 							,MI_RUBRO							
  							 							,'R'
  							 							,MI_TOTAL_R);
  		MI_TOTAL := MI_TOTAL - NVL(MI_TOTAL_R,0);        	 	     
			MI_TOTAL_POR_R := NVL(MI_TOTAL_POR_R,0) + NVL(MI_TOTAL_R,0);        	 	                                                                            						
			MI_TOTAL_POR_RUBRO := MI_TOTAL_POR_RUBRO + NVL(MI_TOTAL_R,0);        	 	                                                                              		                                                                         							 												 							
			
	  	-- POBLA EL VALOR DE RA GIRADAS POR ESE RUBRO
		  OGT_PK_RA.PR_TOTAL_PREDIS_RUBRO(UNA_ENTIDAD					
								         	   	,UNA_UNIDAD						
		  						 						,UNA_VIGENCIA_PREDIS
  							 							,MI_RUBRO							
  							 							,'G'
  							 							,MI_TOTAL_G);  							 							
			MI_TOTAL := MI_TOTAL - NVL(MI_TOTAL_G,0);        	 	                                                                              							 							
			MI_TOTAL_POR_G := NVL(MI_TOTAL_POR_G,0) + NVL(MI_TOTAL_G,0);        	 	                                                                            						
			MI_TOTAL_POR_RUBRO := MI_TOTAL_POR_RUBRO + NVL(MI_TOTAL_G,0);        	 	                                                                            			
			
	  	IF NVL(MI_TOTAL_POR_RUBRO,0) < NVL(MI_TOTAL_RA_RP,0) THEN
	 			MI_CANTIDAD := MI_CANTIDAD + 1;
	  	END IF; 	  		
	  	
  	END LOOP;
    IF C_RUBROS_RA%ISOPEN THEN
  		CLOSE C_RUBROS_RA;
		END IF;  		
  	
  	IF MI_CANTIDAD > 0 OR NVL(MI_TOTAL,0) <= 0 THEN
 			UN_RETORNO := 'No tiene PREDIS para algunos rubros, Disponible total '||NVL(MI_TOTAL,0)
 			 							||' Total PREDIS '||NVL(MI_TOTAL_PR,0) 			
 										||' Total RA Diligenciadas '||NVL(MI_TOTAL_POR_D,0)
 										||' Total RA Aprobadas '||NVL(MI_TOTAL_POR_A,0)
 										||' Total RA Enviadas '||NVL(MI_TOTAL_POR_E,0) 										
 										||' Total RA Radicadas '||NVL(MI_TOTAL_POR_R,0)
 										||' Total RA Giradas '||NVL(MI_TOTAL_POR_G,0)
 										||' Total RA '||NVL(MI_TOTAL_RA,0);  		  		
  	ELSE
  		UN_RETORNO := 'Si tiene PREDIS, Disponible total '||NVL(MI_TOTAL,0)
 			 							||' Total PREDIS '||NVL(MI_TOTAL_PR,0) 			  		
 										||' Total RA Diligenciadas '||NVL(MI_TOTAL_POR_D,0)
 										||' Total RA Aprobadas '||NVL(MI_TOTAL_POR_A,0)
 										||' Total RA Enviadas '||NVL(MI_TOTAL_POR_E,0) 										
 										||' Total RA Radicadas '||NVL(MI_TOTAL_POR_R,0)
 										||' Total RA Giradas '||NVL(MI_TOTAL_POR_G,0)
 										||' Total RA '||NVL(MI_TOTAL_RA,0);  		  		
  	END IF; 	
	EXCEPTION 
		WHEN OTHERS THEN
			PR_DESPLIEGA_MENSAJE('AL_STOP_1','Se presento este error validando PREDIS '||sqlerrm);
			RAISE FORM_TRIGGER_FAILURE;  	
  END PR_VALIDAR_PREDIS;
/****************************************************************************/
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   TOTALIZA POR ENTIDAD, UNIDAD, VIGENCIA PAC, MES PAC Y RUBRO 
  --             LAS RA QUE HAN SIDO DILIGENCIADAS O APROBADAS 
  -- PARAMETROS: UNA ENTIDAD
	--						 UNA UNIDAD
  --						 UNA VIGENCIA PAC
  --						 UN MES PAC
  --						 UN RUBRO
  --             UN FILTRO  -- D DILIGENCIADAS A APROBADAS 
  --						 RETORNA UN MENSAJE
/****************************************************************************/  
	PROCEDURE PR_TOTAL_PAC_RUBRO(UNA_ENTIDAD					OGT_RELACION_AUTORIZACION.ENTIDAD%TYPE
								         	   	,UNA_UNIDAD						OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA%TYPE
		  						 						,UNA_VIGENCIA_PAC			OGT_IMPUTACION.ANO_PAC%TYPE
  								 						,UN_MES_PAC						OGT_IMPUTACION.MES_PAC%TYPE
  							 							,UN_RUBRO							OGT_IMPUTACION.RUBRO_INTERNO%TYPE
  							 							,UN_FILTRO						VARCHAR2
  							 							,UN_RETORNO           IN OUT NUMBER
  							 							)IS
  BEGIN
		SELECT SUM(NVL(OGTI.VALOR_BRUTO,0))
  	INTO   UN_RETORNO
		FROM   OGT_IMPUTACION             OGTI
      		,OGT_RELACION_AUTORIZACION  OGTRA
		WHERE  OGTRA.ENTIDAD 		      = OGTI.ENTIDAD
		AND    OGTRA.VIGENCIA   		  = OGTI.VIGENCIA
		AND    OGTRA.UNIDAD_EJECUTORA = OGTI.UNIDAD_EJECUTORA
		AND    OGTRA.CONSECUTIVO      = OGTI.CONSECUTIVO
		AND    OGTRA.TIPO_DOCUMENTO   = OGTI.TIPO_DOCUMENTO
		AND    OGTRA.TIPO_DOCUMENTO   = MI_CON_TIPO_DOCUMENTO
		AND    DECODE(UN_FILTRO
								 ,MI_CON_ESTADO_D,OGTRA.ESTADO								 
                 ,SUBSTR(OGTRA.ESTADO,4,6)
                 )        		 	   	= DECODE(UN_FILTRO
                                  			    ,MI_CON_ESTADO_D,'00000000000'
                                  			    ,MI_CON_ESTADO_A,'100000'
                                  			    ,MI_CON_ESTADO_E,'110000'
                                  			    ,MI_CON_ESTADO_R,'111000'
                                  			    ,MI_CON_ESTADO_G,'111010'
                                    	  		)		
		AND    OGTI.UNIDAD_EJECUTORA  = UNA_UNIDAD
		AND    OGTI.ENTIDAD           = UNA_ENTIDAD
		AND    OGTI.ANO_PAC           = UNA_VIGENCIA_PAC
		AND    OGTI.MES_PAC           = UN_MES_PAC
    AND    OGTI.RUBRO_INTERNO     = UN_RUBRO;
	EXCEPTION 
		WHEN OTHERS THEN
			PR_DESPLIEGA_MENSAJE('AL_STOP_1','Se presento este error calculando PAC por rubro '||sqlerrm);
			RAISE FORM_TRIGGER_FAILURE;  	    
  END PR_TOTAL_PAC_RUBRO;
/****************************************************************************/
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   TOTALIZA POR ENTIDAD, UNIDAD, VIGENCIA Y RUBRO 
  --             LAS RA QUE HAN SIDO DILIGENCIADAS O APROBADAS 
  -- PARAMETROS: UNA ENTIDAD
	--						 UNA UNIDAD
  --						 UNA VIGENCIA 
  --						 UN RUBRO
  --             UN FILTRO  -- D DILIGENCIADAS A APROBADAS 
  --						 RETORNA UN MENSAJE
/****************************************************************************/  
	PROCEDURE PR_TOTAL_PREDIS_RUBRO(UNA_ENTIDAD				OGT_RELACION_AUTORIZACION.ENTIDAD%TYPE
								         	   	,UNA_UNIDAD						OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA%TYPE
		  						 						,UNA_VIGENCIA					OGT_IMPUTACION.VIGENCIA%TYPE
  							 							,UN_RUBRO							OGT_IMPUTACION.RUBRO_INTERNO%TYPE
  							 							,UN_FILTRO						VARCHAR2
  							 							,UN_RETORNO           IN OUT NUMBER
  							 							)IS
  BEGIN
		SELECT SUM(NVL(OGTI.VALOR_BRUTO,0))
  	INTO   UN_RETORNO
		FROM   OGT_IMPUTACION             OGTI
      		,OGT_RELACION_AUTORIZACION  OGTRA
		WHERE  OGTRA.ENTIDAD 			      = OGTI.ENTIDAD
		AND    OGTRA.VIGENCIA   			  = OGTI.VIGENCIA
		AND    OGTRA.UNIDAD_EJECUTORA	 	= OGTI.UNIDAD_EJECUTORA
		AND    OGTRA.CONSECUTIVO  	    = OGTI.CONSECUTIVO
		AND    OGTRA.TIPO_DOCUMENTO 	  = OGTI.TIPO_DOCUMENTO
		AND    OGTI.UNIDAD_EJECUTORA  	= UNA_UNIDAD
		AND    OGTI.ENTIDAD         	  = UNA_ENTIDAD
		AND    OGTI.VIGENCIA_PRESUPUESTO= UNA_VIGENCIA
    AND    OGTI.RUBRO_INTERNO     	= UN_RUBRO
    AND    OGTRA.TIPO_DOCUMENTO     = MI_CON_TIPO_DOCUMENTO
		AND    DECODE(UN_FILTRO
								 ,MI_CON_ESTADO_D,OGTRA.ESTADO								 
                 ,SUBSTR(OGTRA.ESTADO,4,6)
                 )        		 	   	= DECODE(UN_FILTRO
                                  			    ,MI_CON_ESTADO_D,'00000000000'
                                  			    ,MI_CON_ESTADO_A,'100000'
                                  			    ,MI_CON_ESTADO_E,'110000'
                                  			    ,MI_CON_ESTADO_R,'111000'
                                  			    ,MI_CON_ESTADO_D,'111010'
                                    	  		);
	EXCEPTION 
		WHEN OTHERS THEN
			PR_DESPLIEGA_MENSAJE('AL_STOP_1','Se presento este error calculando PREDIS por rubro '||sqlerrm);
			RAISE FORM_TRIGGER_FAILURE;  	    
  END PR_TOTAL_PREDIS_RUBRO;  
/****************************************************************************/	
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   TOTALIZA UNA RA
  -- PARAMETROS: VIGENCIA, ENTIDAD, UNIDAD, TIPO_DOCUMENTO, CONSECUTIVO
/****************************************************************************/  
  FUNCTION OGT_FN_TOTAL_RA(UN_VIGENCIA         OGT_RELACION_AUTORIZACION.VIGENCIA%TYPE
                          ,UN_ENTIDAD          OGT_RELACION_AUTORIZACION.ENTIDAD%TYPE
                          ,UN_UNIDAD_EJECUTORA OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA%TYPE
                          ,UN_TIPO_DOCUMENTO   OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO%TYPE
                          ,UN_CONSECUTIVO      OGT_RELACION_AUTORIZACION.CONSECUTIVO%TYPE
                          ) RETURN NUMBER AS
  	CURSOR C_TOTAL IS
	    SELECT SUM(NVL(CC.VALOR_REGISTRO,0))
  	  FROM   OGT_REGISTRO_PRESUPUESTAL       CC
    	WHERE  CC.VIGENCIA         = UN_VIGENCIA         
	    AND    CC.ENTIDAD          = UN_ENTIDAD          
  	  AND    CC.UNIDAD_EJECUTORA = UN_UNIDAD_EJECUTORA 
    	AND    CC.TIPO_DOCUMENTO   = UN_TIPO_DOCUMENTO   
	    AND    CC.CONSECUTIVO      = UN_CONSECUTIVO      
     	;
  	MI_TOTAL   NUMBER;
	BEGIN
	  OPEN C_TOTAL;
	  FETCH C_TOTAL INTO MI_TOTAL;
	  IF C_TOTAL%ISOPEN THEN
		  CLOSE C_TOTAL;
		END IF;
	  RETURN(MI_TOTAL);	

	EXCEPTION WHEN OTHERS THEN
	  PR_DESPLIEGA_MENSAJE('AL_STOP_1','Error calculando el total de la RA '||sqlerrm);	  
	  RETURN 0;  	
	END OGT_FN_TOTAL_RA;  

/***************************************************************************/  
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   VALIDA UNA RA PARA SER RADICADA
  -- PARAMETROS: VIGENCIA, ENTIDAD, UNIDAD, TIPO_DOCUMENTO, CONSECUTIVO
  -- RETORNA UNA CADENA QUE INDICA EL ESTADO DE LA VALIDACION
  --   SI FUE EXITOSA RETORNA OK
  --   SI FUE FALLIDA RETORNA ErroR CONCATENADO CON UNA CADENA QUE JUSTIFICA EL ERROR
/***************************************************************************/    
  PROCEDURE PR_VALIDA_RADICACION_RA(UN_VIGENCIA         OGT_RELACION_AUTORIZACION.VIGENCIA%TYPE
	        	            ,UN_ENTIDAD          OGT_RELACION_AUTORIZACION.ENTIDAD%TYPE
  	        	          ,UN_UNIDAD_EJECUTORA OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA%TYPE
    	        	        ,UN_TIPO_DOCUMENTO   OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO%TYPE
      	        	      ,UN_CONSECUTIVO      OGT_RELACION_AUTORIZACION.CONSECUTIVO%TYPE
      	        	      ,UN_CODIGO           IN OUT VARCHAR2
        	        	 	  ) IS
		MI_ESTADO    					OGT_RELACION_AUTORIZACION.ESTADO%TYPE;        	        	 	  
		MI_RETORNO   					VARCHAR2(1000);
		MI_TOTAL_RA  				 	NUMBER;
		MI_TOTAL_CC						NUMBER;
		MI_TOTAL_ANEXO        NUMBER;
		UN_TIPO_RA					 	OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE;           
		UN_FECHA_DESDE 		 		OGT_RELACION_AUTORIZACION.FECHA_DESDE%TYPE;
		UN_MES    			 		 	OGT_RELACION_AUTORIZACION.MES%TYPE;                 	        	            	        	                       	        	      

	BEGIN
		-- VERIFICA QUE LA RA ESTE FIRMADA Y VALIDA
		BEGIN
			SELECT 	OGT_RELACION_AUTORIZACION.ESTADO
						 ,OGT_RELACION_AUTORIZACION.TIPO_RA           
						 ,OGT_RELACION_AUTORIZACION.FECHA_DESDE
						 ,OGT_RELACION_AUTORIZACION.MES                 	        	            	        	                       	        	      			
			INTO		MI_ESTADO
						 ,UN_TIPO_RA					 				
						 ,UN_FECHA_DESDE 		 		
						 ,UN_MES    			 		 	
			FROM    OGT_RELACION_AUTORIZACION
			WHERE   OGT_RELACION_AUTORIZACION.VIGENCIA 					= UN_VIGENCIA         
			AND 		OGT_RELACION_AUTORIZACION.ENTIDAD  					= UN_ENTIDAD          
			AND 		OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA 	= UN_UNIDAD_EJECUTORA 
			AND 		OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO    = UN_TIPO_DOCUMENTO   
			AND 		OGT_RELACION_AUTORIZACION.CONSECUTIVO       = UN_CONSECUTIVO      
			;

			IF SUBSTR(MI_ESTADO,4,1) = 1 THEN
				UN_CODIGO := 'Error: La RA esta Anulada';
			ELSIF SUBSTR(MI_ESTADO,4,1) = 1 AND SUBSTR(MI_ESTADO,4,1) = 0 THEN
				UN_CODIGO := 'OK';								
			ELSIF SUBSTR(MI_ESTADO,1,3)||SUBSTR(MI_ESTADO,10,2) <> '00000' THEN
				UN_CODIGO := 'Error: La RA no esta valida';				
			END IF;							
		EXCEPTION WHEN OTHERS THEN
			UN_CODIGO := 'Error: Verificando el estado';
		END;	

		-- RETORNA EL TOTAL DE LA RA
		MI_TOTAL_RA := OGT_PK_RA.OGT_FN_TOTAL_RA(UN_VIGENCIA         
                          ,UN_ENTIDAD          
                          ,UN_UNIDAD_EJECUTORA 
                          ,UN_TIPO_DOCUMENTO   
                          ,UN_CONSECUTIVO      
                          );
                          		
		-- VERIFICA CC
		SELECT 	SUM(NVL(OGT_CENTRO_COSTOS.VALOR,0))
		INTO   	MI_TOTAL_CC
		FROM		OGT_CENTRO_COSTOS
 		WHERE   OGT_CENTRO_COSTOS.ENTIDAD           = UN_ENTIDAD
		AND 		OGT_CENTRO_COSTOS.FECHA_DESDE				= UN_FECHA_DESDE
		AND 		OGT_CENTRO_COSTOS.CONSECUTIVO				= UN_CONSECUTIVO
		AND 		OGT_CENTRO_COSTOS.TIPO_RA						= UN_TIPO_RA
		AND 		OGT_CENTRO_COSTOS.TIPO_DOCUMENTO		= UN_TIPO_DOCUMENTO
		AND 		OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA  = UN_UNIDAD_EJECUTORA
		AND 		OGT_CENTRO_COSTOS.MES								= UN_MES
		AND 		OGT_CENTRO_COSTOS.VIGENCIA					= UN_VIGENCIA
		;
		
		IF NVL(MI_TOTAL_RA,0) <> NVL(MI_TOTAL_CC,0) THEN
			UN_CODIGO := 'Error: El centro de costos no coincide con el total de la RA';      	  			 						
    ELSE
			UN_CODIGO := 'OK';				      	
    END IF;
		
		-- VERIFICA ANEXOS
		IF UN_TIPO_RA = 1 THEN  -- NOMINA
			MI_TOTAL_ANEXO := OGT_PK_RA.OGT_FN_TOTAL_ANEXOS_NOMINA(UN_VIGENCIA         
                                ,UN_ENTIDAD      
                                ,UN_UNIDAD_EJECUTORA 
                                ,UN_TIPO_DOCUMENTO   
                                ,UN_CONSECUTIVO      
                                ,UN_TIPO_RA          
                                ,UN_MES              
                                ,UN_FECHA_DESDE      
                                );
		ELSE -- APORTES
			MI_TOTAL_ANEXO := OGT_PK_RA.OGT_FN_TOTAL_ANEXOS_PATRONAL(UN_VIGENCIA         
                                ,UN_ENTIDAD      
                                ,UN_UNIDAD_EJECUTORA 
                                ,UN_TIPO_DOCUMENTO   
                                ,UN_CONSECUTIVO      
                                ,UN_TIPO_RA          
                                ,UN_MES              
                                ,UN_FECHA_DESDE      
                                );
		END IF;
		
		IF NVL(MI_TOTAL_RA,0) <> NVL(MI_TOTAL_ANEXO,0) THEN
			UN_CODIGO := 'Error: El total de la RA es '||mi_total_ra||' y los totales de los anexos suman '||mi_total_anexo;      	  			 						
    ELSE
			UN_CODIGO := 'OK';				      			
    END IF;
	EXCEPTION    
		WHEN OTHERS THEN
			PR_DESPLIEGA_MENSAJE('AL_STOP_1','Se presento este error validando radicacion de la RA '||sqlerrm);
			FORMS_DDL('ROLLBACK COMIENZO');
	END PR_VALIDA_RADICACION_RA;
	
/***************************************************************************/  
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   DEFINE EL PROCEDIMIENTO PARA LA CREACION DE SALDOS
  -- PARAMETROS: VIGENCIA, ENTIDAD, UNIDAD, TIPO_DOCUMENTO, CONSECUTIVO
  -- RETORNA UNA CADENA QUE INDICA EL ESTADO DE LA CREACION  
  --   SI FUE EXITOSA RETORNA OK
  --   SI FUE FALLIDA RETORNA ErroR CONCATENADO CON UNA CADENA QUE JUSTIFICA EL ERROR
/***************************************************************************/  

		FUNCTION FN_SALDO_TEMPORALES(UN_UNIDAD_EJECUTORA      OGT_DOCUMENTO_PAGO.UNIDAD_EJECUTORA%TYPE
																			,UN_VIGENCIA              OGT_DOCUMENTO_PAGO.VIGENCIA%TYPE
																			,UN_CONSECUTIVO						OGT_RELACION_AUTORIZACION.CONSECUTIVO%TYPE
																			,UN_ENTIDAD               OGT_DOCUMENTO_PAGO.ENTIDAD%TYPE
																			,UN_ID										OGT_EGRESO.TER_ID%TYPE
																			,UN_COTE_ID								OGT_EGRESO.COTE_ID%TYPE
																			) RETURN NUMBER IS

      MI_CON_ESTADO    OGT_EGRESO.ESTADO%TYPE    := 'B';
		  CURSOR CUR_TEMPORALES IS
		  SELECT TIPO_DOCUMENTO
						,UNIDAD_EJECUTORA
						,VIGENCIA
						,CONSECUTIVO
						,ENTIDAD
						,TER_ID
						,COTE_ID
						,SUM(NVL(VALOR_BRUTO,0))  VALOR
		  FROM   OGT_EGRESO
		  WHERE  OGT_EGRESO.UNIDAD_EJECUTORA = UN_UNIDAD_EJECUTORA      
		  AND    OGT_EGRESO.VIGENCIA         = UN_VIGENCIA     
		  AND    OGT_EGRESO.CONSECUTIVO      = UN_CONSECUTIVO	
		  AND    OGT_EGRESO.ENTIDAD          = UN_ENTIDAD     
		  AND    OGT_EGRESO.TIPO_DOCUMENTO   = 'RA'
		  AND    OGT_EGRESO.TER_ID           = UN_ID					
		  AND    OGT_EGRESO.COTE_ID          = UN_COTE_ID	
		  AND    OGT_EGRESO.ESTADO           = MI_CON_ESTADO	   --- TEMPORAL	  
		  GROUP BY TIPO_DOCUMENTO
						,UNIDAD_EJECUTORA
						,VIGENCIA
						,CONSECUTIVO
						,ENTIDAD
						,TER_ID
						,COTE_ID
			;

		BEGIN		
      FOR A IN CUR_TEMPORALES LOOP 
															 
				UPDATE OGT_EGRESO
				SET    VALOR_BRUTO = 0
							,ESTADO      = 'G'				--- AGOTADO				
				WHERE  TIPO_DOCUMENTO   = A.TIPO_DOCUMENTO
				AND    UNIDAD_EJECUTORA = A.UNIDAD_EJECUTORA
				AND    VIGENCIA         = A.VIGENCIA
				AND    CONSECUTIVO      = A.CONSECUTIVO
				AND    ENTIDAD          = A.ENTIDAD
				AND    TER_ID           = A.TER_ID
				AND    COTE_ID          = A.COTE_ID
				;			
				RETURN  NVL(A.VALOR,0);
      END LOOP;
    RETURN 0;  
		EXCEPTION 
			WHEN NO_DATA_FOUND THEN
				CLOSE CUR_TEMPORALES;
				RETURN  0;
				FORMS_DDL('ROLLBACK COMIENZO');
				--RAISE FORM_TRIGGER_FAILURE;		
			WHEN OTHERS THEN
				CLOSE CUR_TEMPORALES;
				PR_DESPLIEGA_MENSAJE('AL_STOP_1','Error buscando temporales Error: '||SQLERRM);
				RETURN  0;
				FORMS_DDL('ROLLBACK COMIENZO');
				--RAISE FORM_TRIGGER_FAILURE;
END FN_SALDO_TEMPORALES;

/***************************************************************************/  
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   DEFINE EL PROCEDIMIENTO PARA LA CREACION DE EEGRESOS DE UNA RA
  -- PARAMETROS: VIGENCIA, ENTIDAD, UNIDAD, TIPO_DOCUMENTO, CONSECUTIVO
  -- RETORNA UNA CADENA QUE INDICA EL ESTADO DE LA CREACION  
  --   SI FUE EXITOSA RETORNA OK
  --   SI FUE FALLIDA RETORNA ErroR CONCATENADO CON UNA CADENA QUE JUSTIFICA EL ERROR
/***************************************************************************/    
  PROCEDURE PR_CREA_EGRESOS_RA(UN_VIGENCIA         OGT_RELACION_AUTORIZACION.VIGENCIA%TYPE
	        	            ,UN_ENTIDAD          OGT_RELACION_AUTORIZACION.ENTIDAD%TYPE
  	        	          ,UN_UNIDAD_EJECUTORA OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA%TYPE
    	        	        ,UN_TIPO_DOCUMENTO   OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO%TYPE
      	        	      ,UN_CONSECUTIVO      OGT_RELACION_AUTORIZACION.CONSECUTIVO%TYPE
      	        	      ,UN_FECHA_RADICACION DATE
      	        	      ,UN_CODIGO           IN OUT VARCHAR2      	        	      
        	        	 	  ) IS

		MI_FECHA_DESDE 		 		OGT_RELACION_AUTORIZACION.FECHA_DESDE%TYPE;
		MI_MES    			 		 	OGT_RELACION_AUTORIZACION.MES%TYPE;
		MI_TIPO_RA 			 		 	OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE;                 	        	            	        	                       	        	      		                 	        	            	        	                       	        	      
		MI_ESTADO    					OGT_RELACION_AUTORIZACION.ESTADO%TYPE;        	        	 	  
		MI_RETORNO   					VARCHAR2(1000);
		UN_ID_ENTIDAD         OGT_ANEXO_EMBARGO.ID_PAGAR_A%TYPE;
		MI_INFCOMERCIAL_ENT   PK_SIT_INFCOMERCIAL.CUR_INFOCOMERCIAL;
		MI_FECHA_INICIAL			DATE;
		MI_FECHA_FINAL  	    DATE;
		MI_BANCO							OGT_ANEXO_EMBARGO.BANCO%TYPE;
		MI_SUCURSAL						OGT_ANEXO_EMBARGO.SUCURSAL%TYPE;           
		MI_TIPO_CUENTA				OGT_ANEXO_EMBARGO.TIPO_CUENTA%TYPE;
		MI_CUENTA							OGT_ANEXO_EMBARGO.NUMERO_CUENTA%TYPE;
		MI_TIPO_PAGO          OGT_ANEXO_EMBARGO.FORMA_PAGO%TYPE;
		MI_ID									OGT_ANEXO_EMBARGO.ID_PAGAR_A%TYPE;
		MI_TOTAL_EMBARGOS     NUMBER := 0;
		MI_TOTAL_DESCUENTOS   NUMBER := 0;		
		MI_SALDO_TEMPORALES   NUMBER := 0;
		MI_SITUACION_FONDOS   OGT_RELACION_AUTORIZACION.SITUACION_FONDOS%TYPE;
    MI_ESTADO_LEGALIZACION    BOOLEAN := TRUE;
    MI_MENSAJE_LEGALIZACION   VARCHAR(2000);
		MI_ESTADO_TRASLADO        BOOLEAN := TRUE;
		MI_MENSAJE_TRASLADO       VARCHAR(2000);
		MI_RESULTADO_TRASLADO     NUMBER;
		MI_TAB_AFCTCIONES         OGT_PK_TRASLADO_CONCEPTOS.Tab_Afctciones;   
		MI_DESCRIPCION            OGT_RELACION_AUTORIZACION.DESCRIPCION%TYPE;
		MI_TIPO_COMPROMISO        OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO%TYPE;
		MI_NUMERO_COMPROMISO        OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO%TYPE;
		MI_ID_PAGAR_A             OGT_ANEXO_NOMINA.ID_PAGAR_A%TYPE;
		MI_FORMA_PAGO							OGT_ANEXO_NOMINA.FORMA_PAGO%TYPE;             	
		MI_CUANTOS                NUMBER;
		MI_VV_UNO									NUMBER := '1';
		MI_VV_CERO								NUMBER := '0';
		MI_VV_DOS								NUMBER := '2';
		MI_VV_A										VARCHAR2(1) := 'A';
		
			  
		-- CURSOR PARA CREAR LO EGRESOS PARA RA DE APORTES
		CURSOR MI_CUR_APORTES_EGRESOS(UN_TIPO_RA      OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE
																 ,UN_MES          OGT_RELACION_AUTORIZACION.MES%TYPE
																 ,UN_FECHA_DESDE  OGT_RELACION_AUTORIZACION.FECHA_DESDE%TYPE) IS
			SELECT ALL 	MIN(OGT_CONCEPTO_RA.CUENTA_CONTABLE)         CUENTA_CONTABLE, 
									OGT_CONCEPTO_RA.VALIDAR_SALDO                VALIDAR_SALDO, 
									MIN(OGT_RELACION_AUTORIZACION.DESCRIPCION)   DESCRIPCION, 									 
									OGT_ANEXO_PATRONAL.ID_PAGAR_A                ID, 
									MIN(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS)  CODIGO_CENTRO_COSTOS,
									MIN(DECODE(OGT_RELACION_AUTORIZACION.SITUACION_FONDOS,1,'S','N')) SITUACION_FONDOS,
									SUM(NVL(OGT_ANEXO_PATRONAL.APORTE_PATRONAL,0)) PATRONAL,
									SUM(NVL(OGT_ANEXO_PATRONAL.APORTE_EMPLEADO,0)) EMPLEADO,									
									SUM(NVL(OGT_ANEXO_PATRONAL.INCAPACIDAD,0))     INCAPACIDAD,
									SUM(NVL(OGT_ANEXO_PATRONAL.SALDO,0))           SALDO,									
									OGT_CONCEPTO_RA.ID                            COTE_ID,
									OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO     TIPO_COMPROMISO,
									OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO   NUMERO_COMPROMISO,
									OGT_V_PROVEEDORES_RA.FORMA_PAGO                 FORMA_PAGO,
									OGT_V_PROVEEDORES_RA.BANCO                      BANCO,
									OGT_V_PROVEEDORES_RA.NUMERO_CUENTA              NUMERO_CUENTA,
									OGT_V_PROVEEDORES_RA.TIPO_CUENTA								CLASE,
									MIN(OGT_CONCEPTO_RA.NIVEL)                    NIVEL,
									MIN(OGT_CONCEPTO_RA.INTERNO_NIVEL)            INTERNO_NIVEL
			FROM 				OGT_V_PROVEEDORES_RA,
									OGT_CENTRO_COSTOS, 
									OGT_CONCEPTO_RA, 
									OGT_RELACION_AUTORIZACION, 
									OGT_ANEXO_PATRONAL
			WHERE 			OGT_RELACION_AUTORIZACION.FECHA_APROBACION >= OGT_V_PROVEEDORES_RA.FECHA_INICIAL
			AND         OGT_RELACION_AUTORIZACION.FECHA_APROBACION < NVL(OGT_V_PROVEEDORES_RA.FECHA_FINAL,SYSDATE+1)
			AND					OGT_V_PROVEEDORES_RA.ID = OGT_ANEXO_PATRONAL.ID_PAGAR_A
			AND					(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS=OGT_CONCEPTO_RA.CODIGO_CENTRO_COSTOS)
 			AND 				(OGT_CENTRO_COSTOS.FECHA_DESDE=OGT_RELACION_AUTORIZACION.FECHA_DESDE
		  AND 				OGT_CENTRO_COSTOS.MES=OGT_RELACION_AUTORIZACION.MES
		  AND 				OGT_CENTRO_COSTOS.TIPO_RA=OGT_RELACION_AUTORIZACION.TIPO_RA
		  AND 				OGT_CENTRO_COSTOS.ENTIDAD=OGT_RELACION_AUTORIZACION.ENTIDAD
		  AND 				OGT_CENTRO_COSTOS.CONSECUTIVO=OGT_RELACION_AUTORIZACION.CONSECUTIVO
		  AND 				OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA=OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA
		  AND 				OGT_CENTRO_COSTOS.VIGENCIA=OGT_RELACION_AUTORIZACION.VIGENCIA
		  AND 				OGT_CENTRO_COSTOS.TIPO_DOCUMENTO=OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO)
		  AND 				(OGT_ANEXO_PATRONAL.CODIGO_CENTRO_COSTOS=OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS
		  AND 				OGT_ANEXO_PATRONAL.UNIDAD_EJECUTORA=OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA
		  AND 				OGT_ANEXO_PATRONAL.TIPO_DOCUMENTO=OGT_CENTRO_COSTOS.TIPO_DOCUMENTO
		  AND 				OGT_ANEXO_PATRONAL.MES=OGT_CENTRO_COSTOS.MES
		  AND 				OGT_ANEXO_PATRONAL.CONSECUTIVO=OGT_CENTRO_COSTOS.CONSECUTIVO
		  AND 				OGT_ANEXO_PATRONAL.FECHA_DESDE=OGT_CENTRO_COSTOS.FECHA_DESDE
		  AND 				OGT_ANEXO_PATRONAL.TIPO_RA=OGT_CENTRO_COSTOS.TIPO_RA
		  AND 				OGT_ANEXO_PATRONAL.ENTIDAD=OGT_CENTRO_COSTOS.ENTIDAD
		  AND 				OGT_ANEXO_PATRONAL.VIGENCIA=OGT_CENTRO_COSTOS.VIGENCIA)
		  AND         OGT_CONCEPTO_RA.NETO_NOMINA <> MI_VV_UNO  -- NO CESANTIAS
		  AND         OGT_RELACION_AUTORIZACION.ENTIDAD = UN_ENTIDAD
			AND					OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA = UN_UNIDAD_EJECUTORA
			AND					OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO = UN_TIPO_DOCUMENTO
			AND					OGT_RELACION_AUTORIZACION.CONSECUTIVO = UN_CONSECUTIVO						
			AND					OGT_RELACION_AUTORIZACION.TIPO_RA = UN_TIPO_RA			
			AND					OGT_RELACION_AUTORIZACION.VIGENCIA = UN_VIGENCIA			
			AND					OGT_RELACION_AUTORIZACION.MES = UN_MES
			AND					OGT_RELACION_AUTORIZACION.FECHA_DESDE = UN_FECHA_DESDE
			AND         OGT_CONCEPTO_RA.TIPO_ANEXO = MI_VV_DOS  -- APORTES
			AND         OGT_CONCEPTO_RA.PAGOS_SIN_GIRO = MI_VV_CERO  -- NO ES UNA MULTA O UN REINTEGRO
			AND         OGT_CONCEPTO_RA.INCLUIR_SS = MI_VV_UNO						
		  GROUP BY    OGT_CONCEPTO_RA.ID
		  						,OGT_CONCEPTO_RA.VALIDAR_SALDO                
		  						,OGT_ANEXO_PATRONAL.ID_PAGAR_A 			
									,OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO     
									,OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO   
									,OGT_V_PROVEEDORES_RA.FORMA_PAGO                 
  								,OGT_V_PROVEEDORES_RA.BANCO                      
									,OGT_V_PROVEEDORES_RA.NUMERO_CUENTA              
									,OGT_V_PROVEEDORES_RA.TIPO_CUENTA
		  ;

		-- CURSOR PARA CREAR LO EGRESOS PARA RA DE APORTES CESANTIAS
		CURSOR MI_CUR_APORTES_CESANTIAS_ABONO(UN_TIPO_RA      OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE
																 ,UN_MES          OGT_RELACION_AUTORIZACION.MES%TYPE
																 ,UN_FECHA_DESDE  OGT_RELACION_AUTORIZACION.FECHA_DESDE%TYPE) IS
			SELECT ALL 	MIN(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS)      CODIGO_CENTRO_COSTOS,
									SUM(NVL(OGT_ANEXO_PATRONAL.APORTE_PATRONAL,0)) PATRONAL,
									SUM(NVL(OGT_ANEXO_PATRONAL.APORTE_EMPLEADO,0)) EMPLEADO,									
									SUM(NVL(OGT_ANEXO_PATRONAL.INCAPACIDAD,0))     INCAPACIDAD,
									SUM(NVL(OGT_ANEXO_PATRONAL.SALDO,0))           SALDO,									
									MIN(DECODE(OGT_RELACION_AUTORIZACION.SITUACION_FONDOS,1,'S','N')) SITUACION_FONDOS,
									MIN(OGT_RELACION_AUTORIZACION.DESCRIPCION)       DESCRIPCION,
							    OGT_CONCEPTO_RA.ID                               COTE_ID,
									OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO        TIPO_COMPROMISO,
									OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO      NUMERO_COMPROMISO,
									MIN(OGT_CONCEPTO_RA.NIVEL)                       NIVEL,
									MIN(OGT_CONCEPTO_RA.INTERNO_NIVEL)               INTERNO_NIVEL												
			FROM 				OGT_V_PROVEEDORES_RA,
									OGT_CENTRO_COSTOS, 
									OGT_CONCEPTO_RA, 
									OGT_RELACION_AUTORIZACION, 
									OGT_ANEXO_PATRONAL
			WHERE 			OGT_RELACION_AUTORIZACION.FECHA_APROBACION >= OGT_V_PROVEEDORES_RA.FECHA_INICIAL
			AND         OGT_RELACION_AUTORIZACION.FECHA_APROBACION < NVL(OGT_V_PROVEEDORES_RA.FECHA_FINAL,SYSDATE+1)
			AND					OGT_V_PROVEEDORES_RA.ID = OGT_ANEXO_PATRONAL.ID_PAGAR_A
			AND 				(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS=OGT_CONCEPTO_RA.CODIGO_CENTRO_COSTOS)
 			AND 				(OGT_CENTRO_COSTOS.FECHA_DESDE=OGT_RELACION_AUTORIZACION.FECHA_DESDE
		  AND 				OGT_CENTRO_COSTOS.MES=OGT_RELACION_AUTORIZACION.MES
		  AND 				OGT_CENTRO_COSTOS.TIPO_RA=OGT_RELACION_AUTORIZACION.TIPO_RA
		  AND 				OGT_CENTRO_COSTOS.ENTIDAD=OGT_RELACION_AUTORIZACION.ENTIDAD
		  AND 				OGT_CENTRO_COSTOS.CONSECUTIVO=OGT_RELACION_AUTORIZACION.CONSECUTIVO
		  AND 				OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA=OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA
		  AND 				OGT_CENTRO_COSTOS.VIGENCIA=OGT_RELACION_AUTORIZACION.VIGENCIA
		  AND 				OGT_CENTRO_COSTOS.TIPO_DOCUMENTO=OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO)
		  AND 				(OGT_ANEXO_PATRONAL.CODIGO_CENTRO_COSTOS=OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS
		  AND 				OGT_ANEXO_PATRONAL.UNIDAD_EJECUTORA=OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA
		  AND 				OGT_ANEXO_PATRONAL.TIPO_DOCUMENTO=OGT_CENTRO_COSTOS.TIPO_DOCUMENTO
		  AND 				OGT_ANEXO_PATRONAL.MES=OGT_CENTRO_COSTOS.MES
		  AND 				OGT_ANEXO_PATRONAL.CONSECUTIVO=OGT_CENTRO_COSTOS.CONSECUTIVO
		  AND 				OGT_ANEXO_PATRONAL.FECHA_DESDE=OGT_CENTRO_COSTOS.FECHA_DESDE
		  AND 				OGT_ANEXO_PATRONAL.TIPO_RA=OGT_CENTRO_COSTOS.TIPO_RA
		  AND 				OGT_ANEXO_PATRONAL.ENTIDAD=OGT_CENTRO_COSTOS.ENTIDAD
		  AND 				OGT_ANEXO_PATRONAL.VIGENCIA=OGT_CENTRO_COSTOS.VIGENCIA)
		  AND         OGT_CONCEPTO_RA.NETO_NOMINA = MI_VV_UNO -- CESANTIAS
		  AND         OGT_V_PROVEEDORES_RA.FORMA_PAGO = MI_VV_A  -- ABONO
		  AND         OGT_RELACION_AUTORIZACION.ENTIDAD = UN_ENTIDAD
			AND					OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA = UN_UNIDAD_EJECUTORA
			AND					OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO = UN_TIPO_DOCUMENTO
			AND					OGT_RELACION_AUTORIZACION.CONSECUTIVO = UN_CONSECUTIVO						
			AND					OGT_RELACION_AUTORIZACION.TIPO_RA = UN_TIPO_RA			
			AND					OGT_RELACION_AUTORIZACION.VIGENCIA = UN_VIGENCIA			
			AND					OGT_RELACION_AUTORIZACION.MES = UN_MES
			AND					OGT_RELACION_AUTORIZACION.FECHA_DESDE = UN_FECHA_DESDE
			AND         OGT_CONCEPTO_RA.TIPO_ANEXO = MI_VV_DOS  -- APORTES
			AND         OGT_CONCEPTO_RA.PAGOS_SIN_GIRO = MI_VV_CERO  -- NO ES UNA MULTA O UN REINTEGRO
			GROUP BY    OGT_CONCEPTO_RA.ID
									,OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO     
									,OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO   
		  ;

		-- CURSOR PARA CREAR LO EGRESOS PARA RA DE APORTES CESANTIAS
		CURSOR MI_CUR_APORTES_CESANTIAS_NOABO(UN_TIPO_RA      OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE
																 ,UN_MES          OGT_RELACION_AUTORIZACION.MES%TYPE
																 ,UN_FECHA_DESDE  OGT_RELACION_AUTORIZACION.FECHA_DESDE%TYPE) IS
			SELECT ALL 	MIN(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS)      CODIGO_CENTRO_COSTOS,
									SUM(NVL(OGT_ANEXO_PATRONAL.APORTE_PATRONAL,0)) PATRONAL,
									SUM(NVL(OGT_ANEXO_PATRONAL.APORTE_EMPLEADO,0)) EMPLEADO,									
									SUM(NVL(OGT_ANEXO_PATRONAL.INCAPACIDAD,0))     INCAPACIDAD,
									SUM(NVL(OGT_ANEXO_PATRONAL.SALDO,0))           SALDO,		
									OGT_ANEXO_PATRONAL.ID_PAGAR_A                  ID, 																
									MIN(DECODE(OGT_RELACION_AUTORIZACION.SITUACION_FONDOS,1,'S','N')) SITUACION_FONDOS,
									MIN(OGT_RELACION_AUTORIZACION.DESCRIPCION)       DESCRIPCION,
							    OGT_CONCEPTO_RA.ID                               COTE_ID,
									OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO        TIPO_COMPROMISO,
									OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO      NUMERO_COMPROMISO,
									OGT_V_PROVEEDORES_RA.FORMA_PAGO                    FORMA_PAGO,
									OGT_V_PROVEEDORES_RA.BANCO                         BANCO,
									OGT_V_PROVEEDORES_RA.NUMERO_CUENTA                 NUMERO_CUENTA,
									OGT_V_PROVEEDORES_RA.TIPO_CUENTA 	 								 CLASE,
									MIN(OGT_CONCEPTO_RA.NIVEL)                       NIVEL,
									MIN(OGT_CONCEPTO_RA.INTERNO_NIVEL)               INTERNO_NIVEL												
			FROM 				OGT_V_PROVEEDORES_RA,
									OGT_CENTRO_COSTOS, 
									OGT_CONCEPTO_RA, 
									OGT_RELACION_AUTORIZACION, 
									OGT_ANEXO_PATRONAL
			WHERE 			OGT_RELACION_AUTORIZACION.FECHA_APROBACION >= OGT_V_PROVEEDORES_RA.FECHA_INICIAL
			AND         OGT_RELACION_AUTORIZACION.FECHA_APROBACION < NVL(OGT_V_PROVEEDORES_RA.FECHA_FINAL,SYSDATE+1)
			AND					OGT_V_PROVEEDORES_RA.ID = OGT_ANEXO_PATRONAL.ID_PAGAR_A
			AND					(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS=OGT_CONCEPTO_RA.CODIGO_CENTRO_COSTOS)
 			AND 				(OGT_CENTRO_COSTOS.FECHA_DESDE=OGT_RELACION_AUTORIZACION.FECHA_DESDE
		  AND 				OGT_CENTRO_COSTOS.MES=OGT_RELACION_AUTORIZACION.MES
		  AND 				OGT_CENTRO_COSTOS.TIPO_RA=OGT_RELACION_AUTORIZACION.TIPO_RA
		  AND 				OGT_CENTRO_COSTOS.ENTIDAD=OGT_RELACION_AUTORIZACION.ENTIDAD
		  AND 				OGT_CENTRO_COSTOS.CONSECUTIVO=OGT_RELACION_AUTORIZACION.CONSECUTIVO
		  AND 				OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA=OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA
		  AND 				OGT_CENTRO_COSTOS.VIGENCIA=OGT_RELACION_AUTORIZACION.VIGENCIA
		  AND 				OGT_CENTRO_COSTOS.TIPO_DOCUMENTO=OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO)
		  AND 				(OGT_ANEXO_PATRONAL.CODIGO_CENTRO_COSTOS=OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS
		  AND 				OGT_ANEXO_PATRONAL.UNIDAD_EJECUTORA=OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA
		  AND 				OGT_ANEXO_PATRONAL.TIPO_DOCUMENTO=OGT_CENTRO_COSTOS.TIPO_DOCUMENTO
		  AND 				OGT_ANEXO_PATRONAL.MES=OGT_CENTRO_COSTOS.MES
		  AND 				OGT_ANEXO_PATRONAL.CONSECUTIVO=OGT_CENTRO_COSTOS.CONSECUTIVO
		  AND 				OGT_ANEXO_PATRONAL.FECHA_DESDE=OGT_CENTRO_COSTOS.FECHA_DESDE
		  AND 				OGT_ANEXO_PATRONAL.TIPO_RA=OGT_CENTRO_COSTOS.TIPO_RA
		  AND 				OGT_ANEXO_PATRONAL.ENTIDAD=OGT_CENTRO_COSTOS.ENTIDAD
		  AND 				OGT_ANEXO_PATRONAL.VIGENCIA=OGT_CENTRO_COSTOS.VIGENCIA)
		  AND         OGT_CONCEPTO_RA.NETO_NOMINA = MI_VV_UNO  -- CESANTIAS
		  AND         OGT_V_PROVEEDORES_RA.FORMA_PAGO <> MI_VV_A  -- ABONO		  
		  AND         OGT_RELACION_AUTORIZACION.ENTIDAD = UN_ENTIDAD
			AND					OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA = UN_UNIDAD_EJECUTORA
			AND					OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO = UN_TIPO_DOCUMENTO
			AND					OGT_RELACION_AUTORIZACION.CONSECUTIVO = UN_CONSECUTIVO						
			AND					OGT_RELACION_AUTORIZACION.TIPO_RA = UN_TIPO_RA			
			AND					OGT_RELACION_AUTORIZACION.VIGENCIA = UN_VIGENCIA			
			AND					OGT_RELACION_AUTORIZACION.MES = UN_MES
			AND					OGT_RELACION_AUTORIZACION.FECHA_DESDE = UN_FECHA_DESDE
			AND         OGT_CONCEPTO_RA.TIPO_ANEXO = MI_VV_DOS  -- APORTES
			AND         OGT_CONCEPTO_RA.PAGOS_SIN_GIRO = MI_VV_CERO  -- NO ES UNA MULTA O UN REINTEGRO
			GROUP BY    OGT_CONCEPTO_RA.ID			
									,OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO     
									,OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO   
									,OGT_ANEXO_PATRONAL.ID_PAGAR_A                  
									,OGT_V_PROVEEDORES_RA.FORMA_PAGO                 
									,OGT_V_PROVEEDORES_RA.BANCO                         
									,OGT_V_PROVEEDORES_RA.NUMERO_CUENTA                 
									,OGT_V_PROVEEDORES_RA.TIPO_CUENTA 	 								 									
		  ;

		-- CURSOR PARA CREAR EGRESOS PARA RA DE NOMINA POR CONCEPTOS DE EMBARGOS
		CURSOR MI_CUR_EMBARGOS_EGRESOS(UN_TIPO_RA      OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE
																 ,UN_MES          OGT_RELACION_AUTORIZACION.MES%TYPE
																 ,UN_FECHA_DESDE  OGT_RELACION_AUTORIZACION.FECHA_DESDE%TYPE) IS
			SELECT ALL 	MIN(OGT_CONCEPTO_RA.CUENTA_CONTABLE)            CUENTA_CONTABLE, 
									MIN(OGT_RELACION_AUTORIZACION.DESCRIPCION)      DESCRIPCION, 									 									
									OGT_ANEXO_EMBARGO.ID_PAGAR_A                    ID, 
									MIN(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS)     CODIGO_CENTRO_COSTOS,									
									MIN(DECODE(OGT_RELACION_AUTORIZACION.SITUACION_FONDOS,1,'S','N')) SITUACION_FONDOS,
									SUM(OGT_ANEXO_EMBARGO.APORTE_EMBARGO)           VALOR,									
									OGT_CONCEPTO_RA.ID                              COTE_ID,
									OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO       TIPO_COMPROMISO,
									OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO     NUMERO_COMPROMISO,
									MIN(OGT_V_PROVEEDORES_RA.FORMA_PAGO)               FORMA_PAGO,
									MIN(OGT_V_PROVEEDORES_RA.BANCO)                    BANCO,
									MIN(OGT_V_PROVEEDORES_RA.NUMERO_CUENTA)            NUMERO_CUENTA,
									MIN(OGT_V_PROVEEDORES_RA.TIPO_CUENTA)  						CLASE,
									MIN(OGT_CONCEPTO_RA.NIVEL)                      NIVEL,
									MIN(OGT_CONCEPTO_RA.INTERNO_NIVEL)              INTERNO_NIVEL												
			FROM 				OGT_V_PROVEEDORES_RA,
									OGT_CENTRO_COSTOS, 
									OGT_CONCEPTO_RA, 
									OGT_RELACION_AUTORIZACION, 
									OGT_ANEXO_EMBARGO
			WHERE 			OGT_RELACION_AUTORIZACION.FECHA_APROBACION >= OGT_V_PROVEEDORES_RA.FECHA_INICIAL
			AND         OGT_RELACION_AUTORIZACION.FECHA_APROBACION < NVL(OGT_V_PROVEEDORES_RA.FECHA_FINAL,SYSDATE+1)
			AND					OGT_V_PROVEEDORES_RA.ID = OGT_ANEXO_EMBARGO.ID_PAGAR_A
			AND					(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS=OGT_CONCEPTO_RA.CODIGO_CENTRO_COSTOS)
 			AND 				(OGT_CENTRO_COSTOS.FECHA_DESDE=OGT_RELACION_AUTORIZACION.FECHA_DESDE
			AND 				OGT_CENTRO_COSTOS.MES=OGT_RELACION_AUTORIZACION.MES
			AND 				OGT_CENTRO_COSTOS.TIPO_RA=OGT_RELACION_AUTORIZACION.TIPO_RA
			AND 				OGT_CENTRO_COSTOS.ENTIDAD=OGT_RELACION_AUTORIZACION.ENTIDAD
			AND 				OGT_CENTRO_COSTOS.CONSECUTIVO=OGT_RELACION_AUTORIZACION.CONSECUTIVO
			AND 				OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA=OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA
			AND 				OGT_CENTRO_COSTOS.VIGENCIA=OGT_RELACION_AUTORIZACION.VIGENCIA
			AND 				OGT_CENTRO_COSTOS.TIPO_DOCUMENTO=OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO)
			AND 				(OGT_ANEXO_EMBARGO.CODIGO_CENTRO_COSTOS=OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS
			AND 				OGT_ANEXO_EMBARGO.UNIDAD_EJECUTORA=OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA
			AND 				OGT_ANEXO_EMBARGO.TIPO_DOCUMENTO=OGT_CENTRO_COSTOS.TIPO_DOCUMENTO
			AND 				OGT_ANEXO_EMBARGO.MES=OGT_CENTRO_COSTOS.MES
			AND 				OGT_ANEXO_EMBARGO.CONSECUTIVO=OGT_CENTRO_COSTOS.CONSECUTIVO
			AND 				OGT_ANEXO_EMBARGO.FECHA_DESDE=OGT_CENTRO_COSTOS.FECHA_DESDE
			AND 				OGT_ANEXO_EMBARGO.TIPO_RA=OGT_CENTRO_COSTOS.TIPO_RA
			AND 				OGT_ANEXO_EMBARGO.ENTIDAD=OGT_CENTRO_COSTOS.ENTIDAD
			AND 				OGT_ANEXO_EMBARGO.VIGENCIA=OGT_CENTRO_COSTOS.VIGENCIA)
			AND         OGT_RELACION_AUTORIZACION.ENTIDAD = UN_ENTIDAD
			AND					OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA = UN_UNIDAD_EJECUTORA
			AND					OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO = UN_TIPO_DOCUMENTO
			AND					OGT_RELACION_AUTORIZACION.CONSECUTIVO = UN_CONSECUTIVO						
			AND					OGT_RELACION_AUTORIZACION.TIPO_RA = UN_TIPO_RA			
			AND					OGT_RELACION_AUTORIZACION.VIGENCIA = UN_VIGENCIA			
			AND					OGT_RELACION_AUTORIZACION.MES = UN_MES			
			AND					OGT_RELACION_AUTORIZACION.FECHA_DESDE = UN_FECHA_DESDE
			AND         OGT_CONCEPTO_RA.TIPO_ANEXO = MI_VV_UNO  -- NOMINA
			AND         OGT_CONCEPTO_RA.AFECTA_EMBARGOS = MI_VV_UNO  -- SI EMBARGOS			
			AND         OGT_CONCEPTO_RA.NETO_NOMINA = MI_VV_CERO  -- NO NETO NOMINA
			AND         OGT_CONCEPTO_RA.AFECTA_RETENCION = MI_VV_CERO  -- NO RETENCION			
			AND         OGT_CONCEPTO_RA.VALIDAR_SALDO = MI_VV_CERO  -- NO ES DESCUENTO
			AND         OGT_CONCEPTO_RA.PAGOS_SIN_GIRO = MI_VV_CERO  -- NO ES UNA MULTA O UN REINTEGRO
			GROUP BY    OGT_CONCEPTO_RA.ID
									,OGT_ANEXO_EMBARGO.ID_PAGAR_A  
									,OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO     
									,OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO   
			;

		-- INGRESOS POR RETENCION
		CURSOR MI_CUR_RETENCION(UN_TIPO_RA      OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE
																 ,UN_MES          OGT_RELACION_AUTORIZACION.MES%TYPE
																 ,UN_FECHA_DESDE  OGT_RELACION_AUTORIZACION.FECHA_DESDE%TYPE) IS
			SELECT ALL 	MIN(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS)      CODIGO_CENTRO_COSTOS,
									SUM(OGT_ANEXO_NOMINA.APORTE_EMPLEADO)            VALOR,
									OGT_ANEXO_NOMINA.ID_PAGAR_A                     ID, 																		
									MIN(DECODE(OGT_RELACION_AUTORIZACION.SITUACION_FONDOS,1,'S','N')) SITUACION_FONDOS,
									MIN(OGT_RELACION_AUTORIZACION.DESCRIPCION)       DESCRIPCION,
							    OGT_CONCEPTO_RA.ID                               COTE_ID,
									OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO        TIPO_COMPROMISO,
									OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO      NUMERO_COMPROMISO,
									OGT_V_PROVEEDORES_RA.FORMA_PAGO                      FORMA_PAGO,
									MIN(OGT_CONCEPTO_RA.NIVEL)                       NIVEL,
									MIN(OGT_CONCEPTO_RA.INTERNO_NIVEL)               INTERNO_NIVEL									
			FROM 				OGT_V_PROVEEDORES_RA,
									OGT_CENTRO_COSTOS, 
									OGT_CONCEPTO_RA, 
									OGT_RELACION_AUTORIZACION, 
									OGT_ANEXO_NOMINA
			WHERE 			OGT_RELACION_AUTORIZACION.FECHA_APROBACION >= OGT_V_PROVEEDORES_RA.FECHA_INICIAL
			AND         OGT_RELACION_AUTORIZACION.FECHA_APROBACION < NVL(OGT_V_PROVEEDORES_RA.FECHA_FINAL,SYSDATE+1)
			AND					OGT_V_PROVEEDORES_RA.ID = OGT_ANEXO_NOMINA.ID_PAGAR_A
			AND					(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS=OGT_CONCEPTO_RA.CODIGO_CENTRO_COSTOS)
			AND 				(OGT_CENTRO_COSTOS.FECHA_DESDE=OGT_RELACION_AUTORIZACION.FECHA_DESDE
			AND 				OGT_CENTRO_COSTOS.ENTIDAD=OGT_RELACION_AUTORIZACION.ENTIDAD
			AND 				OGT_CENTRO_COSTOS.CONSECUTIVO=OGT_RELACION_AUTORIZACION.CONSECUTIVO
			AND 				OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA=OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA
			AND 				OGT_CENTRO_COSTOS.VIGENCIA=OGT_RELACION_AUTORIZACION.VIGENCIA
			AND 				OGT_CENTRO_COSTOS.TIPO_DOCUMENTO=OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO)
			AND 				(OGT_ANEXO_NOMINA.CODIGO_CENTRO_COSTOS=OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS
			AND 				OGT_ANEXO_NOMINA.UNIDAD_EJECUTORA=OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA
			AND 				OGT_ANEXO_NOMINA.TIPO_DOCUMENTO=OGT_CENTRO_COSTOS.TIPO_DOCUMENTO
			AND 				OGT_ANEXO_NOMINA.MES=OGT_CENTRO_COSTOS.MES
			AND 				OGT_ANEXO_NOMINA.CONSECUTIVO=OGT_CENTRO_COSTOS.CONSECUTIVO
			AND 				OGT_ANEXO_NOMINA.FECHA_DESDE=OGT_CENTRO_COSTOS.FECHA_DESDE
			AND 				OGT_ANEXO_NOMINA.TIPO_RA=OGT_CENTRO_COSTOS.TIPO_RA
			AND 				OGT_ANEXO_NOMINA.ENTIDAD=OGT_CENTRO_COSTOS.ENTIDAD
			AND 				OGT_ANEXO_NOMINA.VIGENCIA=OGT_CENTRO_COSTOS.VIGENCIA)
			AND         OGT_RELACION_AUTORIZACION.ENTIDAD = UN_ENTIDAD
			AND					OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA = UN_UNIDAD_EJECUTORA
			AND					OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO = UN_TIPO_DOCUMENTO
			AND					OGT_RELACION_AUTORIZACION.CONSECUTIVO = UN_CONSECUTIVO						
			AND					OGT_RELACION_AUTORIZACION.VIGENCIA = UN_VIGENCIA			
			AND         OGT_CONCEPTO_RA.TIPO_ANEXO = MI_VV_UNO  -- NOMINA
			AND         OGT_CONCEPTO_RA.AFECTA_EMBARGOS = MI_VV_CERO  -- SI EMBARGOS			
			AND         OGT_CONCEPTO_RA.NETO_NOMINA = MI_VV_CERO  -- NO NETO NOMINA
			AND         OGT_CONCEPTO_RA.VALIDAR_SALDO = MI_VV_CERO  -- NO ES DESCUENTO
			AND         OGT_CONCEPTO_RA.AFECTA_RETENCION = MI_VV_UNO  -- NO RETENCION			
			AND         OGT_CONCEPTO_RA.PAGOS_SIN_GIRO = MI_VV_CERO  -- NO ES UNA MULTA O UN REINTEGRO						
			GROUP BY    OGT_CONCEPTO_RA.ID
									,OGT_ANEXO_NOMINA.ID_PAGAR_A
									,OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO     
									,OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO   
									,OGT_V_PROVEEDORES_RA.FORMA_PAGO                 
 			;

		-- CURSOR PARA CREAR EGRESOS PARA RA DE NOMINA POR OTROS CONCEPTOS
		CURSOR MI_CUR_OTROS_NOMINA_EGRESOS(UN_TIPO_RA      OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE
																 ,UN_MES          OGT_RELACION_AUTORIZACION.MES%TYPE
																 ,UN_FECHA_DESDE  OGT_RELACION_AUTORIZACION.FECHA_DESDE%TYPE) IS
			SELECT ALL 	MIN(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS)     CODIGO_CENTRO_COSTOS,
									SUM(OGT_ANEXO_NOMINA.APORTE_EMPLEADO)           VALOR,
									OGT_ANEXO_NOMINA.ID_PAGAR_A                     ID, 									
									MIN(DECODE(OGT_RELACION_AUTORIZACION.SITUACION_FONDOS,1,'S','N')) SITUACION_FONDOS,
									MIN(OGT_RELACION_AUTORIZACION.DESCRIPCION)      DESCRIPCION,
									OGT_CONCEPTO_RA.ID                              COTE_ID,									
									OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO       TIPO_COMPROMISO,
									OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO     NUMERO_COMPROMISO,
									OGT_V_PROVEEDORES_RA.FORMA_PAGO                     FORMA_PAGO,
									OGT_V_PROVEEDORES_RA.BANCO                          BANCO,
									OGT_V_PROVEEDORES_RA.NUMERO_CUENTA                  NUMERO_CUENTA,
									OGT_V_PROVEEDORES_RA.TIPO_CUENTA 	 								  CLASE,
									MIN(OGT_CONCEPTO_RA.NIVEL)                      NIVEL,
									MIN(OGT_CONCEPTO_RA.INTERNO_NIVEL)              INTERNO_NIVEL												
			FROM 				OGT_V_PROVEEDORES_rA,
									OGT_CENTRO_COSTOS, 
									OGT_CONCEPTO_RA, 
									OGT_RELACION_AUTORIZACION, 
									OGT_ANEXO_NOMINA
			WHERE 			OGT_RELACION_AUTORIZACION.FECHA_APROBACION >= OGT_V_PROVEEDORES_RA.FECHA_INICIAL
			AND         OGT_RELACION_AUTORIZACION.FECHA_APROBACION < NVL(OGT_V_PROVEEDORES_RA.FECHA_FINAL,SYSDATE+1)
			AND					OGT_V_PROVEEDORES_RA.ID = OGT_ANEXO_NOMINA.ID_PAGAR_A
			AND					(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS=OGT_CONCEPTO_RA.CODIGO_CENTRO_COSTOS)
			AND 				(OGT_CENTRO_COSTOS.FECHA_DESDE=OGT_RELACION_AUTORIZACION.FECHA_DESDE
			AND 				OGT_CENTRO_COSTOS.ENTIDAD=OGT_RELACION_AUTORIZACION.ENTIDAD
			AND 				OGT_CENTRO_COSTOS.CONSECUTIVO=OGT_RELACION_AUTORIZACION.CONSECUTIVO
			AND 				OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA=OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA
			AND 				OGT_CENTRO_COSTOS.VIGENCIA=OGT_RELACION_AUTORIZACION.VIGENCIA
			AND 				OGT_CENTRO_COSTOS.TIPO_DOCUMENTO=OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO)
			AND 				(OGT_ANEXO_NOMINA.CODIGO_CENTRO_COSTOS=OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS
			AND 				OGT_ANEXO_NOMINA.UNIDAD_EJECUTORA=OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA
			AND 				OGT_ANEXO_NOMINA.TIPO_DOCUMENTO=OGT_CENTRO_COSTOS.TIPO_DOCUMENTO
			AND 				OGT_ANEXO_NOMINA.MES=OGT_CENTRO_COSTOS.MES
			AND 				OGT_ANEXO_NOMINA.CONSECUTIVO=OGT_CENTRO_COSTOS.CONSECUTIVO
			AND 				OGT_ANEXO_NOMINA.FECHA_DESDE=OGT_CENTRO_COSTOS.FECHA_DESDE
			AND 				OGT_ANEXO_NOMINA.TIPO_RA=OGT_CENTRO_COSTOS.TIPO_RA
			AND 				OGT_ANEXO_NOMINA.ENTIDAD=OGT_CENTRO_COSTOS.ENTIDAD
			AND 				OGT_ANEXO_NOMINA.VIGENCIA=OGT_CENTRO_COSTOS.VIGENCIA)
			AND         OGT_RELACION_AUTORIZACION.ENTIDAD = UN_ENTIDAD
			AND					OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA = UN_UNIDAD_EJECUTORA
			AND					OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO = UN_TIPO_DOCUMENTO
			AND					OGT_RELACION_AUTORIZACION.CONSECUTIVO = UN_CONSECUTIVO						
			AND					OGT_RELACION_AUTORIZACION.VIGENCIA = UN_VIGENCIA			
			AND         OGT_CONCEPTO_RA.TIPO_ANEXO = MI_VV_UNO  -- NOMINA
			AND         OGT_CONCEPTO_RA.AFECTA_EMBARGOS = MI_VV_CERO  -- SI EMBARGOS			
			AND         OGT_CONCEPTO_RA.NETO_NOMINA = MI_VV_CERO  -- NO NETO NOMINA
			AND         OGT_CONCEPTO_RA.AFECTA_RETENCION = MI_VV_CERO  -- NO RETENCION			
			AND         OGT_CONCEPTO_RA.VALIDAR_SALDO = MI_VV_CERO  -- NO ES DESCUENTO
			AND         OGT_CONCEPTO_RA.PAGOS_SIN_GIRO = MI_VV_CERO  -- NO ES UNA MULTA O UN REINTEGRO		
			AND         OGT_CONCEPTO_RA.INCLUIR_SS = MI_VV_UNO	
			GROUP BY    OGT_CONCEPTO_RA.ID
									,OGT_ANEXO_NOMINA.ID_PAGAR_A    
									,OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO     
									,OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO   
									,OGT_V_PROVEEDORES_RA.FORMA_PAGO                 
									,OGT_V_PROVEEDORES_RA.BANCO                      
									,OGT_V_PROVEEDORES_RA.NUMERO_CUENTA              
									,OGT_V_PROVEEDORES_RA.TIPO_CUENTA
 			;

		-- CURSOR PARA CREAR EGRESOS PARA RA DE NOMINA PAGOS SIN GIRO
		CURSOR MI_CUR_PAGOS_SIN_GIRO(UN_TIPO_RA      OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE
																 ,UN_MES          OGT_RELACION_AUTORIZACION.MES%TYPE
																 ,UN_FECHA_DESDE  OGT_RELACION_AUTORIZACION.FECHA_DESDE%TYPE) IS
			SELECT ALL 	MIN(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS)     CODIGO_CENTRO_COSTOS,
									SUM(OGT_ANEXO_NOMINA.APORTE_EMPLEADO)           VALOR,
									MIN(DECODE(OGT_RELACION_AUTORIZACION.SITUACION_FONDOS,1,'S','N')) SITUACION_FONDOS,
									MIN(OGT_RELACION_AUTORIZACION.DESCRIPCION)      DESCRIPCION,
									OGT_CONCEPTO_RA.ID                              COTE_ID,									
									OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO       TIPO_COMPROMISO,
									OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO     NUMERO_COMPROMISO,
									MIN(OGT_CONCEPTO_RA.NIVEL)                      NIVEL,
									MIN(OGT_CONCEPTO_RA.INTERNO_NIVEL)              INTERNO_NIVEL												
			FROM 				OGT_CENTRO_COSTOS, 
									OGT_CONCEPTO_RA, 
									OGT_RELACION_AUTORIZACION, 
									OGT_ANEXO_NOMINA
			WHERE 			(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS=OGT_CONCEPTO_RA.CODIGO_CENTRO_COSTOS)
			AND 				(OGT_CENTRO_COSTOS.FECHA_DESDE=OGT_RELACION_AUTORIZACION.FECHA_DESDE
			AND 				OGT_CENTRO_COSTOS.ENTIDAD=OGT_RELACION_AUTORIZACION.ENTIDAD
			AND 				OGT_CENTRO_COSTOS.CONSECUTIVO=OGT_RELACION_AUTORIZACION.CONSECUTIVO
			AND 				OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA=OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA
			AND 				OGT_CENTRO_COSTOS.VIGENCIA=OGT_RELACION_AUTORIZACION.VIGENCIA
			AND 				OGT_CENTRO_COSTOS.TIPO_DOCUMENTO=OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO)
			AND 				(OGT_ANEXO_NOMINA.CODIGO_CENTRO_COSTOS=OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS
			AND 				OGT_ANEXO_NOMINA.UNIDAD_EJECUTORA=OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA
			AND 				OGT_ANEXO_NOMINA.TIPO_DOCUMENTO=OGT_CENTRO_COSTOS.TIPO_DOCUMENTO
			AND 				OGT_ANEXO_NOMINA.MES=OGT_CENTRO_COSTOS.MES
			AND 				OGT_ANEXO_NOMINA.CONSECUTIVO=OGT_CENTRO_COSTOS.CONSECUTIVO
			AND 				OGT_ANEXO_NOMINA.FECHA_DESDE=OGT_CENTRO_COSTOS.FECHA_DESDE
			AND 				OGT_ANEXO_NOMINA.TIPO_RA=OGT_CENTRO_COSTOS.TIPO_RA
			AND 				OGT_ANEXO_NOMINA.ENTIDAD=OGT_CENTRO_COSTOS.ENTIDAD
			AND 				OGT_ANEXO_NOMINA.VIGENCIA=OGT_CENTRO_COSTOS.VIGENCIA)
			AND         OGT_RELACION_AUTORIZACION.ENTIDAD = UN_ENTIDAD
			AND					OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA = UN_UNIDAD_EJECUTORA
			AND					OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO = UN_TIPO_DOCUMENTO
			AND					OGT_RELACION_AUTORIZACION.CONSECUTIVO = UN_CONSECUTIVO						
			AND					OGT_RELACION_AUTORIZACION.VIGENCIA = UN_VIGENCIA			
			AND         OGT_CONCEPTO_RA.TIPO_ANEXO = MI_VV_UNO  -- NOMINA
			AND         OGT_CONCEPTO_RA.AFECTA_EMBARGOS = MI_VV_CERO  -- SI EMBARGOS			
			AND         OGT_CONCEPTO_RA.NETO_NOMINA = MI_VV_CERO  -- NO NETO NOMINA
			AND         OGT_CONCEPTO_RA.AFECTA_RETENCION = MI_VV_CERO  -- NO RETENCION			
			AND         OGT_CONCEPTO_RA.VALIDAR_SALDO = MI_VV_CERO  -- NO ES DESCUENTO
			AND         OGT_CONCEPTO_RA.PAGOS_SIN_GIRO = MI_VV_UNO  -- ES UNA MULTA O UN REINTEGRO
			GROUP BY    OGT_CONCEPTO_RA.ID
									,OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO     
									,OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO   
 			;

		-- CURSOR PARA CREAR EGRESOS E INGRESOS PARA CONCEPTOS CON SALDO
		CURSOR MI_CUR_SALDO(UN_TIPO_RA      OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE
																 ,UN_MES          OGT_RELACION_AUTORIZACION.MES%TYPE
																 ,UN_FECHA_DESDE  OGT_RELACION_AUTORIZACION.FECHA_DESDE%TYPE) IS
			SELECT ALL 	MIN(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS)     CODIGO_CENTRO_COSTOS,
									SUM(OGT_ANEXO_NOMINA.APORTE_EMPLEADO)           VALOR,
									OGT_ANEXO_NOMINA.ID_PAGAR_A                     ID, 									
									MIN(DECODE(OGT_RELACION_AUTORIZACION.SITUACION_FONDOS,1,'S','N')) SITUACION_FONDOS,
									MIN(OGT_RELACION_AUTORIZACION.DESCRIPCION)      DESCRIPCION,
									OGT_CONCEPTO_RA.ID                              COTE_ID,									
									OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO       TIPO_COMPROMISO,
									OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO     NUMERO_COMPROMISO,
									OGT_V_PROVEEDORES_RA.FORMA_PAGO                     FORMA_PAGO,
									OGT_V_PROVEEDORES_RA.BANCO                          BANCO,
									OGT_V_PROVEEDORES_RA.NUMERO_CUENTA                  NUMERO_CUENTA,
									OGT_V_PROVEEDORES_RA.TIPO_CUENTA	 								  CLASE,
									MIN(OGT_CONCEPTO_RA.NIVEL)                      NIVEL,
									MIN(OGT_CONCEPTO_RA.INTERNO_NIVEL)              INTERNO_NIVEL												
			FROM 				OGT_V_PROVEEDORES_RA,
									OGT_CENTRO_COSTOS, 
									OGT_CONCEPTO_RA, 
									OGT_RELACION_AUTORIZACION, 
									OGT_ANEXO_NOMINA
			WHERE 			OGT_RELACION_AUTORIZACION.FECHA_APROBACION >= OGT_V_PROVEEDORES_RA.FECHA_INICIAL
			AND        OGT_RELACION_AUTORIZACION.FECHA_APROBACION < NVL(OGT_V_PROVEEDORES_RA.FECHA_FINAL,SYSDATE+1)
			AND					OGT_V_PROVEEDORES_RA.ID = OGT_ANEXO_NOMINA.ID_PAGAR_A
			AND					(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS=OGT_CONCEPTO_RA.CODIGO_CENTRO_COSTOS)
			AND 				(OGT_CENTRO_COSTOS.FECHA_DESDE=OGT_RELACION_AUTORIZACION.FECHA_DESDE
			AND 				OGT_CENTRO_COSTOS.ENTIDAD=OGT_RELACION_AUTORIZACION.ENTIDAD
			AND 				OGT_CENTRO_COSTOS.CONSECUTIVO=OGT_RELACION_AUTORIZACION.CONSECUTIVO
			AND 				OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA=OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA
			AND 				OGT_CENTRO_COSTOS.VIGENCIA=OGT_RELACION_AUTORIZACION.VIGENCIA
			AND 				OGT_CENTRO_COSTOS.TIPO_DOCUMENTO=OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO)
			AND 				(OGT_ANEXO_NOMINA.CODIGO_CENTRO_COSTOS=OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS
			AND 				OGT_ANEXO_NOMINA.UNIDAD_EJECUTORA=OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA
			AND 				OGT_ANEXO_NOMINA.TIPO_DOCUMENTO=OGT_CENTRO_COSTOS.TIPO_DOCUMENTO
			AND 				OGT_ANEXO_NOMINA.MES=OGT_CENTRO_COSTOS.MES
			AND 				OGT_ANEXO_NOMINA.CONSECUTIVO=OGT_CENTRO_COSTOS.CONSECUTIVO
			AND 				OGT_ANEXO_NOMINA.FECHA_DESDE=OGT_CENTRO_COSTOS.FECHA_DESDE
			AND 				OGT_ANEXO_NOMINA.TIPO_RA=OGT_CENTRO_COSTOS.TIPO_RA
			AND 				OGT_ANEXO_NOMINA.ENTIDAD=OGT_CENTRO_COSTOS.ENTIDAD
			AND 				OGT_ANEXO_NOMINA.VIGENCIA=OGT_CENTRO_COSTOS.VIGENCIA)
			AND         OGT_RELACION_AUTORIZACION.ENTIDAD = UN_ENTIDAD
			AND					OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA = UN_UNIDAD_EJECUTORA
			AND					OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO = UN_TIPO_DOCUMENTO
			AND					OGT_RELACION_AUTORIZACION.CONSECUTIVO = UN_CONSECUTIVO						
			AND					OGT_RELACION_AUTORIZACION.VIGENCIA = UN_VIGENCIA			
			AND         OGT_CONCEPTO_RA.TIPO_ANEXO = MI_VV_UNO  -- NOMINA
			AND         OGT_CONCEPTO_RA.AFECTA_EMBARGOS = MI_VV_CERO  -- SI EMBARGOS			
			AND         OGT_CONCEPTO_RA.NETO_NOMINA = MI_VV_CERO  -- NO NETO NOMINA
			AND         OGT_CONCEPTO_RA.AFECTA_RETENCION = MI_VV_CERO  -- NO RETENCION
			AND         OGT_CONCEPTO_RA.VALIDAR_SALDO = MI_VV_UNO  -- DESCUENTOS
			AND         OGT_CONCEPTO_RA.PAGOS_SIN_GIRO = MI_VV_CERO  -- NO ES UNA MULTA O UN REINTEGRO						
			GROUP BY    OGT_CONCEPTO_RA.ID
									,OGT_ANEXO_NOMINA.ID_PAGAR_A    
									,OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO     
									,OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO   
									,OGT_V_PROVEEDORES_rA.FORMA_PAGO                 
									,OGT_V_PROVEEDORES_rA.BANCO                      
									,OGT_V_PROVEEDORES_rA.NUMERO_CUENTA              
									,OGT_V_PROVEEDORES_rA.TIPO_CUENTA									
 			;

		-- CURSOR PARA CREAR EGRESOS PARA RA DE NOMINA POR CONCEPTOS DE NOMINA
		-- POR ABONO EN CUENTA
		CURSOR MI_CUR_NETO_ABONO(UN_TIPO_RA      OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE
																 ,UN_MES          OGT_RELACION_AUTORIZACION.MES%TYPE
																 ,UN_FECHA_DESDE  OGT_RELACION_AUTORIZACION.FECHA_DESDE%TYPE) IS
			SELECT ALL 	MIN(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS)      CODIGO_CENTRO_COSTOS,
									SUM(OGT_ANEXO_NOMINA.APORTE_EMPLEADO)            VALOR,
									MIN(DECODE(OGT_RELACION_AUTORIZACION.SITUACION_FONDOS,1,'S','N')) SITUACION_FONDOS,
									MIN(OGT_RELACION_AUTORIZACION.DESCRIPCION)       DESCRIPCION,
							    OGT_CONCEPTO_RA.ID                               COTE_ID,
									OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO        TIPO_COMPROMISO,
									OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO      NUMERO_COMPROMISO,
									MIN(OGT_CONCEPTO_RA.NIVEL)                       NIVEL,
									MIN(OGT_CONCEPTO_RA.INTERNO_NIVEL)               INTERNO_NIVEL												
			FROM 				OGT_V_PROVEEDORES_RA,
									OGT_CENTRO_COSTOS, 
									OGT_CONCEPTO_RA, 
									OGT_RELACION_AUTORIZACION, 
									OGT_ANEXO_NOMINA
			WHERE 			OGT_RELACION_AUTORIZACION.FECHA_APROBACION >= OGT_V_PROVEEDORES_RA.FECHA_INICIAL
			AND         OGT_RELACION_AUTORIZACION.FECHA_APROBACION < NVL(OGT_V_PROVEEDORES_RA.FECHA_FINAL,SYSDATE+1)
			AND					OGT_V_PROVEEDORES_RA.ID = OGT_ANEXO_NOMINA.ID_PAGAR_A
			AND         OGT_V_PROVEEDORES_RA.BANCO = 51  -- DAVIVIENDA
			AND					(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS=OGT_CONCEPTO_RA.CODIGO_CENTRO_COSTOS)
			AND 				(OGT_CENTRO_COSTOS.FECHA_DESDE=OGT_RELACION_AUTORIZACION.FECHA_DESDE
			AND 				OGT_CENTRO_COSTOS.ENTIDAD=OGT_RELACION_AUTORIZACION.ENTIDAD
			AND 				OGT_CENTRO_COSTOS.CONSECUTIVO=OGT_RELACION_AUTORIZACION.CONSECUTIVO
			AND 				OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA=OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA
			AND 				OGT_CENTRO_COSTOS.VIGENCIA=OGT_RELACION_AUTORIZACION.VIGENCIA
			AND 				OGT_CENTRO_COSTOS.TIPO_DOCUMENTO=OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO)
			AND 				(OGT_ANEXO_NOMINA.CODIGO_CENTRO_COSTOS=OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS
			AND 				OGT_ANEXO_NOMINA.UNIDAD_EJECUTORA=OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA
			AND 				OGT_ANEXO_NOMINA.TIPO_DOCUMENTO=OGT_CENTRO_COSTOS.TIPO_DOCUMENTO
			AND 				OGT_ANEXO_NOMINA.MES=OGT_CENTRO_COSTOS.MES
			AND 				OGT_ANEXO_NOMINA.CONSECUTIVO=OGT_CENTRO_COSTOS.CONSECUTIVO
			AND 				OGT_ANEXO_NOMINA.FECHA_DESDE=OGT_CENTRO_COSTOS.FECHA_DESDE
			AND 				OGT_ANEXO_NOMINA.TIPO_RA=OGT_CENTRO_COSTOS.TIPO_RA
			AND 				OGT_ANEXO_NOMINA.ENTIDAD=OGT_CENTRO_COSTOS.ENTIDAD
			AND 				OGT_ANEXO_NOMINA.VIGENCIA=OGT_CENTRO_COSTOS.VIGENCIA)
			AND         OGT_RELACION_AUTORIZACION.ENTIDAD = UN_ENTIDAD
			AND					OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA = UN_UNIDAD_EJECUTORA
			AND					OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO = UN_TIPO_DOCUMENTO
			AND					OGT_RELACION_AUTORIZACION.CONSECUTIVO = UN_CONSECUTIVO						
			AND					OGT_RELACION_AUTORIZACION.VIGENCIA = UN_VIGENCIA			
			AND         OGT_V_PROVEEDORES_RA.FORMA_PAGO = MI_VV_A -- ABONO A CUENTA 
			AND         OGT_CONCEPTO_RA.TIPO_ANEXO = MI_VV_UNO  -- NOMINA
			AND         OGT_CONCEPTO_RA.NETO_NOMINA = MI_VV_UNO  -- NOMINA			
			AND         OGT_CONCEPTO_RA.PAGOS_SIN_GIRO = MI_VV_CERO  -- NO ES UNA MULTA O UN REINTEGRO						
			GROUP BY    OGT_CONCEPTO_RA.ID
									,OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO     
									,OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO   
 			;

		-- CURSOR PARA CREAR EGRESOS PARA RA DE NOMINA POR CONCEPTOS DE NOMINA
		-- POR ABONO EN CUENTA
		CURSOR MI_CUR_OTRO_NETO_ABONO(UN_TIPO_RA      OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE
																 ,UN_MES          OGT_RELACION_AUTORIZACION.MES%TYPE
																 ,UN_FECHA_DESDE  OGT_RELACION_AUTORIZACION.FECHA_DESDE%TYPE) IS
			SELECT ALL 	MIN(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS)      CODIGO_CENTRO_COSTOS,
									SUM(OGT_ANEXO_NOMINA.APORTE_EMPLEADO)            VALOR,
									OGT_ANEXO_NOMINA.ID_PAGAR_A                     ID, 																		
									MIN(DECODE(OGT_RELACION_AUTORIZACION.SITUACION_FONDOS,1,'S','N')) SITUACION_FONDOS,
									MIN(OGT_RELACION_AUTORIZACION.DESCRIPCION)       DESCRIPCION,
							    OGT_CONCEPTO_RA.ID                               COTE_ID,
									OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO        TIPO_COMPROMISO,
									OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO      NUMERO_COMPROMISO,
									OGT_V_PROVEEDORES_RA.FORMA_PAGO                  FORMA_PAGO,
									OGT_V_PROVEEDORES_RA.BANCO                          BANCO,
									OGT_V_PROVEEDORES_RA.NUMERO_CUENTA                  NUMERO_CUENTA,
									OGT_V_PROVEEDORES_RA.TIPO_CUENTA	 								  CLASE,
									MIN(OGT_CONCEPTO_RA.NIVEL)                       NIVEL,
									MIN(OGT_CONCEPTO_RA.INTERNO_NIVEL)               INTERNO_NIVEL									
			FROM 				OGT_V_PROVEEDORES_RA,
									OGT_CENTRO_COSTOS, 
									OGT_CONCEPTO_RA, 
									OGT_RELACION_AUTORIZACION, 
									OGT_ANEXO_NOMINA
			WHERE 			OGT_RELACION_AUTORIZACION.FECHA_APROBACION >= OGT_V_PROVEEDORES_RA.FECHA_INICIAL
			AND         OGT_RELACION_AUTORIZACION.FECHA_APROBACION < NVL(OGT_V_PROVEEDORES_RA.FECHA_FINAL,SYSDATE+1)
			AND					OGT_V_PROVEEDORES_RA.ID = OGT_ANEXO_NOMINA.ID_PAGAR_A
			AND         OGT_V_PROVEEDORES_RA.BANCO <> 51  -- NO DAVIVIENDA
			AND					(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS=OGT_CONCEPTO_RA.CODIGO_CENTRO_COSTOS)
			AND 				(OGT_CENTRO_COSTOS.FECHA_DESDE=OGT_RELACION_AUTORIZACION.FECHA_DESDE
			AND 				OGT_CENTRO_COSTOS.ENTIDAD=OGT_RELACION_AUTORIZACION.ENTIDAD
			AND 				OGT_CENTRO_COSTOS.CONSECUTIVO=OGT_RELACION_AUTORIZACION.CONSECUTIVO
			AND 				OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA=OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA
			AND 				OGT_CENTRO_COSTOS.VIGENCIA=OGT_RELACION_AUTORIZACION.VIGENCIA
			AND 				OGT_CENTRO_COSTOS.TIPO_DOCUMENTO=OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO)
			AND 				(OGT_ANEXO_NOMINA.CODIGO_CENTRO_COSTOS=OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS
			AND 				OGT_ANEXO_NOMINA.UNIDAD_EJECUTORA=OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA
			AND 				OGT_ANEXO_NOMINA.TIPO_DOCUMENTO=OGT_CENTRO_COSTOS.TIPO_DOCUMENTO
			AND 				OGT_ANEXO_NOMINA.MES=OGT_CENTRO_COSTOS.MES
			AND 				OGT_ANEXO_NOMINA.CONSECUTIVO=OGT_CENTRO_COSTOS.CONSECUTIVO
			AND 				OGT_ANEXO_NOMINA.FECHA_DESDE=OGT_CENTRO_COSTOS.FECHA_DESDE
			AND 				OGT_ANEXO_NOMINA.TIPO_RA=OGT_CENTRO_COSTOS.TIPO_RA
			AND 				OGT_ANEXO_NOMINA.ENTIDAD=OGT_CENTRO_COSTOS.ENTIDAD
			AND 				OGT_ANEXO_NOMINA.VIGENCIA=OGT_CENTRO_COSTOS.VIGENCIA)
			AND         OGT_RELACION_AUTORIZACION.ENTIDAD = UN_ENTIDAD
			AND					OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA = UN_UNIDAD_EJECUTORA
			AND					OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO = UN_TIPO_DOCUMENTO
			AND					OGT_RELACION_AUTORIZACION.CONSECUTIVO = UN_CONSECUTIVO						
			AND					OGT_RELACION_AUTORIZACION.VIGENCIA = UN_VIGENCIA			
			AND         OGT_V_PROVEEDORES_RA.FORMA_PAGO = MI_VV_A -- ABONO A CUENTA 
			AND         OGT_CONCEPTO_RA.TIPO_ANEXO = MI_VV_UNO  -- NOMINA
			AND         OGT_CONCEPTO_RA.NETO_NOMINA = MI_VV_UNO  -- NOMINA			
			AND         OGT_CONCEPTO_RA.PAGOS_SIN_GIRO = MI_VV_CERO  -- NO ES UNA MULTA O UN REINTEGRO						
			GROUP BY    OGT_CONCEPTO_RA.ID
									,OGT_ANEXO_NOMINA.ID_PAGAR_A
									,OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO     
									,OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO   
									,OGT_V_PROVEEDORES_rA.FORMA_PAGO                 
									,OGT_V_PROVEEDORES_RA.BANCO                          
									,OGT_V_PROVEEDORES_RA.NUMERO_CUENTA                  
									,OGT_V_PROVEEDORES_RA.TIPO_CUENTA	 								  
 			;

		-- CURSOR PARA CREAR EGRESOS PARA RA DE NOMINA POR CONCEPTOS DE NOMINA
		-- POR CHEQUE PARA CADA FULANO
		CURSOR MI_CUR_NETO_NO_ABONO(UN_TIPO_RA      OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE
																 ,UN_MES          OGT_RELACION_AUTORIZACION.MES%TYPE
																 ,UN_FECHA_DESDE  OGT_RELACION_AUTORIZACION.FECHA_DESDE%TYPE) IS
			SELECT ALL 	MIN(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS)      CODIGO_CENTRO_COSTOS,
									SUM(OGT_ANEXO_NOMINA.APORTE_EMPLEADO)            VALOR,
									OGT_ANEXO_NOMINA.ID_PAGAR_A                     ID, 																		
									MIN(DECODE(OGT_RELACION_AUTORIZACION.SITUACION_FONDOS,1,'S','N')) SITUACION_FONDOS,
									MIN(OGT_RELACION_AUTORIZACION.DESCRIPCION)       DESCRIPCION,
							    OGT_CONCEPTO_RA.ID                               COTE_ID,
									OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO        TIPO_COMPROMISO,
									OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO      NUMERO_COMPROMISO,
									OGT_V_PROVEEDORES_RA.FORMA_PAGO                  FORMA_PAGO,
									MIN(OGT_CONCEPTO_RA.NIVEL)                       NIVEL,
									MIN(OGT_CONCEPTO_RA.INTERNO_NIVEL)               INTERNO_NIVEL									
			FROM 				OGT_V_PROVEEDORES_rA,
									OGT_CENTRO_COSTOS, 
									OGT_CONCEPTO_RA, 
									OGT_RELACION_AUTORIZACION, 
									OGT_ANEXO_NOMINA
			WHERE 			OGT_RELACION_AUTORIZACION.FECHA_APROBACION >= OGT_V_PROVEEDORES_RA.FECHA_INICIAL
			AND         OGT_RELACION_AUTORIZACION.FECHA_APROBACION < NVL(OGT_V_PROVEEDORES_RA.FECHA_FINAL,SYSDATE+1)
			AND					OGT_V_PROVEEDORES_RA.ID = OGT_ANEXO_NOMINA.ID_PAGAR_A
			AND					(OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS=OGT_CONCEPTO_RA.CODIGO_CENTRO_COSTOS)
			AND 				(OGT_CENTRO_COSTOS.FECHA_DESDE=OGT_RELACION_AUTORIZACION.FECHA_DESDE
			AND 				OGT_CENTRO_COSTOS.ENTIDAD=OGT_RELACION_AUTORIZACION.ENTIDAD
			AND 				OGT_CENTRO_COSTOS.CONSECUTIVO=OGT_RELACION_AUTORIZACION.CONSECUTIVO
			AND 				OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA=OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA
			AND 				OGT_CENTRO_COSTOS.VIGENCIA=OGT_RELACION_AUTORIZACION.VIGENCIA
			AND 				OGT_CENTRO_COSTOS.TIPO_DOCUMENTO=OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO)
			AND 				(OGT_ANEXO_NOMINA.CODIGO_CENTRO_COSTOS=OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS
			AND 				OGT_ANEXO_NOMINA.UNIDAD_EJECUTORA=OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA
			AND 				OGT_ANEXO_NOMINA.TIPO_DOCUMENTO=OGT_CENTRO_COSTOS.TIPO_DOCUMENTO
			AND 				OGT_ANEXO_NOMINA.MES=OGT_CENTRO_COSTOS.MES
			AND 				OGT_ANEXO_NOMINA.CONSECUTIVO=OGT_CENTRO_COSTOS.CONSECUTIVO
			AND 				OGT_ANEXO_NOMINA.FECHA_DESDE=OGT_CENTRO_COSTOS.FECHA_DESDE
			AND 				OGT_ANEXO_NOMINA.TIPO_RA=OGT_CENTRO_COSTOS.TIPO_RA
			AND 				OGT_ANEXO_NOMINA.ENTIDAD=OGT_CENTRO_COSTOS.ENTIDAD
			AND 				OGT_ANEXO_NOMINA.VIGENCIA=OGT_CENTRO_COSTOS.VIGENCIA)
			AND         OGT_RELACION_AUTORIZACION.ENTIDAD = UN_ENTIDAD
			AND					OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA = UN_UNIDAD_EJECUTORA
			AND					OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO = UN_TIPO_DOCUMENTO
			AND					OGT_RELACION_AUTORIZACION.CONSECUTIVO = UN_CONSECUTIVO						
			AND					OGT_RELACION_AUTORIZACION.VIGENCIA = UN_VIGENCIA			
			AND         OGT_V_PROVEEDORES_RA.FORMA_PAGO <> MI_VV_A -- DIFERENTE DE ABONO A CUENTA 
			AND         OGT_CONCEPTO_RA.TIPO_ANEXO = MI_VV_UNO  -- NOMINA
			AND         OGT_CONCEPTO_RA.NETO_NOMINA = MI_VV_UNO  -- NOMINA			
			AND         OGT_CONCEPTO_RA.PAGOS_SIN_GIRO = MI_VV_CERO  -- NO ES UNA MULTA O UN REINTEGRO						
			GROUP BY    OGT_CONCEPTO_RA.ID
									,OGT_ANEXO_NOMINA.ID_PAGAR_A
									,OGT_RELACION_AUTORIZACION.TIPO_COMPROMISO     
									,OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO   
									,OGT_V_PROVEEDORES_rA.FORMA_PAGO                 
 			;

		-- PAR EVALUAR SI HAY ENDOSOS
		CURSOR MI_CUR_ENDOSO IS
	  		SELECT 		ID_PAGAR_A             
									,FORMA_PAGO             
									,BANCO                  
									,TIPO_CUENTA            
									,NUMERO_CUENTA          
									,DESCRIPCION
									,DECODE(OGT_RELACION_AUTORIZACION.SITUACION_FONDOS,1,'S','N') SITUACION_FONDOS
									,TIPO_COMPROMISO
									,NUMERO_COMPROMISO
				FROM OGT_ENDOSO_RA
				,OGT_RELACION_AUTORIZACION
			  WHERE     OGT_ENDOSO_RA.ENTIDAD = OGT_RELACION_AUTORIZACION.ENTIDAD
			  AND 			OGT_ENDOSO_RA.VIGENCIA = OGT_RELACION_AUTORIZACION.VIGENCIA
			  AND 			OGT_ENDOSO_RA.UNIDAD_EJECUTORA = OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA
			  AND 			OGT_ENDOSO_RA.TIPO_DOCUMENTO = OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO
			  AND 			OGT_ENDOSO_RA.CONSECUTIVO = OGT_RELACION_AUTORIZACION.CONSECUTIVO
			  AND       OGT_ENDOSO_RA.VIGENCIA=UN_VIGENCIA
				AND				OGT_ENDOSO_RA.ENTIDAD= UN_ENTIDAD
				AND				OGT_ENDOSO_RA.UNIDAD_EJECUTORA=UN_UNIDAD_EJECUTORA
				AND				OGT_ENDOSO_RA.CONSECUTIVO= UN_CONSECUTIVO
				AND				OGT_ENDOSO_RA.TIPO_DOCUMENTO= UN_TIPO_DOCUMENTO;
				
		-- CURSOR PARA CREAR EGRESOS PARA RA CON ENDOSOS				
		CURSOR MI_CUR_EGRESOS_ENDOSO IS  
		SELECT CC
					,ID    COTE_ID
		  		,NIVEL
		  		,INTERNO_NIVEL					
		      ,SUM(VALOR)   VALOR
		FROM (
	  		SELECT OGT_ANEXO_NOMINA.CODIGO_CENTRO_COSTOS CC
	  		,ID
	  		,NIVEL
	  		,INTERNO_NIVEL
				,SUM(NVL(APORTE_EMPLEADO,0))                        VALOR
				FROM   OGT_ANEXO_NOMINA
				,OGT_CONCEPTO_RA
				WHERE  OGT_CONCEPTO_RA.CODIGO_CENTRO_COSTOS   = OGT_ANEXO_NOMINA.CODIGO_CENTRO_COSTOS
				AND    OGT_ANEXO_NOMINA.TIPO_DOCUMENTO       	= UN_TIPO_DOCUMENTO
				AND    OGT_ANEXO_NOMINA.UNIDAD_EJECUTORA     	= UN_UNIDAD_EJECUTORA
				AND    OGT_ANEXO_NOMINA.ENTIDAD 							= UN_ENTIDAD
				AND    OGT_ANEXO_NOMINA.VIGENCIA 							= UN_VIGENCIA
				AND    OGT_ANEXO_NOMINA.CONSECUTIVO 					= UN_CONSECUTIVO
				HAVING SUM(NVL(APORTE_EMPLEADO,0)) > 0
				GROUP BY OGT_ANEXO_NOMINA.CODIGO_CENTRO_COSTOS 
				,ID
	  		,NIVEL
	  		,INTERNO_NIVEL
				UNION
	  		SELECT OGT_ANEXO_EMBARGO.CODIGO_CENTRO_COSTOS CC
	  		,OGT_CONCEPTO_RA.ID
	  		,NIVEL
	  		,INTERNO_NIVEL	  		
				,SUM(NVL(APORTE_EMBARGO,0))                        VALOR
				FROM   OGT_ANEXO_EMBARGO
				,OGT_CONCEPTO_RA
				WHERE  OGT_CONCEPTO_RA.CODIGO_CENTRO_COSTOS   = OGT_ANEXO_EMBARGO.CODIGO_CENTRO_COSTOS
				AND    OGT_ANEXO_EMBARGO.TIPO_DOCUMENTO       = UN_TIPO_DOCUMENTO
				AND    OGT_ANEXO_EMBARGO.UNIDAD_EJECUTORA     = UN_UNIDAD_EJECUTORA
				AND    OGT_ANEXO_EMBARGO.ENTIDAD 							= UN_ENTIDAD
				AND    OGT_ANEXO_EMBARGO.VIGENCIA 						= UN_VIGENCIA
				AND    OGT_ANEXO_EMBARGO.CONSECUTIVO 					= UN_CONSECUTIVO
				HAVING SUM(NVL(APORTE_EMBARGO,0)) > 0
				GROUP BY OGT_ANEXO_EMBARGO.CODIGO_CENTRO_COSTOS 
				,OGT_CONCEPTO_RA.ID
	  		,NIVEL
	  		,INTERNO_NIVEL				
				UNION
				SELECT OGT_ANEXO_PATRONAL.CODIGO_CENTRO_COSTOS CC
	  		,OGT_CONCEPTO_RA.ID				
	  		,NIVEL
	  		,INTERNO_NIVEL	  		
				,SUM(NVL(APORTE_EMPLEADO,0)+NVL(APORTE_PATRONAL,0)-NVL(SALDO,0)-NVL(INCAPACIDAD,0))      VALOR
				FROM   OGT_ANEXO_PATRONAL
				,OGT_CONCEPTO_RA
				WHERE  OGT_CONCEPTO_RA.CODIGO_CENTRO_COSTOS   = OGT_ANEXO_PATRONAL.CODIGO_CENTRO_COSTOS
				AND    OGT_ANEXO_PATRONAL.TIPO_DOCUMENTO       	= UN_TIPO_DOCUMENTO
				AND    OGT_ANEXO_PATRONAL.UNIDAD_EJECUTORA     	= UN_UNIDAD_EJECUTORA
				AND    OGT_ANEXO_PATRONAL.ENTIDAD 							= UN_ENTIDAD
				AND    OGT_ANEXO_PATRONAL.VIGENCIA 							= UN_VIGENCIA
				AND    OGT_ANEXO_PATRONAL.CONSECUTIVO 					= UN_CONSECUTIVO
				GROUP BY OGT_ANEXO_PATRONAL.CODIGO_CENTRO_COSTOS 
				,OGT_CONCEPTO_RA.ID
				,NIVEL
	  		,INTERNO_NIVEL
			)
			GROUP BY CC
			,ID
  		,NIVEL
 		  ,INTERNO_NIVEL;

    /*******************************************************/

    /* INSERTAR EGRESOS */
		PROCEDURE PR_INSERTA_EGRESOS 			(UN_UNIDAD_EJECUTORA      OGT_DOCUMENTO_PAGO.UNIDAD_EJECUTORA%TYPE
																			,UN_VIGENCIA              OGT_DOCUMENTO_PAGO.VIGENCIA%TYPE
																			,UN_CONSECUTIVO						OGT_RELACION_AUTORIZACION.CONSECUTIVO%TYPE
																			,UN_ENTIDAD               OGT_DOCUMENTO_PAGO.ENTIDAD%TYPE
																			,UN_ESTADO								OGT_EGRESO.ESTADO%TYPE
																			,UN_VALOR_NETO						OGT_EGRESO.VALOR%TYPE
																			,UN_VALOR_BRUTO				    OGT_EGRESO.VALOR_BRUTO%TYPE					
																			,UNA_DESCRIPCION					OGT_EGRESO.DESCRIPCION%TYPE
																			,UN_SITUACION_FONDOS			OGT_EGRESO.SITUACION_FONDOS%TYPE
																			,UN_ID										OGT_EGRESO.TER_ID%TYPE
																			,UN_COTE_ID								OGT_EGRESO.COTE_ID%TYPE
																			,UN_TIPO_COMPROMISO				OGT_EGRESO.CODIGO_COMPROMISO%TYPE
																			,UN_NUMERO_COMPROMISO     OGT_EGRESO.NUMERO_COMPROMISO%TYPE
																			,UNA_FORMA_PAGO						OGT_EGRESO.FORMA_PAGO%TYPE
																			,UN_BANCO									OGT_EGRESO.BANCO%TYPE
																			,UN_NUMERO_CUENTA					OGT_EGRESO.NUMERO_CUENTA%TYPE
																			,UN_CLASE									OGT_EGRESO.CLASE%TYPE
																			,UN_NIVEL                 OGT_EGRESO.NIVEL%TYPE
																			,UN_INTERNO_NIVEL         OGT_EGRESO.INTERNO_NIVEL%TYPE																			
																			,UN_CODIGO_CENTRO_COSTOS  OGT_EGRESO.CODIGO_CENTRO_COSTOS%TYPE
																			,UN_FECHA                 DATE  -- FECHA PARA VALIDAR LA FORMA DE PAGO DEL PROVEEDOR
																			,UN_LLAMADO								VARCHAR2
																			) IS
      
				MI_ID_BANCO         NUMBER(20);
				MI_SITUACION_FONDOS VARCHAR2(2);
				MI_ESTADO           OGT_EGRESO.ESTADO%TYPE;
				
		BEGIN									
			BEGIN
			MI_ID_BANCO := PK_SIT_INFENTIDADES.SIT_FN_ID_SUPERBANCARIA (UN_BANCO
																																,TO_CHAR(SYSDATE,'DD-MON-YYYY'));

			EXCEPTION
				WHEN OTHERS THEN
				  --NO SE HACE NADA EN CASO DE NO EXISTIR EL PROVEEDOR O DE ESTAR DUPLICADO
				  NULL;
			END;							 	
			MI_ESTADO := UN_ESTADO;
			
			-- SIN SITUACION DE FONDOS
			IF UN_SITUACION_FONDOS = '1' THEN
				MI_SITUACION_FONDOS := 'S';
			ELSIF UN_SITUACION_FONDOS = '0' THEN
				MI_SITUACION_FONDOS := 'N';
			END IF;
			
			-- INSERTAR EL EGRESO			
			INSERT INTO OGT_EGRESO
			(TIPO_DOCUMENTO                 
			,UNIDAD_EJECUTORA               
			,VIGENCIA                       
			,CONSECUTIVO                    
			,ENTIDAD                        
			,FECHA_REGISTRO                 
			,ESTADO                         
			,VALOR                          
			,DESCRIPCION                    
			,SITUACION_FONDOS               
			,TER_ID         
			,SALDO
			,VALOR_BRUTO
			,COTE_ID
			,CORRESPONDE_NETO
			,UNTE_CODIGO
			,CODIGO_COMPROMISO
			,NUMERO_COMPROMISO
			,FORMA_PAGO
			,BANCO
			,NUMERO_CUENTA
			,CLASE						
			,NIVEL
			,INTERNO_NIVEL
			,CODIGO_CENTRO_COSTOS
			)
				VALUES
			('RA'
			,UN_UNIDAD_EJECUTORA               
			,UN_VIGENCIA                       
			,TO_NUMBER(UN_CONSECUTIVO)
			,UN_ENTIDAD                        
			--  FMD 23-07-2003
			-- SE ABRE LA FECHA DE RADICACION PARA QUE EL USUARIO LA DIGITE
--			,SYSDATE                 
      , UN_FECHA_RADICACION
			,UN_ESTADO
			,NVL(UN_VALOR_NETO,0)              
			,SUBSTR(UNA_DESCRIPCION,1,30)                    
			-- FMD 4-11-2003
			-- PARA UNIFICAR EL CONTENIDO DEL CAMPO
--			,NVL(UN_SITUACION_FONDOS,'N')
			,NVL(NVL(MI_SITUACION_FONDOS,UN_SITUACION_FONDOS),'S')
			,UN_ID
			,'S'  
			,NVL(UN_VALOR_BRUTO,0)              
			,UN_COTE_ID
			,'S'        
			,'PAGADURIA'
			,UN_TIPO_COMPROMISO
			,UN_NUMERO_COMPROMISO
			,UNA_FORMA_PAGO
			,NVL(MI_ID_BANCO,UN_BANCO)
			,UN_NUMERO_CUENTA
			,UN_CLASE
			,UN_NIVEL
			,UN_INTERNO_NIVEL
			,UN_CODIGO_CENTRO_COSTOS
			);
		EXCEPTION 
			WHEN DUP_VAL_ON_INDEX THEN
				PR_DESPLIEGA_MENSAJE('AL_STOP_1',UN_LLAMADO||' Error radicando RA: Posible tercero duplicado Tercero:' ||UN_UNIDAD_EJECUTORA||' '||           
			UN_VIGENCIA                       
			||' '||TO_NUMBER(UN_CONSECUTIVO)
			||' '||UN_ENTIDAD                        
      ||' '||UN_FECHA_RADICACION
			||' '||UN_ESTADO
			||' '||NVL(UN_VALOR_NETO,0)              
			||' '||SUBSTR(UNA_DESCRIPCION,1,30)                    
			||' '||NVL(NVL(MI_SITUACION_FONDOS,UN_SITUACION_FONDOS),'S')
			||' '||UN_ID
			||' '||'S'  
			||' '||NVL(UN_VALOR_BRUTO,0)              
			||' '||UN_COTE_ID
			||' '||'S'        
			||' '||'PAGADURIA'
			||' '||UN_TIPO_COMPROMISO
			||' '||UN_NUMERO_COMPROMISO
			||' '||UNA_FORMA_PAGO
			||' '||NVL(MI_ID_BANCO,UN_BANCO)
			||' '||UN_NUMERO_CUENTA
			||' '||UN_CLASE
			||' '||UN_NIVEL
			||' '||UN_INTERNO_NIVEL
			||' '||UN_CODIGO_CENTRO_COSTOS);
				UN_CODIGO := SQLERRM;
				RAISE FORM_TRIGGER_FAILURE;						
			WHEN OTHERS THEN
				PR_DESPLIEGA_MENSAJE('AL_STOP_1',UN_LLAMADO|| '1... Error radicado RA: No se ha creado el egreso del aportes por el error '||SQLERRM);
				FORMS_DDL('ROLLBACK COMIENZO');
				UN_CODIGO := SQLERRM;
				--RAISE FORM_TRIGGER_FAILURE;
		END;

    /*******************************************************/

    /* INSERTAR INGRESOS */
		PROCEDURE PR_INSERTA_INGRESOS 			(UN_UNIDAD_EJECUTORA      OGT_DOCUMENTO_PAGO.UNIDAD_EJECUTORA%TYPE
																			,UN_VIGENCIA              OGT_DOCUMENTO_PAGO.VIGENCIA%TYPE
																			,UN_CONSECUTIVO						OGT_RELACION_AUTORIZACION.CONSECUTIVO%TYPE
																			,UN_VALOR      						OGT_EGRESO.VALOR%TYPE
																			,UN_ENTIDAD               OGT_DOCUMENTO_PAGO.ENTIDAD%TYPE
																			,UN_ID										OGT_EGRESO.TER_ID%TYPE
																			,UN_COTE_ID								OGT_EGRESO.COTE_ID%TYPE
																			,UN_LLAMADO								VARCHAR2
																			) IS
      
		MI_ID_INGRESO         OGT_INGRESO.ID%TYPE;
						
		BEGIN									
			MI_ID_INGRESO := OGT_PK_INGRESO.FN_CREAR(UN_VIGENCIA
                                     ,NULL          -- Fecha legalización
                                     -- FMD SE ABRE LA FECHA DE RADICACION PARA SE DIGITADA POE EL USUARIO
                                     --,SYSDATE       -- Fecha consignación
                                     ,UN_FECHA_RADICACION
                                     ,UN_COTE_ID     -- Concepto tesorería
                                     ,TO_NUMBER(UN_CONSECUTIVO) -- Numero de documento
                                     ,'RA'          -- Tipo documento
                                     ,'PAGADURIA'   -- Código de unidad de tesorería
                                     ,UN_ID_ENTIDAD -- Tercero origen
                                     ,UN_ID          -- Tercero destino
                                     ,NULL          -- Cuenta bancaria
                                     ,NULL          -- Tipo cuenta bancaria
                                     ,NULL          -- Sucursal
                                     ,NULL          -- Entidad financiera
                                     ,UN_VALOR       -- Valor bruto
                                     ,'EL'          -- Estado del ingreso (verificar)
                                     ,'RA'          -- Tipo documento de legalización
                                     ,TO_NUMBER(UN_CONSECUTIVO) -- Número documento de legalización       
                                     ,'N');        -- Situacion de fondos
			-- INSERTAR EN OGT_PAGO_INGRESO EL ID                                     
       IF MI_ID_INGRESO = 0 THEN          	
	     				PR_DESPLIEGA_MENSAJE('AL_STOP_1',UN_LLAMADO||' Se presento un error creando ingresos para RA '|| OGT_PK_INGRESO.FN_MENSAJE_ERROR);
							FORMS_DDL('ROLLBACK COMIENZO');
							UN_CODIGO := 'MAL';
       ELSE
		      BEGIN
		          	INSERT INTO OGT_PAGO_INGRESO
		          	(UNIDAD_EJECUTORA       
								,VIGENCIA               
								,CONSECUTIVO            
								,ENTIDAD                
								,TIPO_DOCUMENTO         
								,ID                     )
          	    VALUES
          	    (UN_UNIDAD_EJECUTORA
          	    ,UN_VIGENCIA
          	    ,UN_CONSECUTIVO
          	    ,UN_ENTIDAD
          	    ,UN_TIPO_DOCUMENTO
          	    ,MI_ID_INGRESO);
	       	EXCEPTION WHEN OTHERS THEN
		     				PR_DESPLIEGA_MENSAJE('AL_STOP_1','Se presento el siguiente error creando ingresos para RA '||sqlerrm);
								FORMS_DDL('ROLLBACK COMIENZO');
								UN_CODIGO := SQLERRM;
								RAISE FORM_TRIGGER_FAILURE;
	       	END;
       END IF;
		EXCEPTION 
			WHEN DUP_VAL_ON_INDEX THEN
				PR_DESPLIEGA_MENSAJE('AL_STOP_1',UN_LLAMADO||' Error radicando RA: Registro duplicado ');
				UN_CODIGO := SQLERRM;				
				FORMS_DDL('ROLLBACK COMIENZO');				
				RAISE FORM_TRIGGER_FAILURE;						
			WHEN OTHERS THEN
				PR_DESPLIEGA_MENSAJE('AL_STOP_1',UN_LLAMADO|| '2... Error radicado RA: No se ha creado ingresos por el error '||SQLERRM);
				UN_CODIGO := SQLERRM;				
				FORMS_DDL('ROLLBACK COMIENZO');				
				RAISE FORM_TRIGGER_FAILURE;						
		END;  -- INSERTA INGRESOS

    /*******************************************************/

	BEGIN
		-- VALIDAR LA RA
    OGT_PK_RA.PR_VALIDA_RADICACION_RA(UN_VIGENCIA         
	        	            ,UN_ENTIDAD          
  	        	          ,UN_UNIDAD_EJECUTORA 
    	        	        ,UN_TIPO_DOCUMENTO   
      	        	      ,UN_CONSECUTIVO      
      	        	      ,UN_CODIGO           
      	        	      );
      	        	      
    IF UN_CODIGO <> 'OK' THEN
				PR_DESPLIEGA_MENSAJE('AL_STOP_1','Error validando RA: '||UN_CODIGO);
				FORMS_DDL('ROLLBACK COMIENZO');    	
    END IF;       	        	      
		-- BUSCAR EL TIPO DE RA      	        	      
		BEGIN
		  SELECT    OGT_RELACION_AUTORIZACION.TIPO_RA
		  				 ,OGT_RELACION_AUTORIZACION.MES
		  				 ,OGT_RELACION_AUTORIZACION.FECHA_DESDE
		  				 ,OGT_RELACION_AUTORIZACION.SITUACION_FONDOS
		  INTO      MI_TIPO_RA
		  				 ,MI_MES
		  				 ,MI_FECHA_DESDE
		  				 ,MI_SITUACION_FONDOS
		  FROM      OGT_RELACION_AUTORIZACION
		  WHERE     OGT_RELACION_AUTORIZACION.VIGENCIA=UN_VIGENCIA
			AND				OGT_RELACION_AUTORIZACION.ENTIDAD= UN_ENTIDAD
			AND				OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA=UN_UNIDAD_EJECUTORA
			AND				OGT_RELACION_AUTORIZACION.CONSECUTIVO= UN_CONSECUTIVO
			AND				OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO= UN_TIPO_DOCUMENTO
			;
		EXCEPTION 
			WHEN OTHERS THEN
				PR_DESPLIEGA_MENSAJE('AL_STOP_1','3... Error radicado RA: No se encontro el tipo de RA por el error '||SQLERRM);
				FORMS_DDL('ROLLBACK COMIENZO');
				--RAISE FORM_TRIGGER_FAILURE;
		END;

		-- BUSCA EL ID DE LA ENTIDAD
    UN_ID_ENTIDAD := PK_SIT_INFENTIDADES.SIT_FN_ID_ENTIDAD(UN_ENTIDAD, SYSDATE);

		-- BUSCA EL ID DEL BANCO
		MI_BANCO := PK_SIT_INFENTIDADES.SIT_FN_ID_SUPERBANCARIA ('51',TO_CHAR(SYSDATE,'DD-MON-YYYY'));

		-- GENERAR LOS EGRESOS 
	  BEGIN			
		  -- MANEJO PARA ENDOSOS
	  	BEGIN
	  			-- PAR EVALUAR SI HAY ENDOSOS
	  		SELECT 		COUNT(*)
	  		INTO      MI_CUANTOS
				FROM OGT_ENDOSO_RA
			  WHERE     OGT_ENDOSO_RA.VIGENCIA=UN_VIGENCIA
				AND				OGT_ENDOSO_RA.ENTIDAD= UN_ENTIDAD
				AND				OGT_ENDOSO_RA.UNIDAD_EJECUTORA=UN_UNIDAD_EJECUTORA
				AND				OGT_ENDOSO_RA.CONSECUTIVO= UN_CONSECUTIVO
				AND				OGT_ENDOSO_RA.TIPO_DOCUMENTO= UN_TIPO_DOCUMENTO;				
	  	END;
			IF MI_CUANTOS = 0 THEN						  	
					-- APORTES			  	
					IF MI_TIPO_RA = 2 THEN   -- APORTES 
						-- GENERA EGRESOS POR APORTES PATRONALES 
						FOR A IN MI_CUR_APORTES_EGRESOS(MI_TIPO_RA      
																					 ,MI_MES          
																					 ,MI_FECHA_DESDE  )  LOOP																					 	
							-- LOS APORTES PATRONALES QUE TUVIERON DESCUENTO DE EMPLEADO																			 	
							IF A.VALIDAR_SALDO = 1 THEN 
								PR_INSERTA_EGRESOS 		(UN_UNIDAD_EJECUTORA               
									,UN_VIGENCIA                       
									,UN_CONSECUTIVO
									,UN_ENTIDAD                        
									,'R'          -- ESTADO RADICADO
									,NVL(A.PATRONAL,0)   -- VALOR_NETO
									,NVL(A.PATRONAL,0)   -- VALOR_BRUTO																			
									,SUBSTR(A.DESCRIPCION,1,30)
									,NVL(A.SITUACION_FONDOS,'N')
									,A.ID
									,A.COTE_ID
									,A.TIPO_COMPROMISO
									,A.NUMERO_COMPROMISO
									,A.FORMA_PAGO
									,A.BANCO
									,A.NUMERO_CUENTA
									,A.CLASE
									,A.NIVEL
									,A.INTERNO_NIVEL														
									,A.CODIGO_CENTRO_COSTOS
									,UN_FECHA_RADICACION
									,'1.'							
									);
							-- LOS APORTES NORMALES							
							ELSE  
		
								PR_INSERTA_EGRESOS 		(UN_UNIDAD_EJECUTORA               
									,UN_VIGENCIA                       
									,UN_CONSECUTIVO
									,UN_ENTIDAD                        
									,'R'          -- ESTADO RADICADO
									,NVL(A.EMPLEADO,0) + NVL(A.PATRONAL,0) - NVL(A.INCAPACIDAD,0) - NVL(A.SALDO,0) -- VALOR_NETO
									,NVL(A.PATRONAL,0) - NVL(A.INCAPACIDAD,0) - NVL(A.SALDO,0)  -- VALOR_BRUTO																			
									,SUBSTR(A.DESCRIPCION,1,30)
									,NVL(A.SITUACION_FONDOS,'N')
									,A.ID
									,A.COTE_ID
									,A.TIPO_COMPROMISO
									,A.NUMERO_COMPROMISO
									,A.FORMA_PAGO
									,A.BANCO
									,A.NUMERO_CUENTA
									,A.CLASE
									,A.NIVEL
									,A.INTERNO_NIVEL						
									,A.CODIGO_CENTRO_COSTOS															
									,UN_FECHA_RADICACION
									,'2.'
									); 						
							END IF;
						END LOOP;				
					
						-- GENERA EGRESOS POR APORTES PATRONALES CESANTIAS
						FOR CE IN MI_CUR_APORTES_CESANTIAS_ABONO(MI_TIPO_RA      
																					 ,MI_MES          
																					 ,MI_FECHA_DESDE  )  LOOP																					 	
							-- LOS APORTES PATRONALES QUE TUVIERON DESCUENTO DE EMPLEADO																			 	
								PR_INSERTA_EGRESOS 		(UN_UNIDAD_EJECUTORA               
									,UN_VIGENCIA                       
									,UN_CONSECUTIVO
									,UN_ENTIDAD                        
									,'R'          -- ESTADO RADICADO
									,NVL(CE.EMPLEADO,0) + NVL(CE.PATRONAL,0) - NVL(CE.INCAPACIDAD,0) - NVL(CE.SALDO,0) -- VALOR_NETO
									,NVL(CE.PATRONAL,0) - NVL(CE.INCAPACIDAD,0) - NVL(CE.SALDO,0)  -- VALOR_BRUTO																			
									,SUBSTR(CE.DESCRIPCION,1,30)
									,NVL(CE.SITUACION_FONDOS,'N')
									,UN_ID_ENTIDAD
									,CE.COTE_ID
									,CE.TIPO_COMPROMISO
									,CE.NUMERO_COMPROMISO
									,'M'   -- MODEM DAVIVIENDA
									,MI_BANCO							
									,NULL
									,NULL
									,CE.NIVEL
									,CE.INTERNO_NIVEL														
									,CE.CODIGO_CENTRO_COSTOS							
									,UN_FECHA_RADICACION
									,'2 '
									); 						
							END LOOP;
																					 
						FOR CNE IN MI_CUR_APORTES_CESANTIAS_NOABO(MI_TIPO_RA      
																					 ,MI_MES          
																					 ,MI_FECHA_DESDE  )  LOOP																					 	
							-- LOS APORTES PATRONALES QUE TUVIERON DESCUENTO DE EMPLEADO																			 	
		
								PR_INSERTA_EGRESOS 		(UN_UNIDAD_EJECUTORA               
									,UN_VIGENCIA                       
									,UN_CONSECUTIVO
									,UN_ENTIDAD                        
									,'R'          -- ESTADO RADICADO
									,NVL(CNE.EMPLEADO,0) + NVL(CNE.PATRONAL,0) - NVL(CNE.INCAPACIDAD,0) - NVL(CNE.SALDO,0) -- VALOR_NETO
									,NVL(CNE.PATRONAL,0) - NVL(CNE.INCAPACIDAD,0) - NVL(CNE.SALDO,0)  -- VALOR_BRUTO																			
									,SUBSTR(CNE.DESCRIPCION,1,30)
									,NVL(CNE.SITUACION_FONDOS,'N')
									,CNE.ID
									,CNE.COTE_ID
									,CNE.TIPO_COMPROMISO
									,CNE.NUMERO_COMPROMISO
									,CNE.FORMA_PAGO
									,CNE.BANCO				
									,CNE.NUMERO_CUENTA							
									,CNE.CLASE
									,CNE.NIVEL
									,CNE.INTERNO_NIVEL														
									,CNE.CODIGO_CENTRO_COSTOS							
									,UN_FECHA_RADICACION
									,'8 '
									); 												
							END LOOP;
					
					-- POR CONCEPTOS DE NOMINA
					ELSE  
		
					  -- GENERA EGRESOS DE EMBARGOS		
						FOR E IN MI_CUR_EMBARGOS_EGRESOS(MI_TIPO_RA      
																		 ,MI_MES          
																		 ,MI_FECHA_DESDE  )  LOOP					
								PR_INSERTA_EGRESOS 		(UN_UNIDAD_EJECUTORA               
									,UN_VIGENCIA                       
									,UN_CONSECUTIVO
									,UN_ENTIDAD                        
									,'R'            -- ESTADO RADICADO
									,NVL(E.VALOR,0) -- VALOR_NETO
									,NVL(E.VALOR,0) -- VALOR_BRUTO																			
									,SUBSTR(E.DESCRIPCION,1,30)
									,NVL(E.SITUACION_FONDOS,'N')
									,E.ID
									,E.COTE_ID
									,E.TIPO_COMPROMISO
									,E.NUMERO_COMPROMISO
									,E.FORMA_PAGO
									,E.BANCO
									,E.NUMERO_CUENTA
									,E.CLASE
									,E.NIVEL
									,E.INTERNO_NIVEL														
									,E.CODIGO_CENTRO_COSTOS							
									,UN_FECHA_RADICACION
									,'3.'
									); 						
						 END LOOP;		
																		 
						-- GENERAR EL INGRESO DE RETENCION
						FOR E IN MI_CUR_RETENCION(MI_TIPO_RA      
																		 ,MI_MES          
																		 ,MI_FECHA_DESDE  )  LOOP					
							MI_TOTAL_EMBARGOS := MI_TOTAL_EMBARGOS + E.VALOR;																					 	
		
							-- INGRESOS
							PR_INSERTA_INGRESOS (UN_UNIDAD_EJECUTORA      
																	,UN_VIGENCIA            
																	,UN_CONSECUTIVO					
																	,E.VALOR      					
																	,UN_ENTIDAD             
																	,E.ID									
																	,E.COTE_ID							
																	,'7.'
																	);
		          
		        END LOOP;
		
		        -- EGRESOS POR OTROS CONCEPTOS QUE NO SEAN DESCUENTOS, EMBARGOS NI NETO NOMINA
		        FOR O IN MI_CUR_OTROS_NOMINA_EGRESOS(MI_TIPO_RA      
																		 ,MI_MES          
																		 ,MI_FECHA_DESDE  )  LOOP					
								PR_INSERTA_EGRESOS 		(UN_UNIDAD_EJECUTORA               
									,UN_VIGENCIA                       
									,UN_CONSECUTIVO
									,UN_ENTIDAD                        
									,'R'          -- ESTADO RADICADO
									,NVL(O.VALOR,0) -- VALOR_NETO
									,NVL(O.VALOR,0) -- VALOR_BRUTO																			
									,SUBSTR(O.DESCRIPCION,1,30)
									,NVL(O.SITUACION_FONDOS,'N')
									,O.ID
									,O.COTE_ID
									,O.TIPO_COMPROMISO
									,O.NUMERO_COMPROMISO
									,O.FORMA_PAGO
									,O.BANCO
									,O.NUMERO_CUENTA
									,O.CLASE
									,O.NIVEL
									,O.INTERNO_NIVEL														
								  ,O.CODIGO_CENTRO_COSTOS
								  ,UN_FECHA_RADICACION
									,'4.'
									); 						
									-- INGRESOS
									PR_INSERTA_INGRESOS (UN_UNIDAD_EJECUTORA      
																	,UN_VIGENCIA            
																	,UN_CONSECUTIVO					
																	,O.VALOR      					
																	,UN_ENTIDAD             
																	,O.ID									
																	,O.COTE_ID							
																	,'4.'
																	);
									
						 END LOOP;		
		
		        -- EGRESOS POR PAGOS SIN GIRO
		        FOR O IN MI_CUR_PAGOS_SIN_GIRO(MI_TIPO_RA      
																		 ,MI_MES          
																		 ,MI_FECHA_DESDE  )  LOOP					
								PR_INSERTA_EGRESOS 		(UN_UNIDAD_EJECUTORA               
									,UN_VIGENCIA                       
									,UN_CONSECUTIVO
									,UN_ENTIDAD                        
									,'R'          -- RADICADO
									,NVL(O.VALOR,0) -- VALOR_NETO
									,NVL(O.VALOR,0) -- VALOR_BRUTO																			
									,SUBSTR(O.DESCRIPCION,1,30)
									,'N' -- PARA QUE NO GENERE PAGO
									,UN_ID_ENTIDAD
									,O.COTE_ID
									,O.TIPO_COMPROMISO
									,O.NUMERO_COMPROMISO
									,NULL
									,NULL
									,NULL
									,NULL
									,O.NIVEL
									,O.INTERNO_NIVEL														
								  ,O.CODIGO_CENTRO_COSTOS
								  ,UN_FECHA_RADICACION
									,'9.'
									); 						
						 END LOOP;		
		
		        -- EGRESOS POR OTROS CONCEPTOS QUE SEAN DESCUENTOS
		        FOR T IN MI_CUR_SALDO(MI_TIPO_RA      
																		 ,MI_MES          
																		 ,MI_FECHA_DESDE  )  LOOP					
		
		
							MI_TOTAL_DESCUENTOS := MI_TOTAL_DESCUENTOS + T.VALOR;
		
		          MI_SALDO_TEMPORALES := OGT_PK_RA.FN_SALDO_TEMPORALES(UN_UNIDAD_EJECUTORA      
																					,UN_VIGENCIA           
																					,UN_CONSECUTIVO				
																					,UN_ENTIDAD           
																					,T.ID					
																					,T.COTE_ID			
																					);					
		
							PR_INSERTA_EGRESOS 		(UN_UNIDAD_EJECUTORA               
								,UN_VIGENCIA                       
								,UN_CONSECUTIVO
								,UN_ENTIDAD                        
								,'B'          -- ESTADO TEMPORAL
								,NVL(T.VALOR,0) -- VALOR_NETO  
								,NVL(T.VALOR,0) + MI_SALDO_TEMPORALES + MI_TOTAL_DESCUENTOS -- VALOR_BRUTO  
								,SUBSTR(T.DESCRIPCION,1,30)
								,NVL(T.SITUACION_FONDOS,'N')
								,T.ID
								,T.COTE_ID
								,T.TIPO_COMPROMISO
								,T.NUMERO_COMPROMISO
								,T.FORMA_PAGO
								,T.BANCO
								,T.NUMERO_CUENTA
								,T.CLASE
								,T.NIVEL
								,T.INTERNO_NIVEL														
								,T.CODIGO_CENTRO_COSTOS						
								,UN_FECHA_RADICACION
								,'5.'
								); 						
						 END LOOP;		
		
						FOR N IN MI_CUR_NETO_ABONO(MI_TIPO_RA      
																		 ,MI_MES          
																		 ,MI_FECHA_DESDE  )  LOOP					
								IF MI_BANCO IS NOT NULL THEN										 	
										PR_INSERTA_EGRESOS 		(UN_UNIDAD_EJECUTORA               
											,UN_VIGENCIA                       
											,UN_CONSECUTIVO
											,UN_ENTIDAD                        
											,'R'          -- ESTADO RADICADO
											,NVL(N.VALOR,0) -- VALOR_NETO
											,NVL(N.VALOR,0) + NVL(MI_TOTAL_DESCUENTOS,0) -- VALOR_BRUTO = TODA LA NOMINA Y TODOS LOS DESCUENTOS
											,SUBSTR(N.DESCRIPCION,1,30)
											,NVL(N.SITUACION_FONDOS,'N')
											,UN_ID_ENTIDAD
											,N.COTE_ID
											,N.TIPO_COMPROMISO
											,N.NUMERO_COMPROMISO
											,'M' -- MODEM POR DAVIVIENDA
											,MI_BANCO							
											,NULL
											,NULL
											,N.NIVEL
											,N.INTERNO_NIVEL														
											,N.CODIGO_CENTRO_COSTOS							
											,UN_FECHA_RADICACION
											,'6.'
											); 						
								END IF;
						 END LOOP;		
		
						--LOS GIROS DE NOMINA QUE SON PARA OTRO BANCO
						FOR N IN MI_CUR_OTRO_NETO_ABONO(MI_TIPO_RA      
																		 ,MI_MES          
																		 ,MI_FECHA_DESDE  )  LOOP					
								IF MI_BANCO IS NOT NULL THEN										 	
										PR_INSERTA_EGRESOS 		(UN_UNIDAD_EJECUTORA               
											,UN_VIGENCIA                       
											,UN_CONSECUTIVO
											,UN_ENTIDAD                        
											,'R'          -- ESTADO RADICADO
											,NVL(N.VALOR,0) -- VALOR_NETO
											,NVL(N.VALOR,0) + NVL(MI_TOTAL_DESCUENTOS,0) -- VALOR_BRUTO = TODA LA NOMINA Y TODOS LOS DESCUENTOS
											,SUBSTR(N.DESCRIPCION,1,30)
											,NVL(N.SITUACION_FONDOS,'N')
											,N.ID
											,N.COTE_ID
											,N.TIPO_COMPROMISO
											,N.NUMERO_COMPROMISO
											,N.FORMA_PAGO
											,N.BANCO
											,N.NUMERO_CUENTA
											,N.CLASE
											,N.NIVEL
											,N.INTERNO_NIVEL														
											,N.CODIGO_CENTRO_COSTOS							
											,UN_FECHA_RADICACION
											,'6.'
											); 						
								END IF;
						 END LOOP;		
		
						FOR N IN MI_CUR_NETO_NO_ABONO(MI_TIPO_RA      
																		 ,MI_MES          
																		 ,MI_FECHA_DESDE  )  LOOP					
								PR_INSERTA_EGRESOS 		(UN_UNIDAD_EJECUTORA               
									,UN_VIGENCIA                       
									,UN_CONSECUTIVO
									,UN_ENTIDAD                        
									,'R'          -- ESTADO RADICADO
									,NVL(N.VALOR,0) -- VALOR_NETO
									,0               -- VA EN CERO PARA NO ALTERAR EL ESTADO DE TESORERIA
									,SUBSTR(N.DESCRIPCION,1,30)
									,NVL(N.SITUACION_FONDOS,'N')
									,N.ID
									,N.COTE_ID
									,N.TIPO_COMPROMISO
									,N.NUMERO_COMPROMISO
									,N.FORMA_PAGO
									,NULL
									,NULL
									,NULL
									,N.NIVEL
									,N.INTERNO_NIVEL														
									,N.CODIGO_CENTRO_COSTOS							
									,UN_FECHA_RADICACION
									,'7.'
									); 						
						 END LOOP;		
					END IF;				
			-- MANEJO DE ENDOSOS			
			-- FMD 06-02-2004
			ELSE
				OPEN MI_CUR_ENDOSO;
				FETCH MI_CUR_ENDOSO INTO
						MI_ID_PAGAR_A             
				,MI_FORMA_PAGO             
				,MI_BANCO                  
				,MI_TIPO_CUENTA            
				,MI_CUENTA				
				,MI_DESCRIPCION
				,MI_SITUACION_FONDOS
				,MI_TIPO_COMPROMISO
				,MI_NUMERO_COMPROMISO;
				CLOSE MI_CUR_ENDOSO;
				FOR N IN MI_CUR_EGRESOS_ENDOSO LOOP
								PR_INSERTA_EGRESOS 		(UN_UNIDAD_EJECUTORA               
									,UN_VIGENCIA                       
									,UN_CONSECUTIVO
									,UN_ENTIDAD                        
									,'R'          -- ESTADO RADICADO
									,NVL(N.VALOR,0) -- VALOR_NETO
									,0               -- VA EN CERO PARA NO ALTERAR EL ESTADO DE TESORERIA
									,SUBSTR(MI_DESCRIPCION,1,30)
									,NVL(MI_SITUACION_FONDOS,'N')
									,MI_ID_PAGAR_A
									,N.COTE_ID
									,MI_TIPO_COMPROMISO
									,MI_NUMERO_COMPROMISO
									,MI_FORMA_PAGO
									,NULL
									,NULL
									,NULL
									,N.NIVEL
									,N.INTERNO_NIVEL														
									,N.CC							
									,UN_FECHA_RADICACION
									,'8.'
									); 						
				END LOOP;
			END IF;
			-- FMD 5-11-2003
			-- LLAMADO AL METODO DE TRASLADO DE CONCEPTOS PARA RA SSF
			IF NVL(MI_SITUACION_FONDOS,'1') = '0' 
			OR NVL(MI_SITUACION_FONDOS,'S') = 'N' THEN  -- 1 CON SITUACION DE FONDOS DIFERENTE SIN SITUACION DE FONDOS
					MI_ESTADO_TRASLADO := TRUE;
					MI_ESTADO_LEGALIZACION := TRUE;
					MI_RESULTADO_TRASLADO := OGT_PK_TRASLADO_CONCEPTOS.OGT_FN_TRASLADAR_CONCEPTO_DOC
									(8 -- CODIGO QUE DEBE EXISTIR EN BINTABLAS Y PARAMETRIZADO EN LAS TABLAS DE TRANSLADO DE FONDOS
									,NVL(UN_FECHA_RADICACION,SYSDATE)
									,OGT_PK_TRASLADO_CONCEPTOS.OGT_FN_CUR_DET_TRASLADO 
									      (NULL,  -- LA SESION VA NULA
									       UN_VIGENCIA,
									       UN_UNIDAD_EJECUTORA,
									       UN_TIPO_DOCUMENTO,
									       UN_ENTIDAD,
									       UN_CONSECUTIVO,
									       MI_ESTADO_LEGALIZACION,
									       MI_MENSAJE_LEGALIZACION)
									,UN_TIPO_DOCUMENTO
									,UN_CONSECUTIVO
									,UN_VIGENCIA
									,UN_ENTIDAD
									,UN_UNIDAD_EJECUTORA
									,MI_TAB_AFCTCIONES
									,MI_ESTADO_TRASLADO
									,MI_MENSAJE_TRASLADO
									);
					IF NOT MI_ESTADO_TRASLADO THEN
						UN_CODIGO := MI_MENSAJE_TRASLADO;
						PR_DESPLIEGA_MENSAJE('AL_STOP_1','Se presento este error trasladando conceptos '||MI_MENSAJE_TRASLADO);
						FORMS_DDL('ROLLBACK COMIENZO');	
					ELSE
  					UN_CODIGO := 'OK';						
					END IF;
			END IF;
		END;
  EXCEPTION
		WHEN OTHERS THEN
			PR_DESPLIEGA_MENSAJE('AL_STOP_1','Se presento este error creando egresos RA '||sqlerrm);
 	    UN_CODIGO := SQLERRM;			
			FORMS_DDL('ROLLBACK COMIENZO');
			--RAISE FORM_TRIGGER_FAILURE;
	END PR_CREA_EGRESOS_RA;	     	        	 	  

/***************************************************************************/  
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   DEFINE LA FUNCION QUE RETORNA EL SALDO POR PAGAR DADA UNA ENTIDAD
  --             POR UN TERCERO POR CONCEPTO DE RA DE APORTES PATRONALES
  --             DESDE SIEMPRE NO IMPORTAN LOS ESTADOS
  -- PARAMETROS: ENTIDAD, UNIDAD, TIPO_DOCUMENTO, ID
  -- RETORNA EL VALOR DEL SALDO PENDIENTE POR PAGAR  
/***************************************************************************/    
  FUNCTION FN_SALDO_POR_TERCERO_RA(UN_ENTIDAD          OGT_RELACION_AUTORIZACION.ENTIDAD%TYPE
  	        	          ,UN_UNIDAD_EJECUTORA OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA%TYPE
  											,UN_ID               OGT_ANEXO_NOMINA.ID_PAGAR_A%TYPE      	        	      
        	        	 	  ) RETURN NUMBER IS

	UN_CON_TIPO_RA_APORTES     OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE := '2';
	UN_CON_ESTADO_PAGADO       OGT_DETALLE_PAGO.ESTADO%TYPE           := 'P';

  -- GENERA LOS EGRESOS GENERADOS PARA UNA ENTIDAD Y UNA UNIDAD PARA UN TERCERO
	CURSOR MI_CUR_EGRESO IS	
		SELECT ALL 	SUM(NVL(OGT_EGRESO.VALOR,0))  VALOR
		FROM 				OGT_DOCUMENTO_PAGO, 
								OGT_RELACION_AUTORIZACION, 
								OGT_EGRESO
		WHERE (OGT_RELACION_AUTORIZACION.VIGENCIA        = OGT_DOCUMENTO_PAGO.VIGENCIA
 		AND OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA = OGT_DOCUMENTO_PAGO.UNIDAD_EJECUTORA
 		AND OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO   = OGT_DOCUMENTO_PAGO.TIPO_DOCUMENTO
 		AND OGT_RELACION_AUTORIZACION.ENTIDAD          = OGT_DOCUMENTO_PAGO.ENTIDAD
 		AND OGT_RELACION_AUTORIZACION.CONSECUTIVO      = OGT_DOCUMENTO_PAGO.CONSECUTIVO)
 		AND (OGT_EGRESO.VIGENCIA                       = OGT_DOCUMENTO_PAGO.VIGENCIA
 		AND OGT_EGRESO.UNIDAD_EJECUTORA                = OGT_DOCUMENTO_PAGO.UNIDAD_EJECUTORA
 		AND OGT_EGRESO.TIPO_DOCUMENTO                  = OGT_DOCUMENTO_PAGO.TIPO_DOCUMENTO
 		AND OGT_EGRESO.ENTIDAD                         = OGT_DOCUMENTO_PAGO.ENTIDAD
 		AND OGT_EGRESO.CONSECUTIVO                     = OGT_DOCUMENTO_PAGO.CONSECUTIVO)
 		AND OGT_DOCUMENTO_PAGO.ENTIDAD                 = UN_ENTIDAD
		AND OGT_DOCUMENTO_PAGO.UNIDAD_EJECUTORA        = UN_UNIDAD_EJECUTORA
		AND OGT_RELACION_AUTORIZACION.TIPO_RA          = UN_CON_TIPO_RA_APORTES   -- RA DE APORTES
		AND OGT_EGRESO.TER_ID                          = UN_ID		
		;
		        	        	 	  
  -- GENERA LOS PAGOS GENERADOS PARA UNA ENTIDAD Y UNA UNIDAD PARA UN TERCERO
	CURSOR MI_CUR_DETALLE_PAGO IS	
		SELECT ALL 	SUM(NVL(OGT_DETALLE_PAGO.VALOR,0))  VALOR
		FROM 				OGT_DOCUMENTO_PAGO, 
								OGT_RELACION_AUTORIZACION, 
								OGT_EGRESO, 
								OGT_DETALLE_EGRESO, 	
								OGT_PAGO, 
								OGT_DETALLE_PAGO
		WHERE (OGT_RELACION_AUTORIZACION.VIGENCIA        = OGT_DOCUMENTO_PAGO.VIGENCIA
 		AND OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA = OGT_DOCUMENTO_PAGO.UNIDAD_EJECUTORA
 		AND OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO   = OGT_DOCUMENTO_PAGO.TIPO_DOCUMENTO
 		AND OGT_RELACION_AUTORIZACION.ENTIDAD          = OGT_DOCUMENTO_PAGO.ENTIDAD
 		AND OGT_RELACION_AUTORIZACION.CONSECUTIVO      = OGT_DOCUMENTO_PAGO.CONSECUTIVO)
 		AND (OGT_EGRESO.VIGENCIA                       = OGT_DOCUMENTO_PAGO.VIGENCIA
 		AND OGT_EGRESO.UNIDAD_EJECUTORA                = OGT_DOCUMENTO_PAGO.UNIDAD_EJECUTORA
 		AND OGT_EGRESO.TIPO_DOCUMENTO                  = OGT_DOCUMENTO_PAGO.TIPO_DOCUMENTO
 		AND OGT_EGRESO.ENTIDAD                         = OGT_DOCUMENTO_PAGO.ENTIDAD
 		AND OGT_EGRESO.CONSECUTIVO                     = OGT_DOCUMENTO_PAGO.CONSECUTIVO)
 		AND (OGT_DETALLE_EGRESO.TER_ID                 = OGT_EGRESO.TER_ID
 		AND OGT_DETALLE_EGRESO.CONSECUTIVO             = OGT_EGRESO.CONSECUTIVO
 		AND OGT_DETALLE_EGRESO.ENTIDAD                 = OGT_EGRESO.ENTIDAD
 		AND OGT_DETALLE_EGRESO.TIPO_DOCUMENTO          = OGT_EGRESO.TIPO_DOCUMENTO
 		AND OGT_DETALLE_EGRESO.UNIDAD_EJECUTORA        = OGT_EGRESO.UNIDAD_EJECUTORA
 		AND OGT_DETALLE_EGRESO.VIGENCIA                = OGT_EGRESO.VIGENCIA)
 		AND (OGT_DETALLE_EGRESO.ID_PAGO                = OGT_PAGO.ID_PAGO)
 		AND (OGT_DETALLE_PAGO.ID_PAGO                  = OGT_PAGO.ID_PAGO)
 		AND OGT_DOCUMENTO_PAGO.ENTIDAD                 = UN_ENTIDAD
		AND OGT_DOCUMENTO_PAGO.UNIDAD_EJECUTORA        = UN_UNIDAD_EJECUTORA
		AND OGT_RELACION_AUTORIZACION.TIPO_RA          = UN_CON_TIPO_RA_APORTES   -- RA DE APORTES
		AND OGT_EGRESO.TER_ID                          = UN_ID		
		AND OGT_DETALLE_PAGO.ESTADO                    = UN_CON_ESTADO_PAGADO   -- PAGADO
		;

	MI_EGRESO         NUMBER;
	MI_DETALLE_PAGO  NUMBER;
  BEGIN  	
  	OPEN MI_CUR_EGRESO;
  	OPEN MI_CUR_DETALLE_PAGO;
  	FETCH MI_CUR_EGRESO INTO MI_EGRESO;
  	FETCH MI_CUR_DETALLE_PAGO INTO MI_DETALLE_PAGO;  	
  	IF MI_CUR_EGRESO%ISOPEN THEN
  		CLOSE MI_CUR_EGRESO;
  	END IF;
  	IF MI_CUR_DETALLE_PAGO%ISOPEN THEN
  		CLOSE MI_CUR_DETALLE_PAGO;
  	END IF;
  	
  	-- RETORNA LA DIFERENCIA ENTRE LOS EGRESOS Y LO PAGADO
  	RETURN(NVL(MI_EGRESO,0) - NVL(MI_DETALLE_PAGO,0));  	
  EXCEPTION 
  	WHEN OTHERS THEN  	
	  	IF MI_CUR_EGRESO%ISOPEN THEN
	  		CLOSE MI_CUR_EGRESO;
	  	END IF;
	  	IF MI_CUR_DETALLE_PAGO%ISOPEN THEN
	  		CLOSE MI_CUR_DETALLE_PAGO;
	  	END IF;
  		RETURN(0);  		
  END FN_SALDO_POR_TERCERO_RA;	        	        	 	  
  
/***************************************************************************/  
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   EVALUAR QUE NO EXISTA EL MISMO TERCERO EN LA MISMA RA  
  --             PARA QUE NO FALLE LA CREACION DE EGRESOS
  -- PARAMETROS: ENTIDAD, UNIDAD, VIGENCIA, CONSECUTIVO, TIPO_RA
  -- RETORNA 0 SI NO EXISTEN TERCEROS DUPLICADOS Y 1 SI HAY DUPLICADOS
/***************************************************************************/    
  FUNCTION FN_VALIDA_TERCERO_RA(UN_ENTIDAD   OGT_RELACION_AUTORIZACION.ENTIDAD%TYPE
  	        	          ,UN_UNIDAD_EJECUTORA OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA%TYPE
  	        	          ,UN_VIGENCIA         OGT_RELACION_AUTORIZACION.VIGENCIA%TYPE
  	        	          ,UN_CONSECUTIVO      OGT_RELACION_AUTORIZACION.CONSECUTIVO%TYPE
  											,UN_TIPO_RA          OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE      	        	      
        	        	 	  )RETURN NUMBER IS 
    MI_CUANTOS               NUMBER;
    -- RETORNA DATOS BASICOS DE LA RA
    CURSOR MI_CUR_RA IS
      SELECT DISTINCT
      			 OGT_CENTRO_COSTOS.FECHA_DESDE           FECHA_DESDE
            ,OGT_CENTRO_COSTOS.MES                   MES
      FROM   OGT_CENTRO_COSTOS
      WHERE  OGT_CENTRO_COSTOS.ENTIDAD              = UN_ENTIDAD
      AND    OGT_CENTRO_COSTOS.CONSECUTIVO          = UN_CONSECUTIVO
      AND    OGT_CENTRO_COSTOS.TIPO_RA              = UN_TIPO_RA
      AND    OGT_CENTRO_COSTOS.TIPO_DOCUMENTO       = MI_CON_TIPO_DOCUMENTO
      AND    OGT_CENTRO_COSTOS.UNIDAD_EJECUTORA     = UN_UNIDAD_EJECUTORA
      AND    OGT_CENTRO_COSTOS.VIGENCIA             = UN_VIGENCIA
      ;
    -- RETORNA CODIGO DE CENTRO DE COSTOS Y ID CON MAS DE UNA OCURRENCIA
    -- PARA RA DE NOMINA
    CURSOR MI_CUR_NOMINA_REPETIDOS(UN_FECHA_DESDE   DATE
                                  ,UN_MES           VARCHAR2) IS
  		SELECT DISTINCT
 					 OGT_ANEXO_NOMINA.CODIGO_CENTRO_COSTOS CC
 					,OGT_ANEXO_NOMINA.ID_PAGAR_A					 ID_PAGAR_A
  		FROM   OGT_ANEXO_NOMINA
			WHERE  OGT_ANEXO_NOMINA.TIPO_DOCUMENTO       	= MI_CON_TIPO_DOCUMENTO
			AND    OGT_ANEXO_NOMINA.UNIDAD_EJECUTORA     	= UN_UNIDAD_EJECUTORA
			AND    OGT_ANEXO_NOMINA.ENTIDAD 							= UN_ENTIDAD
			AND    OGT_ANEXO_NOMINA.VIGENCIA 							= UN_VIGENCIA
			AND    OGT_ANEXO_NOMINA.FECHA_DESDE 					= UN_FECHA_DESDE
			AND    OGT_ANEXO_NOMINA.CONSECUTIVO 					= UN_CONSECUTIVO
			AND    OGT_ANEXO_NOMINA.TIPO_RA 							= UN_TIPO_RA				
			AND    OGT_ANEXO_NOMINA.MES 									= UN_MES
			HAVING COUNT(ID_PAGAR_A) > 1
			GROUP BY OGT_ANEXO_NOMINA.CODIGO_CENTRO_COSTOS
			,OGT_ANEXO_NOMINA.ID_PAGAR_A
			UNION
			SELECT 
			     OGT_ANEXO_EMBARGO.CODIGO_CENTRO_COSTOS   CC
			    ,OGT_ANEXO_EMBARGO.ID_PAGAR_A					    ID_PAGAR_A
			FROM   OGT_ANEXO_EMBARGO
			WHERE  OGT_ANEXO_EMBARGO.ENTIDAD 							= UN_ENTIDAD
			AND    OGT_ANEXO_EMBARGO.FECHA_DESDE 					= UN_FECHA_DESDE
			AND    OGT_ANEXO_EMBARGO.MES 									= UN_MES
			AND    OGT_ANEXO_EMBARGO.TIPO_RA 							= UN_TIPO_RA
			AND    OGT_ANEXO_EMBARGO.TIPO_DOCUMENTO 			= MI_CON_TIPO_DOCUMENTO
			AND    OGT_ANEXO_EMBARGO.UNIDAD_EJECUTORA 		= UN_UNIDAD_EJECUTORA
			AND    OGT_ANEXO_EMBARGO.CONSECUTIVO 					= UN_CONSECUTIVO
			AND    OGT_ANEXO_EMBARGO.VIGENCIA 						= UN_VIGENCIA
			HAVING COUNT(ID_PAGAR_A) > 1
			GROUP BY OGT_ANEXO_EMBARGO.CODIGO_CENTRO_COSTOS
			,OGT_ANEXO_EMBARGO.ID_PAGAR_A					
			;
    -- RETORNA CODIGO DE CENTRO DE COSTOS Y ID CON MAS DE UNA OCURRENCIA
    -- PARA RA DE APORTES
    CURSOR MI_CUR_APORTES_REPETIDOS(UN_FECHA_DESDE   DATE
                                   ,UN_MES           VARCHAR2) IS
				SELECT OGT_ANEXO_PATRONAL.CODIGO_CENTRO_COSTOS  CC
				      ,OGT_ANEXO_PATRONAL.ID_PAGAR_A            ID_PAGAR_A
				FROM   OGT_ANEXO_PATRONAL
				WHERE  OGT_ANEXO_PATRONAL.ENTIDAD 					= UN_ENTIDAD
				AND		 OGT_ANEXO_PATRONAL.TIPO_RA 					= UN_TIPO_RA
				AND		 OGT_ANEXO_PATRONAL.TIPO_DOCUMENTO 		= MI_CON_TIPO_DOCUMENTO
				AND 	 OGT_ANEXO_PATRONAL.UNIDAD_EJECUTORA 	= UN_UNIDAD_EJECUTORA
				AND 	 OGT_ANEXO_PATRONAL.FECHA_DESDE 			= UN_FECHA_DESDE
				AND 	 OGT_ANEXO_PATRONAL.MES 							= UN_MES
				AND 	 OGT_ANEXO_PATRONAL.VIGENCIA 					= UN_VIGENCIA
				AND 	 OGT_ANEXO_PATRONAL.CONSECUTIVO 			= UN_CONSECUTIVO
				HAVING COUNT(ID_PAGAR_A) > 1
				GROUP BY OGT_ANEXO_PATRONAL.CODIGO_CENTRO_COSTOS
				,OGT_ANEXO_PATRONAL.ID_PAGAR_A
				;   
  MI_CON_NETO_NOMINA     OGT_CONCEPTO_RA.NETO_NOMINA%TYPE   := '0';    
  
  BEGIN
  	FOR A IN MI_CUR_RA LOOP
	  	IF UN_TIPO_RA = 1 THEN -- NOMINA Y EMBARGOS
	  	  FOR B IN MI_CUR_NOMINA_REPETIDOS (A.FECHA_DESDE
	  		                           ,A.MES) LOOP
					BEGIN	  		                           	
		  			SELECT COUNT(*)
		  			INTO   MI_CUANTOS
			  		FROM   OGT_ANEXO_NOMINA
			  		      ,OGT_CONCEPTO_RA
						WHERE  OGT_ANEXO_NOMINA.TIPO_DOCUMENTO       	= MI_CON_TIPO_DOCUMENTO
						AND    OGT_ANEXO_NOMINA.UNIDAD_EJECUTORA     	= UN_UNIDAD_EJECUTORA
						AND    OGT_ANEXO_NOMINA.ENTIDAD 							= UN_ENTIDAD
						AND    OGT_ANEXO_NOMINA.VIGENCIA 							= UN_VIGENCIA
						AND    OGT_ANEXO_NOMINA.FECHA_DESDE 					= A.FECHA_DESDE
						AND    OGT_ANEXO_NOMINA.CONSECUTIVO 					= UN_CONSECUTIVO
						AND    OGT_ANEXO_NOMINA.TIPO_RA 							= UN_TIPO_RA				
						AND    OGT_ANEXO_NOMINA.MES 									= A.MES
						AND    OGT_ANEXO_NOMINA.CODIGO_CENTRO_COSTOS <> B.CC
						AND    OGT_ANEXO_NOMINA.ID_PAGAR_A            = B.ID_PAGAR_A
						AND    OGT_CONCEPTO_RA.CODIGO_CENTRO_COSTOS   = OGT_ANEXO_NOMINA.CODIGO_CENTRO_COSTOS
						AND    OGT_CONCEPTO_RA.NETO_NOMINA            = MI_CON_NETO_NOMINA  -- NO SEA EL NETO DE LA NOMINA
						UNION
						SELECT COUNT(*)
						FROM   OGT_ANEXO_EMBARGO
						WHERE  OGT_ANEXO_EMBARGO.ENTIDAD 							= UN_ENTIDAD
						AND    OGT_ANEXO_EMBARGO.FECHA_DESDE 					= A.FECHA_DESDE
						AND    OGT_ANEXO_EMBARGO.MES 									= A.MES
						AND    OGT_ANEXO_EMBARGO.TIPO_RA 							= UN_TIPO_RA
						AND    OGT_ANEXO_EMBARGO.TIPO_DOCUMENTO 			= MI_CON_TIPO_DOCUMENTO
						AND    OGT_ANEXO_EMBARGO.UNIDAD_EJECUTORA 		= UN_UNIDAD_EJECUTORA
						AND    OGT_ANEXO_EMBARGO.CONSECUTIVO 					= UN_CONSECUTIVO
						AND    OGT_ANEXO_EMBARGO.VIGENCIA 						= UN_VIGENCIA
						AND    OGT_ANEXO_EMBARGO.CODIGO_CENTRO_COSTOS <> B.CC
						AND    OGT_ANEXO_EMBARGO.ID_PAGAR_A           = B.ID_PAGAR_A
						;
						-- EVALUAR QUE EL TERCERO ESTE DUPLICADO
						IF MI_CUANTOS > 1 THEN
							PR_DESPLIEGA_MENSAJE('AL_STOP_1','1. Error: El tercero esta duplicado en la RA en otro centro de costos');
							RAISE FORM_TRIGGER_FAILURE;		 				
						END IF;							
					EXCEPTION 
						WHEN TOO_MANY_ROWS THEN  -- EL TERCERO ESTA DUPLICADO
							PR_DESPLIEGA_MENSAJE('AL_STOP_1','2. Error: El tercero esta duplicado en la RA en otro centro de costos');
							RAISE FORM_TRIGGER_FAILURE;		 				
						WHEN OTHERS THEN
							PR_DESPLIEGA_MENSAJE('AL_STOP_1','1. Error validando tercero '||SQLERRM);
							RAISE FORM_TRIGGER_FAILURE;		 				
					END;
	  		END LOOP;
	  	ELSE -- APORTES	

	  		FOR C IN MI_CUR_APORTES_REPETIDOS (A.FECHA_DESDE
	  		                            ,A.MES) LOOP
					BEGIN
						SELECT COUNT(*)
						INTO   MI_CUANTOS
						FROM   OGT_ANEXO_PATRONAL
						WHERE  OGT_ANEXO_PATRONAL.ENTIDAD 					= UN_ENTIDAD
						AND		 OGT_ANEXO_PATRONAL.TIPO_RA 					= UN_TIPO_RA
						AND		 OGT_ANEXO_PATRONAL.TIPO_DOCUMENTO 		= MI_CON_TIPO_DOCUMENTO
						AND 	 OGT_ANEXO_PATRONAL.UNIDAD_EJECUTORA 	= UN_UNIDAD_EJECUTORA
						AND 	 OGT_ANEXO_PATRONAL.FECHA_DESDE 			= A.FECHA_DESDE
						AND 	 OGT_ANEXO_PATRONAL.MES 							= A.MES
						AND 	 OGT_ANEXO_PATRONAL.VIGENCIA 					= UN_VIGENCIA
						AND 	 OGT_ANEXO_PATRONAL.CONSECUTIVO 			= UN_CONSECUTIVO
						AND    OGT_ANEXO_PATRONAL.CODIGO_CENTRO_COSTOS      <> C.CC
						AND    OGT_ANEXO_PATRONAL.ID_PAGAR_A         = C.ID_PAGAR_A
						;   
					EXCEPTION 
						WHEN OTHERS THEN
							PR_DESPLIEGA_MENSAJE('AL_STOP_1','2. Error validando tercero '||SQLERRM);
							RAISE FORM_TRIGGER_FAILURE;		 				
					END;				
	  		END LOOP;	  			
	  	END IF;
  	END LOOP;	
  	IF MI_CUANTOS <> 0 THEN
	  	RETURN(1);
  	ELSE
  		RETURN(0);
  	END IF;	
  EXCEPTION 
  	WHEN TOO_MANY_ROWS THEN
	  	RETURN(1);
	  	PR_DESPLIEGA_MENSAJE('AL_STOP_1','Error validando terceros, existe un tercero repetido en diferentes CC');
  	WHEN NO_DATA_FOUND THEN
	  	RETURN(1);
	  	PR_DESPLIEGA_MENSAJE('AL_STOP_1','Error validando terceros, no ha diligenciado anexos');
  END FN_VALIDA_TERCERO_RA;      	        	 	          	        	 	    
/****************************************************************************/
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   MUESTRA EL NOMBRE DE UN CONCEPTO 
  -- PARAMETROS: CODIGO_CENTOR DE COSTOS
/****************************************************************************/  
  FUNCTION OGT_FN_DESC_CONCEPTO(UN_TIPO_RA OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE
  												,UN_CODIGO_CENTRO_COSTOS OGT_CONCEPTO_RA.CODIGO_CENTRO_COSTOS%TYPE
  												,UNA_FECHA DATE  -- A QUE FECHA MUESTRA LA DESCRIPCION
  												) 
  												RETURN VARCHAR2 IS
  	MI_NOMBRE   OGT_CONCEPTO_RA.NOMBRE_CENTRO_COSTOS%TYPE := '';
  	MI_CON_CONCEPTO_HOJA    OGT_CONCEPTO_TESORERIA.CONCEPTO_HOJA%TYPE  := 1;
	BEGIN
	  SELECT OGT_CONCEPTO_RA.NOMBRE_CENTRO_COSTOS
	  INTO   MI_NOMBRE
		FROM 	 OGT_CONCEPTO_TESORERIA
					,OGT_CONCEPTO_RA
		WHERE  OGT_CONCEPTO_TESORERIA.ID                 = OGT_CONCEPTO_RA.ID
		AND    OGT_CONCEPTO_RA.TIPO_ANEXO                = UN_TIPO_RA
		AND    OGT_CONCEPTO_TESORERIA.CONCEPTO_HOJA      = MI_CON_CONCEPTO_HOJA
		AND   (OGT_CONCEPTO_TESORERIA.FECHA_FINAL        IS NULL
  		     OR UNA_FECHA BETWEEN OGT_CONCEPTO_TESORERIA.FECHA_INICIAL
    		              AND OGT_CONCEPTO_TESORERIA.FECHA_FINAL
    	  	 )
	  AND    OGT_CONCEPTO_RA.CODIGO_CENTRO_COSTOS      = UN_CODIGO_CENTRO_COSTOS
  	;
  	RETURN(MI_NOMBRE);
	EXCEPTION WHEN NO_DATA_FOUND THEN
		RETURN('NO DEFINIDO');
	WHEN OTHERS THEN
		RETURN ('MUY DEFINIDO');
		RAISE FORM_TRIGGER_FAILURE;
	END OGT_FN_DESC_CONCEPTO;  
	
/****************************************************************************/
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   VALIDA QUE EL PARAMETRO SEA NUMERICO
  -- PARAMETROS: UN VALOR
/****************************************************************************/  
	FUNCTION OGT_FN_VALIDA_NUMERO (UN_NUMERO VARCHAR2)
														RETURN BOOLEAN IS
		MI_NUMERO  NUMBER;
	BEGIN
	  MI_NUMERO := TO_NUMBER(UN_NUMERO);
	  RETURN TRUE;
	EXCEPTION
	  WHEN OTHERS THEN
	    RETURN FALSE;
	END OGT_FN_VALIDA_NUMERO ; 
	
/****************************************************************************/
  -- AUTOR:      FANNY MALAGON
  -- NOMBRE:     OGT_PR_CARGAR_ARCHIVO_APORTES
  -- OBJETIVO:   MUESTRA EL NOMBRE DE UN CONCEPTO 

/****************************************************************************/  
PROCEDURE OGT_PR_CARGAR_ARCHIVO_APORTES (UN_ID_ARCHIVO         TEXT_IO.FILE_TYPE
																					,UN_ID_ERROR        TEXT_IO.FILE_TYPE
  																				,UN_INDICA				  IN OUT NUMBER 
  																				,UN_TPL_AP          IN OUT PK_OGT_BD_CREAR_RA.APTAB
  																				,UN_NUMERO_LINEA    IN OUT NUMBER 
  																				,UN_CODIGO_CC       IN VARCHAR2
																					)	IS
  MI_LINEA        			  VARCHAR2(1800);
BEGIN
	  UN_NUMERO_LINEA := 0;
  	LOOP
 		-- COMIENZA A LEER EL ARCHIVO
		TEXT_IO.GET_LINE(UN_ID_ARCHIVO, MI_LINEA);
		UN_NUMERO_LINEA := UN_NUMERO_LINEA + 1;
		
		-- POBLA EL CODIGO DEL CC
		UN_TPL_AP(UN_NUMERO_LINEA).MI_CODIGO_CENTRO_COSTOS := UN_CODIGO_CC;

		-- LEE EL APORTE PATRONAL
		UN_TPL_AP(UN_NUMERO_LINEA).MI_APORTE_PATRONAL := SUBSTR(MI_LINEA
																		,1
																		,INSTR(MI_LINEA,';',1,1) - 1); -- 	NOT NULL	NUMBER(16,2)

		-- LEE EL APORTE DEL EMPLEADO
		UN_TPL_AP(UN_NUMERO_LINEA).MI_APORTE_EMPLEADO := SUBSTR(MI_LINEA
																			,INSTR(MI_LINEA,';',1,1) + 1
																			,INSTR(MI_LINEA,';',1,2) - INSTR(MI_LINEA,';',1,1) - 1
																			);-- 	NOT NULL	NUMBER(16,2)

		-- LEE EL TIPO DE IDENTIFICACION
		UN_TPL_AP(UN_NUMERO_LINEA).MI_TIPO_PAGAR_A := SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,2) + 1
																		,INSTR(MI_LINEA,';',1,3) - INSTR(MI_LINEA,';',1,2) - 1
																		); -- 	NOT NULL 	VARCHAR2(30)
		
    -- LEE EL NUMERO DEL DOCUMENTO DEL TERCERO AL QUE SE VA A GIRAR
		UN_TPL_AP(UN_NUMERO_LINEA).MI_NRO_PAGAR_A	:= SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,3) + 1
																		,INSTR(MI_LINEA,';',1,4) - INSTR(MI_LINEA,';',1,3) - 1
																		);-- 	NOT NULL	VARCHAR2(20)

		-- LEE LA FORMA DE PAGO																
		UN_TPL_AP(UN_NUMERO_LINEA).MI_FORMA_PAGO := SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,4) + 1
																		,INSTR(MI_LINEA,';',1,5) - INSTR(MI_LINEA,';',1,4) - 1
																		); -- 	NOT NULL	VARCHAR2(15)

		-- LEE LA SUCURSAL																
		UN_TPL_AP(UN_NUMERO_LINEA).MI_SUCURSAL := SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,5) + 1
																		,INSTR(MI_LINEA,';',1,6) - INSTR(MI_LINEA,';',1,5) - 1
																		); -- 	VARCHAR2(30)
																		
		-- LEE EL BANCO
		UN_TPL_AP(UN_NUMERO_LINEA).MI_BANCO := SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,6) + 1
																		,INSTR(MI_LINEA,';',1,7) - INSTR(MI_LINEA,';',1,6) - 1
																		); -- 	NUMBER(20)
																		
		-- LEE EL TIPO CUENTA
		UN_TPL_AP(UN_NUMERO_LINEA).MI_TIPO_CUENTA := SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,7) + 1
																		,INSTR(MI_LINEA,';',1,8) - INSTR(MI_LINEA,';',1,7) - 1
																		); -- 	VARCHAR2(30)
		
		-- LEE EL NUMERO DE CUENTA																		
		UN_TPL_AP(UN_NUMERO_LINEA).MI_NUMERO_CUENTA := SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,8) + 1
																		,INSTR(MI_LINEA,';',1,9) - INSTR(MI_LINEA,';',1,8) - 1
																		); -- 		VARCHAR2(30)

		-- LEE EL SALDO
		UN_TPL_AP(UN_NUMERO_LINEA).MI_SALDO := SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,9) + 1
																		,INSTR(MI_LINEA,';',1,10) - INSTR(MI_LINEA,';',1,9) - 1
																		); -- 	NUMBER(16,2)
		
		-- LEE LA INCAPACIDAD
		UN_TPL_AP(UN_NUMERO_LINEA).MI_INCAPACIDAD := SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,10) + 1
																		,INSTR(MI_LINEA,';',1,11) - INSTR(MI_LINEA,';',1,10) - 1
																		); -- 	NUMBER(16,2)   	

		-- LEE EL TIPO DE IDENTIFICACION
		UN_TPL_AP(UN_NUMERO_LINEA).MI_TIPO_ID := SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,11) + 1
																		,INSTR(MI_LINEA,';',1,12) - INSTR(MI_LINEA,';',1,11) - 1
																		); -- 	NOT NULL 	VARCHAR2(30)
		
    -- LEE EL NUMERO DEL DOCUMENTO DEL TERCERO AL QUE SE VA A GIRAR
		UN_TPL_AP(UN_NUMERO_LINEA).MI_NRO_ID	:= SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,12) + 1
--																		,INSTR(MI_LINEA,';',1,13) - INSTR(MI_LINEA,';',1,12) - 1
																		);-- 	NOT NULL	VARCHAR2(20)

  END LOOP;	  
  	UN_INDICA := 0;
  EXCEPTION
		WHEN NO_DATA_FOUND THEN
	  	UN_INDICA := 0;			
  	WHEN OTHERS THEN
  	  UN_INDICA := 1;
  	  PR_DESPLIEGA_MENSAJE('AL_STOP_1','Error cargando plano aportes '||SQLERRM);
		  RAISE FORM_TRIGGER_FAILURE;
END OGT_PR_CARGAR_ARCHIVO_APORTES;

/****************************************************************************/
  -- AUTOR:      FANNY MALAGON
  -- NOMBRE:     OGT_PR_CARGAR_ARCHIVO_NOMINA
  -- OBJETIVO:   MUESTRA EL NOMBRE DE UN CONCEPTO 

/****************************************************************************/  
PROCEDURE OGT_PR_CARGAR_ARCHIVO_NOMINA (UN_ID_ARCHIVO         TEXT_IO.FILE_TYPE
																					,UN_ID_ERROR        TEXT_IO.FILE_TYPE
  																				,UN_INDICA				  IN OUT NUMBER 
  																				,UN_TPL_AN          IN OUT PK_OGT_BD_CREAR_RA.ANTAB
  																				,UN_NUMERO_LINEA    IN OUT NUMBER 
  																				,UN_CODIGO_CC       IN VARCHAR2
  																				)	IS
  MI_LINEA        			  VARCHAR2(1800);
BEGIN
	  UN_NUMERO_LINEA := 0;
	 	LOOP 			 		 
		 		-- COMIENZA A LEER EL ARCHIVO
				TEXT_IO.GET_LINE(UN_ID_ARCHIVO, MI_LINEA);
				UN_NUMERO_LINEA := UN_NUMERO_LINEA + 1;
				-- POBLA EL CODIGO DEL CC
				UN_TPL_AN(UN_NUMERO_LINEA).MI_CODIGO_CENTRO_COSTOS := UN_CODIGO_CC;
				--APORTE EMPLEADO
				UN_TPL_AN(UN_NUMERO_LINEA).MI_APORTE_EMPLEADO := SUBSTR(MI_LINEA,1,INSTR(MI_LINEA,';',1,1) - 1); 
        -- LEE EL TIPO DE DIENTIFICACION
				UN_TPL_AN(UN_NUMERO_LINEA).MI_TIPO_PAGAR_A := SUBSTR(MI_LINEA
																				,INSTR(MI_LINEA,';',1,1) + 1
																				,INSTR(MI_LINEA,';',1,2) - INSTR(MI_LINEA,';',1,1) - 1
																				);  --  NOT NULL 	VARCHAR2(30)
				-- LEE EL NUMERO DEL DOCUMENTO
				UN_TPL_AN(UN_NUMERO_LINEA).MI_NRO_PAGAR_A	:= SUBSTR(MI_LINEA
																			,INSTR(MI_LINEA,';',1,2) + 1
																			,INSTR(MI_LINEA,';',1,3) - INSTR(MI_LINEA,';',1,2) - 1
																			); --  NOT NULL	VARCHAR2(20)

				-- LEE LA FORMA DE PAGO
				UN_TPL_AN(UN_NUMERO_LINEA).MI_FORMA_PAGO := SUBSTR(MI_LINEA
																,INSTR(MI_LINEA,';',1,3) + 1
																,INSTR(MI_LINEA,';',1,4) - INSTR(MI_LINEA,';',1,3) - 1
																);  -- NOT NULL	VARCHAR2(15)
				-- LEE LA SUCURSAL
	  	  UN_TPL_AN(UN_NUMERO_LINEA).MI_SUCURSAL := SUBSTR(MI_LINEA
														,INSTR(MI_LINEA,';',1,4) + 1
														,INSTR(MI_LINEA,';',1,5) - INSTR(MI_LINEA,';',1,4) - 1
														); --	VARCHAR2(30)
	      --LEE EL BANCO
				UN_TPL_AN(UN_NUMERO_LINEA).MI_BANCO := SUBSTR(MI_LINEA
														,INSTR(MI_LINEA,';',1,5) + 1
														,INSTR(MI_LINEA,';',1,6) - INSTR(MI_LINEA,';',1,5) - 1
														);  --	NUMBER(20)
			  -- LEE EL TIPO DE CUENTA
				UN_TPL_AN(UN_NUMERO_LINEA).MI_TIPO_CUENTA := SUBSTR(MI_LINEA
																,INSTR(MI_LINEA,';',1,6) + 1
																,INSTR(MI_LINEA,';',1,7) - INSTR(MI_LINEA,';',1,6) - 1
																);  --	VARCHAR2(30)
        -- LEE EL NUMERO DE CUENTA
				UN_TPL_AN(UN_NUMERO_LINEA).MI_NUMERO_CUENTA := SUBSTR(MI_LINEA
																	,INSTR(MI_LINEA,';',1,7) + 1 
																	);  --	VARCHAR2(30)
 		END LOOP; 	
  	UN_INDICA := 0;
  EXCEPTION
		WHEN NO_DATA_FOUND THEN
	  	UN_INDICA := 0;			
  	WHEN OTHERS THEN
  	  UN_INDICA := 1;
  	  PR_DESPLIEGA_MENSAJE('AL_STOP_1','Error cargando plano nomina '||SQLERRM);
		  RAISE FORM_TRIGGER_FAILURE;
END OGT_PR_CARGAR_ARCHIVO_NOMINA;	
 	
/****************************************************************************/
  -- AUTOR:      FANNY MALAGON
  -- NOMBRE:     OGT_PR_CARGAR_ARCHIVO_EMBARGOS
  -- OBJETIVO:   MUESTRA EL NOMBRE DE UN CONCEPTO 

/****************************************************************************/  
PROCEDURE OGT_PR_CARGAR_ARCHIVO_EMBARGOS (UN_ID_ARCHIVO         TEXT_IO.FILE_TYPE
																					,UN_ID_ERROR          TEXT_IO.FILE_TYPE
  																				,UN_INDICA						 IN OUT NUMBER 
  																				,UN_TPL_AE             IN OUT PK_OGT_BD_CREAR_RA.AETAB
  																				,UN_NUMERO_LINEA    IN OUT NUMBER 
  																				,UN_CODIGO_CC       IN VARCHAR2
																					)	IS
  MI_LINEA        			  VARCHAR2(1800);
BEGIN
	  UN_NUMERO_LINEA := 0;
	LOOP
 		-- COMIENZA A LEER EL ARCHIVO
		TEXT_IO.GET_LINE(UN_ID_ARCHIVO, MI_LINEA);
		UN_NUMERO_LINEA := UN_NUMERO_LINEA + 1;

		-- POBLA EL CODIGO DEL CC
		UN_TPL_AE(UN_NUMERO_LINEA).MI_CODIGO_CENTRO_COSTOS := UN_CODIGO_CC;

		-- LEE EL APORTE DE EMBARGO
		UN_TPL_AE(UN_NUMERO_LINEA).MI_APORTE_EMBARGO := SUBSTR(MI_LINEA
																		,1
																		,INSTR(MI_LINEA,';',1,1) - 1); -- 	NOT NULL	NUMBER(16,2)

		-- LEE EL TIPO DE IDENTIFICACION
		UN_TPL_AE(UN_NUMERO_LINEA).MI_TIPO_PAGAR_A := SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,1) + 1
																		,INSTR(MI_LINEA,';',1,2) - INSTR(MI_LINEA,';',1,1) - 1
																		); -- 	NOT NULL 	VARCHAR2(30)
		
    -- LEE EL NUMERO DEL DOCUMENTO DEL TERCERO AL QUE SE VA A GIRAR
		UN_TPL_AE(UN_NUMERO_LINEA).MI_NRO_PAGAR_A	:= SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,2) + 1
																		,INSTR(MI_LINEA,';',1,3) - INSTR(MI_LINEA,';',1,2) - 1
																		);-- 	NOT NULL	VARCHAR2(20)

		-- LEE LA FORMA DE PAGO																
		UN_TPL_AE(UN_NUMERO_LINEA).MI_FORMA_PAGO := SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,3) + 1
																		,INSTR(MI_LINEA,';',1,4) - INSTR(MI_LINEA,';',1,3) - 1
																		); -- 	NOT NULL	VARCHAR2(15)

		-- LEE LA SUCURSAL																
		UN_TPL_AE(UN_NUMERO_LINEA).MI_SUCURSAL := SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,4) + 1
																		,INSTR(MI_LINEA,';',1,5) - INSTR(MI_LINEA,';',1,4) - 1
																		); -- 	VARCHAR2(30)
																		
		-- LEE EL BANCO
		UN_TPL_AE(UN_NUMERO_LINEA).MI_BANCO := SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,5) + 1
																		,INSTR(MI_LINEA,';',1,6) - INSTR(MI_LINEA,';',1,5) - 1
																		); -- 	NUMBER(20)
																		
		-- LEE EL TIPO CUENTA
		UN_TPL_AE(UN_NUMERO_LINEA).MI_TIPO_CUENTA := SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,6) + 1
																		,INSTR(MI_LINEA,';',1,7) - INSTR(MI_LINEA,';',1,6) - 1
																		); -- 	VARCHAR2(30)

		-- LEE EL NUMERO DE CUENTA																		
		UN_TPL_AE(UN_NUMERO_LINEA).MI_NUMERO_CUENTA := SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,7) + 1
																		,INSTR(MI_LINEA,';',1,8) - INSTR(MI_LINEA,';',1,7) - 1
																		); -- 		VARCHAR2(30)
		
		-- LEE EL NUMERO DEL OFICIO
		UN_TPL_AE(UN_NUMERO_LINEA).MI_NUMERO_OFICIO := SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,8) + 1
																		,INSTR(MI_LINEA,';',1,9) - INSTR(MI_LINEA,';',1,8) - 1
																		); -- 	NOT NULL	NUMBER(16,2)

																		
		-- LEE FUERA CIUDAD
		UN_TPL_AE(UN_NUMERO_LINEA).MI_FUERA_CIUDAD := SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,9) + 1
																		,INSTR(MI_LINEA,';',1,10) - INSTR(MI_LINEA,';',1,9) - 1
																		); -- VARCHAR2(1)

		-- LEE EL TIPO DE IDENTIFICACION
		UN_TPL_AE(UN_NUMERO_LINEA).MI_TIPO_ID := SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,10) + 1
																		,INSTR(MI_LINEA,';',1,11) - INSTR(MI_LINEA,';',1,10) - 1
																		); -- 	NOT NULL 	VARCHAR2(30)
		
    -- LEE EL NUMERO DEL DOCUMENTO DEL TERCERO AL QUE SE VA A GIRAR
		UN_TPL_AE(UN_NUMERO_LINEA).MI_NRO_ID	:= SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,11) + 1
																		,INSTR(MI_LINEA,';',1,12) - INSTR(MI_LINEA,';',1,11) - 1
																		);-- 	NOT NULL	VARCHAR2(20)

    -- EMBARGANTE
		-- LEE EL TIPO DE IDENTIFICACION
		UN_TPL_AE(UN_NUMERO_LINEA).MI_TIPO_ID_EMBARGADO := SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,12) + 1
																		,INSTR(MI_LINEA,';',1,13) - INSTR(MI_LINEA,';',1,12) - 1
																		); -- 	NOT NULL 	VARCHAR2(30)
		
     -- LEE EL NUMERO DEL DOCUMENTO DEL TERCERO AL QUE SE VA A GIRAR
		UN_TPL_AE(UN_NUMERO_LINEA).MI_NRO_ID_EMBARGADO	:= SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,13) + 1
																		,INSTR(MI_LINEA,';',1,14) - INSTR(MI_LINEA,';',1,13) - 1
																		);-- 	NOT NULL	VARCHAR2(20)

		-- LEE EL CONCEPTO
		UN_TPL_AE(UN_NUMERO_LINEA).MI_CONCEPTO := SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,14) + 1
																		,INSTR(MI_LINEA,';',1,15) - INSTR(MI_LINEA,';',1,14) - 1
																		);-- 	NULL	VARCHAR2(30)

		UN_TPL_AE(UN_NUMERO_LINEA).MI_NOMBRE_EMBARGANTE := NULL;
		
		-- LEE EL NOMBRE DEL EMBARGANTE
		UN_TPL_AE(UN_NUMERO_LINEA).MI_NOMBRE_EMBARGANTE := SUBSTR(MI_LINEA
																		,INSTR(MI_LINEA,';',1,15) + 1
--																		,INSTR(MI_LINEA,';',1,15) - INSTR(MI_LINEA,';',1,14) - 1
																		);-- 	NULL	VARCHAR2(30)
		IF UN_TPL_AE(UN_NUMERO_LINEA).MI_NOMBRE_EMBARGANTE = MI_LINEA THEN
			UN_TPL_AE(UN_NUMERO_LINEA).MI_NOMBRE_EMBARGANTE := NULL;
		END IF;

	END LOOP;
  	UN_INDICA := 0;
  EXCEPTION
		WHEN NO_DATA_FOUND THEN
	  	UN_INDICA := 0;			
  	WHEN OTHERS THEN
  	  UN_INDICA := 1;
  	  PR_DESPLIEGA_MENSAJE('AL_STOP_1','Error cargando plano embargos '||SQLERRM);
		  RAISE FORM_TRIGGER_FAILURE;
END OGT_PR_CARGAR_ARCHIVO_EMBARGOS; 	
/****************************************************************************/	
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   TOTALIZA EL APORTE PATRONAL DE UN ANEXO DE UNA RA 
  -- PARAMETROS: VIGENCIA, ENTIDAD, UNIDAD, TIPO_DOCUMENTO, CONSECUTIVO, TIPO RA,
  --            ,MES ,FECHA DESDE, FECHA HASTA, UN CODIGO_CENTRO_COSTOS
/****************************************************************************/  
  FUNCTION OGT_FN_TOTAL_UN_ANEXO_PATRONAL(UN_VIGENCIA         OGT_RELACION_AUTORIZACION.VIGENCIA%TYPE
                                       ,UN_ENTIDAD          OGT_RELACION_AUTORIZACION.ENTIDAD%TYPE
                                       ,UN_UNIDAD_EJECUTORA OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA%TYPE
                                       ,UN_TIPO_DOCUMENTO   OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO%TYPE
                                       ,UN_CONSECUTIVO      OGT_RELACION_AUTORIZACION.CONSECUTIVO%TYPE
                                       ,UN_TIPO_RA          OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE
                                       ,UN_MES              OGT_RELACION_AUTORIZACION.MES%TYPE
                                       ,UN_FECHA_DESDE      OGT_RELACION_AUTORIZACION.FECHA_DESDE%TYPE
                                       ,UN_CODIGO_CENTRO_COSTOS OGT_ANEXO_PATRONAL.CODIGO_CENTRO_COSTOS%TYPE                                       
                                       ) RETURN NUMBER AS
  	CURSOR C_TOTAL IS
	    SELECT SUM( NVL(OGT_ANEXO_PATRONAL.APORTE_PATRONAL,0)
								- NVL(OGT_ANEXO_PATRONAL.INCAPACIDAD,0)	                                                        
	              - NVL(OGT_ANEXO_PATRONAL.SALDO,0)                                          
	              )
  	  FROM   OGT_ANEXO_PATRONAL
    	WHERE  OGT_ANEXO_PATRONAL.VIGENCIA         = UN_VIGENCIA         
	    AND    OGT_ANEXO_PATRONAL.ENTIDAD          = UN_ENTIDAD          
  	  AND    OGT_ANEXO_PATRONAL.UNIDAD_EJECUTORA = UN_UNIDAD_EJECUTORA 
    	AND    OGT_ANEXO_PATRONAL.TIPO_DOCUMENTO   = UN_TIPO_DOCUMENTO   
	    AND    OGT_ANEXO_PATRONAL.CONSECUTIVO      = UN_CONSECUTIVO      
  	  AND    OGT_ANEXO_PATRONAL.TIPO_RA          = UN_TIPO_RA          
    	AND    OGT_ANEXO_PATRONAL.MES              = UN_MES              
	    AND    OGT_ANEXO_PATRONAL.FECHA_DESDE      = UN_FECHA_DESDE      
			AND 	 OGT_ANEXO_PATRONAL.CODIGO_CENTRO_COSTOS = UN_CODIGO_CENTRO_COSTOS 
    	;
  	MI_TOTAL   NUMBER;
	BEGIN
	  OPEN C_TOTAL;
	  FETCH C_TOTAL INTO MI_TOTAL;
	  IF C_TOTAL%ISOPEN THEN
		  CLOSE C_TOTAL;
 		END IF;		  
	  RETURN(MI_TOTAL);	
	END OGT_FN_TOTAL_UN_ANEXO_PATRONAL;  

  /***************************************************************************/
  -- OBJETIVO:   RETORNAR LA RAZON DE DEVOLUCION
  -- SE PODRA GENERAR INPENDIENTEMENTE DEL ESTADO DE LA RA
  -- PARAMETROS: VIGENCIA, ENTIDAD, UNIDAD, TIPO_DOCUMENTO, CONSECUTIVO
  /***************************************************************************/

  FUNCTION OGT_FN_DEVOLUCION_RA(UN_VIGENCIA         OGT_RELACION_AUTORIZACION.VIGENCIA%TYPE
	        	                   ,UN_ENTIDAD          OGT_RELACION_AUTORIZACION.ENTIDAD%TYPE
    	        	               ,UN_UNIDAD_EJECUTORA OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA%TYPE
    	        	               ,UN_TIPO_DOCUMENTO   OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO%TYPE
      	                       ,UN_CONSECUTIVO      OGT_RELACION_AUTORIZACION.CONSECUTIVO%TYPE
        	                     ) RETURN VARCHAR2 IS

		UN_RETORNO            VARCHAR2(1000);
		UN_TIPO_RA						OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE;
		UN_MES								OGT_RELACION_AUTORIZACION.MES%TYPE;
		UN_FECHA_DESDE				OGT_RELACION_AUTORIZACION.FECHA_DESDE%TYPE;
		
  BEGIN
		-- VERIFICA QUE TENGA PREDIS
		PR_VALIDAR_PREDIS(UN_ENTIDAD					
				            ,UN_UNIDAD_EJECUTORA
	  		 						,UN_VIGENCIA
	  		 						,UN_CONSECUTIVO
	  		 						,UN_RETORNO           
	  		 						);	

		IF SUBSTR(UN_RETORNO,1,2) = 'Si' THEN
		  -- SI tiene PREDIS
			UN_RETORNO := 'SI  ';
		ELSE
		  -- No tiene PREDIS
			UN_RETORNO := 'NO  ';		  
		END IF;
				
		-- VERIFICA QUE TENGA PAC
		SELECT 	TIPO_RA						
	  	 		 ,MES					
	  	 		 ,FECHA_DESDE	
	  INTO    UN_TIPO_RA						
	  	 		 ,UN_MES					
	  	 		 ,UN_FECHA_DESDE	
	  FROM    OGT_RELACION_AUTORIZACION
	  WHERE   OGT_RELACION_AUTORIZACION.VIGENCIA         = UN_VIGENCIA         
	  AND     OGT_RELACION_AUTORIZACION.ENTIDAD          = UN_ENTIDAD          
    AND     OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA = UN_UNIDAD_EJECUTORA 
    AND     OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO   = UN_TIPO_DOCUMENTO   
    AND     OGT_RELACION_AUTORIZACION.CONSECUTIVO      = UN_CONSECUTIVO      
    ;

		PR_VALIDAR_PAC(UN_ENTIDAD					  
			            ,UN_UNIDAD_EJECUTORA
	  	 						,UN_VIGENCIA    			
	  	 						,UN_CONSECUTIVO
	  	 						,UN_TIPO_RA						
	  	 						,UN_MES								
	  	 						,UN_FECHA_DESDE				
	  	 						,UN_RETORNO           
	  	 						);
	
		IF SUBSTR(UN_RETORNO,1,2) = 'Si' THEN
		  -- SI tiene PAC
			UN_RETORNO := SUBSTR(UN_RETORNO,1,2)||'SI';
		ELSE
		  -- No tiene PAC
			UN_RETORNO := SUBSTR(UN_RETORNO,1,2)||'NO';		  
		END IF;

		-- VERIFICA EL hash
		RETURN UN_RETORNO;
	EXCEPTION 
		WHEN OTHERS THEN
			RETURN 'NONO';
  END OGT_FN_DEVOLUCION_RA;

/****************************************************************************/	
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   VALIDA LAS INCAPACIDADES DE UNA CONCEPTO DE UNA RA
  -- PARAMETROS: VIGENCIA, ENTIDAD, UNIDAD, TIPO_DOCUMENTO, CONSECUTIVO, TIPO RA,
  --            ,MES ,FECHA DESDE, FECHA HASTA, UN CODIGO_CENTRO_COSTOS
/****************************************************************************/  
   PROCEDURE OGT_PR_VALIDA_INCAPACIDAD(UN_VIGENCIA         OGT_RELACION_AUTORIZACION.VIGENCIA%TYPE
                                       ,UN_ENTIDAD          OGT_RELACION_AUTORIZACION.ENTIDAD%TYPE
                                       ,UN_UNIDAD_EJECUTORA OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA%TYPE
                                       ,UN_TIPO_DOCUMENTO   OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO%TYPE
                                       ,UN_CONSECUTIVO      OGT_RELACION_AUTORIZACION.CONSECUTIVO%TYPE
                                       ,UN_TIPO_RA          OGT_RELACION_AUTORIZACION.TIPO_RA%TYPE
                                       ,UN_MES              OGT_RELACION_AUTORIZACION.MES%TYPE
                                       ,UN_FECHA_DESDE      OGT_RELACION_AUTORIZACION.FECHA_DESDE%TYPE
                                       ,UN_RETORNO_BENEFICIARIO  IN OUT  VARCHAR2
                                       ) IS
  	CURSOR C_TOTAL_BENEFICIARIO IS
	    SELECT SUM( NVL(OGT_ANEXO_PATRONAL.APORTE_PATRONAL,0)
	    					+ NVL(OGT_ANEXO_PATRONAL.APORTE_EMPLEADO,0)
								- NVL(OGT_ANEXO_PATRONAL.INCAPACIDAD,0)	                                                        
	              - NVL(OGT_ANEXO_PATRONAL.SALDO,0)                                          
	              )                                         TOTAL
  	  FROM   OGT_ANEXO_PATRONAL
    	WHERE  OGT_ANEXO_PATRONAL.VIGENCIA         = UN_VIGENCIA         
	    AND    OGT_ANEXO_PATRONAL.ENTIDAD          = UN_ENTIDAD          
  	  AND    OGT_ANEXO_PATRONAL.UNIDAD_EJECUTORA = UN_UNIDAD_EJECUTORA 
    	AND    OGT_ANEXO_PATRONAL.TIPO_DOCUMENTO   = UN_TIPO_DOCUMENTO   
	    AND    OGT_ANEXO_PATRONAL.CONSECUTIVO      = UN_CONSECUTIVO      
  	  AND    OGT_ANEXO_PATRONAL.TIPO_RA          = UN_TIPO_RA          
    	AND    OGT_ANEXO_PATRONAL.MES              = UN_MES              
	    AND    OGT_ANEXO_PATRONAL.FECHA_DESDE      = UN_FECHA_DESDE      
			GROUP BY OGT_ANEXO_PATRONAL.CODIGO_CENTRO_COSTOS
			,OGT_ANEXO_PATRONAL.ID_PAGAR_A
    	;
	BEGIN
		UN_RETORNO_BENEFICIARIO := 'BIEN';
	  FOR A IN C_TOTAL_BENEFICIARIO  LOOP
	  	-- MAL SIGNIFICA QUE SUPERA Y SE ENVIA POR UNO SOLO QUE LO SUPERE
	  	-- LA INCAPACIDAD DE UN BENEFICARIO SUPERA EL APORTE PATRONAL Y EL DEL EMPLEADO
	  	-- NO PUEDE GENERAR PAGO
			IF A.TOTAL < 0 THEN				
        UN_RETORNO_BENEFICIARIO := 'MAL';          								
			END IF;	  	
	  END LOOP;		  
  END OGT_PR_VALIDA_INCAPACIDAD;                                        	

/***************************************************************************/  
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   VALIDA EL TERCERO PARA EL CARGUE DE PLANOS
  -- PARAMETROS: NUMERO Y TIPO DE DOCUMENTO
  --   SI FUE EXITOSA RETORNA TRUE
  --   SI FUE FALLIDA RETORNA FALSE
/***************************************************************************/  

	PROCEDURE PR_VALIDA_PROVEEDOR(MI_TIPO_IDENTIFICACION    OGT_PROVEEDORES_RA.TIPO_IDENTIFICACION%TYPE
											          ,MI_NUMERO_DOCUMENTO     OGT_PROVEEDORES_RA.CODIGO_IDENTIFICACION%TYPE
															  ,MI_NUMERO_LINEA    		 NUMBER
															  ,MI_LINEA          			 VARCHAR2
																,UN_ID_ERROR    	       TEXT_IO.FILE_TYPE																					
																,UN_ID                   IN OUT OGT_PROVEEDORES_RA.ID%TYPE
																,UN_INDICA							 IN OUT NUMBER 
																,UN_I_E              		 IN OUT NUMBER)  IS

  MI_REG_INFBASICA_PRO    PK_OGT_BD_CREAR_RA.REG_INFBASICA_PRO;
  MI_DOCUMENTO_NUMERO     NUMBER(30);
  MI_CUANTOS              NUMBER(6);
  
	BEGIN
		-- VALIDA QUE EL TIPO IDENTIFICACION NO SEA NULO
		IF NVL(MI_TIPO_IDENTIFICACION,'Z') = 'Z' THEN
			TEXT_IO.PUT_LINE(UN_ID_ERROR,' 5.ERROR QUE NO PERMITE CARGUE, EL VALOR DEL TIPO DE IDENTIFICACION NO DEBE SER NULO '||'EN LA LINEA '
											||MI_NUMERO_LINEA||' --> '||MI_LINEA);
       UN_I_E := UN_I_E + 1;												
 			UN_INDICA := 1;																						
		END IF;									

		-- VALIDA QUE EL TIPO DE IDENTIFICACION SEA VALIDO
		IF NOT P_BINTABLAS.TEXISTE(MI_TIPO_IDENTIFICACION
															,'GENERAL'
															,'IDENTIFICACION'
															,TO_CHAR(SYSDATE,'DD-MON-YYYY')) THEN
			TEXT_IO.PUT_LINE(UN_ID_ERROR,' 6.ERROR QUE NO PERMITE CARGUE, EL TIPO DE IDENTIFICACION '||MI_TIPO_IDENTIFICACION||' ES INVALIDO '||'EN LA LINEA '
											||MI_NUMERO_LINEA||' --> '||MI_LINEA);
       UN_I_E := UN_I_E + 1;												
				UN_INDICA := 1;																						
		END IF;

		-- VALIDA QUE EL DOCUMENTO NO SEA NULO
		IF NVL(MI_NUMERO_DOCUMENTO,'Z') = 'Z' THEN
			TEXT_IO.PUT_LINE(UN_ID_ERROR,' 7.ERROR QUE NO PERMITE CARGUE, EL VALOR DEL NUMERO DEL DOCUMENTO NO DEBE SER NULO '||'EN LA LINEA '
											||MI_NUMERO_LINEA||' --> '||MI_LINEA);
      UN_I_E := UN_I_E + 1;																								
 			UN_INDICA := 1;																						
		END IF;									

		-- VALIDA QUE LA LONGITUD DEL DOCUMENTO CORRESPINDA AL TIPO
		IF MI_TIPO_IDENTIFICACION IS NOT NULL
			OR MI_NUMERO_DOCUMENTO IS NOT NULL THEN
			IF PK_SIT_INFBASICA.SIT_FN_LONG_TIPO_ID(MI_TIPO_IDENTIFICACION
																						 ,MI_NUMERO_DOCUMENTO)
	   	   = 1 THEN
				TEXT_IO.PUT_LINE(UN_ID_ERROR,' 8.ERROR QUE NO PERMITE CARGUE, LA LONGITUD DEL TIPO DE DOCUMENTO ES INVALIDA '||'EN LA LINEA '
												||MI_NUMERO_LINEA||' --> '||MI_LINEA);       
	       UN_I_E := UN_I_E + 1;																								
	 			UN_INDICA := 1;																						
			END IF; 																					 
		END IF;	

		-- VALIDA QUE EL DOCUMENTO SEA NUMERICO
		IF OGT_FN_VALIDA_NUMERO(MI_NUMERO_DOCUMENTO) THEN			
			MI_DOCUMENTO_NUMERO := TO_NUMBER(MI_NUMERO_DOCUMENTO);
		ELSE 
			TEXT_IO.PUT_LINE(UN_ID_ERROR,' 9.ERROR QUE NO PERMITE CARGUE, EL VALOR DEL NUMERO DE DOCUMENTO DEBE SER NUMERICO '||'EN LA LINEA '
											||MI_NUMERO_LINEA||' --> '||MI_LINEA);
       UN_I_E := UN_I_E + 1;																								
 			UN_INDICA := 1;																						
		END IF;		
		
    -- VALIDA QUE EXISTA EL TERCERO
    IF MI_TIPO_IDENTIFICACION IS NOT NULL
    	AND MI_NUMERO_DOCUMENTO IS NOT NULL THEN
				MI_REG_INFBASICA_PRO := PK_OGT_BD_CREAR_RA.FN_INFBASICA_PROVEEDOR(MI_TIPO_IDENTIFICACION
																											,MI_NUMERO_DOCUMENTO);	   																
    END IF;
    IF MI_REG_INFBASICA_PRO.MI_ID IS NULL THEN
			TEXT_IO.PUT_LINE(UN_ID_ERROR,' 10.ERROR QUE NO PERMITE CARGUE, EL PROVEEDOR NO EXISTE EN LA LINEA '
											||MI_NUMERO_LINEA||' --> '||MI_LINEA);
       UN_I_E := UN_I_E + 1;																								
 			UN_INDICA := 1;																						
    ELSE
    	
    	UN_ID := MI_REG_INFBASICA_PRO.MI_ID;
    	
    	-- SE CREA EL TERCERO EN LOS TERCEROS DE TESORERIA
	    BEGIN
  	  	SELECT 	COUNT(*)
    		INTO   	MI_CUANTOS
	    	FROM 		OGT_TERCERO
	    	WHERE 	ID = MI_REG_INFBASICA_PRO.MI_ID
	    	;
	    	IF MI_CUANTOS = 0 THEN
	    		BEGIN
	          INSERT INTO OGT_TERCERO
	          VALUES (MI_REG_INFBASICA_PRO.MI_ID)
	          ;
					EXCEPTION 
						WHEN OTHERS THEN
							PR_DESPLIEGA_MENSAJE('AL_STOP_1','1. Error creando tercero '||SQLERRM);
							RAISE FORM_TRIGGER_FAILURE;		 				
					END;
        END IF;  
	    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN 		 
		   	NULL;
 		  END;
  	END IF;
	END PR_VALIDA_PROVEEDOR;	

/***************************************************************************/  
  -- AUTOR:      FANNY MALAGON
  -- OBJETIVO:   VALIDA LA INF COMERCIAL DEL TERCERO PARA EL CARGUE DE PLANOS
  -- PARAMETROS: NUMERO Y TIPO DE DOCUMENTO
/***************************************************************************/  

	PROCEDURE PR_VALIDA_INFCOMERCIAL_PRO(MI_TIPO_IDENTIFICACION  OGT_PROVEEDORES_RA.TIPO_IDENTIFICACION%TYPE
											          ,MI_NUMERO_DOCUMENTO                 OGT_PROVEEDORES_RA.CODIGO_IDENTIFICACION%TYPE
																,MI_FORMA_PAGO 							       	 IN OUT OGT_RA_FORMA_PAGO.FORMA_PAGO%TYPE
																,MI_BANCO 											     IN OUT OGT_RA_FORMA_PAGO.BANCO%TYPE
																,MI_TIPO_CUENTA  							       IN OUT OGT_RA_FORMA_PAGO.TIPO_CUENTA%TYPE
																,UNA_SITUACION_FONDOS                OGT_RELACION_AUTORIZACION.SITUACION_FONDOS%TYPE 																					
																,MI_NUMERO_CUENTA  						       IN OUT OGT_RA_FORMA_PAGO.NUMERO_CUENTA%TYPE																
															  ,MI_NUMERO_LINEA    		 NUMBER
															  ,MI_LINEA          			 VARCHAR2
																,UN_ID_ERROR    	       TEXT_IO.FILE_TYPE																					
																,UN_ID                   IN OUT OGT_PROVEEDORES_RA.ID%TYPE
																,UN_INDICA							 IN OUT NUMBER 
																,UN_I_E              		 IN OUT NUMBER) IS

	MI_REG_INFCOMERCIAL_PRO		PK_OGT_BD_CREAR_RA.REG_INFCOMERCIAL_PRO;
	MI_FUNCIONARIO            OGT_V_PROVEEDORES_RA.FUNCIONARIO%TYPE;
  MI_BANCO_F				        NUMBER(20);
  MI_BANCO_P				        NUMBER(20);	  	
  BEGIN
  	-- VALID QUE SEA FUNCIONARIO  	
  	BEGIN
  		SELECT DISTINCT FUNCIONARIO
  		INTO   MI_FUNCIONARIO
  		FROM   OGT_V_PROVEEDORES_RA
  		WHERE  CODIGO_IDENTIFICACION = MI_NUMERO_DOCUMENTO
  		AND    TIPO_IDENTIFICACION   = MI_TIPO_IDENTIFICACION;  		
  	END;
  	
		MI_REG_INFCOMERCIAL_PRO := PK_OGT_BD_CREAR_RA.FN_INFCOMERCIAL_PROVEEDOR(MI_TIPO_IDENTIFICACION
														          ,MI_NUMERO_DOCUMENTO  
														          ,SYSDATE);
    MI_BANCO_P := PK_SIT_INFENTIDADES.SIT_FN_ID_SUPERBANCARIA (MI_REG_INFCOMERCIAL_PRO.MI_BANCO
																														,TO_CHAR(SYSDATE,'DD-MON-YYYY'));
														          
    MI_BANCO_F := PK_SIT_INFENTIDADES.SIT_FN_ID_SUPERBANCARIA (MI_BANCO
																														,TO_CHAR(SYSDATE,'DD-MON-YYYY'));
  	
  	IF   	MI_FORMA_PAGO <>  NVL(MI_REG_INFCOMERCIAL_PRO.MI_FORMA_PAGO,MI_FORMA_PAGO)
		OR  	MI_BANCO      <> NVL(MI_REG_INFCOMERCIAL_PRO.MI_BANCO,MI_BANCO)
  	OR		MI_TIPO_CUENTA <> NVL(MI_REG_INFCOMERCIAL_PRO.MI_TIPO_CUENTA,MI_TIPO_CUENTA)
  	OR		MI_NUMERO_CUENTA <> NVL(MI_REG_INFCOMERCIAL_PRO.MI_NUMERO_CUENTA,MI_NUMERO_CUENTA) THEN
  		-- LA ACTUALIZA SOLO PARA FUNCIONARIOS  		
  		IF MI_FUNCIONARIO = 'S' THEN
				BEGIN
				-- CERRAR LA FORMA DE PAGO ANTERIOR
				UPDATE OGT_RA_FORMA_PAGO
				SET FECHA_FINAL = SYSDATE
				WHERE TIPO_IDENTIFICACION = MI_TIPO_IDENTIFICACION            
				AND CODIGO_IDENTIFICACION = MI_NUMERO_DOCUMENTO
				AND FECHA_FINAL IS NULL;

				-- COLOCAR LA NUEVA FORMA DE PAGO
				INSERT INTO OGT_RA_FORMA_PAGO
				(TIPO_IDENTIFICACION            
				,CODIGO_IDENTIFICACION          
				,FORMA_PAGO                     
				,FECHA_INICIAL                  
				,FECHA_FINAL                    
				,BANCO                          
				,TIPO_CUENTA                    
				,NUMERO_CUENTA                  
				)
				VALUES
				(MI_TIPO_IDENTIFICACION            
				,MI_NUMERO_DOCUMENTO          
				,MI_FORMA_PAGO                     
				,SYSDATE
				,NULL
				,MI_BANCO                          
				,MI_TIPO_CUENTA                    
				,MI_NUMERO_CUENTA                  
				);

				EXCEPTION 
				WHEN DUP_VAL_ON_INDEX THEN
					NULL;
				WHEN OTHERS THEN
					TEXT_IO.PUT_LINE(UN_ID_ERROR,' 11.ERROR QUE NO PERMITE CARGUE '||				
					' DEL FUNCIONARIO '||
					MI_TIPO_IDENTIFICACION||' '||
				  MI_NUMERO_DOCUMENTO||' '||          
					' TIENE EL SIGUIENTE ERROR '||SQLERRM);					
	       UN_I_E := UN_I_E + 1;																								
		  	 UN_INDICA := 1;																						
				END;
	  	-- PARA PROVEEDORES GENERA ERROR QUE PERMITE CARGUE  	 
	  	ELSE
  			MI_FORMA_PAGO    := MI_REG_INFCOMERCIAL_PRO.MI_FORMA_PAGO;
		    MI_BANCO         := MI_BANCO_P;
  	    MI_TIPO_CUENTA   := MI_REG_INFCOMERCIAL_PRO.MI_TIPO_CUENTA;
  	    MI_NUMERO_CUENTA := MI_REG_INFCOMERCIAL_PRO.MI_NUMERO_CUENTA;

				TEXT_IO.PUT_LINE(UN_ID_ERROR,' 11.ERROR QUE PERMITE CARGUE '||				
					' LA INFORMACION COMERCIAL DEL PROVEEDOR '||
						MI_TIPO_IDENTIFICACION||' '||
					  MI_NUMERO_DOCUMENTO||' '||          
						' NO COINCIDE CON LA DE OPGET ');					
		       UN_I_E := UN_I_E + 1;																								
			  	 UN_INDICA := 0;																							
	  	END IF;	  	
		END IF;	
		IF MI_FUNCIONARIO = 'S' THEN
			MI_BANCO := MI_BANCO_F;								
		ELSE
			MI_BANCO := MI_BANCO_P;								
		END IF;
/*		-- VALIDA QUE EL MI_FORMA_PAGO NO SEA NULO
		IF NVL(MI_FORMA_PAGO ,'Z') = 'Z' THEN
			TEXT_IO.PUT_LINE(UN_ID_ERROR,' 11.ERROR QUE NO PERMITE CARGUE, EL VALOR DE LA FORMA DE PAGO NO DEBE SER NULO '||'EN LA LINEA '
											||MI_NUMERO_LINEA||' --> '||MI_LINEA);
       UN_I_E := UN_I_E + 1;																								
 			UN_INDICA := 1;																						
		END IF;									

  	-- VALIDA QUE LA FORMA DE PAGO SEA VALIDA
		IF NOT P_BINTABLAS.TEXISTE(MI_FORMA_PAGO
															,'OPGET'
															,'FORMA_PAGO'
															,TO_CHAR(SYSDATE,'DD-MON-YYYY')) THEN
			TEXT_IO.PUT_LINE(UN_ID_ERROR,' 12.ERROR QUE NO PERMITE CARGUE: LA FORMA DE PAGO ES INVALIDA '||'EN LA LINEA '
											||MI_NUMERO_LINEA||' --> '||MI_LINEA);
       UN_I_E := UN_I_E + 1;											
			 UN_INDICA := 1;																						
		END IF;
		
		-- VVALIDA QUE EL MI_BANCO SEA NUMERICO
		-- SOLO PARA PAGOS POR ABONO
		IF MI_FORMA_PAGO = 'A' THEN 
			
				IF OGT_FN_VALIDA_NUMERO(MI_BANCO_C) THEN			
					MI_BANCO := TO_NUMBER(MI_BANCO_C);
				ELSE 
					TEXT_IO.PUT_LINE(UN_ID_ERROR,' 13.ERROR QUE NO PERMITE CARGUE: EL CODIGO DEL BANCO DEBE SER NUMERICO '||'EN LA LINEA '
													||MI_NUMERO_LINEA||' --> '||MI_LINEA);
		      UN_I_E := UN_I_E + 1;																								
		     	UN_INDICA := 1;																						
				END IF;		
				
				-- GENRA EL MENSAJE DE ERROR
				IF MI_BANCO = NULL THEN
					TEXT_IO.PUT_LINE(UN_ID_ERROR,' 13.ERROR QUE NO PERMITE CARGUE: POR LA FORMA DE PAGO ES ABONO DEBE VENIR UN BANCO '||'EN LA LINEA '
													||MI_NUMERO_LINEA||' --> '||MI_LINEA);
		      UN_I_E := UN_I_E + 1;												
		     	UN_INDICA := 1;																						
				END IF;
		
				-- GENRA EL MENSAJE DE ERROR
				IF MI_TIPO_CUENTA = NULL THEN
					TEXT_IO.PUT_LINE(UN_ID_ERROR,' 13.ERROR QUE NO PERMITE CARGUE: POR LA FORMA DE PAGO ES ABONO DEBE VENIR UN TIPO DE CUENTA '||'EN LA LINEA '
													||MI_NUMERO_LINEA||' --> '||MI_LINEA);
		      UN_I_E := UN_I_E + 1;												
		     	UN_INDICA := 1;																						
				END IF;
		
		    -- VALIDA QUE EL TIPO CUENTA SEA VALIDO
				IF NOT P_BINTABLAS.TEXISTE(MI_TIPO_CUENTA
																	,'GENERAL'
																	,'TIPO_CUENTA'
																	,TO_CHAR(SYSDATE,'DD-MON-YYYY')) THEN
					TEXT_IO.PUT_LINE(UN_ID_ERROR,' 14.ERROR QUE NO PERMITE CARGUE: EL VALOR DEL TIPO DE CUENTA ES INVALIDO, '||'EN LA LINEA '
													||MI_NUMERO_LINEA||' --> '||MI_LINEA);
		      UN_I_E := UN_I_E + 1;																								
					UN_INDICA := 1;
				END IF;
		
				-- GENERA EL MENSAJE DE ERROR
				IF MI_NUMERO_CUENTA = NULL THEN
					TEXT_IO.PUT_LINE(UN_ID_ERROR,' 13.ERROR QUE NO PERMITE CARGUE: POR LA FORMA DE PAGO ES ABONO DEBE VENIR UN NUMERO DE CUENTA '||'EN LA LINEA '
													||MI_NUMERO_LINEA||' --> '||MI_LINEA);
		      UN_I_E := UN_I_E + 1;												
					UN_INDICA := 1;
				END IF;
		END IF; -- SI ES FORMA PAGO = 'A'
		
 		  -- VALIDA QUE EL TERCERO AL QUE SE LE VA A PAGAR TENGA LA CUENTA Y EL BANCO
			-- REGISTRADO EN TERCEROS  SOLO PARA PAGOS POR ABONO EN CUENTA
		IF UN_ID IS NOT NULL 
		AND (MI_FORMA_PAGO = 'A' 
				OR MI_REG_INFCOMERCIAL_PRO.MI_FORMA_PAGO = 'A')
		THEN
					IF NVL(LTRIM(RTRIM(MI_REG_INFCOMERCIAL_PRO.MI_TIPO_CUENTA)),'F') <> NVL(MI_TIPO_CUENTA,'F')
          OR NVL(LTRIM(RTRIM(MI_REG_INFCOMERCIAL_PRO.MI_NUMERO_CUENTA)),'F') <> NVL(MI_NUMERO_CUENTA,'F')
          OR NVL(LTRIM(RTRIM(MI_REG_INFCOMERCIAL_PRO.MI_BANCO)),'F') <> NVL(MI_BANCO,'F')
          OR NVL(MI_TIPO_CUENTA,'F') = 'F'
          OR NVL(MI_NUMERO_CUENTA,'F') = 'F'
          OR NVL(MI_BANCO,'F') = 'F' THEN 
          
							TEXT_IO.PUT_LINE(UN_ID_ERROR,' 13.ERROR QUE NO PERMITE CARGUE: EL TERCERO NO TIENE NUMERO DE CUENTA, BANCO, TIPO DE CUENTA REGISTRADOS O SON DIFERENTES '||'EN LA LINEA '
																||MI_NUMERO_LINEA||' --> '||MI_LINEA);
		    	    UN_I_E := UN_I_E + 1;																								        	
				 			UN_INDICA := 1;																											
					END IF;


					-- VALIDA QUE EL MI_BANCO TENGA UN ID SUPERBANCARIA EN TERCEROS
					IF MI_BANCO IS NOT NULL THEN
						MI_BANCO := PK_SIT_INFENTIDADES.SIT_FN_ID_SUPERBANCARIA (MI_BANCO
																			 															,TO_CHAR(SYSDATE,'DD-MON-YYYY'));
						IF MI_BANCO IS NULL OR MI_BANCO = 0 THEN
								TEXT_IO.PUT_LINE(UN_ID_ERROR,' 15.ERROR QUE NO PERMITE CARGUE: EL CODIGO SUPERBANCARIA DEL BANCO NO EXISTE EN TERCEROS '||'EN LA LINEA '
																||MI_NUMERO_LINEA||' --> '||MI_LINEA);
							  UN_I_E := UN_I_E + 1;																								
						 		UN_INDICA := 1;
						END IF;																										 															
					END IF;
						
					IF MI_BANCO = 0 THEN			
						TEXT_IO.PUT_LINE(UN_ID_ERROR,' 10.ERROR QUE NO PERMITE CARGUE: EL CODIGO DEL BANCO NO EXISTE EN TERCEROS '||'EN LA LINEA '
																	||MI_NUMERO_LINEA||' --> '||MI_LINEA);
					  UN_I_E := UN_I_E + 1;																								
				 		UN_INDICA := 1;
					END IF;							
		END IF;	
*/
		IF MI_FORMA_PAGO NOT IN ('A','D') THEN
				MI_TIPO_CUENTA := NULL;
				MI_NUMERO_CUENTA := NULL;
				MI_BANCO := NULL;								
		END IF;				

		-- SI LA RA NO TIENE SITUACION DE FONDOS = 0 LA FORMA DE PAGO QUEDA NO APLICA Y NO TENDRA 
		-- TIPO CUENTA, NUMERO CUENTA NI SUCURSAL
		IF UNA_SITUACION_FONDOS = 0 THEN
			MI_FORMA_PAGO := 'NA';
			MI_TIPO_CUENTA := NULL;
			MI_NUMERO_CUENTA := NULL;
	  END IF;				
  END PR_VALIDA_INFCOMERCIAL_PRO;	
END;

