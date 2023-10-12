# SQL Project (AppleStore)

## Apple App Store Exploratory Data Analysis (using SQL)

In this project, we are going to conduct an exploratory data analysis on a dataset with data of Apple's App Store. Key functions used in this project are COUNT, CASE, JOIN, UNION, RANK. 

This is done with the assumption that we are working with stakeholders interested in creating a new app, and wants to know what type of app to make so that it would be popular. As such, we are interested in exploring these categories:

1. Genre of apps that are popular/have the highest ratings
2. Other factors that might lead to the apps' popularity (e.g. price, supported languages, length of app description etc.)

The project was conducted on SQLite Online (sqliteonline.com). As the website only permits a maximum upload size of 4MB per file, we would have to split the dataset 'appleStore_description' into 4 different parts, then combining the data using the UNION function as follows: 

```
create table appleStore_description_combined AS

SELECT * FROM appleStore_description1

union ALL

SELECT * FROM appleStore_description2

union ALL

SELECT * FROM appleStore_description3

union ALL

SELECT * FROM appleStore_description4
```

## Data Cleaning/Checking Validity of Data

Firstly, we use the COUNT function to get the number of distinct 'id' values in both tables, and match the results across both tables to check if there is any missing data. 

```
SELECT COUNT(Distinct id) AS UniqueAppIDs
FROM AppleStore

SELECT COUNT(Distinct id) AS UniqueAppIDs
from appleStore_description_combined
```
![image](https://github.com/nl83457/sql_project_applestore/assets/143477919/9e12e5c3-9a27-4612-8074-fa1fdd3947f7)

Based on the results, there is the same number of UniqueAppIDs in both tables (7197), hence there is no missing data. 

Next, we would want to check if there are any missing values within the key fields that we will be conducting data analysis on. This includes 'track_name', 'user_rating' and 'prime_genre', as these three are important to the stakeholders' objectives.

```
SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name is NULL or user_rating is NULL or prime_genre is NULL
```

```
SELECT COUNT(*) AS MissingValues
FROM appleStore_description_combined
WHERE app_desc is NULL
```
![image](https://github.com/nl83457/sql_project_applestore/assets/143477919/9a580e1d-9923-473b-8624-91c4b1303e97)

The results from both codes are 0, hence there are no missing values found within both datasets. 

## Exploratory Data Analysis (EDA)

Moving on to EDA, we would first want to find out which genres of apps are highly populated, which our stakeholders would likely want to avoid as there is a great amount of competition in heavily-populated genres. 

```
select prime_genre, count(*) as NumberOfApps
from AppleStore
group by prime_genre
order by NumberOfApps DESC
```
![image](https://github.com/nl83457/sql_project_applestore/assets/143477919/a23a90ae-d58f-4ff8-8834-01521b496419)

Secondly, for an easier overview of app ratings, we look at the minimum, maximum and average ratings of apps in the app store. 

```
Select min(user_rating) as MinRating, max(user_rating) as MaxRating, avg(user_rating) as AvgRating
from AppleStore
```
![image](https://github.com/nl83457/sql_project_applestore/assets/143477919/e13a6435-0f02-49b5-95ca-e92537ef10c2)

Ideally, if we want to look for characteristics of popular apps, we would want to examine apps that have above average ratings (>3.52).

Next up, one very likely factor leading to an app's popularity is whether the app is free or not. An app being free might lead to a greater number of downloads, but it might not be the case for its ratings. We check using the CASE function as shown below: 

```
select CASE
			when price > 0 then 'Paid'
			else 'Free'
	end as App_Type, 
    avg(user_rating) as Avg_Rating
from AppleStore
group by App_Type
```
![image](https://github.com/nl83457/sql_project_applestore/assets/143477919/26cdc815-3914-42e7-8e7c-706109e66a8e)

Based on the results obtained from the dataset, paid apps have a higher rating on average. This could possibly be due to paid apps being of higher quality, or customers being more attached to the paid apps hence being more inclined to give them a higher rating. 

Also, we might be interested in providing multiple language support for the potential app. We would then want to examine the ideal number of supported languages that an app should provide for it to bring higher ratings. We use three ranges for the number of supported languages (<10, between 10 to 30, >30) for this case. 

```
select CASE
			when lang_num < 10 then '<10 languages'
			when lang_num between 10 and 30 then '10-30 languages'
			else '>30 languages'
	end as language_bucket, 
    avg(user_rating) as Avg_Rating
from AppleStore
group by language_bucket
order by Avg_Rating DESC
```
![image](https://github.com/nl83457/sql_project_applestore/assets/143477919/56366e54-c2ce-4ddb-b74d-6f28a99a39b3)

From the results, apps that fall within the 10-30 languages range are more likely to receive higher ratings. 

Our stakeholders would also likely be interested in knowing which genres of apps to avoid making. Therefore, we want to find out the genres of apps with the lowest average ratings. 

```
select prime_genre, avg(user_rating) as Avg_Rating
from AppleStore
group by prime_genre
order by Avg_Rating ASC
limit 10
```
![image](https://github.com/nl83457/sql_project_applestore/assets/143477919/d154a4be-463d-4f35-818e-b25b945ef844)

Using this code above, we can find out the 10 app genres with the lowest average ratings. If we want to find out the top 10 genres with the highest average ratings instead, we can change the order by command to descending order (DESC) instead. 

We would also want to know if providing a long description is helpful in making an app popular. Hence, we use the code below to find out if there is any correlation between description length and the average rating of apps. The JOIN function will have to be used to examine data from both tables, AppleStore and appleStore_description_combined. 

```
SELECT CASE
		when length(b.app_desc) <500 then 'Short'
        when length(b.app_desc) between 500 and 1000 then 'Medium'
        when length(b.app_desc) >1000 then 'Long'
	end as description_length_bucket, avg(user_rating) as Avg_Rating

from AppleStore as a

join appleStore_description_combined as b

on a.id = b.id

group by description_length_bucket
order by Avg_Rating DESC
```
![image](https://github.com/nl83457/sql_project_applestore/assets/143477919/0aa472fb-4344-4ed4-9aee-d10f757c2853)

We would then find out that the longer the description, the more likely the app is highly rated. 

Lastly, we might want to find out the top rated app of each app genre, to gain specific insight on what kind of apps in particular are popular, using the RANK() function across prime_genre and obtaining the names of apps with rank=1 in their respective genres. 

```
select prime_genre, track_name, user_rating
from (
  SELECT
  prime_genre,
  track_name,
  user_rating,
  RANK() OVER(PARTITION BY prime_genre order by user_rating desc, rating_count_tot desc) AS rank
  FROM AppleStore
  ) AS a
WHERE
a.rank = 1
```
![image](https://github.com/nl83457/sql_project_applestore/assets/143477919/980afd99-6dc6-43b0-8e66-c2455d21f84b)
