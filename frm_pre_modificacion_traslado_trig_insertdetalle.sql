DECLARE
    mi_encontro                 BOOLEAN;
  	mi_numero_cdp               NUMBER;
  	mi_bloque_actual            VARCHAR2(60);
    mi_vigencia                 NUMBER;
    modifica_fuentes            VARCHAR2(250):=null;

 TYPE TypRec_disp IS RECORD (
	    VIGENCIA              pr_detalle_fuentes_cdp.vigencia%TYPE, 
	    CODIGO_COMPANIA       pr_detalle_fuentes_cdp.CODIGO_COMPANIA%TYPE, 
		  UNIDAD_EJECUTORA      pr_detalle_fuentes_cdp.CODIGO_UNIDAD_EJECUTORA%TYPE, 
      TIPO_DOCUMENTO        pr_detalle_fuentes_modif.TIPO_DOCUMENTO%TYPE,
	    DOCUMENTOS_NUMERO     pr_detalle_fuentes_modif.DOCUMENTOS_NUMERO%TYPE,
	    RUBRO_INTERNO         pr_detalle_fuentes_cdp.RUBRO_INTERNO%TYPE,  
			TIPO_MOVIMIENTO       pr_detalle_fuentes_modif.TIPO_MOVIMIENTO%TYPE, 
			NUMERO_DISPONIBILIDAD pr_detalle_fuentes_cdp.NUMERO_DISPONIBILIDAD%TYPE,  
			CODIGO_FUENTE         pr_detalle_fuentes_cdp.CODIGO_FUENTE%TYPE,  
			CODIGO_DETALLE        pr_detalle_fuentes_cdp.CODIGO_DET_FUENTE_FINANC%TYPE,  
			VALOR                 pr_detalle_fuentes_cdp.VALOR%TYPE);   
      
      reg_disp TypRec_disp; 	

 CURSOR c_disponibilidad  IS
  select * ---count(*)
  from pr_detalle_fuentes_cdp
  where vigencia=               2026  --:B_PRE_MODIFICACION_PPTAL.vigencia
  --and rubro_interno=            1679  --:B_PRE_MODIFICACION_PPTAL.rubro_interno	
  and codigo_compania=          206   --:B_PRE_MODIFICACION_PPTAL.CODIGO_compania
  and codigo_unidad_ejecutora=  '01'  --:B_PRE_MODIFICACION_PPTAL.CODIGO_unidad_ejecutora
  and numero_disponibilidad=    0 --:B_PRE_MODIFICACION_PPTAL.numero_disponibilidad;

 --usado para hacer el insert y actualizar apropiaciones
 CURSOR c_disp IS
  SELECT 
	     VIGENCIA, 
	     CODIGO_COMPANIA, 
			 CODIGO_UNIDAD_EJECUTORA, 
       --:B_PRE_MODIFICACION_PPTAL.TIPO_DOCUMENTO,
	     '01679' --:B_PRE_MODIFICACION_PPTAL.DOCUMENTOS_NUMERO,
	     RUBRO_INTERNO, 
			 'TRASLADO'  --:B_PRE_MODIFICACION_PPTAL.TIPO_MOVIMIENTO,
			 NUMERO_DISPONIBILIDAD, 
			 CODIGO_FUENTE, 
			 CODIGO_DET_FUENTE_FINANC, 
			 VALOR
	from pr_detalle_fuentes_cdp
	where vigencia=               2026  --:B_PRE_MODIFICACION_PPTAL.vigencia
	and rubro_interno=            1844  --:B_PRE_MODIFICACION_PPTAL.rubro_interno	
	and codigo_compania=          206 --:B_PRE_MODIFICACION_PPTAL.CODIGO_compania
	and codigo_unidad_ejecutora=  '01'  --:B_PRE_MODIFICACION_PPTAL.CODIGO_unidad_ejecutora
	and numero_disponibilidad=    0    --:B_PRE_MODIFICACION_PPTAL.NUMERO_DISPONIBILIDAD;
;

BEGIN
	
IF NVL(:B_PRE_MODIFICACION_PPTAL.NUMERO_DISPONIBILIDAD,0)<>0 or
	  :B_PRE_MODIFICACION_PPTAL.NUMERO_DISPONIBILIDAD IS NULL THEN
	    
   mi_vigencia := pk_pre_general.global_vigencia_consulta;
   mi_encontro:=pk_pr_detalle_fuentes.fn_pre_busca_entidad(:B_PRE_MODIFICACION_PPTAL.codigo_compania,mi_vigencia);
 
   OPEN c_disponibilidad;
   FETCH c_disponibilidad INTO mi_numero_cdp;
   IF c_disponibilidad%NOTFOUND THEN
      pr_despliega_mensaje('al_stop_1', 'No tiene detalle de disponibilidad');
   END IF;
   CLOSE c_disponibilidad;
   
 OPEN c_disp;
 

 LOOP
 	FETCH c_disp into reg_disp;
 	EXIT WHEN c_disp%NOTFOUND;
 	BEGIN
 	 	  INSERT INTO PR_DETALLE_FUENTES_MODIF 
	        (VIGENCIA, 
		       CODIGO_COMPANIA, 
		       CODIGO_UNIDAD_EJECUTORA, 
           TIPO_DOCUMENTO, 
           DOCUMENTOS_NUMERO, 
		       RUBRO_INTERNO, 
		       TIPO_MOVIMIENTO, 
		       NUMERO_DISPONIBILIDAD, 
		       CODIGO_FUENTE, 
		       CODIGO_DET_FUENTE_FINANC, 
		       VALOR_CONTRACREDITO)
          VALUES (
           reg_disp.vigencia,
           reg_disp.codigo_compania,
           reg_disp.unidad_ejecutora,
           :B_PRE_MODIFICACION_PPTAL.TIPO_DOCUMENTO,
	         :B_PRE_MODIFICACION_PPTAL.DOCUMENTOS_NUMERO,
           reg_disp.rubro_interno,
           :B_PRE_MODIFICACION_PPTAL.TIPO_MOVIMIENTO,
           reg_disp.numero_disponibilidad,
           reg_disp.codigo_fuente,
           reg_disp.codigo_detalle,
           reg_disp.valor);
     EXCEPTION
        	WHEN DUP_VAL_ON_INDEX THEN
          	   PR_DESPLIEGA_mensaje('AL_STOP_1','ERROR.. El registrro ya esta en la base');
          	   ROLLBACK;
          	   
          WHEN OTHERS THEN
          	   PR_DESPLIEGA_mensaje('AL_STOP_1','ERROR.. no se puede insertar el registro');
          	   ROLLBACK;
          	   
    END;
  
    BEGIN 
           UPDATE pr_detalle_fuentes_apropia 
           SET valor_modificaciones = NVL(valor_modificaciones,0) + NVL(reg_disp.valor*-1,0)
           WHERE vigencia = reg_disp.vigencia AND 
               codigo_compania = reg_disp.codigo_compania AND
               codigo_unidad_ejecutora = reg_disp.unidad_ejecutora AND
               rubro_interno = reg_disp.rubro_interno AND
               codigo_fuente=reg_disp.codigo_fuente AND
               codigo_det_fuente_financ=reg_disp.codigo_detalle;
          
      EXCEPTION
      	WHEN OTHERS THEN
       	    PR_DESPLIEGA_mensaje('AL_STOP_1','ERROR ACTUALIZANDO');
          	   ROLLBACK;
     END;               
     END LOOP;       
   CLOSE c_disp;