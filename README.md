# projects

-- Apple App Store Exploratory Data Analysis (using SQL) --

In this project, we are going to conduct an exploratory data analysis on a dataset with data of Apple's App Store. This is done with the assumption that we are working with stakeholders interested in creating a new app, and wants to know what type of app to make so that it would be popular. As such, we are interested in exploring these categories:

1. Genre of apps that are popular/have the highest ratings
2. Factors that might lead to the apps' popularity (e.g. price, supported languages, length of app description etc.)

The project was conducted on SQLite Online (sqliteonline.com). As the website only permits a maximum upload size of 4MB per file, we would have to split the dataset 'appleStore_description' into 4 different parts, then combining the data using the 'union' function as follows: 

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

-- Data Cleaning/Checking Validity of Data --

Firstly, we use the COUNT function to get the number of distinct 'id' values in both tables, and match the results to check if there is any missing data. 

```
SELECT COUNT(Distinct id) AS UniqueAppIDs
FROM AppleStore

SELECT COUNT(Distinct id) AS UniqueAppIDs
from appleStore_description_combined
```

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

The results from both codes are 0, hence there are no missing values found within both datasets. 

-- Exploratory Data Analysis (EDA) --

Moving on to EDA, we would want to create new tables for our convenience. First would be 'NumberOfApps' which includes the count of apps belonging in respective genres. 

```
select prime_genre, count(*) as NumberOfApps
from AppleStore
group by prime_genre
order by NumberOfApps DESC
```

Secondly, for an easier overview of app ratings, we create 'MinRating', 'MaxRating' and 'AvgRating'. 

```
Select min(user_rating) as MinRating, max(user_rating) as MaxRating, avg(user_rating) as AvgRating
from AppleStore
```

Now we are ready to conduct data analysis on the datasets. One very likely factor leading to an app's popularity is whether the app is free or not. An app being free might lead to a greater number of downloads, but it might not be the case for its ratings. We check using the code below: 

```
select CASE
			when price > 0 then 'Paid'
			else 'Free'
	end as App_Type, 
    avg(user_rating) as Avg_Rating
from AppleStore
group by App_Type
```

Based on the results obtained from the dataset, paid apps have a higher rating on average. This could possibly be due to paid apps being of higher quality, or customers being more attached to the paid apps hence being more inclined to give them a higher rating. 

Next, we want to examine the ideal number of supported languages that an app should provide for it to bring higher ratings. We use three ranges for the number of supported languages (<10, between 10 to 30, >30) in this case. 

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

From the results, apps that fall within the 10-30 languages range are more likely to receive higher ratings. 

Our stakeholders would also likely be interested in knowing which genres of apps to avoid making. Therefore, we want to find out the genres of apps with the lowest average ratings. 

```
select prime_genre, avg(user_rating) as Avg_Rating
from AppleStore
group by prime_genre
order by Avg_Rating ASC
limit 10
```

Using this code above, we can find out the 10 app genres with the lowest average ratings. To find out the top 10 genres with the highest average ratings instead, we can change the order by command to descending order (DESC) instead. 

We would also want to know if providing a long description is helpful in making an app popular. Hence, we use the code below to find out if there is any correlation between description length and the average rating of apps. 

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

We would then find out that the longer the description, the more likely the app is highly rated. 

Lastly, we might want to find out the top rated app of each app genre, to gain a more specific insight on what kind of app is popular. 

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
