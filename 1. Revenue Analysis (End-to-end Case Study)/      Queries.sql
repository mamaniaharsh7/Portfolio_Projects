
										/*-- REVENUE ANALYSIS --*/


-- Database name --> sales
-- Tables --> transactions ; products ; customers ; markets ; date


#===============================================================================================================================================


--					***** overview of the Data presented *****

SHOW FULL TABLES IN sales;

SELECT *
FROM information_schema.columns 
WHERE table_schema = 'sales' ;
-- we see all the Tables and their Columns

SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'sales' 
AND table_name = 'transactions' ;

/* we see all the Tables and their Columns
but, the Column-names in 'Transaction' Table don't look named properly, they should be changed as :
	sales_amount ==> selling_price
	profit_margin ==> profit_amount */
    
ALTER TABLE sales.transactions 
RENAME COLUMN sales_amount TO selling_price,
RENAME COLUMN profit_margin TO profit_amount ;


#===============================================================================================================================================


--					***** #1 'OVERALL TREND CHECK' *****
 
SELECT min(order_date) , max(order_date) FROM sales.transactions ;
/* 	To know the span of time that our dataset covers...from '2017-10-04' to '2020-06-26' */

SELECT year(order_date) as 'Year', SUM(selling_price) as 'Revenue', SUM(sales_qty) as 'Sales_Qty'
FROM sales.transactions
GROUP BY year(order_date)  
ORDER BY year(order_date)  ;
/*	
1.  So, the results show a clear **'decline'** in the Revenue every year. (along
    with Sales Quantity)

|   | **Year** | **Revenue**      | **Sales_Qty** |
|---|----------|------------------|---------------|
|   | 2017     | **9,28,82,653**  | 2,34,462      |
|   | 2018     | **41,36,87,163** | 9,97,497      |
|   | 2019     | **33,60,19,102** | 8,47,083      |
|   | 2020     | **14,22,24,545** | 3,50,240      |

- For ‘2017’ data from '2017-10-04' ... monthly avg for 3 given months =
    '30,960,884.33' ...so, on same rate, yearly Revenue would ideally be =
    '37,15,30,611.96' (37Cr)

- For ‘2020’ data till '2020-06-26' ... monthly avg for 6 given months =
    '23,704,090.83' ...so, on same rate, yearly Revenue would ideally be =
    '28,44,49,089.96' (28.4Cr)

<br/>

2.  This implies,

- from 2017 (estimated 37Cr) to 2018 (41.4Cr) year-on-year growth --\> 0.11346
    (**11% incline**)

- from 2018 (41.4Cr) to 2019 (33.6Cr) year-on-year growth --\> -0.18774 (**19%
    decline**)

- from 2019 (33.6Cr) to 2020 (estimated 28.4Cr) year-on-year growth --\>
    \-0.15347 *(***15% decline**)

- Which means on an Average, (-0.07591) **'7.5% decline'** in Revenue every year.
*/

SELECT year(order_date) as 'Yearr', quarter(order_date) as 'Quarterr', SUM(selling_price) as 'Quarterly_Revenue', 
	ROUND((SUM(selling_price) - LAG(SUM(selling_price)) OVER (order by year(order_date), quarter(order_date) ))/ LAG(SUM(selling_price)) OVER (order by year(order_date), quarter(order_date) )*100 , 2) as 'Quarterly_Revenue_Change',
    SUM(sales_qty) as 'Sales_Qty'
FROM sales.transactions
GROUP BY year(order_date), quarter(order_date)  
ORDER BY Yearr, Quarterr ;
/*
Quarter-on-Quarter (Q-O-Q) :

|   | **Yearr** | **Quarterr** | **Quarterly_Revenue** | **Quarterly_Revenue_Change** | **Sales_Qty** |
|---|-----------|--------------|-----------------------|------------------------------|---------------|
|   | 2017      | 4            | 92882653              | NULL                         | 234462        |
|   | 2018      | 1            | 115917613             | **24.8**                     | 265793        |
|   | 2018      | 2            | 102824550             | **-11.3**                    | 271037        |
|   | 2018      | 3            | 105531222             | **2.63**                     | 246481        |
|   | 2018      | 4            | 89413778              | **-15.27**                   | 214186        |
|   | 2019      | 1            | 86932142              | **-2.78**                    | 203795        |
|   | 2019      | 2            | 81027451              | **-6.79**                    | 195263        |
|   | 2019      | 3            | 92181694              | **13.77**                    | 248187        |
|   | 2019      | 4            | 75877815              | **-17.69**                   | 199838        |
|   | 2020      | 1            | 78965343              | **4.07**                     | 204413        |
|   | 2020      | 2            | 63259202              | **-19.89**                   | 145827        |

<<could've applied the same query  logic to directly calculate the Y-o-y growth in previous query, but the Dataset had only 3 months data for 2017, and 6 months data for 2020, which would've hampered the accuracy of calculation.
*/


#===============================================================================================================================================


--					***** #2 'GEOGRAPHIC PRESENCE and REGIONAL CONTRIBUTION' *****

SELECT year(order_date) as 'Yearr', COUNT(DISTINCT market_code) as 'No_of_cities_served' 
FROM sales.transactions 
GROUP BY year(order_date) 
ORDER BY Yearr;
/*
They have presence in **14 cities**, which has mostly remained **constant**
    over years.

|   | **Yearr** | **No_of_cities_served** |
|---|-----------|-------------------------|
|   | 2017      | **14**                  |
|   | 2018      | **15**                  |
|   | 2019      | **14**                  |
|   | 2020      | **14**                  |

*/


with cte_tbl as (
SELECT a.Yearr, a.City, a.Revenue,
	DENSE_RANK() OVER (partition by a.Yearr order by a.Revenue DESC) as 'Rnk',
    ROUND(AVG(a.Revenue) OVER (partition by a.Yearr), 0) as 'Avg_Rev_per_Location_for_that_year'
FROM (
SELECT  year(order_date) as 'Yearr', market_code, markets_name as 'City', SUM(selling_price) as 'Revenue'
FROM sales.transactions JOIN sales.markets
ON sales.transactions.market_code = sales.markets.markets_code
GROUP BY year(order_date), market_code
ORDER BY Yearr, Revenue DESC 
) a 
)
SELECT Yearr, Rnk, City, Revenue, Avg_Rev_per_Location_for_that_year
FROM cte_tbl
WHERE Rnk<6 ;
/*
The **Top 5 Revenue Generating Cities** have nearly remained the same (and
    in the same order as well) throughout the Years.

|   |   | **Rnk** | **City**      |
|---|---|---------|---------------|
|   |   | 1       | **Delhi NCR** |
|   |   | 2       | **Mumbai**    |
|   |   | 3       | **Ahmedabad** |
|   |   | 4       | **Bhopal**    |
|   |   | 5       | **Nagpur**    |

- Thus, **Delhi NCR** being their major cash-cow, which tops the list with
    hefty margin every year.
*/


#===============================================================================================================================================


--					***** #3 'PRODUCT-WISE PERFORMANCE' *****

SELECT COUNT(DISTINCT product_code) as 'Total no. of Products' FROM sales.products ;  -- 279
/* So, firstly their inventory includes '279' different types of products.  */

SELECT year(order_date) as 'Yearr', COUNT(DISTINCT product_code) as 'Types of Products sold'
FROM sales.transactions 
GROUP BY year(order_date)
ORDER BY Yearr ;
/*
Out of the '279' total types of products in the inventory, not all types
    have been sold each year... there's been lot of fluctuations!

|   | **Yearr** | **Types of Products sold** |
|---|-----------|----------------------------|
|   | 2017      | **208**                    |
|   | 2018      | **264**                    |
|   | 2019      | **238**                    |
|   | 2020      | **197**                    |

- Essentially, it appears that with every passing year, lot of products have
    gone **unsold/been discontinued.**

- Given the fact that we have only **3 months** of data from **'2017'**, still
    there were **'208'** different products sold

- While, even after having **6 months** of Data from **'2020'**, only a mere
    **'197'** types of products have made their way.
    
*/

SELECT  MIN(selling_price) as 'Lowest_Order_Ever_Placed', 
		MAX(selling_price) as 'Highest_Order_Ever_Placed',
        MIN(selling_price/sales_qty) as 'Lowest_Product_Price',
        MAX(selling_price/sales_qty) as 'Highest_Product_Price'
FROM sales.transactions ; 
/*
We see that, the **Product Prices** range from :

- **'Rs.0.9024'** (when 41-Qty were sold for Rs.37) to

- **'Rs.5056'(when 1-Qty were sold for Rs.5056) !!**

- **Also, they've fulfilled orders ranging from 'Rs.5' upto 'Rs.15,10,944'
    !!**
*/

#Let's categorize them for better insights.
SELECT *,
		ROUND(a.Revenue_Generated_from_this_Range * 100 / SUM(a.Revenue_Generated_from_this_Range) OVER (),4) as 'Percentage_contribution_to_Revenue'
FROM
(SELECT 
	CASE
		 WHEN (selling_price/sales_qty) BETWEEN 0 and 500 THEN '0 to 500'
         WHEN (selling_price/sales_qty) BETWEEN 500 and 1000 THEN '500 to 1000'
         WHEN (selling_price/sales_qty) BETWEEN 1000 and 1500 THEN '1000 to 1500'
         WHEN (selling_price/sales_qty) BETWEEN 1500 and 2000 THEN '1500 to 2000'
         WHEN (selling_price/sales_qty) BETWEEN 2000 and 2500 THEN '2000 to 2500'
         WHEN (selling_price/sales_qty) BETWEEN 2500 and 3000 THEN '2500 to 3000'
         WHEN (selling_price/sales_qty) BETWEEN 3000 and 3500 THEN '3000 to 3500'
         WHEN (selling_price/sales_qty) BETWEEN 3500 and 4000 THEN '3500 to 4000'
         WHEN (selling_price/sales_qty) BETWEEN 4000 and 4500 THEN '4000 to 4500'
         WHEN (selling_price/sales_qty) BETWEEN 4500 and 5000 THEN '4500 to 5000'
         WHEN (selling_price/sales_qty) BETWEEN 5000 and 5500 THEN '5000 to 5500'
        ELSE 'out of bound'
        END as 'Price_Range',
        COUNT(DISTINCT product_code) as 'No_of_Unique_Products_in_this_Range', 
        SUM(selling_price) as 'Revenue_Generated_from_this_Range'
FROM sales.transactions 
GROUP BY Price_Range
ORDER BY (selling_price/sales_qty) 
) a ;

/*
**Categorizing** the products based on prices:

|   | **Price_Range**  | **No_of_Unique_Products_in_this_Range** | **Revenue_Generated_from_this_Range** | **Percentage_contribution_to_Revenue** |
|---|------------------|-----------------------------------------|---------------------------------------|----------------------------------------|
|   | **0 to 500**     | **298**                                 | 267066724                             | **27.1185**                            |
|   | **500 to 1000**  | **208**                                 | 188650023                             | **19.1559**                            |
|   | **1000 to 1500** | **138**                                 | 206595481                             | **20.9781**                            |
|   | **1500 to 2000** | **101**                                 | 153620605                             | **15.599**                             |
|   | **2000 to 2500** | **63**                                  | 87150545                              | **8.8494**                             |
|   | **2500 to 3000** | **35**                                  | 27710999                              | **2.8138**                             |
|   | **3000 to 3500** | **21**                                  | 14573147                              | **1.4798**                             |
|   | **3500 to 4000** | **14**                                  | 10425999                              | **1.0587**                             |
|   | **4000 to 4500** | **10**                                  | 28985816                              | **2.9433**                             |
|   | **4500 to 5000** | **3**                                   | 18976                                 | **0.0019**                             |
|   | **5000 to 5500** | **1**                                   | 15148                                 | **0.0015**                             |

- Thus, we see that the **most 'economical' price ranges** contribute the most
    to the **Revenue**!!

    - As, the we keep going up in the 'price range', their contribution to the
        Revenue keeps going down. (**Inversely** related)

- Also, the good thing is that, these **economic yet lucrative** categories
    enjoy the **most No. Of Products.**

    - which implies good sense of **pricing** and **placement**

- We notice that though the total no. of 'Unique' products was only **'338'**,
    but if we try to Sum up the 'No_of_Unique_Products_in_this_Range' column, it
    goes way **beyond 338**...How's that possible?

    - Well, maybe some products have been introduced with **different prices
        at different point of times**, so they get counted in all those
        categories of 'Price_Range'.
*/

DROP TEMPORARY TABLE Transactions_and_Products_temp ;
CREATE TEMPORARY Table Transactions_and_Products_temp
(
	YEARR int,
    Product_Code nvarchar(49),
    Product_Type nvarchar(49),
    Selling_Price numeric,
    Sales_Qty numeric
) ;
INSERT into Transactions_and_Products_temp
SELECT year(a.order_date) as 'yearr', 
		a.product_code,
        b.product_type,
        a.selling_price,
        a.sales_qty
FROM sales.transactions a JOIN sales.products b
ON a.product_code = b.product_code 
ORDER BY yearr ;
SELECT 	YEARR,
		SUM(Sales_Qty) as 'Total_SalesQty',
		SUM(CASE WHEN Product_Type LIKE '%Own Brand%' THEN Sales_Qty END) as 'SalesQty_OWN_BRAND',
        SUM(CASE WHEN Product_Type LIKE '%Own Brand%' THEN Sales_Qty END)*100/SUM(Sales_Qty) as 'Percent_of_Total_SalesQty',
        SUM(CASE WHEN Product_Type LIKE '%Distribution%' THEN Sales_Qty END) as 'SalesQty_DISTRIBUTION',
		SUM(CASE WHEN Product_Type LIKE '%Distribution%' THEN Sales_Qty END)*100/SUM(Sales_Qty) as 'Percent_of_Total_SalesQty',
        SUM(CASE WHEN Product_Type LIKE '%Own Brand%' THEN Selling_Price END) as 'Revenue_from_OWN_BRAND',
        SUM(CASE WHEN Product_Type LIKE '%Distribution%' THEN Selling_Price END) as 'Revenue_from_DISTRIBUTION'
FROM Transactions_and_Products_temp
GROUP BY YEARR ;
/*
<<Here, i've used a 'TempTable' just for the sake of practice... could've easily done this using CTE, View or SubQuery also.>>

**‘Own Brand’** vs **‘Distribution’** products:

|   | **YEARR** | **Total_SalesQty** | **SalesQty_OWN_BRAND** | **Percent_of_Total_SalesQty** | **SalesQty\_** **DISTRIBUTION** | **Percent_of_Total_SalesQty** | **Revenue_from\_** **OWN_BRAND** | **Revenue_from\_** **DISTRIBUTION** |
|---|-----------|--------------------|------------------------|-------------------------------|---------------------------------|-------------------------------|----------------------------------|-------------------------------------|
|   | 2017      | 192730             | 161913                 | **84.0103**                   | 30817                           | **15.9897**                   | 34272017                         | 9706266                             |
|   | 2018      | 819210             | 665248                 | **81.2060**                   | 153962                          | **18.7940**                   | 161756295                        | 51317068                            |
|   | 2019      | 706455             | 495559                 | **70.1473**                   | 210896                          | **29.8527**                   | 126207845                        | 55198050                            |
|   | 2020      | 291468             | 190567                 | **65.3818**                   | 100901                          | **34.6182**                   | 47576491                         | 29818192                            |

- Over the years, we can say that, out of **'100'** products sold, on an
    Average **'75'** would be **'Own Brand'** and **'25'** would be of
    **'Distribution'** Type.

- So, it's a no-brainer that their 'Own Brand' sums up to the major part of
    the 'Total Revenue'!

- On an avg, **'Own Brand'** products generate **'2.5x'** more **Revenue**
    than **'Dsitribution'** products.
*/

with cte_prodRank as (
SELECT a.Yearr, a.product_code, a.product_type, a.Revenue,
	DENSE_RANK() OVER (partition by a.Yearr order by a.Revenue DESC) as 'Rnk',
    ROUND(a.Revenue*100/SUM(a.Revenue) OVER (partition by a.Yearr), 2) as 'Contribution_to_Total_Revenue_that_year'
FROM (
SELECT  year(order_date) as 'Yearr', x.product_code, product_type, SUM(selling_price) as 'Revenue'
FROM sales.transactions x JOIN sales.products y
ON x.product_code = y.product_code
GROUP BY year(order_date), product_code
ORDER BY Yearr, Revenue DESC 
) a 
)
SELECT Yearr, Rnk, product_code, product_type, Revenue, Contribution_to_Total_Revenue_that_year
FROM cte_prodRank
WHERE Rnk<6 ;
/*
**Top 5 Products** Annually:

|   | **Yearr** | **Rnk** | **product_code** | **product_type** | **Revenue** | **Contribution_to_Total_Revenue_that_year** |
|---|-----------|---------|------------------|------------------|-------------|---------------------------------------------|
|   | 2017      | 1       | Prod099          | Own Brand        | 4176622     | 9.5                                         |
|   | 2017      | 2       | Prod239          | Own Brand        | 1681827     | 3.82                                        |
|   | 2017      | 3       | Prod105          | Own Brand        | 1597217     | 3.63                                        |
|   | 2017      | 4       | Prod209          | Own Brand        | 1459093     | 3.32                                        |
|   | 2017      | 5       | **Prod053**      | Own Brand        | 1415754     | 3.22                                        |
|   |           |         |                  |                  |             |                                             |
|   | 2018      | 1       | Prod040          | Own Brand        | 13419987    | 6.3                                         |
|   | 2018      | 2       | Prod159          | Distribution     | 10865231    | 5.1                                         |
|   | 2018      | 3       | **Prod053**      | Own Brand        | 7977828     | 3.74                                        |
|   | 2018      | 4       | Prod049          | Own Brand        | 7306890     | 3.43                                        |
|   | 2018      | 5       | Prod239          | Own Brand        | 7218613     | 3.39                                        |
|   |           |         |                  |                  |             |                                             |
|   | 2019      | 1       | Prod018          | Own Brand        | 8281419     | 4.57                                        |
|   | 2019      | 2       | Prod040          | Own Brand        | 7750278     | 4.27                                        |
|   | 2019      | 3       | Prod065          | Own Brand        | 6814949     | 3.76                                        |
|   | 2019      | 4       | **Prod053**      | Own Brand        | 5564681     | 3.07                                        |
|   | 2019      | 5       | Prod090          | Own Brand        | 5253110     | 2.9                                         |
|   |           |         |                  |                  |             |                                             |
|   | 2020      | 1       | Prod047          | Own Brand        | 3982487     | 5.15                                        |
|   | 2020      | 2       | Prod061          | Own Brand        | 3503835     | 4.53                                        |
|   | 2020      | 3       | Prod071          | Distribution     | 3365872     | 4.35                                        |
|   | 2020      | 4       | Prod065          | Own Brand        | 3135964     | 4.05                                        |
|   | 2020      | 5       | Prod237          | Distribution     | 2724291     | 3.52                                        |

Thus, we see that : (There's **no clear winner!**)

- Since, the 'Percent contribution' of any product to that year's revenue has
    never been more than **'9.5%** and **6.3%**' ==\> no single product has been
    a major contributor to the Revenue, it is **accumulated from small amounts**
    generated by **all products**.

- Mostly all the products are from **'Own Brand'** ==\> 'Own Brand' products
    are major contributors to the **Revenue**, and hardly any from
    'Distribution' products.

- There are hardly any products that have **repeated** themselves over years!
    ==\> this goes on to say that, it's **difficult to predict** which product
    will do well in a given year... it's totally **random** --\> which will be
    very **difficult** to plan **inventory**, **pricing** and **offers** on
    products.

- only 3 products have featured Twice :

    - “**Prod239**” **'2nd'** in 2017, **'5th'** in 2018 ==\> **'3.82%'** and
**'3.39%'** of Revenue Contribution in respective years.

    - “**Prod040**” **'1st'** in 2018, **'2nd'** in 2019 ==\> **'6.30%'** and
**'4.27%'** of Revenue Contribution in respective years.

    - “**Prod065**” **'3rd'** in 2019, **'4th'** in 2020 ==\> **'3.76%'** and
**'4.05%'** of Revenue Contribution in respective years.

- And, only 1 Product has featured Thrice :

    - “**Prod053**” **'5th'** in 2017, **'3rd'** in 2018, **'4th'** in 2019 ==\>
**'3.22%'**, **'3.74%'** and **'3.07%'** of Revenue Contribution in respective
years.
*/


#===============================================================================================================================================


--					***** #4 'CUSTOMER-WISE PERFORMANCE' *****

SELECT count(DISTINCT customer_code) FROM sales.transactions ; -- 38
SELECT count(*) FROM sales.customers ; -- 38
/* 
So, over the lifetime it has served only "38" Unique Customers!
*/

SELECT year(order_date) as 'Yearr', count(DISTINCT customer_code) 
FROM sales.transactions 
GROUP BY Yearr;
/*
Annually Repeating/New Customers :

|   | **Yearr** | **DISTINCT customer_code** |
|---|-----------|----------------------------|
|   | 2017      | 38                         |
|   | 2018      | 38                         |
|   | 2019      | 38                         |
|   | 2020      | 38                         |

- So, since the 'Total Unique Customers' served in "entire lifetime" of the
    dataset are '38'

- and, the total 'Total Unique Customers' served "per year" are also'38', for
    all the Years : 2017 to 2020

- We can say that : **Each year, it has served 'ALL' of the 'SAME' 38
    customers.**

- No new customers acquired in any year! --**0 New Customer Acquisition.**

- No previous customer unserved in any year! --**100% Customer Retention.**
*/

CREATE TEMPORARY Table Transactions_and_Customers_temp
SELECT year(a.order_date) as 'yearr', 
		a.customer_code,
        b.customer_type,
        a.selling_price,
        a.sales_qty
FROM sales.transactions a JOIN sales.customers b
ON a.customer_code = b.customer_code 
ORDER BY yearr ;

SELECT 	yearr,
		SUM(sales_qty) as 'Total_SalesQty',
		SUM(CASE WHEN customer_type LIKE '%Brick & Mortar%' THEN sales_qty END) as 'SalesQty_BRICK&MORTAR',
        SUM(CASE WHEN customer_type LIKE '%Brick & Mortar%' THEN sales_qty END)*100/SUM(sales_qty) as 'Percent_of_Total_SalesQty',
        SUM(CASE WHEN customer_type LIKE '%E-Commerce%' THEN sales_qty END) as 'SalesQty_E-COMMERCE',
		SUM(CASE WHEN customer_type LIKE '%E-Commerce%' THEN sales_qty END)*100/SUM(sales_qty) as 'Percent_of_Total_SalesQty',
        SUM(CASE WHEN customer_type LIKE '%Brick & Mortar%' THEN selling_price END) as 'Revenue_from_BRICK&MORTAR',
        SUM(CASE WHEN customer_type LIKE '%E-Commerce%' THEN selling_price END) as 'Revenue_from_E-COMMERCE'
FROM Transactions_and_Customers_temp
GROUP BY yearr ;
/*
 **Brick & Mortar** vs. **E-Commerce** sales:

|   | **year** | **Total_SalesQty** | **SalesQty\_** **BRICK&MORTAR** | **Percent_of\_** **Total_SalesQty** | **SalesQty\_** **E-COMMERCE** | **Percent_of\_** **Total_SalesQty** | **Revenue_from\_** **BRICK&MORTAR** | **Revenue_from\_** **E-COMMERCE** |
|---|----------|--------------------|---------------------------------|-------------------------------------|-------------------------------|-------------------------------------|-------------------------------------|-----------------------------------|
|   | 2017     | 234462             | 181689                          | **77.4919**                         | 52773                         | **22.5081**                         | 66020915                            | 26861738                          |
|   | 2018     | 997497             | 759078                          | **76.0983**                         | 238419                        | **23.9017**                         | 307748862                           | 105938301                         |
|   | 2019     | 847083             | 651750                          | **76.9405**                         | 195333                        | **23.0595**                         | 257563281                           | 78455821                          |
|   | 2020     | 350240             | 261684                          | **74.7156**                         | 88556                         | **25.2844**                         | 113136780                           | 29087765                          |

- Over the years, we can say that, out of **'100'** products sold,

    - on an Average **'76'** would be through "**BRICK & MORTAR**" stores &
        **'24'** would be through "**E-COMMERCE**" Channels.

- So, it's a no-brainer that their **'BRICK & MORTAR'** stores are the major
    contributors of their 'Total **Revenue'**!

    - On an avg, 'BRICK & MORTAR' stores generate "**3.13x**" more Revenue
        than 'E-COMMERCE' Channels.

- Best bet to continuously increase revenue and be **future-proof** is to
    increase their efforts on **'Online Presence'** through **'Digital
    Marketing'** and flourish over **'E-COMMERCE'** !!
*/

with cte_CustRank as (
SELECT a.Yearr, a.customer_code, a.customer_name, a.customer_type, a.Revenue,
	DENSE_RANK() OVER (partition by a.Yearr order by a.Revenue DESC) as 'Rnk',
    ROUND(a.Revenue*100/SUM(a.Revenue) OVER (partition by a.Yearr), 2) as 'Contribution_to_Total_Revenue_that_year'
FROM (
SELECT  year(order_date) as 'Yearr', x.customer_code, custmer_name as 'customer_name', customer_type, SUM(selling_price) as 'Revenue'
FROM sales.transactions x JOIN sales.customers y
ON x.customer_code = y.customer_code
GROUP BY year(order_date), customer_code
ORDER BY Yearr, Revenue DESC 
) a 
)
SELECT Yearr, Rnk, customer_code, customer_name, customer_type, Revenue, Contribution_to_Total_Revenue_that_year
FROM cte_CustRank
WHERE Rnk<6 ;

/*
**Top 5 Customers** each year:

|   | **Yearr** | **Rnk** | **customer_code** | **customer_name**         | **customer_type** | **Revenue** | **Contribution_to_Total_Revenue_that_year** |
|---|-----------|---------|-------------------|---------------------------|-------------------|-------------|---------------------------------------------|
|   | 2017      | 1       | Cus006            | **Electricalsara Stores** | Brick & Mortar    | 36098419    | 38.86                                       |
|   | 2017      | 2       | Cus020            | Nixon                     | E-Commerce        | 7914695     | 8.52                                        |
|   | 2017      | 3       | Cus022            | Electricalslytical        | E-Commerce        | 6135803     | 6.61                                        |
|   | 2017      | 4       | Cus005            | Premium Stores            | Brick & Mortar    | 5237662     | 5.64                                        |
|   | 2017      | 5       | Cus003            | Excel Stores              | Brick & Mortar    | 4600061     | 4.95                                        |
|   |           |         |                   |                           |                   |             |                                             |
|   | 2018      | 1       | Cus006            | **Electricalsara Stores** | Brick & Mortar    | 173050977   | 41.83                                       |
|   | 2018      | 2       | Cus020            | Nixon                     | E-Commerce        | 21809554    | 5.27                                        |
|   | 2018      | 3       | Cus022            | Electricalslytical        | E-Commerce        | 20825800    | 5.03                                        |
|   | 2018      | 4       | Cus005            | Premium Stores            | Brick & Mortar    | 18693181    | 4.52                                        |
|   | 2018      | 5       | Cus003            | Excel Stores              | Brick & Mortar    | 18051333    | 4.36                                        |
|   |           |         |                   |                           |                   |             |                                             |
|   | 2019      | 1       | Cus006            | **Electricalsara Stores** | Brick & Mortar    | 138542215   | 41.23                                       |
|   | 2019      | 2       | Cus003            | Excel Stores              | Brick & Mortar    | 18535841    | 5.52                                        |
|   | 2019      | 3       | Cus022            | Electricalslytical        | E-Commerce        | 17144682    | 5.1                                         |
|   | 2019      | 4       | Cus005            | Premium Stores            | Brick & Mortar    | 15076075    | 4.49                                        |
|   | 2019      | 5       | Cus007            | Info Stores               | Brick & Mortar    | 12569241    | 3.74                                        |
|   |           |         |                   |                           |                   |             |                                             |
|   | 2020      | 1       | Cus006            | **Electricalsara Stores** | Brick & Mortar    | 65641977    | 46.15                                       |
|   | 2020      | 2       | Cus003            | Excel Stores              | Brick & Mortar    | 7928385     | 5.57                                        |
|   | 2020      | 3       | Cus005            | Premium Stores            | Brick & Mortar    | 5899748     | 4.15                                        |
|   | 2020      | 4       | Cus022            | Electricalslytical        | E-Commerce        | 5537904     | 3.89                                        |
|   | 2020      | 5       | Cus007            | Info Stores               | Brick & Mortar    | 5064374     | 3.56                                        |

- The list remains nearly **consistent**, with most pertinent customers being
    :

    - **"Electricalsara Stores"**

    - "Electricalslytical"

    - "Excel Stores"

    - "Premium Stores"

- The best customer, which has always topped the list by a huge margin is :
    **"Electricalsara Stores"**

    - contributing on an Average **"42%" to the Annual Revenue**

- If we see the list after "Electricalsara Stores", all others' contribution
    is merely in Single Digits, **mostly around '5%'**

    - this shows that, the remaining Revenue after the contribution from
        "Electricalsara Stores", is **shared in small parts** among lot of
        customers.

- Mostly all the Customers in the list are 'BRICK & MORTAR' stores...
    "**Electricalslytical**" is the lone **'E-COMMERCE'** customer.
*/


#===============================================================================================================================================


--					***** #5 'Only MUMBAI data (VIEW)' *****

# using a "VIEW" to make separate table for all data related to only 'Mumbai'.

# for limited security access, or to ease off someone's work who can't perform complex joins again and again.

DROP VIEW if exists only_Mumbai ;

CREATE VIEW only_Mumbai as 
SELECT a.product_code, a.customer_code, a.market_code, a.order_date, a.sales_qty, a.selling_price, a.profit_amount, a.cost_price,
		b.markets_name, b.zone,
        c.custmer_name, c.customer_type,
        d.product_type
FROM sales.transactions a INNER JOIN sales.markets b
ON a.market_code = b.markets_code AND b.markets_name='Mumbai'

INNER JOIN sales.customers c
ON a.customer_code = c.customer_code

LEFT OUTER JOIN sales.products d
ON a.product_code = d.product_code ;

SELECT count(*) FROM only_Mumbai ;

SHOW FULL TABLES IN sales WHERE TABLE_TYPE LIKE 'VIEW';


#===============================================================================================================================================



