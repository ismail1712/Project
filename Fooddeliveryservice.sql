drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

--total amount each user spent on products

select s.userid,sum(price)
from sales s
join product p on s.product_id=p.product_id
group by s.userid


-- number of days each customer visited

select userid,count(distinct created_date) as number_of_days
from sales
group by userid

--first product purchased by each customer
select *
from (select *,rank() over (partition by userid order by created_date) as rnk from sales) a
where rnk=1

--most purchased item and number of times it was purchased by all customers

select userid,count(product_id) as cnt
from sales
where product_id=
(select top 1 product_id
from sales s
group by product_id
order by count(product_id) desc)
group by userid


--most popular product for each customer

create view popproducts as
select *,rank() over (partition by userid order by no_of_times_purchased desc) as rnk
from (select userid,s.product_id,count(s.product_id) as no_of_times_purchased
from sales s
group by userid,product_id) a

select userid,product_id,no_of_times_purchased
from popproducts
where rnk=1

--item purchased first by customer after gold membership
create view gldrnk as
select *,rank() over (partition by a.userid order by a.created_date) as rnk
from (select s.userid,s.product_id,s.created_date,g.gold_signup_date
from sales s
join goldusers_signup g on s.userid=g.userid 
where created_date>=gold_signup_date) a

select *
from gldrnk
where rnk=1

----item purchased last by customer before gold membership
create view lsgldrnk as
select *,rank() over (partition by a.userid order by a.created_date desc) as rnk
from (select s.userid,s.product_id,s.created_date,g.gold_signup_date
from sales s
join goldusers_signup g on s.userid=g.userid 
where created_date<=gold_signup_date) a

select *
from lsgldrnk
where rnk=1

--total orders and amount spent for each member before gold membership

select s.userid,count(created_date) as no_of_orders ,sum(price) as total_amount
from sales s
join product p on s.product_id=p.product_id
join goldusers_signup g on s.userid=g.userid 
where created_date<=gold_signup_date
group by s.userid

--each product has diffrent purchasing points;for p1 5rs=1 zomato point, for p2 2rs=1 zomato point,
--for p3 5rs=1 zomato point; 
--calculate points collected by each customer and for which product most points have been given 

select userid,sum(total_points)*2.5 as points_earned
from (select *,amt/point_per_unit as total_points
from(select *,
case when a.product_id=1 then 5
when a.product_id=2 then 2
when a.product_id=3 then 5
else 0
end as point_per_unit
from (select s.userid,s.product_id,sum(price) as amt
from sales s
join product p on s.product_id=p.product_id
group by s.userid,s.product_id) a) b) c
group by userid

create view popprod as
select *,rank() over(order by points_earned desc) as rnk
from (select product_id,sum(total_points) as points_earned
from (select *,amt/point_per_unit as total_points
from(select *,
case when a.product_id=1 then 5
when a.product_id=2 then 2
when a.product_id=3 then 5
else 0
end as point_per_unit
from (select s.userid,s.product_id,sum(price) as amt
from sales s
join product p on s.product_id=p.product_id
group by s.userid,s.product_id) a) b) c
group by product_id) d

select * from popprod
where rnk=1


--In first one year after customer joins gold they earn 1 zomato points for every 2rs
--find who earned more and their point earnings in the first year

select c.*,p.price,p.price/2 as points_earned 
from (select s.userid,s.product_id,s.created_date,g.gold_signup_date
from sales s
join goldusers_signup g on s.userid=g.userid 
where created_date>=gold_signup_date and created_date<=DATEADD(year,1,gold_signup_date)) c
join product p on c.product_id=p.product_id


--rank all the transactions of the customer

select *,rank() over (partition by userid order by created_date) as rnk
from sales




