select*
from imdbtop1000

---------------CLEANING OF THE DATASET-----------------------

--Renaming the Gross column to Gross revenue
EXEC sp_rename 'imdbtop1000.gross', 'gross_revenue', 'COLUMN'

--Rounding up ratings to 2 decimal places
SELECT ROUND(CEILING(IMDB_Rating* 100) / 100, 2) AS rounded_ratings
FROM imdbtop1000

Update imdbtop1000
set IMDB_Rating =ROUND(CEILING(IMDB_Rating* 100) / 100, 2) 

--replacing the Null rows in certifications to UA
UPDATE imdbtop1000
Set Certificate = 'UA'
Where Certificate is NULL

--deleting the nulls from the gross_revenue-----
DELETE FROM imdbtop1000
WHERE gross_revenue IS NULL


---Replacing the certificate colum with the full names
UPDATE imdbtop1000
SET Certificate = 
  CASE 
    WHEN Certificate = 'A' THEN 'Adult'
    WHEN Certificate = 'UA' THEN 'Unrestricted with parental Advisory'
	When Certificate =  'R' THEN 'Restricted'
    When Certificate =  'U' Then 'Unrestricted'
	when Certificate = 'U/A' Then 'Unrestricted with parental Advisory'
	when Certificate = 'G' THEN 'General Audiences'
	When Certificate ='GP' then 'Parental Guidances suggested'
	Else Certificate
  END

---GETTING INSIGHTS FROM THE DATASET----
--getting the top 10 genre that generated the most income
with genreranking as(
select genre,AVG(CONVERT(bigint, gross_revenue)) AS average_revenue,
RANK()over(order by avg(convert(bigint,gross_revenue))DESC) as top10
from imdbtop1000
group by Genre
)

select genre, average_revenue
from genreranking
where top10<=10

---INVESTIGATING THE RUNTIME WITH RATINGS AND GROSS----
select Genre,avg(IMDB_Rating) as avgrat,
avg(convert(bigint,gross_revenue))as avgrev
from imdbtop1000
group by Genre
order by avgrat desc

select Runtime,avg(IMDB_Rating) as avgrat ,
avg(convert(bigint,gross_revenue))as avgrev
from imdbtop1000
group by runtime
order by avgrev desc

select Meta_score,avg(imdb_rating) as avgrat,
avg(convert(bigint,gross_revenue))as avgrev
from imdbtop1000
group by Meta_score
order by avgrat desc

---CHECKING TO SEE IF CERTIFICATIONS AFFECT RATINGS AND GROSS REVENUE----
select Certificate,avg(imdb_rating) as avgrat
from imdbtop1000
group by Certificate
order by avgrat desc

Select certificate, avg(convert(bigint,gross_revenue)) as avgrev
from imdbtop1000
group by certificate
order by avgrev desc

---WHICH STARCOMBINATION RESULTS IN THE HIGHEST-RATED AND MADE THE HIGHEST REVENUE-----
select Star1,Star2,Star3,Star4,IMDB_Rating,gross_revenue,Series_Title,Genre
from imdbtop1000

---WHICH DIRECTOR HAD THE HIGHEST META_SCORE,RATING AND BROUGHT THE HIGHEST REVENUE------
with directorstats as (
         select director,
		 max(meta_score) as maxscore,
		 max(imdb_rating) as maxrat,
           avg(convert(bigint,gross_revenue)) as avgrev
from imdbtop1000
group by Director
)

select maxscore,maxrat,avgrev,director
from directorstats
order by maxscore desc,maxrat desc,avgrev desc

select director,Meta_score,gross_revenue
from imdbtop1000
group by Director
order by gross_revenue desc,Meta_score desc