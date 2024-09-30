# Netflix Movies and TV Shows Data Cleaning And Analysis using Power BI & SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a basic cleaning and comprehensive analysis of Netflix's movies and TV shows data using Power BI & SQL. The goal is to prepare and extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives
- Preparing the clean dataset.
- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
    let
        Source = Csv.Document(File.Contents("C:\Users\hp\Desktop\Projects\SQL_Power_BI_Project_3_Netflix_Data_Cleaning_&_Analysis\netflix_titles.csv"),[Delimiter=",", Columns=12, Encoding=65001, QuoteStyle=QuoteStyle.None]),
        #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
        #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"show_id", type text}, {"type", type text}, {"title", type text}, {"director", type text}, {"cast", type text}, {"country", type text}, {"date_added", type date}, {"release_year", Int64.Type}, {"rating", type text}, {"duration", type text}, {"listed_in", type text}, {"description", type text}}),
        #"Replaced Value" = Table.ReplaceValue(#"Changed Type","","Not Available",Replacer.ReplaceValue,{"director", "cast", "country"}),
        #"Added Conditional Column" = Table.AddColumn(#"Replaced Value", "n", each if Text.Contains([rating], "min") then [rating] else if [duration] = "" then "No Duration" else [duration]),
        #"Added Conditional Column1" = Table.AddColumn(#"Added Conditional Column", "Custom", each if Text.Contains([rating], "min") then " No Rating" else if [rating] = "" then " No Rating" else [rating]),
        #"Removed Columns" = Table.RemoveColumns(#"Added Conditional Column1",{"rating", "duration"}),
        #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"n", "duration"}, {"Custom", "rating"}}),
        #"Reordered Columns" = Table.ReorderColumns(#"Renamed Columns",{"show_id", "type", "title", "director", "cast", "country", "date_added", "release_year", "duration", "rating", "listed_in", "description"}),
        #"Changed Type1" = Table.TransformColumnTypes(#"Reordered Columns",{{"show_id", type text}, {"type", type text}, {"title", type text}, {"director", type text}, {"cast", type text}, {"country", type text}, {"date_added", type date}, {"release_year", Int64.Type}, {"duration", type text}, {"rating", type text}, {"listed_in", type text}, {"description", type text}})
    in
        #"Changed Type1"
```

```sql
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
```

## Business Problems and Solutions

### 1. Count the number of Movies vs TV Shows. 

```sql
    SELECT 
        show_type,
        COUNT(*) AS total_shows
    FROM netflix_titles
    GROUP BY 1;
```

### 2. Find the most common rating for movies and TV shows.

```sql
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
```


### 3. List all movies released in a specific year (e.g., 2020).

```sql
    SELECT *
    FROM netflix_titles
    WHERE release_year = 2020;
```


### 4. Find the top 5 countries with the most content on Netflix.

```sql
    SELECT 
        TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country,
        COUNT(*) AS total_shows
    FROM netflix_titles
    WHERE country <> 'Not Available'
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 5;
```


### 5. Identify the longest movie.

```sql
    SELECT 
        *
    FROM netflix_titles
    WHERE show_type = 'Movie'
    ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
```


### 6. Find content added in the last 4 years.

```sql
    SELECT
    *
    FROM netflix_titles
    WHERE date_added >= CURRENT_DATE - INTERVAL '4 years'
    ORDER BY date_added DESC;
```


### 7. Find all the movies/TV shows by director 'Mike Flanagan'!.

```sql
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
```


### 8. List all TV shows with more than 5 seasons.

```sql
    SELECT *
    FROM netflix_titles
    WHERE 
        show_type = 'TV Show'
        AND
        SPLIT_PART(duration, ' ', 1)::INT > 5;
```


### 9. Count the number of content items in each genre.

```sql
    SELECT 
        TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
        COUNT(*) as total_content
    FROM netflix_titles
    GROUP BY 1;
```


### 10.Find each year and the total numbers of content release in United States on netflix. return top 5 year with highest avg content release!

```sql
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
```


### 11. List all movies that are documentaries

```sql
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
```


### 12. Find all content without a director.

```sql
    SELECT *
    FROM netflix_titles
    WHERE director = 'Not Available';
```


### 13. Find how many movies actor 'Adam Sandler' appeared in last 5 years!.

```sql
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
```


### 14. Find the top 10 actors who have appeared in the highest number of movies produced in United States.

```sql
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
```


### 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each categor

```sql
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
```

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by United States highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.

