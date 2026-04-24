
PROCEDURE PR_TOTAL_PAC_RUBRO(UNA_ENTIDAD					OGT_RELACION_AUTORIZACION.ENTIDAD%TYPE
								         	   	,UNA_UNIDAD						OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA%TYPE
		  						 						,UNA_VIGENCIA_PAC			OGT_IMPUTACION.ANO_PAC%TYPE
  								 						,UN_MES_PAC						OGT_IMPUTACION.MES_PAC%TYPE
  							 							,UN_RUBRO							OGT_IMPUTACION.RUBRO_INTERNO%TYPE
  							 							,UN_FILTRO						VARCHAR2
  							 							,UN_RETORNO           IN OUT NUMBER
  							 							)IS
  BEGIN
		SELECT OGTRA.ESTADO, OGTI.* --SUM(NVL(OGTI.VALOR_BRUTO,0))
  --	INTO   UN_RETORNO
		FROM   OGT_IMPUTACION             OGTI
      		,OGT_RELACION_AUTORIZACION  OGTRA
		WHERE  OGTRA.ENTIDAD 		      = OGTI.ENTIDAD
		AND    OGTRA.VIGENCIA   		  = OGTI.VIGENCIA
		AND    OGTRA.UNIDAD_EJECUTORA = OGTI.UNIDAD_EJECUTORA
		AND    OGTRA.CONSECUTIVO      = OGTI.CONSECUTIVO
		AND    OGTRA.TIPO_DOCUMENTO   = OGTI.TIPO_DOCUMENTO
		AND    OGTRA.TIPO_DOCUMENTO   = 'RA' --MI_CON_TIPO_DOCUMENTO
	/*	AND    DECODE('R' --UN_FILTRO
						,'D' /*MI_CON_ESTADO_D* /,OGTRA.ESTADO								 
                 ,SUBSTR(OGTRA.ESTADO,4,6)
                 )        		 	   	= DECODE('R' --UN_FILTRO
                                  			    ,'D' /*MI_CON_ESTADO_D*/,'00000000000'
                                  			    ,'A' /*MI_CON_ESTADO_A*/,'100000'
                                  			    ,'E' /*MI_CON_ESTADO_E*/,'110000'
                                  			    ,'R' /*MI_CON_ESTADO_R*/,'111000'
                                  			    ,'G' /*MI_CON_ESTADO_G*/,'111010'
                                    	  		)		*/
		AND    OGTI.UNIDAD_EJECUTORA  = '01'	--UNA_UNIDAD
		AND    OGTI.ENTIDAD           = '206'	--UNA_ENTIDAD
		AND    OGTI.ANO_PAC           = 2026    --UNA_VIGENCIA_PAC
		AND    OGTI.MES_PAC           = 3      --UN_MES_PAC
    AND    OGTI.RUBRO_INTERNO     	  = 1804; --UN_RUBRO
	EXCEPTION 
		WHEN OTHERS THEN
			PR_DESPLIEGA_MENSAJE('AL_STOP_1','Se presento este error calculando PAC por rubro '||sqlerrm);
			RAISE FORM_TRIGGER_FAILURE;  	    
  END PR_TOTAL_PAC_RUBRO;



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
		    SELECT * --SUM(NVL(CC.VALOR_REGISTRO,0))
		   -- INTO   MI_TOTAL_RA_RP
	  	  FROM   OGT_REGISTRO_PRESUPUESTAL       CC
	    	WHERE  CC.VIGENCIA         = 2026 --MI_ANO_PAC
		    AND    CC.ENTIDAD          = 206  --UNA_ENTIDAD          
	  	  AND    CC.UNIDAD_EJECUTORA = '01'	  --UNA_UNIDAD 
	  	  AND    CC.RUBRO_INTERNO    = 1804   --MI_RUBRO
	  	  AND    CC.DISPONIBILIDAD   = 39    -- MI_DISPONIBILIDAD
	  	  AND    CC.REGISTRO         = 239   --MI_REGISTRO  	  	  	  	  	  
	    AND    CC.TIPO_DOCUMENTO   = 'RA' --MI_CON_TIPO_DOCUMENTO
		    AND    CC.CONSECUTIVO      = 5 --UN_CONSECUTIVO_RA
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
			-- MI_TOTAL_RA_RP =       614,401,024
			- -MI_TOTAL_POR_RUBRO =   479,461,723
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
		