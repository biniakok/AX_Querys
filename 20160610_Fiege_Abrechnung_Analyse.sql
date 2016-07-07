/*WE-Auswertung*/

select sum(cte.qty*cast(cte.purchunit_num as integer)) from (
SELECT
        v.origpurchid
        ,v.purchaselinelinenumber
        ,v.itemid
        --,v.name
        ,v.qty
        --,v.purchunit
        ,case  
             when length(v.purchunit)='4' then left(v.purchunit,2)
             when (length(v.purchunit)='3' and v.purchunit not like 'PCS') then left(v.purchunit,1)
             else '1'             
        end purchunit_num
    FROM
        "AX.PROD_DynamicsAX2012.dbo.VENDPACKINGSLIPTRANS" as v
    join "AX.PROD_DynamicsAX2012.dbo.VENDPACKINGSLIPJOUR" as vjour
    on vjour.purchid=v.origpurchid
     where vjour.Deliverydate>='2016-05-01'
     and   vjour.Deliverydate<='2016-05-31' 
    group by
        origpurchid
        ,purchaselinelinenumber
        ,itemid
        ,name
        ,purchunit
        ,qty) as cte
 
/* WA-Auswertung*/

select count(distinct cte.salesid) from (
SELECT 
stag.salesid 
,sl.itemid
,sl.salesqty as menge
 FROM "AX.PROD_DynamicsAX2012.dbo.WINSALESORDEROUTPUTTABLESTAGING" as stag
 join "AX.PROD_DynamicsAX2012.dbo.SALESLINE" as sl
 on stag.salesid=sl.salesid
 join "AX.PROD_DynamicsAX2012.dbo.SALESTABLE" as st
 on st.salesid=stag.salesid
 where cast(stag.createddatetime as date)>='2016-05-01'
 and cast(stag.createddatetime as date)<='2016-05-31'
 and stag.status=1
 and taxitemgroup like 'T%'
 and st.inventlocationid='FIEGE_GB') as cte
 
 /*Retoure*/
 
select sum(cte.menge) from (
SELECT 
stag.salesid
,st.customerref
,sl.itemid
,sl.quantityreturned as menge
,stag.inventlocationid
,cast(stag.returndate as date) as ReturnDate
,stag.status
,st.salesoriginid
FROM "AX.PROD_DynamicsAX2012.dbo.WINSALESORDERRETURNTABLESTAGING" stag
join "AX.PROD_DynamicsAX2012.dbo.SALESTABLE" st
on stag.salesid=st.salesid
join "AX.PROD_DynamicsAX2012.dbo.WINSALESORDERRETURNLINESTAGING" as sl
 on stag.returnitemnum=sl.returnitemnum
where stag.status=1
--and st.salesoriginid='WINDELN_DE'
and cast(stag.returndate as date)>='2016-05-01'
and cast(stag.returndate as date)<='2016-06-01'

group by
stag.salesid
,st.customerref
,stag.inventlocationid
,cast(stag.returndate as date) 
,stag.status
,st.salesoriginid
,sl.itemid
,sl.quantityreturned) as cte
 
 
 
 /* Korrekturbuchungen-Auswertung*/
 
 
 