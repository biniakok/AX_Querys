select 
cte.* 
,cte1.qty_route
from (
SELECT 

cn."Orders"
,cn."Debitor"
,cn."Ext_Belegnummer"
,cn."PositionsNr"||'0'
,cn."EAN"
,cn."LieferCode"
,cast(cn."Menge_zu_buchen" as integer) "Menge_zu_buchen"
,cast(cn."qtyordered" as integer)"qtyordered"  
FROM "DWHStaging.DWH_Staging.dbo.CN_Orders_Fehler" cn
join (SELECT 
cast(stag."LINENUM" as integer) as LineNum
,stag."SALESID"
,stag."ITEMID"
,cast(stag."QTYORDERED" as integer) qtyordered
,cast(stag."QTYSHIPPED" as integer) qtyshipped
,stag."STATUS"
FROM "AX.PROD_DynamicsAX2012.dbo.WINSALESORDEROUTPUTLINESTAGING" stag
where stag.status=2) as fehler
on (fehler.salesid=cn."Orders" and fehler.itemid=cn.EAN) 
) as cte
left join (
SELECT 
route.transrefid
,route.customer
,trans.itemid
,cast(sum(trans.qty) as integer) as qty_route
FROM "AX.PROD_DynamicsAX2012.dbo.WMSPICKINGROUTE" route
left join "AX.PROD_DynamicsAX2012.dbo.WMSORDERTRANS" trans
on (route.pickingrouteid=trans.routeid and route.shipmentid=trans.shipmentid)
where  route.expeditionstatus<>'20'
group by
route.transrefid
,route.customer
,trans.itemid
) as cte1
on (cte.Orders=cte1.transrefid and cte.EAN=cte1.itemid)


