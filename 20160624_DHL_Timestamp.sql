/****** Script for SelectTopNRows command from SSMS  ******/
select 
cte2.tracking_id 
,cte2.[Order No_]
,cte2.KnownToDHL
,cte2.DeliveryTimestamp

from (
select 
cte.tracking_id
,cte.[Order No_]
,known.event_timestamp as KnownToDHL
,del.event_timestamp as DeliveryTimestamp
,row_number() over(partition by cte.tracking_id,cte.[Order No_] order by del.event_timestamp desc) as Rankordnung 

from (
SELECT 
a.tracking_id
,a.event_timestamp
,a.[Order No_]
,ice_ric.[ice_event_name]
,ice_ric.[ice_ric_name_de]
  FROM [BI_Data].[dbo].[Dhl_info_api] a
  left join [BI_Data].[dbo].[DHL_ICE_Events_RIC_Kombinations] ice_ric
  on (ice_ric.[ice_event_code]=a.ice and ice_ric.[ice_ric_code]=a.ric) 
 -- where ice_ric.[ice_event_name] in ('Delivered','PAN Received by Carrier')
  where cast(a.event_timestamp as date)>= '2016-01-01'
  ) as cte
   left join (
  SELECT 
a.tracking_id
,a.event_timestamp
,a.[Order No_]
,ice_ric.[ice_event_name]
,ice_ric.[ice_ric_name_de]
  FROM [BI_Data].[dbo].[Dhl_info_api] a
  left join [BI_Data].[dbo].[DHL_ICE_Events_RIC_Kombinations] ice_ric
  on (ice_ric.[ice_event_code]=a.ice and ice_ric.[ice_ric_code]=a.ric) 
  where ice_ric.[ice_event_name]='Delivered'
  ) as del
  on (del.tracking_id=cte.tracking_id and del.[Order No_]=cte.[Order No_])
 left  join (
   SELECT 
a.tracking_id
,a.event_timestamp
,a.[Order No_]
,ice_ric.[ice_event_name]
,ice_ric.[ice_ric_name_de]
  FROM [BI_Data].[dbo].[Dhl_info_api] a
  left join [BI_Data].[dbo].[DHL_ICE_Events_RIC_Kombinations] ice_ric
  on (ice_ric.[ice_event_code]=a.ice and ice_ric.[ice_ric_code]=a.ric) 
  where ice_ric.[ice_event_name]='PAN Received by Carrier'
  ) as known
  on (known.tracking_id=cte.tracking_id and known.[Order No_]=cte.[Order No_])
  group by
  cte.tracking_id
,cte.[Order No_]
,known.event_timestamp 
,del.event_timestamp ) as cte2
where cte2.Rankordnung=1