select 
* 
--,stag_line.uniqueid
from (
select
cte1.PO
,cte1.Ean
,cte1.Menge_gebucht_Fiege
,ifnull(cte4.Gebucht_AX_gesamt,0) as Gebucht_AX_gesamt
,cte1.Menge_gebucht_Fiege-ifnull(cte4.Gebucht_AX_gesamt,0) as Differenz

from (
select 
fiege.po
,fiege.ean
,cast(sum(fiege.menge) as integer) as Menge_gebucht_Fiege from (
	SELECT "PO", "EAN", "Menge" FROM "DWHStaging.DWH_Staging.dbo.WE_Fiege_Original_20160621"
) as fiege
group by
fiege.po
,fiege.ean) as cte1
left join (
select
cte3.origpurchid
,cte3.itemid

,sum(cte3.Menge_gebucht_AX*cast(cte3.purchunit_num as integer)) as Gebucht_AX_gesamt
from (
SELECT
        cast(deliverydate as date)
        ,vendpackingslipjour
        ,origpurchid
                ,itemid

        ,cast(sum(qty) as integer) as Menge_gebucht_AX
        ,case
             when length(purchunit)='4' then left(purchunit,2)
             when (length(purchunit)='3' and purchunit not like 'PCS') then left(purchunit,1)
             else '1'
        end purchunit_num
    FROM
        "AX.PROD_DynamicsAX2012.dbo.VENDPACKINGSLIPTRANS"

    group by
        origpurchid
        ,cast(deliverydate as date)
       ,itemid
       ,vendpackingslipjour
       ,length(purchunit)
       ,purchunit) as cte3
       where cte3.itemid not like ''
      group by
     cte3.origpurchid
,cte3.itemid
) as cte4
on (cte4.origpurchid=cte1.PO and cte4.itemid=cte1.ean)
) as cte5
where cte5.Differenz>0
and cte5.PO<>'Best-1109224'


