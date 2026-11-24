---https://forums.oracle.com/ords/apexds/post/finding-all-possible-combinations-of-numbers-to-reach-a-giv-1152
WITH vals (id, van) AS (
SELECT PR_RP_ANULADOS.NUMERO_OFICIO ID,
      PR_RP_ANULADOS.VALOR_ANULADO VAN
  FROM PR_RP_ANULADOS, PR_COMPROMISOS, PR_RUBRO
 WHERE ((PR_COMPROMISOS.VIGENCIA = PR_RP_ANULADOS.VIGENCIA) AND
       (PR_COMPROMISOS.CODIGO_COMPANIA = PR_RP_ANULADOS.CODIGO_COMPANIA) AND
       (PR_COMPROMISOS.CODIGO_UNIDAD_EJECUTORA =
       PR_RP_ANULADOS.CODIGO_UNIDAD_EJECUTORA) AND
       (PR_COMPROMISOS.NUMERO_REGISTRO = PR_RP_ANULADOS.NUMERO_REGISTRO))
   AND PR_RUBRO.INTERNO = PR_RP_ANULADOS.RUBRO_INTERNO
   AND PR_RUBRO.VIGENCIA = PR_RP_ANULADOS.VIGENCIA
   AND PR_RP_ANULADOS.VIGENCIA=2025
   ), 
iterator (id, van, s, o) AS (
    SELECT id, van, van, cast(van as varchar2(4000)) 
    FROM vals v
    union all
    select v.id, v.van, itr.s + v.van as s,
      itr.o || '+' || CAST(v.van AS VARCHAR2(4000)) as o
    from iterator itr
    join vals v on v.id > itr.id
    where itr.s + v.van <= 404524
)
select o, s
  from iterator
  where s = 404524
  ;