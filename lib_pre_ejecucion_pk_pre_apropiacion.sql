  /**********************************************************************************
   Nombre: fn_pre_traer_diferencia_apr
   Descripción: Devuelve el valor generado a de: Ingresos menos Egresos de 
   Administración Central
  ***********************************************************************************/

   FUNCTION fn_pre_traer_diferencia_apr (una_vigencia NUMBER) RETURN NUMBER IS

      mi_total_egresos  NUMBER;
      mi_total_ingresos NUMBER;
      mi_valor          NUMBER;
   BEGIN

      -- Inicializa las variables de los totales en NULL

      mi_total_egresos := NULL;
      mi_total_ingresos := NULL;

      -- Asigna el total de egresos de Administracion Central

      mi_total_egresos := pk_pre_apropiacion.fn_pre_traer_total_egr (una_vigencia);

      -- Asigna el total de ingresos de Administracion Central

      mi_total_ingresos := pk_pre_apropiacion.fn_pre_traer_total_ing (una_vigencia);

      -- Asigna a los items los valores correspondintes

      mi_valor := NVL(mi_total_egresos,0) - NVL(mi_total_ingresos,0);

      RETURN NVL(mi_valor,0);

  END fn_pre_traer_diferencia_apr;

  FUNCTION fn_pre_traer_total_ing (una_vigencia NUMBER) RETURN NUMBER IS
      mi_total_ingresos NUMBER;
      mi_codigo         bintablas.resultado%TYPE;
      mi_vigencia       VARCHAR2(10);
   BEGIN
      mi_vigencia := '01/01/'||TO_CHAR(una_vigencia);

      mi_codigo := p_bintablas.tbuscar('INGRESOS','PREDIS','CODIGOS_NIVEL',mi_vigencia);

      mi_total_ingresos := NULL;

      -- Asigna el total de ingresos de Administracion Central

       SELECT   SUM(NVL(pr_apropiacion_total.valor,0)) + SUM(NVL(pr_apropiacion_total.valor_modificaciones,0)) 
            ---INTO mi_total_ingresos
         FROM pr_apropiacion_total,pr_rubro,pr_nivel8, pr_nivel7, pr_nivel6,
              pr_nivel5, pr_nivel4,pr_nivel3, pr_nivel2, pr_nivel1
         WHERE pr_apropiacion_total.rubro_interno = pr_rubro.interno AND
              pr_apropiacion_total.vigencia = pr_rubro.vigencia AND
              pr_rubro.vigencia = pr_nivel8.vigencia AND
              pr_rubro.interno_nivel8 = pr_nivel8.interno AND
              pr_rubro.vigencia = pr_nivel7.vigencia AND
              pr_rubro.interno_nivel7 = pr_nivel7.interno AND
              pr_rubro.vigencia = pr_nivel6.vigencia AND
              pr_rubro.interno_nivel6 = pr_nivel6.interno AND
              pr_rubro.vigencia = pr_nivel5.vigencia AND
              pr_rubro.interno_nivel5 = pr_nivel5.interno AND
              pr_rubro.vigencia = pr_nivel4.vigencia AND
              pr_rubro.interno_nivel4 = pr_nivel4.interno AND
              pr_rubro.vigencia = pr_nivel3.vigencia AND
              pr_rubro.interno_nivel3 = pr_nivel3.interno AND
              pr_rubro.vigencia = pr_nivel2.vigencia AND
              pr_rubro.interno_nivel2 = pr_nivel2.interno AND
              pr_rubro.vigencia = pr_nivel1.vigencia AND
              pr_rubro.interno_nivel1 = pr_nivel1.interno AND
              pr_nivel1.codigo = :mi_codigo_1 AND
              pr_apropiacion_total.vigencia = :una_vigencia AND
              (pr_apropiacion_total.codigo_compania IN (SELECT codigo_compania 
                                                  FROM pr_companias_total 
                                                  WHERE pr_companias_total.clasificacion = 'ADMONCENTRAL'));


         RETURN NVL(mi_total_ingresos,0);
     
      EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
             RETURN 0; 

   END fn_pre_traer_total_ing;


    FUNCTION fn_pre_traer_total_egr (una_vigencia NUMBER) RETURN NUMBER IS
      mi_total_egresos NUMBER;
      mi_codigo        bintablas.resultado%TYPE;
      mi_vigencia      VARCHAR2(10);
   BEGIN

       mi_vigencia := '01/01/'||TO_CHAR(una_vigencia);

       mi_codigo := p_bintablas.tbuscar('EGRESOS','PREDIS','CODIGOS_NIVEL',mi_vigencia);

       mi_total_egresos := NULL;

       -- Asigna el total de egresos de las entidades que pertenecen a
       -- Administracion Central

       SELECT  SUM(NVL(pr_apropiacion_total.valor,0)) + SUM(NVL(pr_apropiacion_total.valor_modificaciones,0)) 
       --INTO mi_total_egresos 
         FROM pr_apropiacion_total,pr_rubro,pr_nivel8, pr_nivel7, pr_nivel6,
              pr_nivel5, pr_nivel4,pr_nivel3, pr_nivel2, pr_nivel1
         WHERE pr_apropiacion_total.rubro_interno = pr_rubro.interno AND
              pr_apropiacion_total.vigencia = pr_rubro.vigencia AND
              pr_rubro.vigencia = pr_nivel8.vigencia AND
              pr_rubro.interno_nivel8 = pr_nivel8.interno AND
              pr_rubro.vigencia = pr_nivel7.vigencia AND
              pr_rubro.interno_nivel7 = pr_nivel7.interno AND
              pr_rubro.vigencia = pr_nivel6.vigencia AND
              pr_rubro.interno_nivel6 = pr_nivel6.interno AND
              pr_rubro.vigencia = pr_nivel5.vigencia AND
              pr_rubro.interno_nivel5 = pr_nivel5.interno AND
              pr_rubro.vigencia = pr_nivel4.vigencia AND
              pr_rubro.interno_nivel4 = pr_nivel4.interno AND
              pr_rubro.vigencia = pr_nivel3.vigencia AND
              pr_rubro.interno_nivel3 = pr_nivel3.interno AND
              pr_rubro.vigencia = pr_nivel2.vigencia AND
              pr_rubro.interno_nivel2 = pr_nivel2.interno AND
              pr_rubro.vigencia = pr_nivel1.vigencia AND
              pr_rubro.interno_nivel1 = pr_nivel1.interno AND
              pr_nivel1.codigo = :mi_codigo_2 AND 
              pr_apropiacion_total.vigencia = :una_vigencia AND
              (pr_apropiacion_total.codigo_compania IN (SELECT codigo_compania 
                                                  FROM pr_companias_total
                                                  WHERE pr_companias_total.clasificacion = 'ADMONCENTRAL'));

         RETURN NVL(mi_total_egresos,0);
     
      EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
             RETURN 0; 
      
   END fn_pre_traer_total_egr;
