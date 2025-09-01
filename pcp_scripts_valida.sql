select *
from sl_pcp_encabezado e, sl_pcp_cuenta_cobro cc, SL_PCP_LIQUIDACIONES l
where e.id = cc.ID_ENCABEZADO
and cc.id = l.ID_DET_CUENTA_COBRO