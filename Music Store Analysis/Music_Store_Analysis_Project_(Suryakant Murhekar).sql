create database Music_Store;
use Music_Store;

CREATE TABLE employee_staging (
    employee_id INT PRIMARY KEY,
    last_name VARCHAR(50),
    first_name VARCHAR(50),
    title VARCHAR(100),
    reports_to VARCHAR(10),  
    levels VARCHAR(20),
    birthdate VARCHAR(20),   
    hire_date VARCHAR(20),   
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    phone VARCHAR(50),
    fax VARCHAR(50),
    email VARCHAR(100)
);

CREATE TABLE employee (
    employee_id INT PRIMARY KEY,
    last_name VARCHAR(50),
    first_name VARCHAR(50),
    title VARCHAR(100),
    reports_to INT NULL,
    levels VARCHAR(20),
    birthdate DATE,
    hire_date DATE,
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    phone VARCHAR(50),
    fax VARCHAR(50),
    email VARCHAR(100)
);

INSERT INTO employee (
    employee_id, last_name, first_name, title, reports_to, levels, birthdate, hire_date,
    address, city, state, country, postal_code, phone, fax, email
)
SELECT 
    employee_id, 
    last_name, 
    first_name, 
    title, 
    NULLIF(reports_to, ''),  
    levels,
    STR_TO_DATE(birthdate, '%d-%m-%Y %H:%i'),  
    STR_TO_DATE(hire_date, '%d-%m-%Y %H:%i'),  
    address, 
    city, 
    state, 
    country, 
    postal_code, 
    phone, 
    fax, 
    email
FROM employee_staging;


-- Customer Table
CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    company VARCHAR(100),
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    phone VARCHAR(20),
    fax VARCHAR(20),
    email VARCHAR(100),
    support_rep_id INT,
    FOREIGN KEY (support_rep_id) REFERENCES employee(employee_id) ON DELETE SET NULL
);

-- Artist Table
CREATE TABLE artist (
    artist_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE media_type (
    media_type_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE genre (
    genre_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE playlist (
    playlist_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE album (
    album_id INT PRIMARY KEY,
    title VARCHAR(255),
    artist_id INT,
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id) ON DELETE CASCADE
);

-- Invoice Table
CREATE TABLE invoice (
    invoice_id INT PRIMARY KEY,
    customer_id INT,
    invoice_date DATETIME,
    billing_address VARCHAR(255),	
    billing_city VARCHAR(100),
    billing_state VARCHAR(50),
    billing_country VARCHAR(50),
    billing_postal_code VARCHAR(20),
    total DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE
);


-- Track Table
CREATE TABLE track (
    track_id INT PRIMARY KEY,
    name VARCHAR(255),
    album_id INT,
    media_type_id INT,
    genre_id INT,
    composer VARCHAR(255),
    milliseconds INT,
    bytes INT,
    unit_price DECIMAL(5,2),
    FOREIGN KEY (album_id) REFERENCES album(album_id) ON DELETE CASCADE,
    FOREIGN KEY (media_type_id) REFERENCES media_type(media_type_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id) ON DELETE CASCADE
);
SHOW VARIABLES LIKE 'secure_file_priv';
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/track.csv'
INTO TABLE track
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(track_id, name, album_id, media_type_id, genre_id, composer, milliseconds, bytes, unit_price);

select * from track;
SELECT COUNT(*) FROM track;



-- Invoice Line Table
CREATE TABLE invoice_line (
    invoice_line_id INT PRIMARY KEY,
    invoice_id INT,
    track_id INT,
    unit_price DECIMAL(5,2),
    quantity INT,
    FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id) ON DELETE CASCADE,
    FOREIGN KEY (track_id) REFERENCES track(track_id) ON DELETE CASCADE
);

CREATE TABLE playlist_track (
    playlist_id INT,
    track_id INT,
    PRIMARY KEY (playlist_id, track_id),
    FOREIGN KEY (playlist_id) REFERENCES playlist(playlist_id) ON DELETE CASCADE,
    FOREIGN KEY (track_id) REFERENCES track(track_id) ON DELETE CASCADE
);


select * from  employee;
select * from customer;
select * from artist;
select * from media_type;
select * from genre;
select * from playlist;
select * from album;
select * from invoice;
select * from track;
select * from invoice_line;
select * from playlist_track;

-- Q1) Who is the senior most employee based on job title?
select * from employee
order by levels desc limit 1;


-- Q2) Which countries have the most Invoices?
select billing_country, count(*) AS invoice_count
from invoice
group by billing_country order by invoice_count desc limit 5;


-- Q3 What are the top 3 values of total invoice?
select invoice_id, total from invoice
order by total desc limit 3;


-- Q4) Which city has the best customers? - We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
select billing_city, SUM(total) AS total_revenue
from invoice
group by billing_city 
order by total_revenue desc limit 1;


-- Q5) Who is the best customer? - The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money
select c.customer_id, c.first_name, c.last_name, sum(i.total) as total_spent
from customer c
join invoice i on c.customer_id = i.customer_id
group by c.customer_id, c.first_name, c.last_name
order by total_spent desc limit 1;


-- Q6) Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A
select c.email, c.first_name, c.last_name, g.name as genre
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join genre g on t.genre_id = g.genre_id
where g.name = 'Rock' order by c.email asc;


-- Q7) Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands
select ar.name as artist_name, COUNT(t.track_id) as track_count
from artist ar
join album al on ar.artist_id = al.artist_id
join track t on al.album_id = t.album_id
join genre g on t.genre_id = g.genre_id
where g.name = 'Rock'
group by ar.artist_id, ar.name
order by track_count desc limit 10;


-- Q8) Return all the track names that have a song length longer than the average song length.- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
select name, milliseconds
from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;


-- Q9) Find how much amount is spent by each customer on artists? Write a query to return customer name, artist name and total spent
select
    c.first_name as customer_first_name,
    c.last_name as customer_last_name,
    a.name as artist_name,
    SUM(il.unit_price * il.quantity) as total_spent
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join album al on t.album_id = al.album_id
join artist a on al.artist_id = a.artist_id
group by c.customer_id, a.artist_id order by total_spent desc;


-- Q10) We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres
with Genre_Purchases as (
    select 
        c.country,
        g.name as genre_name,
        count(il.quantity) as total_purchases,
        RANK() over (partition by c.country order by count(il.quantity) desc) as genre_rank
    from invoice i
    join customer c on i.customer_id = c.customer_id
    join invoice_line il on i.invoice_id = il.invoice_id
    join track t on il.track_id = t.track_id
    join genre g on t.genre_id = g.genre_id
    group by c.country, g.name
)
select country, genre_name, total_purchases
from Genre_Purchases
where genre_rank = 1
order by country;


-- Q11) Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount
with Customer_Spending as (
    select 
        c.country,
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(i.total) as total_spent,
        RANK() over (partition by c.country order by SUM(i.total) desc) as spending_rank
    from invoice i
    join customer c on i.customer_id = c.customer_id
    group by c.country, c.customer_id, c.first_name, c.last_name
)
select country, first_name, last_name, total_spent
from Customer_Spending
where spending_rank = 1
order by country;
