/* Music_Store_Analysis*/

Use music_store_sandali;

/*Lets first find senior most employee based  on job title? */
select last_name, first_name
from employee 
order by levels desc
limit 1 ;

/* Now we can explore the data by accessing the counties that generates the maximum invoices*/
select count(*), billing_country 
from invoice
group by 2
order by 1 desc ;

/* We should also fing the top 3 invoices*/

select total as top_invoices
from invoice 
order by total desc
limit 3;


/*  The company would like to throw a promotional Music Festival in the city that made the most money.
In order to find the required cities, we can consider using places that has the highest sum of invoices*/ 
 
select sum(total) as invoice_total , billing_city
from invoice
group by 2
order by 1 desc
limit 5 ;

/* Lets now find which customer spends most money that will be decalred as best customer?*/

select c.customer_id, first_name ,last_name, sum(total) as total_spent
from customer c
left join invoice i
on c.customer_id = i.customer_id
group by 1 
order by 4 desc
limit 1 ;

/* Now, We'll find all the Rock music listeners among the customers. 
Let's put them in a list in an alphabetical order*/

select distinct last_name, email, g.genre_id, g.name as Genre
from customer c
join invoice i on c.customer_id= i.customer_id
join invoice_line v on i.invoice_id= v.invoice_id
join track t  on t.track_id = v.track_id
join genre g  on t.genre_id= g.genre_id
where g.name like "Rock" 
order by 3 ; 

/* The company wants to invite the artists who have written the most rock music in our dataset.
Let's identify the top 10 rock band artists along with their total track count */

select a.artist_id, a.Name as Top_10_Rock_artists, count(t.track_id) as Total_Songs
from track t 
join album al on t.album_id = t.album_id
join artist a on a.artist_id= al.artist_id
join genre g on t.genre_id = g.genre_id
where g.Name = "Rock"
group by a.artist_id
order by 3 desc
limit 10 ;

/* Now let's find the songs that are longer than average song lengths in our list.
We'll find the song name along with its length in milliseconds and order them from longest 
to shortest. */

select name as Track_Name , milliseconds as Song_Length
from track
where milliseconds > ( select AVG(milliseconds) as Avg_Song_Length 
                      from track) 
order by 2 desc ;

/* Lets find the spent by each customer on artists. For that we need to know first which artists had highest earnings... */

with best_selling_artist as (
 select a.artist_id, a.name as artist_name, sum(vl.unit_price*vl.quantity) as Total_Sales
 from invoice_line vl
 join track t on vl.track_id = t.track_id
 join album al on al.album_id = t.album_id
 join artist a on a.artist_id = al.artist_id
 group by 1,2 
 order by 3 desc
 limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name, sum(il.unit_price * il.quantity) as amount_spent
from invoice i 
join customer c  on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id 
join track tr on tr.track_id = il.track_id 
join album alb on alb.album_id = tr.album_id 
join best_selling_artist as bsa on bsa.artist_id = alb.artist_id 
group by 1,2,3,4
order by 5 desc ;  

/* We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. This is a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with most_popular_genre as (

select count(il.quantity) as purchases, c.country, g.name as genre_name, g.genre_id,
      row_number() over(partition by c.country order by count(il.quantity) desc )as rowno 
from invoice_line il 
join invoice i on i.invoice_id = il.invoice_id 
join customer c on i.customer_id = c.customer_id 
join track t on t.track_id = il.track_id
join genre g on g.genre_id = t.genre_id
group by  2, 3, 4
order by 2 asc, 1 desc 

)
select * from most_popular_genre where rowno <=1 ;

/* A query that determines the customer that has spent the most on music for each country. 
This will return the country along with the top customer and how much they spent.*/ 

with customer_country as (

select c.customer_id , c.first_name, c.last_name , i.billing_country, sum(i.total) as total_spent,
       row_number() over(partition by i.billing_country order by sum(i.total) desc ) as rowno
       
from invoice i 
join customer c on c.customer_id= i.customer_id 
group by 1,2,3,4 
order by 4 asc, 5 desc  )
select * from customer_country where rowno <=1 ;


                      
                      

                      

 





