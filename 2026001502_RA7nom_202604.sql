  --Botón click crear RA
   -- CURSOR  c_ra  IS
    SELECT nro_ra, nro_ra_opget, vigencia, vigencia_presupuesto, numero_compromiso, aprobacion
    FROM   rh_lm_ra
    WHERE  scompania              = 206     --:parameter.p_compania
    AND    tipo_ra                = '1'       --:parameter.p_tipo_ra
    AND    grupo_ra               = 5       --:parameter.p_grupo_ra
    AND    dfecha_inicial_periodo = '01/APR/2026'   --:parameter.p_fecha_inicial
    AND    dfecha_final_periodo   = '30/APR/2026'   --:parameter.p_fecha_final
    AND    ntipo_nomina           = 0       --:parameter.p_tipo_nomina
    ORDER BY vigencia_presupuesto
    ;


  --CURSOR c_cc_ra (un_cc NUMBER) IS
	  SELECT * --SUM(a.valor) valor
	  FROM   rh_t_lm_valores a, rh_lm_cuenta b
	  WHERE  b.stipo_funcionario = a.stipofuncionario
	  AND    b.sconcepto         = a.sconcepto
	  AND    a.periodo           = '30/APR/2026'  --una_fecha_final
	  AND    a.ntipo_nomina      = 0      --un_tipo_nomina
	  AND    a.nro_ra            = 1      --un_nro_ra
	  AND    b.scompania         = 206    --una_compania
	  AND    b.tipo_ra           = '1'      --un_tipo_ra
	  AND    b.grupo_ra          IN (5)   --un_grupo_ra)
	  AND    b.ncierre           = 1
	  AND    b.cc                = 1      --un_cc
	  -- RQ2523-2005   05/12/2005
    AND   b.dfecha_inicio_vig <= '30/APR/2026' --una_fecha_final
    AND  (b.dfecha_final_vig  >= '30/APR/2026' /*una_fecha_final*/ OR b.dfecha_final_vig IS NULL)
    ;

-- CURSOR c_cc IS
  	SELECT * --a.codigo, a.descripcion, a.codigo_maestro, c.tipo_ra_ogt, c.codigo_opget
      FROM rh_lm_centros_costo a, rh_lm_ra_cc b, rh_lm_ra_cc_ogt c
     WHERE a.codigo   = b.cc
       AND b.ra       = c.ra
       AND b.transaccion = c.transaccion
       AND b.cc       = c.cc
       AND b.ra       = 1     --un_tipo_ra
       AND c.grupo_ra = 5   --un_grupo_ra
       ;

 -- CURSOR     c_nxp (un_nro_ra  NUMBER)     IS
    SELECT   SUM(valor) valor
	  FROM     rh_t_lm_valores a, rh_lm_cuenta b
	  WHERE    b.stipo_funcionario =   a.stipofuncionario
	  AND      b.sconcepto         =   a.sconcepto
	  AND      a.periodo           =   '30/APR/2026'    --una_fecha_final
	  AND      a.ntipo_nomina      =   0                --un_tipo_nomina	
    AND      a.sdevengado       IN   (0,1)
	  AND      a.nro_ra            =   7                --un_nro_ra	
	  AND      b.scompania         =   206              --una_compania
	  AND      b.tipo_ra           =   '1'              --un_tipo_ra
	  AND      b.grupo_ra         IN  ('5')             --un_grupo_ra)
	  AND      b.ncierre           =   1
	  -- RQ2523-2005   05/12/2005
    AND   b.dfecha_inicio_vig <= '30/APR/2026'        --una_fecha_final
    AND  (b.dfecha_final_vig  >= '30/APR/2026'  /*una_fecha_final*/ OR b.dfecha_final_vig IS NULL)
    ;
    -- Fin RQ2523	       
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
       select *
       from rh_lm_centros_costo
       where codigo=1
       ;

       select *
       from rh_lm_ra_cc
       where cc=1 
       ;

       select *
       from rh_lm_ra_cc_ogt
       where c.ra in 1
       and b.transaccion = 0
       ;

---llenar tabla anexos

 --CURSOR cur_anexos  IS
    SELECT a.codigo, a.descripcion, a.tabla_detalle, c.tipo_ra_ogt, c.codigo_opget
      FROM rh_lm_centros_costo a, rh_lm_ra_cc b, rh_lm_ra_cc_ogt c
     WHERE a.codigo   = b.cc
       AND b.ra       = c.ra
       AND b.transaccion = c.transaccion
       AND b.cc       = c.cc
       AND b.ra       = '1'             --un_tipo_ra
       AND c.grupo_ra = '5'             --un_grupo_ra
       ;

--cur_nxp 
--  CURSOR cur_nxp (un_nro_ra  NUMBER)     IS
    SELECT nfuncionario, SUM(valor) valor
	    FROM rh_t_lm_valores a, rh_lm_cuenta b
	   WHERE b.stipo_funcionario =   a.stipofuncionario
	     AND b.sconcepto         =   a.sconcepto
	     AND a.periodo           =   '30/APR/2026'      --una_fecha_final
	     AND a.ntipo_nomina      =   0                  --un_tipo_nomina	
            AND a.sdevengado       IN   (0,1)
	     AND a.nro_ra            =   7  --un_nro_ra	
	     AND b.scompania         =  206                 -- una_compania
	     AND b.tipo_ra           = 1                    --  un_tipo_ra
	     AND b.grupo_ra         = '5'                    --IN  (un_grupo_ra)
	     AND b.ncierre           =   1
	     -- RQ2523-2005   05/12/2005
       AND   b.dfecha_inicio_vig <= '30/APR/2026'       --una_fecha_final
       AND  (b.dfecha_final_vig  >= '30/APR/2026' /*una_fecha_final*/ OR b.dfecha_final_vig IS NULL)
       -- Fin RQ2523
      Having Sum(valor) <> 0
	  GROUP BY nfuncionario;

--mi_persona_type:=pk_detalle_anexos_ra.fn_detalle_personas (mi_funcionario, mi_err);
--Ocurrió un error al recuperar información de beneficiarios 613      
 --CURSOR c_personas IS
    SELECT tipo_documento, numero_identificacion, nombres, primer_apellido, segundo_apellido
    FROM   rh_personas
    WHERE interno_persona = 613 --una_persona  53116209
    ;



select *
  from rh_t_lm_valores a
 where trunc(a.periodo) = TO_DATE('30-04-2026', 'DD-MM-YYYY')
   AND a.ntipo_nomina = 0
   AND a.sdevengado IN (0, 1)
   AND a.nro_ra = 7
   and a.nfuncionario = 613
   and a.sconcepto='CSINDICATO'
   ;
   