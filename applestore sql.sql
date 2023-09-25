create table appleStore_description_combined AS

SELECT * FROM appleStore_description1

union ALL

SELECT * FROM appleStore_description2

union ALL

SELECT * FROM appleStore_description3

union ALL

SELECT * FROM appleStore_description4

**Exploratory Data Analysis**

-- check number of unique app IDs in both tables

SELECT COUNT(Distinct id) as UniqueAppIDs
FROM AppleStore

SELECT COUNT(Distinct id) AS UniqueAppIDs
from appleStore_description_combined

-- same number in both tables (7197), hence there is no missing data

-- check for any missing values in key fields
-- key fields are track_name, user_rating, prime_genre because it is important to stakeholder's objectives

SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name is NULL or user_rating is NULL or prime_genre is NULL

-- MissingValues = 0, hence no missing values

SELECT COUNT(*) AS MissingValues
FROM appleStore_description_combined
WHERE app_desc is NULL

-- result = 0

-- find out number of apps per genre

select prime_genre, count(*) as NumberOfApps
from AppleStore
group by prime_genre
order by NumberOfApps DESC

-- app rating overview

Select min(user_rating) as MinRating, max(user_rating) as MaxRating, avg(user_rating) as AvgRating
from AppleStore

**DATA ANALYSIS**

-- determine whether paid apps have higher ratings than free apps 

select CASE
			when price > 0 then 'Paid'
			else 'Free'
	end as App_Type, 
    avg(user_rating) as Avg_Rating
from AppleStore
group by App_Type

-- paid apps have slightly higher ratings on average

-- determine if apps with more supported languages have higher ratings 

select CASE
			when lang_num < 10 then '<10 languages'
			when lang_num between 10 and 30 then '10-30 languages'
			else '>30 languages'
	end as language_bucket, 
    avg(user_rating) as Avg_Rating
from AppleStore
group by language_bucket
order by Avg_Rating DESC

-- apps with higher average rating fall between 10-30 languages supported

-- check the 10 genres with low ratings 

select prime_genre, avg(user_rating) as Avg_Rating
from AppleStore
group by prime_genre
order by Avg_Rating ASC
limit 10

-- check for correlation between app description length and ratings

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

-- apps with longer descriptions have higher ratings

-- check top rated apps within each genre 

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