--CURSOR cur_cuenta_afectable IS
     SELECT /*+     full(top) */   
     top.id tiop_id,top.titr_nombre titr_nombre,top.cltr_nombre cltr_nombre,caf.cuco_codigo codigo,caf.d_c d_c
     ,top.cote_id , top.destinacion_especifica, top.titr_nombre
      FROM ogt_tipo_operacion top,
           ogt_cuenta_afectable caf
     WHERE NVL(top.bin_tipo_cuenta,'0')           = 'FD' --mi_tipo_cuenta_bancaria
       AND NVL(top.cote_id,'0')                 = '00-02-37-18-00-00-00' --mi_concepto_ingreso
       AND NVL(top.unte_codigo,'0')               = 'FINANCIERO' --mi_unidad_ingreso
       AND NVL(top.bin_tipo_titulo,'0')           = 0 --mi_tipo_titulo
       AND NVL(top.bin_tipo_emisor_titulo,'0')    = 0  --mi_tipo_emisor   --NUEVO
       AND NVL(top.tipo_resultado,'0')            = 0 --mi_tipo_resultado --NUEVO
       AND NVL(top.bin_vigencia_concepto,'0')     = '0' --mi_vigencia_ingreso
       AND NVL(top.destinacion_especifica,'N' /*mi_destinacion_especifica*/) = 'S' --mi_destinacion_especifica
      AND top.titr_nombre = DECODE('SISTEMA FINANCIERO' /*mi_tipo_transaccion_contable*/,'NO_AJUSTE',top.titr_nombre,'SISTEMA FINANCIERO' /*mi_tipo_transaccion_contable*/)  
      --cambia XYX por SISTEMA FINANCIERO
       AND top.titr_nombre NOT IN (DECODE('SISTEMA FINANCIERO'/*mi_tipo_transaccion_contable*/,'NO_AJUSTE','AJUSTE DE INGRESO','NO_AJUSTE'))
       AND NVL(top.tipo_moneda,'N'/*mi_tipo_moneda*/) = 'N' --mi_tipo_moneda
       AND caf.tiop_id = top.id
       AND caf.d_c IN (1,0)
  ORDER BY TO_NUMBER(SUBSTR(REPLACE(caf.cuco_codigo,'-',''),1,6));


     select *
        from ogt_concepto_tesoreria
       where descripcion in ('RECAUDO CAPITAL CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA',
       'RECAUDO INTERESES CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA');


SELECT * --NVL(destinacion_especifica,'N') destinacion_especifica,decode(tipo_moneda,'COP','N','E') tipo_moneda, sucu_ter_id
     FROM ogt_cuenta_bancaria
    WHERE numero='482800043630' --mi_numero_cuenta
      AND tipo='FD' --mi_tipo_cuenta_bancaria
      AND sucu_ter_id=51 ;--mi_entidad_financiera;       
      482800043630
      