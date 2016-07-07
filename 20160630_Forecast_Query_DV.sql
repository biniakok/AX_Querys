BEGIN 
    DECLARE date date_from = CAST('2016-05-01' AS date);
    DECLARE date date_till = CAST(now() AS date);
    DECLARE string warehouseCode = 'BER_FIEGE';

    SELECT
        warehouseCode AS WarehouseCode
        , d.Date AS "Date"
        , (SELECT ForecastPacks FROM Forecast.dbo.WarehousePackageForecast wpf 
            WHERE wpf.WarehouseCode = warehouseCode AND wpf.Date = d.Date AND DestinationCountryCode = N'CHN'
            ORDER BY wpf.InsertedAt DESC LIMIT 1) AS CHN
        , (SELECT ForecastPacks FROM Forecast.dbo.WarehousePackageForecast wpf 
            WHERE wpf.WarehouseCode = warehouseCode AND wpf.Date = d.Date AND DestinationCountryCode = N'GER'
            ORDER BY wpf.InsertedAt DESC LIMIT 1) AS GER
        , (SELECT ForecastPacks FROM Forecast.dbo.WarehousePackageForecast wpf 
            WHERE wpf.WarehouseCode = warehouseCode AND wpf.Date = d.Date AND DestinationCountryCode = N'CHE'
            ORDER BY wpf.InsertedAt DESC LIMIT 1) AS CHE
        , (SELECT ForecastPacks FROM Forecast.dbo.WarehousePackageForecast wpf      
            WHERE wpf.WarehouseCode = warehouseCode AND wpf.Date = d.Date AND DestinationCountryCode = N'TOTAL'
            ORDER BY wpf.InsertedAt DESC LIMIT 1) AS TOTAL
    FROM
        "UnifiedDWH.D_Date" d
    WHERE
        d.Date between date_from AND date_till ; 
END;