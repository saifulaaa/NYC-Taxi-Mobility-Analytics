CREATE DATABASE nyc_taxi_analysis;
use nyc_taxi_analysis;
select DATABASE();
-- Verify the row count

SELECT COUNT(*) AS total_records
FROM yellow_taxi_trips;
 
-- incepect first 5 rows
SELECT * 
FROM yellow_taxi_trips
LIMIT 5; 

-- Check the table structure

DESCRIBE yellow_taxi_trips; 

-- Taxi Zone Incepection

SELECT count(*) as total_recods 
FROM taxi_zones;

SELECT 
	t.PULocationID,
    z.Borough,
    z.Zone,
    COUNT(*) AS total_pickups
FROM yellow_taxi_trips as t
LEFT JOIN taxi_zones z
	ON t.PULocationID = z.LocationID
GROUP BY 
	t.PULocationID,
    z.Borough,
    z.Zone
ORDER BY total_pickups DESC
LIMIT 10;

-- Check unmatched pickup locations

SELECT COUNT(*) as 	unmatched_pickups
FROM yellow_taxi_trips t
LEFT JOIN taxi_zones z
    ON t.PULocationID = z.LocationID
WHERE z.LocationID IS NULL;

-- Check unmatched drop-off locations

SELECT COUNT(*) as unmatched_dropoffs
FROM yellow_taxi_trips t
LEFT JOIN taxi_zones z
	ON t.DOLocationID = z.LocationID
WHERE z.LocationID IS NULL;

-- This confirms that every pickup and drop-off location ID has a matching zone record.

-- Business Analysis
-- 1.What is the total number of taxi trips recorded in March 2025?
SELECT COUNT(*) as total_trips 
FROM yellow_taxi_trips;

-- 2: What is the total recorded revenue from all taxi trips? 
SELECT ROUND(SUM(total_amount),2) AS total_recorded_revenue 
FROM yellow_taxi_trips;

-- 3: What is the average fare amount per trip?
SELECT ROUND(AVG(fare_amount),2) AS average_fare_amount
FROM yellow_taxi_trips;

-- 4: Find the highest and lowest fare amounts.
SELECT 
	MIN(fare_amount) AS lowest_fare_amount,
    MAX(fare_amount) AS highest_fare_amount
FROM yellow_taxi_trips;

-- 5: How many trips were paid using each payment type?
SELECT payment_type,
	   COUNT(*) AS trips
FROM yellow_taxi_trips
GROUP BY payment_type
ORDER BY trips DESC;

-- 6: Which are the top 10 busiest pickup locations?
SELECT PULocationID AS pickup_location,
	   COUNT(*) AS total_pickups
FROM yellow_taxi_trips
GROUP BY PULocationID
ORDER BY COUNT(*) DESC
LIMIT 10;

-- 7: Which are the top 10 busiest drop-off locations?
SELECT DOLocationID AS dropoff_location,
	   COUNT(*) AS total_dropoffs
FROM yellow_taxi_trips
GROUP BY DOLocationID
ORDER BY total_dropoffs DESC
LIMIT 10;

-- 8: What is the average trip distance?
SELECT ROUND(AVG(trip_distance),2) AS average_trip_distance
FROM  yellow_taxi_trips;

-- 9. What is the average trip duration in minutes? 
SELECT ROUND(AVG(trip_duration_minutes),2) AS average_trip_duration
FROM yellow_taxi_trips
WHERE trip_duration_minutes > 0;

-- 10: Which day had the highest number of taxi trips?
SELECT DATE(tpep_pickup_datetime) AS days,
	   COUNT(*) AS total_trips
FROM yellow_taxi_trips
GROUP BY DATE(tpep_pickup_datetime)
ORDER BY total_trips DESC
LIMIT 1;

-- 11: Which hour had the highest number of taxi trips?
SELECT HOUR(tpep_pickup_datetime) AS hours,
	   COUNT(*) AS total_trips
FROM yellow_taxi_trips
GROUP BY HOUR(tpep_pickup_datetime)
ORDER BY total_trips DESC
LIMIT 1;

-- 12: How many trips happened on weekdays versus weekends?
SELECT
	COUNT(CASE WHEN DAYOFWEEK(tpep_pickup_datetime) BETWEEN 2 AND 6 THEN 1 END) AS weekdays,
	COUNT(CASE WHEN DAYOFWEEK(tpep_pickup_datetime) IN (1, 7) THEN 1 END) AS weekends
FROM yellow_taxi_trips;

-- 13: Which day of the week has the highest number of trips?
SELECT DAYNAME(tpep_pickup_datetime) as days,
	   COUNT(*) AS total_trips
FROM yellow_taxi_trips
GROUP BY DAYNAME(tpep_pickup_datetime)
ORDER BY total_trips DESC
LIMIT 1;

-- 14: Which borough generates the highest recorded revenue?
SELECT z.Borough, ROUND(SUM(t.total_amount),2) AS total_revenue
FROM yellow_taxi_trips t
LEFT JOIN taxi_zones z
	ON t.PULocationID = z.LocationID
GROUP BY z.Borough
ORDER BY total_revenue DESC;

-- 15: Which borough has the highest number of taxi trips?
SELECT z.Borough, COUNT(*) AS total_trips
FROM yellow_taxi_trips t
LEFT JOIN taxi_zones z
	ON t.PULocationID = z.LocationID
GROUP BY z.Borough
ORDER BY total_trips DESC;

-- 16: Which borough has the longest average trip duration?
SELECT z.Borough, ROUND(AVG(trip_duration_minutes),2) AS avg_duration
FROM yellow_taxi_trips t
LEFT JOIN taxi_zones z
	ON t.PULocationID = z.LocationID
WHERE trip_duration_minutes > 0
GROUP BY z.Borough
ORDER BY avg_duration DESC;

-- 17: Which payment type generates the highest average total amount?
SELECT payment_type, 
	   ROUND(AVG(total_amount),2) as avg_total_amount
FROM yellow_taxi_trips
GROUP BY payment_type
ORDER BY avg_total_amount DESC;
 
-- 18: What are the top 10 most popular pickup-to-drop-off routes?
SELECT PULocationID, 
	   DOLocationID, 
       COUNT(*) as no_of_trips 
FROM yellow_taxi_trips
GROUP BY 
	   PULocationID, 
	   DOLocationID
ORDER BY no_of_trips DESC
LIMIT 10;

-- 19: What percentage of total trips happened in each borough?
SELECT z.Borough, 
	   COUNT(*) AS total_trips,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM yellow_taxi_trips),2) AS percentage_share
FROM yellow_taxi_trips t
LEFT JOIN taxi_zones z
	ON t.PULocationID = z.LocationID
GROUP BY z.Borough
ORDER BY total_trips DESC;

-- 20: Find the top 5 pickup zones by total recorded revenue.
SELECT z.Zone,
	   ROUND(SUM(total_amount),2) AS total_revenue
FROM yellow_taxi_trips t
LEFT JOIN taxi_zones z
	ON t.PULocationID = z.LocationID
GROUP BY z.Zone
ORDER BY total_revenue DESC
LIMIT 5;

-- 21: Find the top 5 pickup zones by number of trips
SELECT z.Zone,
	   COUNT(*) AS total_trips
FROM yellow_taxi_trips t
LEFT JOIN taxi_zones z
	ON t.PULocationID = z.LocationID
GROUP BY z.Zone
ORDER BY total_trips DESC
LIMIT 5;

-- Prepare SQL data for Power BI
SELECT DATE(tpep_pickup_datetime) AS pickup_date,
	   COUNT(*) AS total_trips
FROM yellow_taxi_trips
GROUP BY DATE(tpep_pickup_datetime)
ORDER BY pickup_date;

-- Step 2 — Hourly trips summary
SELECT
    HOUR(tpep_pickup_datetime) AS pickup_hour,
    COUNT(*) AS total_trips
FROM yellow_taxi_trips
GROUP BY HOUR(tpep_pickup_datetime)
ORDER BY pickup_hour; 

-- this creted to connet to power bi  
CREATE USER 'powerbi_user'@'localhost'
IDENTIFIED WITH mysql_native_password
BY 'TaxiPowerBI@2026';

GRANT SELECT ON nyc_taxi_analysis.*
TO 'powerbi_user'@'localhost';

SHOW GRANTS FOR 'powerbi_user'@'localhost';