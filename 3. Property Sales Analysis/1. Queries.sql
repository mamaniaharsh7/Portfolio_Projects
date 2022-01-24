
						/*-- PROPERTY SALES ANALYSIS --*/


-- Database name --> house_property_sales
-- Table --> raw_sales


#===============================================================================================================================================


--					***** overview of the Data presented *****

USE house_property_sales ;

SHOW FULL TABLES IN house_property_sales;

SELECT *
FROM information_schema.columns 
WHERE table_schema = 'house_property_sales' ;
/* Table : raw_sales || five columns --> datesold, postcode, price, propertyType, bedrooms. */

#printing some records from the dataset
SELECT * FROM house_property_sales.raw_sales
LIMIT 10 ;

#understanding the dataset
SELECT MIN(datesold) AS first_datesold, MAX(datesold) AS last_datesold, count(*) as 'Total Records' 
FROM house_property_sales.raw_sales ;

SELECT COUNT(distinct postcode), COUNT(distinct propertyType), COUNT(distinct bedrooms)
FROM house_property_sales.raw_sales ;

SELECT DISTINCT propertyType FROM house_property_sales.raw_sales ;

SELECT DISTINCT bedrooms FROM house_property_sales.raw_sales ;

SELECT MIN(price), MAX(price) FROM house_property_sales.raw_sales ;

/* 
-- The dataset covers "29580" records from '7th-Feb-2007' to '27-Jul-2019'. 
-- There are '27' Unique POSTCODES throughout the Dataset.
-- All the properties are divided in '2' PROPERTY TYPES -- 1. 'HOUSE' ; 2. 'UNIT'
-- Dataset also has information regarding the 'NO. OF BEDROOMS' each of these Properties have : ranging from '0' to '5' !
-- The MINIMUM PRICE for any Property sale ever has been "56,500", while the MAXIMUM PRICE stood at "80,00,000".
*/


#==========================================================================================


--					***** #1 'DATE with MOST FREQUENT SALES' *****

SELECT datesold, COUNT(*) AS 'Sales_Count_that_day', SUM(price) AS 'Total_Revenue_that_day'
FROM house_property_sales.raw_sales
GROUP BY datesold
ORDER BY Sales_Count_that_day DESC LIMIT 20 ;
/* 
Thus, MAXIMUM NO. OF SALES for a single day is "50"
	which was on '28th_October_2017'
	with the HIGHEST EVER single day REVENUE of "42.4M".
    
	
| **datesold** | **Sales_Count_that_day** | **Total_Revenue_that_day** |
|--------------|--------------------------|----------------------------|
| 2017-10-28   | 50                       | 42421600                   |
| 2017-11-18   | 39                       | 34661000                   |
| 2018-03-24   | 38                       | 32819000                   |
| 2017-04-08   | 37                       | 31556000                   |
| 2017-11-11   | 37                       | 31425200                   |
| 2018-02-24   | 35                       | 33223500                   |
| 2017-11-04   | 34                       | 31778600                   |
| 2019-07-01   | 34                       | 18373226                   |
| 2017-02-25   | 34                       | 31340500                   |
| 2015-11-07   | 33                       | 28516000                   |
|      .       |  .                       |     .                      |
|      .       |  .                       |     .                      |


    
-- Apart from '50'... we notice that on Best Days, the Sales Count has empirically been between '30' to '40' only.
-- We also notice that, out of the top 10... '6' have been from '2017'... of which, '4' being just from the months of "October-November"
	==>thus, the 'Last Quarter of 2017' has been the 'Golden Period'.
*/


#==========================================================================================


--					***** #2 'POSTCODE which has HIGHEST AVERAGE PRICE per sale' *****

SELECT postcode, AVG(price) AS 'Avg_Sales_Price', COUNT(*) AS 'Sales_Count_for_postcode'
FROM house_property_sales.raw_sales
GROUP BY postcode
ORDER BY Avg_Sales_Price DESC LIMIT 10 ;
/* 
So, POSTCODE '2618' with an Average Price of "1.08M" is the most expensive, 
	though it has a total of only '9' sales. 
   

| **postcode** | **Avg_Sales_Price** | **Sales_Count_for_postcode** |
|--------------|---------------------|------------------------------|
| 2618         | 1081111.1111        | 9                            |
| 2603         | 1028641.9130        | 805                          |
| 2600         | 1028204.3785        | 634                          |
| 2605         | 786175.1232         | 771                          |
| 2911         | 724795.5823         | 249                          |
| 2602         | 695718.7591         | 2603                         |
| 2607         | 694716.3686         | 963                          |
| 2604         | 647640.8998         | 1058                         |
| 2612         | 645411.1182         | 1210                         |
| 2611         | 642145.0365         | 1864                         |


*/


#==========================================================================================


--					***** #3 'YEAR with LOWEST number of sales' *****

SELECT YEAR(datesold) AS 'Yearr', SUM(price) AS 'Total_Revenue', COUNT(1) AS 'Sales_Count'
FROM house_property_sales.raw_sales
GROUP BY YEAR(datesold)
ORDER BY Sales_Count ASC ;
/* 
- Hence, the years '2007' & '2008' have the LOWEST NO. OF SALES (Sales Quantity), with "147" & "639" properties being sold respectively. 
- The immediate next in the list being '2019' with a huge jump to "1385". (More than even '2x' times than previous one.)

	
| **Yearr** | **Total_Revenue** | **Sales_Count** |
|-----------|-------------------|-----------------|
| 2007      | 76789450          | 147             |
| 2008      | 315547250         | 639             |
| 2019      | 878345143         | 1385            |
| 2009      | 707427239         | 1426            |
| 2010      | 870123280         | 1555            |
| 2011      | 925445775         | 1633            |
| 2012      | 1026547544        | 1858            |
| 2013      | 1172689133        | 2119            |
| 2014      | 1696767719        | 2863            |
| 2015      | 2284017698        | 3648            |
| 2018      | 2548984623        | 3858            |
| 2016      | 2482304198        | 3908            |
| 2017      | 3051009584        | 4541            |


- To connect the dots, this goes on to show the drastic effect of the "Great Recession during the period of 2007-2008".  

- Total Revenues in '2007' and '2008' --> "76.78945 million" and "315.54725 million" respectively... 
	Despite the overall Average of 'Yearly-Revenues' being "1387.38451 million" ('18x' times greater than '2017' and '4x' times greater than '2018' Revenues)
    
Calculated Average of 'Yearly-Revenues' using :

SELECT avg(b.Total_Revenue) as Avg_Yearly_Revenue
FROM (SELECT year(datesold) as Year, sum(price) as Total_Revenue, count(1) as Sales_Count
FROM house_property_sales.raw_sales
GROUP BY year(datesold)
ORDER BY Sales_Count ASC) b ;
--1387384510.4615
*/ 


#==========================================================================================


--					***** #4 'TOP 5 POSTCODES by its TOTAL YEARLY REVENUE in each year' *****

SELECT year(datesold) as 'Yearr', count(DISTINCT postcode) as 'No_Of_Postcodes_available_listed'
FROM house_property_sales.raw_sales
GROUP BY Yearr 
ORDER BY Yearr;
/*

| **Yearr** | **No_Of_Postcodes_available_listed** |
|-----------|--------------------------------------|
| 2007      | 21                                   |
| 2008      | 23                                   |
| 2009      | 24                                   |
| 2010      | 24                                   |
| 2011      | 26                                   |
| 2012      | 25                                   |
| 2013      | 26                                   |
| 2014      | 25                                   |
| 2015      | 26                                   |
| 2016      | 26                                   |
| 2017      | 25                                   |
| 2018      | 25                                   |
| 2019      | 25                                   |

-- On an Average, Consumers enjoyed '25' (~24.69) options of POSTCODES to choose from, every year. 
*/

with cte_tbl123 as (
SELECT a.Year, a.postcode, a.Total_Yearly_Revenue,
		RANK() OVER (partition by Year order by Total_Yearly_Revenue DESC) as 'Rnk'	
FROM (SELECT year(datesold) as 'Year',
		postcode,
        sum(price)  as 'Total_Yearly_Revenue'
FROM house_property_sales.raw_sales 
GROUP BY year(datesold), postcode
ORDER BY year(datesold), Total_Yearly_Revenue) a
)
SELECT * FROM cte_tbl123
WHERE Rnk < 6 ; 
/* 
Damnnnn, 3 nested-tables !! << 1st to get 'Sum(price) of each pincode, per year ; 2nd to Rank'em ; 3rd to Limit only 5 Ranks per Year. >>
	

| **Year** | **postcode** | **Total_Yearly_Revenue** | **Rnk** |
|----------|--------------|--------------------------|---------|
| 2007     | 2602         | 11225500                 | 1       |
| 2007     | 2905         | 6415500                  | 2       |
| 2007     | 2906         | 5696500                  | 3       |
| 2007     | 2612         | 5575000                  | 4       |
| 2007     | 2902         | 4870000                  | 5       |
|          |              |                          |         |
| 2008     | 2611         | 32017750                 | 1       |
| 2008     | 2602         | 29482950                 | 2       |
| 2008     | 2906         | 27925000                 | 3       |
| 2008     | 2905         | 26553500                 | 4       |
| 2008     | 2615         | 24940450                 | 5       |
|          |              |                          |         |
| 2009     | 2905         | 72295975                 | 1       |
| 2009     | 2615         | 67330345                 | 2       |
| 2009     | 2602         | 65746250                 | 3       |
| 2009     | 2906         | 61098490                 | 4       |
| 2009     | 2611         | 51864450                 | 5       |
| .        | .            | .                        | .       |
| .        | .            | .                        | .       |
| .        | .            | .                        | .       |
| 2018     | 2615         | 270900394                | 1       |
| 2018     | 2602         | 264462830                | 2       |
| 2018     | 2913         | 241767690                | 3       |
| 2018     | 2914         | 204936759                | 4       |
| 2018     | 2617         | 183623966                | 5       |
|          |              |                          |         |
| 2019     | 2615         | 110214894                | 1       |
| 2019     | 2913         | 84974450                 | 2       |
| 2019     | 2602         | 78585638                 | 3       |
| 2019     | 2914         | 69138650                 | 4       |
| 2019     | 2617         | 67455088                 | 5       |

        
-- POSTCODES "2602" and "2615" have proven to be Gold-mines!!

-- Notice the stellar run of POSTCODE "2602" : 
		Topped the list --> 6 times (for 6yrs) ; 
        Been 2nd --> 5 times ; 3rd --> 2 times ;
-- Also of POSTCODE "2615" : 
		Topped the list --> 5 times (for 5yrs) ; 	
        Been 2nd --> 6 times, 5th --> Once ;
*/


#==========================================================================================


--					***** #5 'NO. OF 'HOUSES' and 'UNITS' sold in every year' *****

SELECT year(datesold) as 'yearrr',
		SUM(propertyType='house') as 'no_of_HOUSES_sold',  -- sum(case when propertyType = "house" then 1 else 0 end)
        SUM(propertyType='unit') as 'no_of_UNITS_sold'	   -- sum(case when propertyType = "unit" then 1 else 0 end)
FROM house_property_sales.raw_sales 
GROUP BY yearrr
ORDER BY yearrr ;
/* 

| **yearrr** | **no_of_HOUSES_sold** | **no_of_UNITS_sold** |
|------------|-----------------------|----------------------|
| 2007       | 130                   | 17                   |
| 2008       | 592                   | 47                   |
| 2009       | 1235                  | 191                  |
| 2010       | 1374                  | 181                  |
| 2011       | 1439                  | 194                  |
| 2012       | 1612                  | 246                  |
| 2013       | 1841                  | 278                  |
| 2014       | 2507                  | 356                  |
| 2015       | 3093                  | 555                  |
| 2016       | 3213                  | 695                  |
| 2017       | 3630                  | 911                  |
| 2018       | 2864                  | 994                  |
| 2019       | 1022                  | 363                  |


-- Each and every year, more HOUSES have been sold, than UNITs... that too, more by a big big margin. 
-- Every year on an Avg, "1888.6154" HOUSES have been sold, while only "386.7692" UNITS have been sold. <<obtained from the query after this>>
-- This means, generally, for every 1 'UNIT' sold, 5 (~4.88) 'HOUSES' are sold !! 
*/

SELECT avg(no_of_HOUSES_sold) as 'Avg_no_of_HOUSES_sold_per_yr', avg(no_of_UNITS_sold) as 'Avg_no_of_UNITS_sold_per_yr'
FROM ( SELECT year(datesold) as 'yearrr',
				SUM(propertyType='house') as 'no_of_HOUSES_sold',  
				SUM(propertyType='unit') as 'no_of_UNITS_sold'	   
		FROM house_property_sales.raw_sales 
		GROUP BY yearrr
		ORDER BY yearrr) q ;
/*
-- Avg_no_of_HOUSES_sold_per_yr --> 1888.6154 ;  
-- Avg_no_of_UNITS_sold_per_yr  --> 386.7692  ;
*/


#==========================================================================================


--					***** #6 'The DIFFERENCES in AVERGAE PRICEs of 'HOUSE' and 'UNIT'.' *****

SELECT year(datesold) as 'yearrr',
		AVG(CASE WHEN propertyType='house' THEN price ELSE NULL end) as 'HOUSES_price_Avg',  #default value after 'ELSE' is anyway 'NULL' only
        AVG(CASE WHEN propertyType='unit' THEN price ELSE NULL end) as 'UNITS_price_Avg'	   
FROM house_property_sales.raw_sales 
GROUP BY yearrr
ORDER BY yearrr ;
/* 
	
| **yearrr** | **HOUSES_price_Avg** | **UNITS_price_Avg** |
|------------|----------------------|---------------------|
| 2007       | 539903.8462          | 388350.0000         |
| 2008       | 506913.0068          | 328824.4681         |
| 2009       | 514341.6915          | 378090.3141         |
| 2010       | 574450.5633          | 446564.6740         |
| 2011       | 587022.5678          | 416084.0206         |
| 2012       | 572388.0906          | 422186.7561         |
| 2013       | 571525.1456          | 433494.0288         |
| 2014       | 612682.2800          | 451610.2331         |
| 2015       | 661248.3653          | 430227.9351         |
| 2016       | 680150.1335          | 427311.9698         |
| 2017       | 734985.2997          | 420431.3348         |
| 2018       | 744013.1473          | 420654.8984         |
| 2019       | 713141.4795          | 411885.8154         |


-- General Trend in the AVERAGE PRICES has always been UPWARDS, throughout the years.

-- TThe average price for a 'house' is pretty much more than a 'unit', always !

-- Both had their lowest Avg Prices in '2008' : 
	'house' --> 506913.0068 and 'unit' --> 328824.4681
    
-- However, both have had different times for their 'All-time-high'
    in '2014' for 'Unit' when its AvgPriceForTheYear shot up to '451610.2331'  
    in '2018' for 'House' when its AvgPriceForTheYear shot up to '744013.1473'
*/


#==========================================================================================


--					***** #7 'AVERAGE PRICE to afford '1 BEDROOM' in each property type' *****

SELECT year(datesold) as 'yearrr',
		AVG(CASE WHEN propertyType='house' THEN price/bedrooms ELSE NULL end) as 'HOUSES_price_Avg_per_Bedroom',  
        AVG(CASE WHEN propertyType='unit' THEN price/bedrooms ELSE NULL end) as 'UNITS_price_Avg_per_Bedroom'	   
FROM house_property_sales.raw_sales 
GROUP BY yearrr
ORDER BY yearrr 
/* 
	
| **yearrr** | **HOUSES_price_Avg_per_Bedroom** | **UNITS_price_Avg_per_Bedroom** |
|------------|----------------------------------|---------------------------------|
| 2007       | 159899.80769462                  | 183008.33332941                 |
| 2008       | 148832.47888547                  | 204470.10869348                 |
| 2009       | 148299.90735547                  | 218741.57940733                 |
| 2010       | 165950.66791630                  | 243916.72928177                 |
| 2011       | 170924.96415309                  | 243486.34020567                 |
| 2012       | 165814.48070540                  | 250641.15311748                 |
| 2013       | 164179.79286910                  | 242955.57761661                 |
| 2014       | 173524.80558643                  | 244176.75774676                 |
| 2015       | 185480.09155620                  | 244952.40355714                 |
| 2016       | 193627.13572781                  | 252692.47074345                 |
| 2017       | 207370.46589010                  | 250572.55005523                 |
| 2018       | 210748.69649124                  | 261469.03494597                 |
| 2019       | 200855.10730626                  | 244309.60433961                 |

    
-- The picture is different this time !! 
The AVERAGE PRICE for the 'UNIT' is higher than 'HOUSE' in terms of the "NO. OF BEDROOMS"... 
    
(contrary to the previous query's result, which showed that AVERAGE PRICE for a 'HOUSE' is pretty much more than a 'UNIT'.) 
*/


#==========================================================================================





