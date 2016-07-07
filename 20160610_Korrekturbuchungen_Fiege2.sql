select 
cte2."Item No_"
,cte2.AnzahlVerarbeitet
,cte2."Return Reason Code"
,replace(cte2.Warenwert,'.',',') as Warenwert from ( 
select 
cte1.journalid
,cte1.itemid as "Item No_"
,cte1.menge as AnzahlVerarbeitet
,cte1.reasoncode as "Return Reason Code"
, case when cte1.reasoncode in ('K12', 'K13', 'K14', 'K17')then (-1*cast(cte1.menge as integer)*cast(round(cte1.Betrag,2) as float))
else (cast(cte1.menge as integer)*cast(round(cte1.Betrag,2) as float))end Warenwert

from (
select 
cte.TransDatum
,cte.journalid
,cte.itemid
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
--,replace(cast(price.amount as float),'.',',') as WW_Einheit
--,case  when corr.reasoncode in ('K12', 'K13', 'K14', 'K17') then (-1*(cast(price.amount as float)*abs(it.qty))) else (cast(price.amount as float)*abs(it.qty)) end Warenwert
--,replace(it.inventonhand,'.',',') as auf_Lager
--,replace(it.counted,'.',',') as gezählt
,replace(cast(abs(it.qty)as integer),'.',',') as menge
,it.inventdimid
,id.inventlocationid
,corr.reasoncode
--,corr.description

 FROM "AX.PROD_DynamicsAX2012.dbo.INVENTJOURNALTRANS" it
 left join "AX.PROD_DynamicsAX2012.dbo.INVENTDIM" id
 on it.inventdimid=id.inventdimid
 left join "AX.PROD_DynamicsAX2012.dbo.WININVCORREASON" corr
 on corr.recid=it.WININVCORREASON
 where cast(it.transdate as date)>='2016-05-01'
 and cast(it.transdate as date)<='2016-05-31'
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
--order by linenum

