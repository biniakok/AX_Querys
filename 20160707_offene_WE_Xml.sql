select 
cte2.PO
,cte2.ean
,cast(cte2.Menge_buchen as integer) as qtyshipped
,cte2.orderaccount
,ifnull(cte2.linenumber||'000',0)linenumber
,cte2.OrderDate
,'PCS' as purchunit
 from (
SELECT 
we.*
,pt.orderaccount
,pl2.LineNumber
,cast(pt.createddatetime as date) as OrderDate
FROM "DWHStaging.DWH_Staging.dbo.'20160707_offene_WE'" we
left join "AX.PROD_DynamicsAX2012.dbo.PURCHTABLE" pt
on pt.purchid=we.PO
left join (select
cte.Purchid
,cte.linenumber
,cte.itemid
,cte.purchstatus
,cte.qtyordered
,cte.purchunit
from (
SELECT pl."PURCHID",pl.linenumber,pl."ITEMID", pl."PURCHSTATUS"
,cast(pl."qtyordered" as integer) as qtyordered
,pl.purchunit
,row_number () over (partition by pl."PURCHID",pl."ITEMID" order by pl."ITEMID") as Rankordnung 
 FROM "AX.PROD_DynamicsAX2012.dbo.PURCHLINE" pl
 where taxitemgroup like 'T%') as cte
 where cte.Rankordnung=1)pl2
 on (pl2.purchid=we.po and we.ean=pl2.itemid)) as cte2