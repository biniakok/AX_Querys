SELECT "OrderDate", "SALESID", "CUSTOMERREF", "SALESNAME", "CUSTACCOUNT", "dlvmode", "PAYMMODE", "CountryID",   "Fulfillment_Date", "Fulfillment_Response", "trackingid", "KnownToDHL", "DeliveryTimestamp"
,case when DeliveryTimestamp not like '' then '1' else '0' end isDelivered
,case when KnownToDHL not like '' then '1' else '0' end isKnownToDHL
,timestampdiff (sql_tsi_day,"OrderDate","KnownToDHL") as Deliverytime_Win_DHL
,timestampdiff (sql_tsi_day,"OrderDate","DeliveryTimestamp") as DeliverytimeTotal
FROM "views.KonB_DLZ_kompakt_2016"
where dlvmode='DPWC'