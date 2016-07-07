select 
cast(cte2.OrderDate as timestamp) as OrderDate
,cast(cast(left(cte2.Zeitstempel,23) as varchar(50))as timestamp) as "TimeStamp" 
,timestampdiff (sql_tsi_day,cte2.OrderDate,cast(cast(left(cte2.Zeitstempel,23) as varchar(50))as timestamp)) as TimeDiff
,cte2.order_id
,cte2.tracking_numbers
,cte2.shipping_address_first_name
,cte2.shipping_address_last_name
,cte2.shipping_address_postcode
,cte2.shipping_address_city
,cte2.shipping_address_country
,cte2.email
,cte2.billing_address_region 
,case when cte2.Status like '"1-IN_TRANSPORTATION%' then 'IN_Transpost'
      when cte2.Status like '"2_A-IN_DELIVERY" , "' then 'IN_Delivery'
      when cte2.Status like '%TAX%'  then 'Tax_Paid'
      when cte2.Status like '%ERROR%' then 'Error'
      when cte2.Status like '%DELIVERED%' then 'Delivered' end  Status
from (
select 
cte.OrderDate
,cte.order_id
,cte.tracking_numbers
,cte.shipping_address_first_name
,cte.shipping_address_last_name
,cte.shipping_address_postcode
,cte.shipping_address_city
,cte.shipping_address_country
,cte.email
,cte.billing_address_region 
,replace(substring(cte."Timestamp",locate(':',cte."Timestamp")+3,length(cte."Timestamp")-length(right(cte."Timestamp",6))-5),'T',' ') as Zeitstempel
,substring(cte.Status,locate(':',cte.Status)+1,length(cte.Status)-length(right(cte.Status,4))-3) as Status
from (
SELECT 
cast(so.order_date as timestamp) as OrderDate
,so.order_id
,so.tracking_numbers
,so.shipping_address_first_name
,so.shipping_address_last_name
,so.shipping_address_postcode
,so.shipping_address_city
,so.shipping_address_country
,so.email
,so.billing_address_region
,substring(substring(so.deliverystatuses,locate('$',so.deliverystatuses)),locate('"',substring(so.deliverystatuses,locate('$',so.deliverystatuses)))) as "Timestamp"
,substring(so.deliverystatuses,locate('status',so.deliverystatuses),locate('details',so.deliverystatuses)-locate('status',so.deliverystatuses)) as status

FROM "shop_orders.orders" so
where so.shipping_method_id='DIRECT_DELIVERY_EXPRESS'
and cast(so.order_date as date)>='2016-01-01') as cte
where cte.tracking_numbers is not null 
and cte.tracking_numbers not like ''
) as cte2

