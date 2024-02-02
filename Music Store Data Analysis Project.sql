/* Q: Who is the senior most employee based on job title? */
select title, first_name,last_name 
from employee
order by levels desc
limit 1
;

/* Q: Which countries have the most Invoices? */

select count(*)as c , billing_country 
from invoice
group by billing_country
order by c desc
limit 1 ;

/* Q: What are top 3 values of total invoice? */

select total
from invoice
order by total desc
limit 3;

/* Q: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select sum(total) as total_sum , billing_city
from invoice
group by billing_city
order by total_sum desc
limit 1;

/* Q: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select customer.customer_id ,customer.first_name, customer.last_name, sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id , customer.first_name, customer.last_name
order by total desc
limit 1 
;


/* Q: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select first_name, last_name, email , genre.name
from customer
join invoice on invoice.customer_id = customer.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id 
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
where genre.name = 'Rock'
order by email;

/* Q: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select artist.artist_id , artist.name , count(artist.artist_id) as track_count 
FROM track
join album2 on album2.album_id = track.album_id
join artist on artist.artist_id = album2.album_id
join genre on genre.genre_id = track.genre_id
where genre.name = 'Rock'
group by artist.artist_id , artist.name
order by track_count desc
limit 10;

/* Q: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select track.name, track.milliseconds as song_length
from track
where milliseconds > (
select avg(milliseconds) as avg_millionseconds
from track)
order by song_length desc
;



/* Q: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

with best_saling_article as (
select artist.artist_id as artist_id , artist.name as artist_name , sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track on track.track_id = invoice_line.track_id
join album on album.album_id = track.album_id 
join artist on artist.artist_id = album.artist_id 
group by 1 , 2
order by 3 desc
limit 1
)
select customer.customer_id , customer.first_name , customer.last_name , best_saling_article.artist_name, sum(invoice_line.unit_price*invoice_line.quantity) as total_spent
from invoice
join customer on customer.customer_id = invoice.customer_id 
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join album on album.album_id = track.album_id
join best_saling_article on best_saling_article.artist_id = album.artist_id
group by 1,2,3,4
order by 5 desc
;

/* Q: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1
;








