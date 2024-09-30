
-- Creating the table
DROP TABLE IF EXISTS netflix_titles;
CREATE TABLE netflix_titles
(
	show_id	VARCHAR(10),
	show_type	VARCHAR(10),
	title	VARCHAR(110),
	director VARCHAR(220),
	casts VARCHAR(800),
	country VARCHAR(130),
	date_added DATE,
	release_year INT,
	listed_in VARCHAR(85),
	description VARCHAR(255),
	duration VARCHAR(15),
	rating VARCHAR(15)
);

SELECT * FROM netflix_titles;

SELECT COUNT(*) FROM netflix_titles;


-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows
SELECT 
	show_type,
	COUNT(*) AS total_shows
FROM netflix_titles
GROUP BY 1;



-- 2. Find the most common rating for movies and TV shows

SELECT 
	show_type,
	rating,
	rating_count
FROM
(
	SELECT 
		show_type,
		rating,
		COUNT(*) AS rating_count,
		RANK() OVER (PARTITION BY show_type ORDER BY COUNT(*) DESC) AS ranking
	FROM netflix_titles
	GROUP BY 1,2
) AS t_rank
WHERE ranking = 1;



-- 3. List all movies released in a specific year (e.g., 2020)
SELECT *
FROM netflix_titles
WHERE release_year = 2020;



-- 4. Find the top 5 countries with the most content on Netflix
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country,
	COUNT(*) AS total_shows
FROM netflix_titles
WHERE country <> 'Not Available'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 5. Identify the longest movie
SELECT 
	*
FROM netflix_titles
WHERE show_type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC



-- 6. Find content added in the last 5 years
SELECT
*
FROM netflix_titles
WHERE date_added >= CURRENT_DATE - INTERVAL '4 years'
ORDER BY date_added DESC;



-- 7. Find all the movies/TV shows by director 'Mike Flanagan'!
SELECT 
	*
FROM
(
	SELECT 
		*,
		TRIM(UNNEST(STRING_TO_ARRAY(director, ','))) as director_name
	FROM netflix_titles
)
WHERE director = 'Mike Flanagan';


	
-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix_titles
WHERE 
	show_type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::INT > 5;



-- 9. Count the number of content items in each genre
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
	COUNT(*) as total_content
FROM netflix_titles
GROUP BY 1;



-- 10.Find each year and the average numbers of content release in United States on netflix.
-- return top 5 year with highest avg content release!
SELECT
	country,
	release_year,
	COUNT(*) AS total_release,
	ROUND(COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM netflix_titles WHERE country = 'United States')::NUMERIC * 100, 2) AS average_release
FROM netflix_titles
WHERE country = 'United States'
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5;



-- 11. List all movies that are documentaries
SELECT
	*
FROM
(
	SELECT 
		*,
		TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) as genre
	FROM netflix_titles
)

WHERE
	show_type = 'Movie'
	AND
	genre = 'Documentaries';



-- 12. Find all content without a director
SELECT *
FROM netflix_titles
WHERE director = 'Not Available';



-- 13. Find how many movies actor 'Adam Sandler' appeared in last 5 years!
SELECT
	*
FROM
(
	SELECT 
		*,
		TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS specific_cast
	FROM netflix_titles	
)

WHERE 
	specific_cast = 'Adam Sandler'
	AND
	date_added >= CURRENT_DATE - INTERVAL '5 years'



-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in United States.
SELECT
	actor,
	COUNT(*) AS total_produced_movies
FROM
(
	SELECT 
		*,
		TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actor,
		TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) as country
	FROM netflix_titles
	WHERE country = 'United States' AND show_type = 'Movie'
)
WHERE actor <> 'Not Available'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.
SELECT 
	category,
	COUNT(*) AS total_content
FROM
(
	SELECT 
		CASE
			WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' OR
				 description ILIKE '%died%' OR description ILIKE '%death%' THEN 'Bad'
			ELSE 'Good'
		END AS category,
		*
	FROM netflix_titles
)
GROUP BY 1;















