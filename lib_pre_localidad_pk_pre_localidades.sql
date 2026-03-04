   /*******************************************************************************  
   Nombre: fn_pre_traer_total_egr_ent
   Descripción : Devuelve el valor total de la apropiacion correspondiente
   a los egresos de una entidad
   *******************************************************************************/
   
   FUNCTION fn_pre_traer_total_egr_ent (una_vigencia NUMBER, una_entidad VARCHAR2) RETURN NUMBER IS
      mi_total_egresos NUMBER;
      mi_codigo1       bintablas.resultado%TYPE;
      mi_codigo2       bintablas.resultado%TYPE;
      mi_vigencia      VARCHAR2(10);
   BEGIN

       mi_vigencia := '01/01/'||TO_CHAR(una_vigencia);

       mi_codigo1 := 2: --p_bintablas.tbuscar('EGRESOS','PREDIS','CODIGOS_NIVEL',mi_vigencia);
       mi_codigo2 :=null; -- p_bintablas.tbuscar('DISP_FINAL','PREDIS','CODIGOS_NIVEL',mi_vigencia);
       mi_total_egresos := NULL;

       -- Asigna el total de egresos de la entidad

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
              (pr_nivel1.codigo = :mi_codigo1 OR pr_nivel1.codigo = :mi_codigo2) AND 
              pr_apropiacion_total.vigencia = :una_vigencia AND
              pr_apropiacion_total.codigo_compania = :una_entidad 
              and 12483615 in (NVL(pr_apropiacion_total.valor,0), NVL(pr_apropiacion_total.valor_modificaciones,0));
              --801084830385

         RETURN NVL(mi_total_egresos,0);
     
      EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
             RETURN 0; 
      
   END fn_pre_traer_total_egr_ent;

  /**********************************************************************************
   Nombre: fn_pre_traer_total_ing_ent
   Descripción: Devuelve el valor total de la apropiacion correspondiente
   a los ingresos de una entidad
  ***********************************************************************************/

   FUNCTION fn_pre_traer_total_ing_ent (una_vigencia NUMBER, una_entidad VARCHAR2) RETURN NUMBER IS
      mi_total_ingresos NUMBER;
      mi_codigo1        bintablas.resultado%TYPE;
      mi_codigo2        bintablas.resultado%TYPE;
      mi_vigencia       VARCHAR2(10);
   BEGIN
      mi_vigencia := '01/01/'||TO_CHAR(una_vigencia);

      mi_codigo1 := 1; --p_bintablas.tbuscar('INGRESOS','PREDIS','CODIGOS_NIVEL',mi_vigencia);
      mi_codigo2 := null; --p_bintablas.tbuscar('DISP_INICIAL','PREDIS','CODIGOS_NIVEL',mi_vigencia);
      mi_total_ingresos := NULL;

      -- Asigna el total de ingresos de la entidad

       SELECT   * --SUM(NVL(pr_apropiacion_total.valor,0)) + SUM(NVL(pr_apropiacion_total.valor_modificaciones,0)) 
       --INTO mi_total_ingresos
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
              (pr_nivel1.codigo = :mi_codigo1 OR pr_nivel1.codigo = :mi_codigo2) AND
              pr_apropiacion_total.vigencia = :una_vigencia AND
              pr_apropiacion_total.codigo_compania = :una_entidad
              and 12483615 in (NVL(pr_apropiacion_total.valor,0), NVL(pr_apropiacion_total.valor_modificaciones,0));
            801097674000

         RETURN NVL(mi_total_ingresos,0);
     
      EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
             RETURN 0; 

   END fn_pre_traer_total_ing_ent;


  /**********************************************************************************
   Nombre: fn_pre_traer_diferencia_ent
   Descripción: Devuelve el valor generado a de: Ingresos menos Egresos de 
   la entidad
  ***********************************************************************************/

   FUNCTION fn_pre_traer_diferencia_ent (una_vigencia NUMBER, una_entidad VARCHAR2) RETURN NUMBER IS

      mi_total_egresos  NUMBER;
      mi_total_ingresos NUMBER;
      mi_valor          NUMBER;
   BEGIN

      -- Inicializa las variables de los totales en NULL

      mi_total_egresos := NULL;
      mi_total_ingresos := NULL;

      -- Asigna el total de egresos de Administracion Central

      mi_total_egresos := pk_pre_localidades.fn_pre_traer_total_egr_ent (una_vigencia, una_entidad);

      -- Asigna el total de ingresos de Administracion Central

      mi_total_ingresos := pk_pre_localidades.fn_pre_traer_total_ing_ent (una_vigencia, una_entidad);

      -- Asigna a los items los valores correspondintes

      mi_valor := NVL(mi_total_egresos,0) - NVL(mi_total_ingresos,0);

      RETURN NVL(mi_valor,0);

  END fn_pre_traer_diferencia_ent;