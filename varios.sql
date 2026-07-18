SELECT SECUENCIAL
FROM     BINCONSECUTIVO
WHERE   GRUPO = 'OPGET'
    AND NOMBRE = 'ACTA_LEGAL_ID'
    AND VIGENCIA = '0000'
    AND CODIGO_COMPANIA = '000'
    AND CODIGO_UNIDAD_EJECUTORA = '00'
    ;

    SELECT NUMERO FROM OGT_DOCUMENTO
    ORDER BY 1 DESC
    ;

AND VIG_INICIAL <= SYSDATE
AND (VIG_FINAL IS NULL OR VIG_FINAL >= SYSDATE)
;

select *
from RH_PERSONAS
where --numero_identificacion = 79384072 
    interno_persona = 11
;


select * from rh_maestro_personas
where nfuncionario in 
(select * --interno_persona, numero_identificacion, nombres, primer_apellido, segundo_apellido
 from rh_personas
--where nombres ='DIANA MARCELA' and primer_apellido='SANABRIA'
where --numero_identificacion in (52116283)) --651, 652
--or 
interno_persona IN (519,614)   --  20730522
--649 --1030575813
;


SELECT *
FROM shd_informacion_entidades
      WHERE id = 51 AND ie_fecha_inicial <= SYSDATE AND
      (ie_fecha_final >= SYSDATE OR ie_fecha_final IS NULL);


select *
from rh_personas
where interno_persona in (11) --20730522, 52876090
nombres like 'MARGARITA%' --numero_identificacion= 79693028
;

select *
from pr_rubro
where interno = 1547
;



select *
from rh_personas
where numero_identificacion in (51604666);
/*
JF 79355621 65 PUBLICO
SUESCA 52316271 595 PRIVADO
SANDOVAL 1049606827 607 PRIVADO
*/
;

select *
from rh_concepto
where nombre like '%PAGO  APORTE CAJA DE COMPENSACION FAMILIAR%'
;
select hn.*
from 
--delete 
rh_historico_nomina hn
where hn.nfuncionario=633
and nhash like '1994%'
and hn.dinicioperiodo = 20260401
and sproceso = 'NEWNOVELTIES'
and hn.ncorrida=1   1994
;

commit

select *
from rh_novedad
;




select *
from bintablas
where grupo='SISLA' AND nombre='GRAFICOS'
;

select * from rh_conceptos;

select * from pr_apropiacion
where vigencia=2016
;

select *
from pr_rubro
where vigencia=2016

select *  --personas_interno
from rh_funcionario
where personas_interno=613
/*and  codigo_fondo_pensiones <>61
and estado_funcionario =1*/
order by personas_interno asc
;


select TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')  as fysdate from dual
;

select *
from pr_rubro;

select *
from rh_concepto   
where codigo_hash = 2091789934
;

    select *
    from rh_concepto
    where nombre_corto like '%ICBF%' --121290711
    ;

    select *
    from rh_tipos_acto_nove
    where nombre = 'INFO_PLANILLA_ENTIDAD' --854032720
    --'INFOAPORTEPARAF' --543977345

    select *
    from rh_historico_nomina
    where nhash=543977345 and dinicioperiodo>=20260101 and dfinalperiodo<=20260131
    and nfuncionario=33
    ;

select usu.id, usu.usuario, usu.nombre_usuario, bin.resultado, usu.estado
     from   SL_PCP_USUARIOS usu, bintablas bin
     where  usu.centro_costo = bin.argumento
     and    bin.grupo = 'SISLA'
     and    nombre = 'CENTROS_COSTO_CP'
     and    usu.centro_costo = null
     order by bin.resultado;


SELECT * /*cot.afecta_ingreso,
         ing.ing_id*/
    FROM ogt_ingreso ing,
         ogt_concepto_tesoreria cot
   WHERE ing.cote_id = cot.id
     AND ing.id = 622526;


  CURSOR cur_documento IS
 SELECT atr_nombre,clmo_nombre,valor
     FROM   ogt_info_ing
     WHERE  ing_id=622526;


             select resultado
         from bintablas
         where grupo = 'OPGET'
         and nombre = 'LIMAY_INGRESO_PORTAL'
         and argumento ='CENTRO CONTABLE';

         insert into bintablas (grupo,nombre,argumento,resultado,vig_inicial)
values ('OPGET','LIMAY_INGRESO_PORTAL','CENTRO CONTABLE','02',TO_DATE('01/01/2026','DD/MM/YYYY'));

delete bintablas
where grupo ='OPGET' AND NOMBRE='LIMAY_INGRESO_PORTAL'AND ARGUMENTO='CONTABLE'

commit


 select * --id_tercero
  from sl_relacion_terceros
   where id_sisla = 4959
   and fecha_fin is null
   and nvl(fecha_fin,sysdate) = sysdate; 

   alter user lm2 identified by "#FonC3p2026";
   ALTER USER smithj IDENTIFIED BY "MyNewPassword123#";


select *
from pr_v_rubros
where vigencia=2026
and descripcion in ('Aportes a la seguridad social en pensiones públicas',  --1831
                    'Aportes a la seguridad social en pensiones privadas')
;


select *
from ogt_orden_pago
where vigencia=2026
and entidad=206
and unidad_ejecutora='02'
and num_radicacion in (295,297);



select *
from ogt_detalle_pago
where id_pago = 110046;

select count(1)
from sl_relacion_tac;


select *
from pr_v_rubros
where vigencia=2026
and descripcion in ('Aportes a la seguridad social en pensiones públicas',  --1831
                    'Aportes a la seguridad social en pensiones privadas',--1832
                    'Aportes a la seguridad social en salud pública',  --1834
                    'Aportes a la seguridad social en salud privada',  --1834
                    'Aportes generales al sistema de riesgos laborales públicos', --1838
                    'Sueldo básico')  --1804
;

   select * --valor     into valor_aportes_empleado_mes
        from ogt_centro_costos
        where entidad         =  206
        and unidad_ejecutora  = '01'
        and vigencia          = 2026
        and extract(month from fecha_desde) = 1
        --and consecutivo=10
        and codigo_centro_costos IN (5, 1285, 1267)
        and exists (select 1 from ogt_relacion_autorizacion b
                where b.consecutivo = ogt_centro_costos.consecutivo
                  and b.entidad = ogt_centro_costos.entidad
                  and b.tipo_documento = ogt_centro_costos.tipo_documento
                  and b.unidad_ejecutora = ogt_centro_costos.unidad_ejecutora
                  and b.vigencia = ogt_centro_costos.vigencia
                  and b.tipo_ra = ogt_centro_costos.tipo_ra
                  and b.ind_aprobado = 1
                  and substr(b.estado, 4, 1) = '1'
                  );


  select descripcion
      from pr_v_rubros
     where interno_rubro = 1804
       and vigencia = 2026
       and codigo=compania=206
       and codigo_uidad_ejecutora='01';                  
