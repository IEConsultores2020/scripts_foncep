UPDATE RH_MOVIMIENTOS_PLANTA mp
  SET POSICION_ANTERIOR = NVL((SELECT POSICION_ACTUAL
                          FROM RH_MOVIMIENTOS_PLANTA
                          WHERE tipo_acto = ('040')
                          AND FUNCIONARIO = mp.FUNCIONARIO
                          AND mp.FECHA_FINAL BETWEEN FECHA_INICIAL AND
                              NVL(FECHA_FINAL - 1, TO_DATE('99991231', 'YYYYMMDD'))),
                          POSICION_ANTERIOR)
  WHERE tipo_acto IN ('171', '255') -- Vacaciones y reanude de vacaciones
  AND POSICION_ANTERIOR <> NVL((SELECT POSICION_ACTUAL
                          FROM RH_MOVIMIENTOS_PLANTA
                          WHERE tipo_acto = ('040')
                          AND FUNCIONARIO = mp.FUNCIONARIO
                          AND mp.FECHA_FINAL BETWEEN FECHA_INICIAL AND
                              NVL(FECHA_FINAL - 1, TO_DATE('99991231', 'YYYYMMDD'))),
                          POSICION_ANTERIOR)
                          ;

SELECT POSICION_ACTUAL
FROM RH_MOVIMIENTOS_PLANTA
WHERE tipo_acto = ('040')
AND mp.FECHA_FINAL BETWEEN FECHA_INICIAL AND
NVL(FECHA_FINAL - 1, TO_DATE('99991231', 'YYYYMMDD'))                          
group by funcionario