CREATE OR REPLACE PACKAGE "PR".Pk_Pr_Detalle_Fuentes IS
/*Cursor utilizado para cargar los datos del tdetalle de fuentes de financiacion del modulo de programacion*/

TYPE TypRec_fuentes IS RECORD (codigo_fuente PR_DETALLE_FUENTES_APROPIA.codigo_fuente%TYPE,
	     				       codigo_det_fuente_financ PR_DETALLE_FUENTES_APROPIA.codigo_det_fuente_financ%TYPE,
						       valor PR_DETALLE_FUENTES_APROPIA.valor%TYPE);

   -- Cursor de rubros presupuestales
TYPE cur_c_temporal IS REF CURSOR RETURN TypRec_fuentes;

--INI 2025002524 
TYPE TypRec_valFuentes IS RECORD (codigo_fuente  pr_fuentes_financiacion.codigo%TYPE,
                                  desc_fuente    pr_detalle_fuentes.descripcion%TYPE,
                                  codigo_detalle pr_detalle_fuentes.consecutivo_fuente%TYPE,
                                  desc_detalle   pr_detalle_fuentes.descripcion%TYPE,
                                   valor          pr_detalle_fuentes_apropia.valor%TYPE);

TYPE cur_c_valFuentes IS REF CURSOR RETURN TypRec_valFuentes;

--INIRQ1723-2007 P345 
/*-----------------------------------------------------------------------------
Cursor que contiene el detalle de las fuentes
-----------------------------------------------------------------------------*/                                
FUNCTION fn_cursor_valFuentes  (una_vigencia    pr_apropiacion.vigencia%TYPE,
                                una_compania    pr_apropiacion.codigo_compania%TYPE,
                                una_unidad      pr_apropiacion.codigo_unidad_ejecutora%TYPE,
                                un_rubro        pr_detalle_fuentes_apropia.rubro_interno%TYPE,
                                un_cdp          pr_detalle_fuentes_cdp.numero_disponibilidad%TYPE,
                                un_rp           pr_detalle_fuentes_rp.numero_registro%TYPE
                               )
 RETURN Pk_Pr_Detalle_Fuentes.cur_c_valFuentes;
--FINRQ1723-2007 P345 
--FINRQ1995-2006 


--FIN 2025002524 

/********************************************************
 Funcion: fn_carga_apropia_det_ftes
 Descripcion: Carga los registros de detalle de fuentes de financiacion (de programacion)
              en la tabla pr_detalle_fuentes_apropia
 Entradas: Vigencia
           Rubro
           Compania
           Unidad ejecutora
           Clasificacion (ADMONCENTRAL)
           Cursor que contiene el detalle de las fuentes
 Salidas: 1  Ejecuta la Isercion
          0 no puede realizar la insercion

 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/

FUNCTION fn_carga_apropia_det_ftes (una_vigencia      PR_APROPIACION.vigencia%TYPE,
          						    un_rubro          PR_APROPIACION.rubro_interno%TYPE,
							        una_compania      PR_APROPIACION.codigo_compania%TYPE,
									una_unidad        PR_APROPIACION.codigo_unidad_ejecutora%TYPE,
  								    una_clasificacion PR_DETALLE_FUENTES.clasificacion%TYPE,
									un_cursor         Pk_Pr_Detalle_Fuentes.cur_c_temporal) RETURN NUMBER;

 /********************************************************
 Funcion: fn_pre_ins_apropia
 Descripcion: Inserta los registros correspondientes al detalle de fuentes de financiciacion
 Entradas: Vigencia
           Rubro
		   Compania
           Unidad ejecutora
		   Clasificacion (ADMONCENTRAL)
		   Cursor que contiene el detalle de las fuentes
 Salidas: 1  Ejecuta la Isercion
          0 no puede realizar la insercion
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/

FUNCTION fn_pre_ins_apropia (una_vigencia      PR_APROPIACION.vigencia%TYPE,
          					 un_rubro          PR_APROPIACION.rubro_interno%TYPE,
							 una_compania      PR_APROPIACION.codigo_compania%TYPE,
							 una_unidad        PR_APROPIACION.codigo_unidad_ejecutora%TYPE,
							 un_codigo_fuente  PR_DETALLE_FUENTES_APROPIA.codigo_fuente%TYPE,
							 un_detalle_fuente PR_DETALLE_FUENTES_APROPIA.codigo_det_fuente_financ%TYPE,
							 una_clasificacion PR_DETALLE_FUENTES.clasificacion%TYPE,
							 un_valor          PR_DETALLE_FUENTES_APROPIA.valor%TYPE)
							 RETURN NUMBER;


/********************************************************
 Funcion: fn_cursor
 Descripcion: Crea el cursor que contiene el detalle de las fuentes de financiacion
 Entradas: Vigencia
           Rubro
           Compania
           Unidad ejecutora

 Salidas:  Cursor que contiene el detalle de las fuentes
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

*********************************************************/
FUNCTION fn_cursor  (una_vigencia      PR_APROPIACION.vigencia%TYPE,
          			 un_rubro          PR_APROPIACION.rubro_interno%TYPE,
					 una_compania      PR_APROPIACION.codigo_compania%TYPE,
					 una_unidad        PR_APROPIACION.codigo_unidad_ejecutora%TYPE)
					 RETURN Pk_Pr_Detalle_Fuentes.cur_c_temporal;


/********************************************************
 Funcion: fn_pre_traer_desc_fuente
 Descripcion: trae la descripcion de una fuente de financiacion
 Entradas: Codigo de la fuente
 Salidas:  Descripcion de la fuente.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/

FUNCTION fn_pre_traer_desc_fuente (una_fuente VARCHAR) RETURN VARCHAR2 ;

/********************************************************
 Funcion: fn_pre_traer_desc_det_fuente
 Descripcion: trae la descripcion de un detalle de fuente de financiacion
 Entradas: Codigo del detalle de la fuente
           Vigencia
           Codigo Fuente
           Clasificacion
 Salidas:  Descripcion del detalle de la fuente.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/
FUNCTION fn_pre_traer_desc_det_fuente (un_detalle_fuente NUMBER,
                                       una_vigencia NUMBER,
                                       un_codigo_fuente VARCHAR,
                                       una_clasificacion VARCHAR) RETURN VARCHAR;


/********************************************************
 Funcion: fn_busca_entidad
 Descripcion: Busca una entidad para determinar si la entidad
              tiene autorizadas las fuuentes de fu?inanciacion
 Entradas: Codigo_entidad
 Salidas: Falso: si no encuentra la entidad
          Verdadero: Si la emtidad esta registrada
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/

FUNCTION fn_pre_busca_entidad( un_codigo_compania VARCHAR2,
                               una_vigencia       NUMBER ) RETURN BOOLEAN;


/********************************************************
 Procedimiento: pr_pre_ins_anula_total_detalle
 Descripcion:Insertqa los regostros correspondientes  al detalle de fuentes de financiacion
             cuando se hacen anulaciones totales de CDP's
 Entradas: vigencia, codigo_compania, numero_documento , documento_anulado
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/

PROCEDURE pr_pre_ins_anula_total_detalle (una_vigencia          NUMBER,
                                          un_codigo_compania    VARCHAR2,
                                          una_unidad_ejecutora  VARCHAR2,
                                          un_numero_documento   NUMBER,
										  un_documento_anulado  VARCHAR2);


/********************************************************
 Procedimiento: pr_pre_ins_anula_total_deta_rp
 Descripcion:Inserta anulacioens totales de los registros correspondientes
             al detalle de fuentes de financiacion
             cuando se hacen anulaciones totales de CDP's
 Entradas: vigencia, codigo_compania, numero_documento , documento_anulado

 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o
 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/

PROCEDURE pr_pre_ins_anula_total_deta_rp ( una_vigencia            NUMBER,
                                           un_codigo_compania      VARCHAR2,
                                           una_unidad_ejecutora    VARCHAR2,
                                           un_numero_documento     NUMBER,  --NUMERO DEL RP
										   un_documento_anulado    VARCHAR2 -- RP
                                             );



/*********************************************r***********
 Procedimiento: pr_pre_ins_anula_total_deta_op
 Descripcion:Inserta los registros correspondientes al detalle de fuentes de financiacion
             cuando se hacen anulaciones totales de Ordenes de Pago
 Entradas: vigencia, codigo_compania, numero_documento , documento_anulado
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o
 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/

PROCEDURE pr_pre_ins_anula_total_deta_op ( una_vigencia               NUMBER,
                                           un_codigo_compania         VARCHAR2,
                                           una_unidad_ejecutora       VARCHAR2,
                                           un_numero_documento        NUMBER,  --NUMERO DEL RP
										   un_documento_anulado       VARCHAR2 -- RP
                                             );

 /********************************************************
 Procedimiento: pr_pre_ins_anul_total_det_reser
 Descripcion:Inserta los regIstros correspondientes al detalle de fuentes de financiacion
             cuando se hacen anulaciones totales de reservas (CDP's)
 Entradas: vigencia, codigo_compania, numero_documento , documento_anulado
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o
 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/

PROCEDURE pr_pre_ins_anulTot_det_reser (  una_vigencia          NUMBER,
                                          un_codigo_compania    VARCHAR2,
                                          una_unidad_ejecutora  VARCHAR2,
                                          un_numero_documento   NUMBER,
										  un_documento_anulado  VARCHAR2,
										  un_numero_registro    NUMBER,
										  un_consecutivo_orden  NUMBER);


/********************************************************
 Procedimiento: pr_pre_insanulTot_det_reseRp
 Descripcion:Inserta los regostros correspondientes al detalle de fuentes de financiacion
             cuando se hacen anulaciones totales de reservas (CDP's)
 Entradas: vigencia, codigo_compania, numero_documento , documento_anulado
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o
 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/

PROCEDURE pr_pre_insanulTot_det_reseRp (una_vigencia          NUMBER,
                                        un_codigo_compania    VARCHAR2,
                                        una_unidad_ejecutora  VARCHAR2,
                                        un_numero_documento   NUMBER,
									    un_documento_anulado  VARCHAR2,
										un_numero_registro    NUMBER,
										un_consecutivo_orden  NUMBER);


 /********************************************************
 Procedimiento: pr_pre_insanulTot_det_reseOp
 Descripcion:Inserta los registros correspondientes al detalle de fuentes de financiacion
             cuando se hacen anulaciones totales de reservas (Ordenes de Pago )
 Entradas: vigencia, codigo_compania, numero_documento , documento_anulado
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o
 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/

PROCEDURE pr_pre_insanulTot_det_reseOp (una_vigencia          NUMBER,
                                        un_codigo_compania    VARCHAR2,
                                        una_unidad_ejecutora  VARCHAR2,
                                        un_numero_documento   NUMBER,
									    un_documento_anulado  VARCHAR2,
										un_numero_registro    NUMBER,
										un_consecutivo_orden  NUMBER);



/***********************************************************************************************
 Funcion: fn_pre_cuenta_registros_apro
 Descripcion:Trae el total de registros de detalle de apropiaciones
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora
 Salidas : Total de Registros de detalle de apropiaciones.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 ***********************************************************************************************/

FUNCTION fn_pre_cuenta_registros_apro(una_vigencia               NUMBER,
                                      un_rubro_interno           NUMBER,
                                      una_compania               VARCHAR2,
                                      una_unidad_ejecutora       VARCHAR2
                                      )RETURN NUMBER;

/***********************************************************************************************
 Funcion: fn_pre_cuenta_registros
 Descripcion:Trae el total de registros de detalle de disponibilidades para un rubro
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora
 Salidas : Total de Registros de detalle de apropiaciones.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 ***********************************************************************************************/

FUNCTION fn_pre_cuenta_registros(una_vigencia              NUMBER,
                                 un_rubro_interno          NUMBER,
                                 una_compania              VARCHAR2,
                                 una_unidad_ejecutora      VARCHAR2,
                                 un_numero_disponibilidad  NUMBER)RETURN NUMBER;


/***********************************************************************************************
 Funcion: fn_pre_cuenta_registrosT
 Descripcion:Trae el total de registros de detalle de disponibilidades para un rubro
 en la tabla temporal de disponibilidades
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora
 Salidas : Total de Registros de detalle de apropiaciones.
 Fecha             Octubre 2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 ***********************************************************************************************/

FUNCTION fn_pre_TraeAcum_CDPT(una_vigencia              NUMBER,
                              un_rubro_interno          NUMBER,
                              una_compania              VARCHAR2,
                              una_unidad_ejecutora      VARCHAR2,
                              un_usuario                VARCHAR2,
							  un_consec_user            NUMBER)
							  RETURN NUMBER;


/***********************************************************************************************
 Funcion: fn_pre_cuenta_registros_rp
 Descripcion:Trae el total de registros de detalle de rp para
             un rubro
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, Numero disponibilidad, Numero Registro
           presupuestal.

 Salidas : Total de Registros de Rp.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 ***********************************************************************************************/

FUNCTION fn_pre_cuenta_registros_rp(una_vigencia               NUMBER,
                                    un_rubro_interno           NUMBER,
                                    una_compania               VARCHAR2,
                                    una_unidad_ejecutora       VARCHAR2,
                                    un_numero_disponibilidad   NUMBER,
								    un_numero_registro         NUMBER )RETURN NUMBER;



/***********************************************************************************************
 Funcion: fn_pre_cuenta_registros_op
 Descripcion:Trae el total de registros de detalle de rp para
             un rubro
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, Numero disponibilidad, Numero Registro
           presupuestal.

 Salidas : Total de Registros de Ordenes de pago.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 ***********************************************************************************************/


FUNCTION fn_pre_cuenta_registros_op(una_vigencia                 NUMBER,
                                    un_rubro_interno             NUMBER,
                                    una_compania                 VARCHAR2,
                                    una_unidad_ejecutora         VARCHAR2,
                                    un_numero_disponibilidad     NUMBER,
            			            un_numero_registro           NUMBER,
    		            		    un_numero_orden              NUMBER,
                                    un_consecutivo_orden         NUMBER ) RETURN NUMBER;


/***********************************************************************************************
 Funcion: fn_pre_cuenta_registros_reint
 Descripcion:Trae el total de registros de detalle de reintgegros.
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, Numero disponibilidad, Numero Registro
           presupuestal, numero_orden, consecutivo_orden, consecutivo_ajuste.

 Salidas : Total de Registros de reintegros (de detalle fuentes) .
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 ***********************************************************************************************/
FUNCTION fn_pre_cuenta_registros_reint (una_vigencia                 NUMBER,
                                        un_rubro_interno             NUMBER,
                                        una_compania                 VARCHAR2,
                                        una_unidad_ejecutora         VARCHAR2,
                                        un_numero_disponibilidad     NUMBER,
		                		        un_numero_registro           NUMBER,
				                        un_numero_orden              NUMBER,
                                        un_consecutivo_orden         NUMBER,
										un_consecutivo_ajuste        NUMBER ) RETURN NUMBER;



/***********************************************************************************************
 Funcion: fn_pre_cuenta_registros_ajust
 Descripcion:Trae el total de registros de detalle de los ajustes.
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, Numero disponibilidad, Numero Registro
           presupuestal, numero_orden, consecutivo_orden, consecutivo_ajuste.

 Salidas : Total de Registros de ajustes  (de detalle fuentes) .
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 ***********************************************************************************************/


FUNCTION fn_pre_cuenta_registros_ajust (una_vigencia                 NUMBER,
                                        un_rubro_interno             NUMBER,
                                        una_compania                 VARCHAR2,
                                        una_unidad_ejecutora         VARCHAR2,
                                        un_numero_disponibilidad     NUMBER,
		                		        un_numero_registro           NUMBER,
				                        un_numero_orden              NUMBER,
                                        un_consecutivo_orden         NUMBER,
										un_consecutivo_ajuste        NUMBER ) RETURN NUMBER;



/***********************************************************************************************
 Funcion: fn_pre_cuenta_registros_res
 Descripcion:Trae el total de registros de detalle de anulacion parcial de reservas.
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, Numero disponibilidad, Numero Registro
           presupuestal,consecutivo_anulacion.

 Salidas : Total de Registros de anulacion parcial de reservas .
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_cuenta_registros_res(una_vigencia                NUMBER,
                                     un_rubro_interno            NUMBER,
                                     una_compania                VARCHAR2,
                                     una_unidad_ejecutora        VARCHAR2,
                                     un_numero_disponibilidad    NUMBER,
								     un_numero_registro          NUMBER,
									 un_consecutivo_anulacion    NUMBER ) RETURN NUMBER;


/***********************************************************************************************
 Funcion: fn_pre_cuenta_reg_modif
 Descripcion:trae el total de registros detallados en las modificaciones
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, Numero disponibilidad, Numero Registro
           presupuestal,consecutivo_anulacion.

 Salidas : Total de Registros de anulacion parcial de reservas .
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_cuenta_reg_modif (una_vigencia                NUMBER,
                                  una_compania                VARCHAR2,
                                  una_unidad_ejecutora        VARCHAR2,
	                              un_tipo_documento           VARCHAR2,
								  un_documentos_numero        NUMBER,
                                  un_rubro_interno            NUMBER,
								  un_tipo_movimiento          VARCHAR2,
                                  un_numero_disponibilidad    NUMBER)
								  RETURN NUMBER;



/***********************************************************************************************
 Funcion: fn_pre_cuenta_cdp_anulados
 Descripcion:trae el total de registros detallados en la anulacion de disponiobuilidades
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, Numero disponibilidad, Numero Registro
           presupuestal,consecutivo_anulacion.

 Salidas : Total de Registros de anulacion parcial de reservas .
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_cuenta_cdp_anulados (mi_vigencia               NUMBER,
                                    mi_rubro_interno           NUMBER,
                                    mi_compania                VARCHAR2,
                                    mi_unidad_ejecutora        VARCHAR2,
                                    mi_numero_disponibilidad   NUMBER,
								    mi_numero_registro         NUMBER,
									mi_consec_anulacion        NUMBER )RETURN NUMBER;

 /***********************************************************************************************
 Funcion: fn_pre_traer_valor_apropia
 Descripcion:Trae el valor de la apropiacion para un rubro
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora

 Salidas : Valor  de la apropiacion para un rubro
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :
***********************************************************************************************/


FUNCTION fn_pre_traer_valor_apropia(una_vigencia           NUMBER,
                                una_compania               VARCHAR2,
								una_unidad_ejecutora       VARCHAR2,
                                un_rubro_interno           NUMBER
                                ) RETURN NUMBER;

/***********************************************************************************************
 Funcion: fn_pre_traer_valor_det_apro
 Descripcion:Trae el valor de la apropiacion vigente de una fuente de financiacion
             parte de requerimiento RQ160
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro,fuente de financiacion
           detalle de la fuente, calsificacion
 Salidas : Valor apropiacion vigente de una fuente
 Fecha             Febrero de 2005
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones : RQ160: Se a?ade valor_cambio para CAMBIO_FUENTES
 Fecha          :
 Responsable    :
 Descripcion    :
 ***********************************************************************************************/

FUNCTION fn_pre_traer_valor_det_apro(una_vigencia          NUMBER,
                                una_compania               VARCHAR2,
								una_unidad_ejecutora       VARCHAR2,
                                un_rubro_interno           NUMBER,
								una_fuente                 VARCHAR2,
								un_detalle_fuente          NUMBER,
								una_clasificacion          VARCHAR2
                                ) RETURN NUMBER;

/***********************************************************************************************
 Funcion: fn_pre_traer_valor_cdp
 Descripcion:Trae el valor de detalle de disponibilidades de una fuente de financiacion
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro,fuente de financiacion
           detalle de la fuente, calsificacion
 Salidas : suma de valor  detallado para la fuente de financiacion en los CDP's
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/
FUNCTION fn_pre_traer_valor_cdp (una_vigencia               NUMBER,
                                 una_compania               VARCHAR2,
								 una_unidad_ejecutora       VARCHAR2,
                                 un_rubro_interno           NUMBER,
                                 un_numero_disponibilidad   NUMBER,
								 una_fuente                 VARCHAR2,
								 un_detalle_fuente          NUMBER,
								 una_clasificacion          VARCHAR2) RETURN NUMBER;


/***********************************************************************************************
 Funcion: fn_pre_traer_valor_acum_cdp  (disponibilidades)
 Descripcion:Trae la suma de valor de detalle de una fuente de financiacion en las sisponibilidades
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro,fuente de financiacion
           detalle de la fuente, calsificacion
 Salidas : suma de valor  detallado para la fuente de financiacion en los CDP's
 Modificaciones :
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_val_acum_cdp (una_vigencia            NUMBER,
                                    una_compania            VARCHAR2,
								    una_unidad_ejecutora    VARCHAR2,
                                    un_rubro_interno        NUMBER,
   	 							    una_fuente              VARCHAR2,
								    un_detalle_fuente       NUMBER,
								    una_clasificacion       VARCHAR2) RETURN NUMBER;

/***********************************************************************************************
 Funcion: fn_pre_traer_valor_rp
 Descripcion:Trae la suma de valor de detalle de una fuente de financiacion en los registros presupuestales
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro,fuente de financiacion
           detalle de la fuente, calsificacion
 Salidas : suma de valor  detallado para la fuente de financiacion en los CDP's
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :
***********************************************************************************************/

FUNCTION fn_pre_traer_valor_rp (una_vigencia               NUMBER,
                                una_compania               VARCHAR2,
								una_unidad_ejecutora       VARCHAR2,
                                un_rubro_interno           NUMBER,
                                un_numero_disponibilidad   NUMBER,
								una_fuente                 VARCHAR2,
								un_detalle_fuente          NUMBER,
								una_clasificacion          VARCHAR2,
								un_numero_registro         NUMBER) RETURN NUMBER;



/***********************************************************************************************
 Funcion: fn_pre_traer_valor_rp
 Descripcion:trae el valor detalllado del op
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro,fuente de financiacion
           detalle de la fuente, calsificacion
 Salidas : suma de valor  detallado para la fuente de financiacion en los CDP's
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_op (una_vigencia               NUMBER,
                                una_compania               VARCHAR2,
								una_unidad_ejecutora       VARCHAR2,
                                un_rubro_interno           NUMBER,
                                un_numero_disponibilidad   NUMBER,
								una_fuente                 VARCHAR2,
								un_detalle_fuente          NUMBER,
								una_clasificacion          VARCHAR2,
								un_numero_registro         NUMBER,
								un_numero_orden            NUMBER,
								un_consecutivo_orden       NUMBER
								  ) RETURN NUMBER;



/***********************************************************************************************
 Funcion: ffn_pre_traer_valor_pagado
 Descripcion:Trae la suma de valor de ordenes de pago de detalle de una fuente de financiacion
 acumulada por numero disponibilidad, rubro y un registro_presupuestal
 Salidas : suma de valor  detallado para la fuente de financiacion en los OP's
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/
FUNCTION fn_pre_traer_valor_pagado (una_vigencia               NUMBER,
                                    una_compania               VARCHAR2,
								    una_unidad_ejecutora       VARCHAR2,
                                    un_rubro_interno           NUMBER,
                                    un_numero_disponibilidad   NUMBER,
								    una_fuente                 VARCHAR2,
								    un_detalle_fuente          NUMBER,
								    un_numero_registro         NUMBER
     								 ) RETURN NUMBER;

/***********************************************************************************************
 Funcion: fn_pre_saldo_op_reservas
 Descripcion:Trae el saldo de ordenes de pago de  reservas  (valor disponible en anulaciones
             parciales de reservas.
 acumulada por numero disponibilidad, rubro y un registro_presupuestal
 Salidas : suma de valor  detallado para la fuente de financiacion en los OP's
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :
***********************************************************************************************/

FUNCTION fn_pre_saldo_op_reservas  (una_vigencia               NUMBER,
                                    una_compania               VARCHAR2,
								    una_unidad_ejecutora       VARCHAR2,
                                    un_rubro_interno           NUMBER,
								    una_fuente                 VARCHAR2,
								    un_detalle_fuente          NUMBER,
								    un_numero_registro         NUMBER
     								 ) RETURN NUMBER;

/***********************************************************************************************
 Funcion: fn_pre_traer_valor_detalle de los registros presupuestales
 Descripcion:Trae la suma de detalles de un rubro para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en los registros presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_detalle (una_vigencia           NUMBER,
                                 una_compania               VARCHAR2,
								 una_unidad_ejecutora       VARCHAR2,
                                 un_rubro_interno           NUMBER,
                                 un_numero_disponibilidad   NUMBER,
								 un_fuente                  VARCHAR2,
								 un_detalle_fuente          NUMBER,
								 una_clasificacion          VARCHAR2) RETURN NUMBER;



/***********************************************************************************************
 Funcion: fn_pre_traer_valor_deta_anul
 Descripcion:Trae la suma de detalles de un rubro para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en los registros presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/


FUNCTION fn_pre_traer_valor_deta_anul (una_vigencia             NUMBER,
                                       una_compania             VARCHAR2,
								       una_unidad_ejecutora     VARCHAR2,
                                       un_rubro                 NUMBER,
								       una_fuente               VARCHAR2,
								       un_detalle_fuente        NUMBER
								      ) RETURN NUMBER;


/***********************************************************************************************
 Funcion: ffn_pre_traer_val_anul_rp
 Descripcion:Trae la suma de detalles de un rubro para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en los registros presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/


FUNCTION fn_pre_traer_val_anul_rp (una_vigencia             NUMBER,
                                   una_compania             VARCHAR2,
								   una_unidad_ejecutora     VARCHAR2,
                                   una_disponibilidad       NUMBER,
								   un_rubro                 NUMBER,
								   una_fuente               VARCHAR2,
								   un_detalle_fuente        NUMBER
								   ) RETURN NUMBER;


/***********************************************************************************************
 Funcion: fn_pre_traer_val_anulTot
 Descripcion:Trae la suma de detalles de fuentes de financiacion registradas en anulaciones totales
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en los anulaciones totales
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o
 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 ***********************************************************************************************/

FUNCTION fn_pre_traer_val_anulTot (una_vigencia              NUMBER,
                                   una_compania              VARCHAR2,
								   una_unidad_ejecutora      VARCHAR2,
								   un_rubro                  NUMBER,
                                   un_doc_anulado            VARCHAR2,
    							   una_fuente                VARCHAR2,
								   un_detalle_fuente         NUMBER
								 ) RETURN NUMBER;

/***********************************************************************************************
 Funcion: fn_pre_traer_valor_detalle de anulaciones parciales de CDP's (Disponibilidades)
 Descripcion:Trae la suma de detalles de un rubro para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladado en los registros presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_anulado (una_vigencia               NUMBER,
                                     una_compania               VARCHAR2,
	    							 una_unidad_ejecutora       VARCHAR2,
                                     un_rubro                   NUMBER,
			    					 una_fuente                 VARCHAR2,
					    			 un_detalle_fuente          NUMBER
                                     ) RETURN NUMBER;



/***********************************************************************************************
 Funcion: fn_pre_traer_valor_anul_compro
 Descripcion:Trae la suma de detalles de un rubro para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladado en los registros presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_anul_compro (una_vigencia               NUMBER,
                                         una_compania               VARCHAR2,
       							         una_unidad_ejecutora       VARCHAR2,
                                         un_rubro                   NUMBER,
			    					     una_fuente                 VARCHAR2,
					    			     un_detalle_fuente          NUMBER,
										 una_disponibilidad         NUMBER
                                         ) RETURN NUMBER;


/***********************************************************************************************
 Funcion: fn_pre_saldo_rp
 Descripcion:Trae la suma de valores detallados en registros presupuestales (usado para vlor disponible en CDP's )
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladado en los registros presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/


FUNCTION fn_pre_saldo_rp (una_vigencia               NUMBER,
                          una_compania               VARCHAR2,
					      una_unidad_ejecutora       VARCHAR2,
                          un_rubro_interno           NUMBER,
						  un_numero_disponibilidad   NUMBER,
						  una_fuente                 VARCHAR2,
						  un_detalle_fuente          NUMBER
						  ) RETURN NUMBER;

/***********************************************************************************************
 Funcion: fn_pre_traer_valor_rp_anulado
 Descripcion:Trae la suma de detalles de un rubro para una determinada fuente  de rp's anulados detallados
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en los registros presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_rp_anulado (una_vigencia               NUMBER,
                                        una_compania               VARCHAR2,
								 		una_unidad_ejecutora       VARCHAR2,
                                        un_rubro_interno           NUMBER,
										un_numero_disponibilidad   NUMBER,
										un_numero_registro         NUMBER,
								        una_fuente                 VARCHAR2,
								        un_detalle_fuente          NUMBER,
								        una_clasificacion          VARCHAR2
                                       ) RETURN NUMBER;

/***********************************************************************************************
 Funcion: fn_pre_valRp_anul_compro
 Descripcion:Trae la suma de detalles de un rubro para una determinada fuente  de rp's anulados detallados
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en los registros presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_valRp_anul_compro (una_vigencia               NUMBER,
                                   una_compania               VARCHAR2,
								   una_unidad_ejecutora       VARCHAR2,
                                   un_rubro_interno           NUMBER,
								   un_numero_disponibilidad   NUMBER,
								   una_fuente                 VARCHAR2,
								   un_detalle_fuente          NUMBER
                                   ) RETURN NUMBER;


/***********************************************************************************************
 Funcion: fn_pre_valRp_anul_cdp
 Descripcion:Trae la suma de detalles de un rubro para una determinada fuente  de rp's anulados detallados
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en los registros presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_valRp_anul_cdp    (una_vigencia               NUMBER,
                                   una_compania               VARCHAR2,
								   una_unidad_ejecutora       VARCHAR2,
								   un_numero_disponibilidad   NUMBER,
								   una_fuente                 VARCHAR2,
								   un_detalle_fuente          NUMBER,
								   una_clasificacion          VARCHAR2
                                   ) RETURN NUMBER;


/***********************************************************************************************
 Funcion: fn_pre_traer_valor_rp_anul_res
 Descripcion:Trae la suma de detalles de un rubro para una determinada fuente  de rp's anulados detallados
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en los registros presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/
FUNCTION fn_pre_traer_valor_rp_anul_res (una_vigencia               NUMBER,
                                         una_compania               VARCHAR2,
	         					 		 una_unidad_ejecutora       VARCHAR2,
                                         un_rubro_interno           NUMBER,
										 un_numero_registro         NUMBER,
								         una_fuente                 VARCHAR2,
								         un_detalle_fuente          NUMBER
                                         ) RETURN NUMBER;



/***********************************************************************************************
 Funcion: fn_pre_trae_valModif_cdp (disponibilidades)
 Descripcion:Trae la suma de detalles de un rubro de modificaciones presupuestales, para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en modificaciones presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/
FUNCTION fn_pre_trae_valModif_cdp (una_vigencia               NUMBER,
                                   una_compania               VARCHAR2,
								   una_unidad_ejecutora       VARCHAR2,
                                   un_tipo_documento          VARCHAR2,
								   un_rubro_interno           NUMBER,
                                   un_tipo_movimiento         VARCHAR2,
								   un_numero_disponibilidad   NUMBER,
								   una_fuente                 VARCHAR2,
								   un_detalle_fuente          NUMBER,
								   un_documentos_numero       NUMBER
								   ) RETURN NUMBER;
/***********************************************************************************************
 Funcion: fn_pre_trae_AjusReint_cdp
 Descripcion:Trae la suma de detalles de reintegros ajustes, para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en modificaciones presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/


FUNCTION fn_pre_trae_AjusReint_cdp (una_vigencia              NUMBER,
                                   una_compania               VARCHAR2,
								   una_unidad_ejecutora       VARCHAR2,
								   un_rubro                   NUMBER,
								   una_fuente                 VARCHAR2,
								   un_detalle_fuente          NUMBER
								   ) RETURN NUMBER ;


/***********************************************************************************************
 Funcion: ffn_pre_trae_Ajustes_cdp (disponibilidades)
 Descripcion:Trae la suma de detalles de un rubro de ajustes, para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en modificaciones presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_trae_Ajustes_cdp  (una_vigencia               NUMBER,
                                   una_compania               VARCHAR2,
								   una_unidad_ejecutora       VARCHAR2,
                                   un_tipo_documento          VARCHAR2,
                                   un_tipo_movimiento         VARCHAR2,
								   un_rubro                   NUMBER,
								   una_fuente                 VARCHAR2,
								   un_detalle_fuente          NUMBER,
								   un_documentos_numero       NUMBER
								   ) RETURN NUMBER;


/***********************************************************************************************
 Funcion: fn_pre_trae_AjusReint_Rp (compromisos)
 Descripcion:Trae la suma de detalles de un rubro de modificaciones presupuestales, para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en modificaciones presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_trae_AjusReint_Rp (una_vigencia               NUMBER,
                                   una_compania               VARCHAR2,
								   una_unidad_ejecutora       VARCHAR2,
    							   un_rubro                   NUMBER,
								   una_fuente                 VARCHAR2,
								   un_detalle_fuente          NUMBER,
								   un_documentos_numero       NUMBER
								   ) RETURN NUMBER;


/***********************************************************************************************
 Funcion: fn_pre_trae_Ajustes_Rp (compromisos)
 Descripcion:Trae la suma de detalles de un rubro de ajustes, para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en modificaciones presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/


FUNCTION fn_pre_trae_Ajustes_Rp (una_vigencia               NUMBER,
                                   una_compania               VARCHAR2,
								   una_unidad_ejecutora       VARCHAR2,
								   un_rubro                   NUMBER,
								   una_fuente                 VARCHAR2,
								   un_detalle_fuente          NUMBER,
								   un_documentos_numero       NUMBER
								   ) RETURN NUMBER;


/***********************************************************************************************
 Funcion: fn_pre_trae_valReint_cdp  (disponibilidades)
 Descripcion:Trae la suma de detalles de un rubro de modificaciones presupuestales, para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en modificaciones presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/


FUNCTION fn_pre_trae_ValReint_cdp (una_vigencia               NUMBER,
                                   una_compania               VARCHAR2,
								   una_unidad_ejecutora       VARCHAR2,
								   un_rubro                   NUMBER,
								   una_fuente                 VARCHAR2,
								   un_detalle_fuente          NUMBER
								   ) RETURN NUMBER;

/***********************************************************************************************
 Funcion: fn_pre_trae_valReint_Rp   (compromisos)
 Descripcion:Trae la suma de detalles de un rubro de modificaciones presupuestales, para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en modificaciones presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_trae_valReint_Rp (una_vigencia               NUMBER,
                                  una_compania               VARCHAR2,
								  una_unidad_ejecutora       VARCHAR2,
                                  un_tipo_documento          VARCHAR2,
                                  un_tipo_movimiento         VARCHAR2,
								  un_rubro                   NUMBER,
								  una_fuente                 VARCHAR2,
								  un_detalle_fuente          NUMBER,
								  una_disponibilidad         NUMBER
								   ) RETURN NUMBER;

/***********************************************************************************************
 Funcion: fn_pre_traer_valor_modif (suspensiones )
 Descripcion:Trae la suma de detalles de un rubro de modificaciones presupuestales, para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en modificaciones presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_modif (una_vigencia               NUMBER,
                                   una_compania               VARCHAR2,
								   una_unidad_ejecutora       VARCHAR2,
                                   un_tipo_documento          VARCHAR2,
								   un_rubro_interno           NUMBER,
                                   un_tipo_movimiento         VARCHAR2,
								   un_numero_disponibilidad   NUMBER,
								   una_fuente                 VARCHAR2,
								   un_detalle_fuente          NUMBER,
								   un_documentos_numero       VARCHAR2
								   ) RETURN NUMBER;

/***********************************************************************************************
 Funcion: fn_pre_traer_valor_rezago
 Descripcion:Trae la suma de detalles de un rubro de suspensiones
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, fuente de financiacion, detalle_fuente
 Salidas : suma de valores de lo detallados en las suspensiones
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_rezago (una_vigencia              NUMBER,
                                   una_compania               VARCHAR2,
								   una_unidad_ejecutora       VARCHAR2,
								   un_rubro_interno           NUMBER,
								   una_fuente                 VARCHAR2,
								   un_detalle_fuente          NUMBER
								   ) RETURN NUMBER;



/***********************************************************************************************
 Funcion: fn_pre_valor_anul_parc_res
 Descripcion:Trae la suma de detalles de fuentes de financiacion de anulaciones parciales de reservas
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, fuente de financiacion, detalle_fuente
 Salidas : suma de valores de lo detallados en las suspensiones
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/


FUNCTION fn_pre_valor_anul_parc_res (una_vigencia             NUMBER,
                                     una_compania             VARCHAR2,
                                     una_unidad               VARCHAR2,
                                     un_registro              NUMBER,
                                     una_disponibilidad       NUMBER,
                                     un_rubro                 NUMBER,
                                     una_orden                NUMBER,
							         un_codigo_fuente         VARCHAR2,
							         un_detalle_fuente        NUMBER) RETURN NUMBER;


/***********************************************************************************************
 Funcion: fn_pre_valor_anula_reserva
 Descripcion:Trae la suma de detalles de fuentes de financiacion de anulaciones totales de reservas
 Entradas: Vigencia, Compania , Unidad Ejecutora, registro presupuestal,Rubro,
           orden de pago, fuente de financiacion, detalle_fuente
 Salidas : suma de valores de lo detallados en anulaciones totales de reservas
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_valor_anula_reserva (una_vigencia             NUMBER,
                                     una_compania             VARCHAR2,
                                     una_unidad               VARCHAR2,
                                     un_registro              NUMBER,
                                     un_rubro                 NUMBER,
                                     una_orden                NUMBER,
							         un_codigo_fuente         VARCHAR2,
							         un_detalle_fuente        NUMBER) RETURN NUMBER;


/***********************************************************************************************
 Funcion: fn_traer_cdpsincomp_det
 Descripcion:Devuelve el valor sin comprometer de un rubro de un CDP para una fuente de
             financiacion
 Entradas: Vigencia, Compania , Unidad Ejecutora, registro presupuestal,Rubro,
           orden de pago, fuente de financiacion, detalle_fuente
 Salidas : suma de valores de lo detallados en anulaciones totales de reservas
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/


FUNCTION fn_traer_cdpsincomp_det(un_numero_cdp      NUMBER,
                                 un_codigo_compania VARCHAR2,
							 	 un_codigo_unidad   VARCHAR2,
        					 	 una_vigencia       NUMBER,
        					 	 un_interno         VARCHAR2,
								 un_codigo_fuente   VARCHAR2,
								 un_detalle_fuente  NUMBER) RETURN NUMBER;

/***********************************************************************************************
 Funcion: fn_pre_traer_valor_dis
 Descripcion:Devuelve el valor disponible de na fuente de financiacion determinada
            Parte del Requerimiento RQ163
 Entradas: Vigencia, Compania , Unidad Ejecutora, registro presupuestal,Rubro,
           orden de pago, fuente de financiacion, detalle_fuente
 Salidas : Valor disponible de una fuente de financiacion
 Fecha
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/


FUNCTION fn_pre_traer_valor_dis (un_codigo_compania VARCHAR2,
							 	 un_codigo_unidad   VARCHAR2,
        					 	 una_vigencia       NUMBER,
        					 	 un_interno         VARCHAR2,
								 un_codigo_fuente   VARCHAR2,
								 un_detalle_fuente  NUMBER,
								 una_clasificacion  VARCHAR2)
								 RETURN NUMBER;



 /***********************************************************************************************
 Funcion: fn_pre_traer_valor_modifica
  Descripcion:Devuelve el valor de modificaciones para un rubro de
             una fuente de financiacion determinada,
 Entradas: Vigencia, Compania , Unidad Ejecutora, registro presupuestal,Rubro,
           orden de pago, fuente de financiacion, detalle_fuente
 Salidas : Valor disponible de una fuente de financiacion
 Fecha             Noviembre  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/


FUNCTION fn_pre_traer_valor_modifica (un_codigo_compania VARCHAR2,
							 	      un_codigo_unidad   VARCHAR2,
        					 	      una_vigencia       NUMBER,
        					 	      un_interno         VARCHAR2,
								      un_codigo_fuente   VARCHAR2,
								      un_detalle_fuente  NUMBER,
									  una_fecha          DATE  )
								      RETURN NUMBER;


/***********************************************************************************************
 Funcion: fn_pre_traer_valor_cambiof
 Descripcion:Devuelve el valor de cambios en  fuentes de financiacion para un rubro
             parte del requerimiento RQ160
 Entradas: Vigencia pago, fuente de financiacion, detalle_fuente
 Salidas : Valor disponible de una fuente de financiacion
 Fecha     Febrero de 2005
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/


FUNCTION fn_pre_traer_valor_cambiof ( un_codigo_compania VARCHAR2,
							 	      un_codigo_unidad   VARCHAR2,
        					 	      una_vigencia       NUMBER,
        					 	      un_interno         VARCHAR2,
								      un_codigo_fuente   VARCHAR2,
								      un_detalle_fuente  NUMBER,
									  una_fecha          DATE  )
								      RETURN NUMBER;


/***********************************************************************************************
 Funcion: fn_pre_traer_valor_dis_cambiof
 Descripcion:Devuelve el valor disponible de na fuente de financiacion determinada,
             para un rubro
			  parte del requerimiento RQ160
 Entradas: Vigencia, Compania , Unidad Ejecutora, registro presupuestal,Rubro,
           orden de pago, fuente de financiacion, detalle_fuente
 Salidas : Valor disponible de una fuente de financiacion
 Fecha             Septiembre de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_discambiof (un_codigo_compania VARCHAR2,
							 	 un_codigo_unidad   VARCHAR2,
        					 	 una_vigencia       NUMBER,
        					 	 un_interno         VARCHAR2,
								 un_codigo_fuente   VARCHAR2,
								 un_detalle_fuente  NUMBER,
								 una_clasificacion  VARCHAR2,
								 una_fecha          DATE
								 )
								 RETURN NUMBER;




/***********************************************************************************************
 Funcion: fn_pre_traer_valor_dis_rp
 Descripcion:Devuelve el valor disponible (para registros presupuestales)
             de una fuente de financiacion determinada
 Entradas: Vigencia, Compania , Unidad Ejecutora, registro presupuestal,Rubro,
           orden de pago, fuente de financiacion, detalle_fuente
 Salidas : Valor disponible de una fuente de financiacion
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/


FUNCTION fn_pre_traer_valor_dis_rp (un_codigo_compania VARCHAR2,
							 	    un_codigo_unidad   VARCHAR2,
        					 	 	una_vigencia       NUMBER,
        					 	 	un_interno         VARCHAR2,
								 	un_codigo_fuente   VARCHAR2,
								 	un_detalle_fuente  NUMBER,
								 	una_clasificacion  VARCHAR2,
								 	una_disponibilidad NUMBER)
								 	RETURN NUMBER;

/***********************************************************************************************
 Funcion: fn_pre_traer_valor_dis_anu_au
 Descripcion:Devuelve el valor disponible (para anulaciones parciales autorizadas )
             de una fuente de financiacion determinada
 Entradas: Vigencia, Compania , Unidad Ejecutora, registro presupuestal,Rubro,
           orden de pago, fuente de financiacion, detalle_fuente
 Salidas : Valor disponible de una fuente de financiacion
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/


FUNCTION fn_pre_traer_valor_dis_anu_au (un_codigo_compania VARCHAR2,
							 	    un_codigo_unidad   VARCHAR2,
        					 	 	una_vigencia       NUMBER,
        					 	 	un_interno         VARCHAR2,
								 	un_codigo_fuente   VARCHAR2,
								 	un_detalle_fuente  NUMBER,
								 	una_clasificacion  VARCHAR2,
								 	una_disponibilidad NUMBER)
								 	RETURN NUMBER;



/***********************************************************************************************
 Funcion: fn_pre_traer_valor_dis_anu_rp
 Descripcion:Devuelve el valor disponible (para anulaciones parciales de registros presupuetales)
             de una fuente de financiacion determinada
 Entradas: Vigencia, Compania , Unidad Ejecutora, registro presupuestal,Rubro,
           orden de pago, fuente de financiacion, detalle_fuente
 Salidas : Valor disponible de una fuente de financiacion
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_dis_anu_rp (un_codigo_compania VARCHAR2,
							 	    un_codigo_unidad   VARCHAR2,
        					 	 	una_vigencia       NUMBER,
        					 	 	un_interno         VARCHAR2,
								 	un_codigo_fuente   VARCHAR2,
								 	un_detalle_fuente  NUMBER,
								 	una_clasificacion  VARCHAR2,
								 	una_disponibilidad NUMBER,
									un_numero_registro NUMBER)
								 	RETURN NUMBER;


/***********************************************************************************************
 Funcion: fn_saldo_cdp_modif_det
 Descripcion:Devuelve el valor disponible de detalle de fuente para las modificaciones
 Entradas: Cdp, compania, unidad, vigencia , rubto, fuente, detalle fuente
 Salidas : Valor disponible de una fuente de financiacion
 Fecha             Agostode  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_saldo_cdp_modif_det(un_numero_cdp       NUMBER,
          				  	     un_codigo_compania VARCHAR2,
                                 un_codigo_unidad   VARCHAR2,
                                 una_vigencia       NUMBER,
                                 un_interno         VARCHAR2,
								 una_fuente         VARCHAR2,
								 un_detalle         NUMBER)
								 RETURN NUMBER;


 /***********************************************************************************************
 Funcion: pr_pre_actualiza_tempo_fuentes
 Descripcion:actualiza el estado dem la tabla temporal
 Entradas: VIGENCIA, RUBRO_INTERNO, CODIGO_COMPANIA, CODIGO_UNIDAD_EJECUTORA,
         NUMERO_DISPONIBILIDAD, NUMERO_REGISTRO,NUMERO_ORDEN,CONSECUTIVO_ORDEN,
         CONSECUTIVO_AJUSTE,TIPO_DOCUMENTO,DOCUMENTOS_NUMERO,TIPO_MOVIMIENTO,
         SALIR,ESTADO,CONSECUTIVO_ANULACION,FORMA
 Salidas :
 Fecha             Agosto   2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

PROCEDURE pr_pre_actualiza_tempo_fuentes (una_vigencia       PR_TEMPO_FUENTES.vigencia%TYPE,
		  								  un_interno         PR_TEMPO_FUENTES.rubro_interno%TYPE,
                                          una_compania       PR_TEMPO_FUENTES.codigo_compania%TYPE,
                                          una_unidad         PR_TEMPO_FUENTES.codigo_unidad_ejecutora%TYPE,
                                          una_disponibilidad PR_TEMPO_FUENTES.numero_disponibilidad%TYPE,
                                          un_registro        PR_TEMPO_FUENTES.numero_registro%TYPE,
                                          una_orden          PR_TEMPO_FUENTES.numero_orden%TYPE,
                                          un_consec_orden    PR_TEMPO_FUENTES.consecutivo_orden%TYPE,
                                          un_consec_ajus     PR_TEMPO_FUENTES.consecutivo_ajuste%TYPE,
                                          un_tip_doc         PR_TEMPO_FUENTES.tipo_documento%TYPE,
                                          un_doc_num         PR_TEMPO_FUENTES.documentos_numero%TYPE,
                                          un_tip_mov         PR_TEMPO_FUENTES.tipo_movimiento%TYPE,
                                          un_consec_anul     PR_TEMPO_FUENTES.consecutivo_anulacion%TYPE,
                                          una_forma          PR_TEMPO_FUENTES.forma%TYPE);


 /***********************************************************************************************
 Funcion: fn_pre_apropiacion_inicial
 Descripcion:trae el valor de la apropaicion (teniendo en cuenta modificaciones)
              para un rubro
 Entradas: VIGENCIA, RUBRO_INTERNO, CODIGO_COMPANIA, CODIGO_UNIDAD_EJECUTORA,
 Salidas :
 Fecha             Noviembre  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_apropiacion_inicial (una_vigencia NUMBER,
                                     una_compania VARCHAR2,
								     una_unidad   VARCHAR2,
								     un_rubro     NUMBER )
                                     RETURN NUMBER;



/***********************************************************************************************
 Funcion: fn_pre_apr_inicial_detalle
 Descripcion:trae el valor de la apropiacion inicial de un rubro para una fuente de financiacion
 Entradas: VIGENCIA, RUBRO_INTERNO, CODIGO_COMPANIA, CODIGO_UNIDAD_EJECUTORA,
 Salidas :
 Fecha             Noviembre  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_apr_inicial_detalle (una_vigencia NUMBER,
                                     una_compania VARCHAR2,
							         una_unidad   VARCHAR2,
							         un_rubro     NUMBER ,
									 una_fuente	  VARCHAR2,
									 un_detalle  NUMBER )
                             RETURN NUMBER ;


/***********************************************************************************************
 Funcion: fn_pre_disponibilidades
 Descripcion: Calcula el total de disponibilidades  para un rubro
 Entradas: VIGENCIA, RUBRO_INTERNO, CODIGO_COMPANIA, CODIGO_UNIDAD_EJECUTORA,
 Salidas :
 Fecha             Noviembre   2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/


FUNCTION fn_pre_disponibilidades (una_vigencia NUMBER,
                                  una_compania VARCHAR2,
								  una_unidad   VARCHAR2,
								  una_fecha    DATE,
								  un_rubro     NUMBER )
                                  RETURN NUMBER;


/***********************************************************************************************
 Funcion: fn_pre_totcdp_detalle
 Descripcion: Calcula el total de disponibilidades  para un rubro , para una fuente de
              financiacion
			   parte del requerimiento RQ163
 Entradas: VIGENCIA, RUBRO_INTERNO, CODIGO_COMPANIA, CODIGO_UNIDAD_EJECUTORA,
 Salidas :
 Fecha             Febrero    2005
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_totcdp_detalle (una_vigencia NUMBER,
                                una_compania VARCHAR2,
								una_unidad   VARCHAR2,
								una_fecha    DATE,
								un_rubro     NUMBER,
								una_fuente   VARCHAR2,
								un_detalle   NUMBER )
                                RETURN NUMBER;


/***********************************************************************************************
 Funcion: fn_pre_saldo_apropiacion
 Descripcion: Calcula el a?saldo de apropiacion para un rubro
 Entradas: VIGENCIA, RUBRO_INTERNO, CODIGO_COMPANIA, CODIGO_UNIDAD_EJECUTORA,
 Salidas :
 Fecha             Noviembre   2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_saldo_apropiacion (una_vigencia NUMBER,
                                   una_compania VARCHAR2,
								   una_unidad   VARCHAR2,
								   una_fecha    DATE,
								   un_rubro     NUMBER )
                                   RETURN NUMBER;




/***********************************************************************************************
 Funcion: fn_pre_apropiacion_dis
 Descripcion: Calcula apropiacion disponible para un rubro
               parte del requerimiento RQ160
 Entradas: VIGENCIA, RUBRO_INTERNO, CODIGO_COMPANIA, CODIGO_UNIDAD_EJECUTORA,
 Salidas :
 Fecha
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :   Marzo de 2005
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_apropiacion_dis (una_vigencia NUMBER,
                                 una_compania VARCHAR2,
								 una_unidad   VARCHAR2,
								 una_fecha    DATE,
								 un_rubro     NUMBER )
                                 RETURN NUMBER;



END Pk_Pr_Detalle_Fuentes;
/