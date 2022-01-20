> # **Project Planning and Workflow:-**

1.  Seeing the problem, **Sales Director** decides to invest in **data analysis
    project**, and he would like to build **TABLEAU dashboard** that can give
    him real time **sales insights**. He will do a meeting with IT team, sales
    team, data analytics team to come up with a plan.

2.  They will use **AIMS Grid** to define purpose and success criteria of this
    project. 4 components of the AIMS Grid :

    1.  ### **Purpose** :

        1.  To unlock **Sales Insights** that are currently not evident enough,
            for **data-backed** *Decision making.*

    2.  ### **Stake Holders** :

        1.  **Sales Director**

        2.  **Marketing Team**

        3.  **Sales Team**

        4.  **IT Team**

        5.  **Data and Analytics Team** (in-house)

    3.  ### **End Result** :

        1.  Detailed **stats** and an **interactive Dashboard** providing quick
            and latest **insights** into sales data, with filters based on year,
            location, products, consumers, etc.

    4.  ### **Success Criteria :**

        1.  Make better Sales decisions based on the insights and prove **10%
            cost savings** of total expenditure.

        2.  **Save 20% time** of going through and merging long Excel files,
            trying to interpret trends, and reinvest that time in other
            value-added activities.

3.  (Now, the actual project will begin.) Next step is **Data Discovery**. In
    this step, data analyst team approaches IT team within an organization who
    owns software system that keep track of sales records. These records are
    stored in **MySQL database**. **Tableau** can be plugged to this database to
    pull necessary information required for **data analysis**.

## **IT Team** :

-   responsible for building and maintaining the **‘Sales Management System’**
    software used by the company, which has the information about all the
    **Transactions** ever done – like: date, amount, customer, product,
    location, etc.

-   Behind this software is the **MySQL** **Database**. Together called as
    ‘**OLTP**’ (**Online Transaction Processing System).**

## **Data Engineers Team (‘Data Warehousing’)** :

-   take this Database and perform **ETL (Extract, Transform, Load)** to
    transform it into a different format & store it in a **Data Warehouse**
    **(Terra Data/Amazon Redshift/MySQL**).

-   Thus, maintain the **Data Infrastructure**. This Data Warehouse is also
    called as **‘OLAP’ (Online Analytical Processing System).**

## **Data Analytics Team** :

-   Runs **Queries**, **Python Programs** on the Database for **Analysis** and
    hooks it to **Tableau** to build **dashboards**.

### **Note :**

-   **OLTP** is a **critical** system where **day-to-day** sales are recorded,
    invoices are printed, etc.

-   If this system goes down, it will **affect the overall business** in a
    negative way.

-   Also, if Data Analysts run **queries** directly on this **OLTP** Database,
    it will use lot of **computing** power and **slower** the **critical**
    **Database** itself, which will again hamper the everyday functioning of
    business.

-   If some query by mistake **Alters/Deletes** any important records from the
    **OLTP** Database, it will cause a **permanent damage**.

-   So what the company will do is, it’ll create an **extra copy** of this OLTP
    Database, called **Data Warehouse**, where they’ll also **transform** the
    data so that it’s easier to analyze.

-   Now, Data Analysts can run their queries and perform analysis on this **Data
    Warehouse**. (not the OLTP Database.)

-   Even if this **OLAP** Database (Data Warehouse) goes **down**, it won’t
    **affect** the Main **OLTP** Database and the **day-to-day functioning** of
    the business.
