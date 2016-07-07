select 
ax_times2.*
,dhl_times.tracking_id
,dhl_times.KnownToDHL
,dhl_times.DeliveryTimestamp
,case when dhl_times.DeliveryTimestamp like '' then '0' else '1' end isDelivered
from (
select 
--ax_times.AX_OrderDate
cast(so.order_date as timestamp) as OrderDate
,ax_times.salesid
,ax_times.customerref
,ax_times.salesname
,ax_times.custaccount
,ax_times.displayvalue
,ax_times.dlvmode
,ax_times.salesoriginid
,ax_times.paymmode
,ax_times.countryid
,ax_times.documentstatus
,ax_times.orderstopped
,ax_times.Fulfillment_Date
,ax_times.Fulfillment_Response


from (
SELECT 
cast(st.createddatetime as timestamp) as AX_OrderDate
--,cast (so.order_date as timestamp) as OrderDate_Shop
,st.salesid
,st.customerref
,st.salesname
,st.custaccount
,ddv.displayvalue
,st.dlvmode
,st.salesoriginid
,st.paymmode
,lo.countryregionid as CountryID
,CASE st.documentstatus
	WHEN '0' THEN 'Hold'
	WHEN '3' THEN 'Warten auf Ware'
	WHEN '4' THEN 'in Logistik'
	when '7' then 'Fakturiert' end as Documentstatus
,st.mcrorderstopped as OrderStopped
,timestampadd(sql_tsi_hour,2,cast(pick.activationdatetime as timestamp)) as Fulfillment_Date
,timestampadd(sql_tsi_hour,2,cast(stag_out.createddatetime as timestamp)) as Fulfillment_Response
,row_number() over (partition by st.salesid,st.customerref order by timestampadd(sql_tsi_hour,2,cast(pick.activationdatetime as timestamp))) as Rankordnung
 FROM "AX.PROD_DynamicsAX2012.dbo.SALESTABLE" as st
left join "shop_orders.orders" so
 on so.order_id=st.customerref
 left join "AX.PROD_DynamicsAX2012.dbo.DEFAULTDIMENSIONVIEW" ddv
 on ddv.defaultdimension=st.defaultdimension
 left join "AX.PROD_DynamicsAX2012.dbo.LOGISTICSPOSTALADDRESS" lo
 on lo.recid=st.deliverypostaladdress 
 left join "AX.PROD_DynamicsAX2012.dbo.WMSPICKINGROUTE"  as pick
on pick.transrefid=st.salesid
left join "AX.PROD_DynamicsAX2012.dbo.WINSALESORDEROUTPUTTABLESTAGING" as stag_out
on stag_out.salesid=st.salesid
where ddv.Name='BusinessUnit'

 group by
 cast(st.createddatetime as timestamp)
 --,cast (so.order_date as timestamp)
,st.salesid
,st.customerref
,st.salesname
,ddv.displayvalue
,st.custaccount
,st.salesoriginid
,st.paymmode
,st.dlvmode
,lo.countryregionid 
,st.documentstatus
,st.mcrorderstopped
,cast(pick.activationdatetime as timestamp)
,cast(stag_out.createddatetime as timestamp)
) ax_times
left join "shop_orders.orders" so
on so.order_id=ax_times.customerref 
where ax_times.Rankordnung=1
and cast(so.order_date as date)>='2016-01-01'
) as ax_times2
left join "views.DHL_Timestamps" dhl_times
on dhl_times."Order No_"=ax_times2.salesid
