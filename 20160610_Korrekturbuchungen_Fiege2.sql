select 
--cte3.journalid
cte3."Item No_"
,sum(cte3.AnzahlVerarbeitet) as AnzahlVerarbeitet
,cte3."Return Reason Code"
,cte3.Warenwert
from (
select 
cte2.journalid
,cte2.inventtransid
,cte2."Item No_"
,cast(cte2.AnzahlVerarbeitet as integer) as AnzahlVerarbeitet
,cte2."Return Reason Code"
,replace(cte2.Betrag,'.',',') as Warenwert from ( 
select 
cte1.journalid
,cte1.inventtransid
,cte1.itemid as "Item No_"
,cte1.menge as AnzahlVerarbeitet
,cte1.reasoncode as "Return Reason Code"
,cte1.Betrag
--, case when cte1.reasoncode in ('K12', 'K13', 'K14', 'K17')then (-1*cast(cte1.menge as --integer)*cast(round(cte1.Betrag,2) as float))
--else (cast(cte1.menge as integer)*cast(round(cte1.Betrag,2) as float))end Warenwert

from (
select 
cte.TransDatum
,cte.journalid
,cte.itemid
,cte.inventtransid
,cte.menge
,cte.reasoncode
,fiege.amount as amount_fiege
,abe.amount as amount_abe
,case when fiege.amount='<null>' then ifnull(abe.amount,0) else ifnull(fiege.amount,0) end Betrag

 from (
SELECT 
cast(it.transdate as date) as TransDatum
,it.journalid
,it.linenum
,it.itemid
,replace(cast(abs(it.qty)as integer),'.',',') as menge
,it.inventdimid
,it.inventtransid
,id.inventlocationid
,corr.reasoncode
--,corr.description

 FROM "AX.PROD_DynamicsAX2012.dbo.INVENTJOURNALTRANS" it
 left join "AX.PROD_DynamicsAX2012.dbo.INVENTDIM" id
 on it.inventdimid=id.inventdimid
 left join "AX.PROD_DynamicsAX2012.dbo.WININVCORREASON" corr
 on corr.recid=it.WININVCORREASON
 where cast(it.transdate as date)>='2016-06-01'
 and cast(it.transdate as date)<='2016-06-30'
 and id.inventlocationid='FIEGE_GB'
) as cte
left join (
SELECT 
pt.itemrelation
,pt.accountrelation
,pt.amount
,pt.currency
,pt.unitid
,pt.inventdimid
,id.inventlocationid
 FROM "AX.PROD_DynamicsAX2012.dbo.PRICEDISCTABLE" pt
left join "AX.PROD_DynamicsAX2012.dbo.INVENTDIM" id
on pt.inventdimid=id.inventdimid
where id.inventlocationid='FIEGE_GB'
and pt.unitid='PCS'
) as fiege
on fiege.itemrelation=cte.itemid
left join (
SELECT 
pt.itemrelation
,pt.accountrelation
,pt.amount
,pt.currency
,pt.unitid
,pt.inventdimid
,id.inventlocationid
 FROM "AX.PROD_DynamicsAX2012.dbo.PRICEDISCTABLE" pt
left join "AX.PROD_DynamicsAX2012.dbo.INVENTDIM" id
on pt.inventdimid=id.inventdimid
where id.inventlocationid='WDB_AB'
and pt.unitid='PCS'
) as abe
on abe.itemrelation=cte.itemid
) as cte1
) as cte2
where cte2."Return Reason Code" in ('K02','K03')
group by
cte2.journalid
,cte2.inventtransid
,cte2."Item No_"
,cte2.AnzahlVerarbeitet
,cte2."Return Reason Code"
,replace(cte2.Betrag,'.',',')
) as cte3
group by
--cte3.journalid
cte3."Item No_"
,cte3."Return Reason Code"
,cte3.Warenwert









