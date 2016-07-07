select
cte4.Auftrag
,cte4.customerref
,cte4.Shop
,ifnull(cte4.LineNum,cte4."Line No_") LineNo
,cte4.Ean
,cte4.Menge_Fiege
,cte4.AX_Menge
,cte4.NAV_Menge
,cte4.Differenz
from (
select 
cte3.*
,line_nav."Line No_" 
from (
select
cte2.*
,line2.LineNum
from(
select 
cte.Auftrag
,cte.customerref
,cte.shop
,cte.Ean
,cte.Menge_Fiege
,cte.AX_Menge
,cte.NAV_Menge
,cte.Differenz


from (
SELECT 
view_ret.Auftrag
,view_ret.Ean
,view_ret.Menge_Fiege
,view_ret.AX_Menge
,ifnull(nav_ret.NAV_Menge,0) as NAV_Menge
,view_ret.Menge_Fiege-view_ret.AX_Menge-ifnull(nav_ret.NAV_Menge,0) as Differenz
,view_ret.customerref
,view_ret.Shop
,view_ret.Datum
FROM "views.Retouren_Auswertung_Fiege_2016" as view_ret
left join (
SELECT 
rrh."Order No_"
,rrh."External Document No_"
,rrl.No_
,cast(sum(rrl.Quantity) as integer) as NAV_Menge

 FROM "nav.Urban-Brand GmbH$Return Receipt Header" rrh
 join "nav.Urban-Brand GmbH$Return Receipt Line" rrl
 on rrh.No_=rrl."Document No_"
 where rrl.Type=2
 group by
 rrh."Order No_"
,rrh."External Document No_"
,rrl.No_
) as nav_ret
on (nav_ret."Order No_" =right(view_ret.Auftrag,11) and nav_ret.No_=view_ret.Ean)
) as cte
group by
cte.Auftrag
,cte.customerref
,cte.shop
,cte.Ean
,cte.Menge_Fiege
,cte.AX_Menge
,cte.NAV_Menge
,cte.Differenz
having cte.Differenz>0
) as cte2
left join (
select 
line1.salesid
,line1.LineNum
,line1.itemid
from (
SELECT 
salesid
,cast(linenum as integer)||'0000' as LineNum
,itemid
,cast(qtyordered as integer) as qtyordered
,row_number() over (partition by salesid, itemid order by itemid) as Rankordnung
 FROM "AX.PROD_DynamicsAX2012.dbo.SALESLINE"
 where taxitemgroup like 'T%'
  group by
 salesid
,cast(linenum as integer)||'0000'
,itemid
,cast(qtyordered as integer)
) as line1
where line1.Rankordnung=1	
)line2
on (cte2.Auftrag=line2.salesid and cte2.EAN=line2.itemid)
) as cte3
left join (select 
ffsl2."Document No_"
,ffsl2."Line No_"
,ffsl2.No_
from (
SELECT 
ffsl."Document No_"
,ffsl."Line No_" 
,ffsl.No_
,row_number() over (partition by ffsl."Document No_",ffsl.No_ order by ffsl.No_) as Rankordnung
from "nav.Urban-Brand GmbH$eBayFFSalesHeader" ffsh
join"nav.Urban-Brand GmbH$eBayFFSalesLine" ffsl
on (ffsh."No_"=ffsl."Document No_" and ffsh."Entry No_"=ffsl."Document Entry No_")
where ffsl."Document Entry No_"='1'
and ffsl.Type='2'
and cast(ffsh."Order Date" as date)>='2015-10-01'
 ) as ffsl2
where ffsl2.Rankordnung=1) as line_nav
on (line_nav."Document No_"=cte3.Auftrag and line_nav.No_=cte3.Ean)
) as cte4
where cte4.Auftrag<>'NAV-A0005207551'
and ifnull(cte4.LineNum,cte4."Line No_") not like ''





