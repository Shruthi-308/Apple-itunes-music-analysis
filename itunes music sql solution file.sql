use project;

CREATE TABLE `project`.`album` (
  `AlbumId` INT NOT NULL AUTO_INCREMENT,
  `Title` VARCHAR(255) NOT NULL,
  `ArtistId` INT NOT NULL,
  PRIMARY KEY (`AlbumId`)
);

LOAD DATA LOCAL INFILE "E:\\itunes sql\\album.csv"
INTO TABLE album
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- I have created album table & imported data manually...whereas the remaining are directely imported through "Table data import wizard"*/
select * from album;
select * from artist;
select * from customer;
select * from employee;
select * from genre;
select * from invoice;
select * from invoive_line;
select * from media_type;
select * from playlist;
select * from playlist_track;
select * from track;


### Q1. Who is the senior most employee (by Title)?
SELECT * 
FROM employee
ORDER BY Title DESC
LIMIT 1;

### Q2. Which countries have the most invoices?
SELECT billing_country, COUNT(*) AS TotalInvoices
FROM invoice
GROUP BY billing_country
ORDER BY TotalInvoices DESC;

### Q3. What are the top 3 highest invoice totals?
SELECT invoice_id, total
FROM invoice
ORDER BY Total DESC
LIMIT 3;

### Q4. Which city has the best customers (highest sales)?
SELECT billing_city, SUM(total) AS TotalSales
FROM invoice
GROUP BY billing_city
ORDER BY TotalSales DESC
LIMIT 1;

### Q5. Who is the best customer (spent most money)?
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS TotalSpent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY TotalSpent DESC
LIMIT 1;

### Q6. Find all Rock Music listeners’ info
SELECT DISTINCT c.email, c.first_name, c.last_name, g.name AS genre
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line ii ON i.invoice_id = ii.invoice_id
JOIN track t ON ii.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email ASC;

### Q7. Top 10 artists with most Rock tracks
SELECT ar.name AS artist_name, COUNT(t.track_Id) AS rock_tracks
FROM artist ar
JOIN album al ON ar.artist_id = al.ArtistId
JOIN track t ON al.AlbumId = t.album_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY ar.name
ORDER BY rock_tracks DESC
LIMIT 10;

### Q8 Tracks longer than average song length
SELECT Name, milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;

### Q9 Amount spent by each customer on each artist
SELECT 
  c.customer_id,
  ar.artist_id,
  SUM(il.unit_price * il.quantity) AS amount_spent
FROM 
  customer c
  JOIN invoice i ON c.customer_id = i.customer_id
  JOIN invoice_line il ON i.invoice_id = il.invoice_id
  JOIN track t ON il.track_id = t.track_id
  JOIN album al ON t.album_id = al.AlbumId
  JOIN artist ar ON al.ArtistId = ar.artist_id
GROUP BY 
  c.customer_id, ar.artist_id;

 ### Q10. Most popular genre by country
SELECT billing_country, g.name AS genre, 
  COUNT(*) AS purchases 
FROM invoice i 
JOIN invoice_line ii ON i.invoice_id = ii.invoice_id 
JOIN track t ON ii.track_id = t.track_id 
JOIN genre g ON t.genre_id = g.genre_id 
GROUP BY billing_country, genre 
ORDER BY billing_country, purchases DESC;

/* Q 11. “Which customer has spent the most on music in each country? Show country, top customer, and how much they spent.
If there’s a tie for the highest spend, show all tied customers.”*/
SELECT
  totals.country,
  totals.customer_name,
  totals.total_spent
FROM (
  SELECT
    c.country,
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(i.total) AS total_spent
  FROM customer c
  JOIN invoice i ON c.customer_id = i.customer_id
  GROUP BY c.country, c.customer_id, c.first_name, c.last_name
) AS totals
JOIN (
  SELECT
    country,
    MAX(total_spent) AS max_spent
  FROM (
    SELECT
      c.country,
      SUM(i.total) AS total_spent
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.country, c.customer_id
  ) AS sums
  GROUP BY country
) AS maxes
ON totals.country = maxes.country AND totals.total_spent = maxes.max_spent
ORDER BY totals.country
LIMIT 0, 1000;

### Q 12. Who are the most popular artists? (by tracks sold)?
SELECT
  ar.name AS artist_name,
  COUNT(il.invoice_line_id) AS tracks_sold
FROM artist ar
JOIN album al ON ar.artist_id = al.ArtistId
JOIN track t ON al.AlbumId = t.album_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY ar.artist_id, ar.name
ORDER BY tracks_sold DESC
LIMIT 10;

### Q13. Find the single song that has sold the most — by number of units .
SELECT
  t.name AS song_name,
  COUNT(ii.invoice_line_id) AS units_sold
FROM track t
JOIN invoice_line ii ON t.track_id = ii.track_id
GROUP BY t.track_id, t.name
ORDER BY units_sold DESC
LIMIT 1;

### Q14. What are the average prices of different types of music?
SELECT
  g.name AS genre_name,
  ROUND(AVG(t.unit_price), 2) AS avg_unit_price
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
GROUP BY g.genre_id, g.name
ORDER BY avg_unit_price DESC;

### Q15 What are the most popular countries for music purchases?
SELECT
  i.billing_country AS country,
  COUNT(*) AS purchase_count
FROM invoice i
GROUP BY i.billing_country
ORDER BY purchase_count DESC;
