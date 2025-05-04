-- Q1.List customers who made more than 5 successful bookings but never canceled a ride.
 
 select customer_id,count(customer_id) as total_rides from uber
 where booking_status = 'success' and cancelled_rides_by_customer = 0
 group by customer_id
 having count(customer_id) > 5
 order by total_rides desc;

-- Q2.Find the day of the week with the highest average number of (customer and driver combined)

select dayname(booking_date) as dayName,
round(avg(cancelled_rides_by_customer) + avg(cancelled_rides_by_driver),3) 
as avg_cancellations 
from uber
group by dayName
order by avg_cancellations desc
limit 1;

-- Q3.Identify the top 3 Pickup → Drop pairs that generated the highest total revenue.

select concat(pickup_location,' - ',drop_location) as pickup_and_drop, 
round(sum(booking_value),2) as total_revenue
from uber
group by pickup_and_drop
order by total_revenue desc
limit 3;

-- Q4.How the total booking revenue changes across different months (or weeks/days)

select booking_date as date, dayname(booking_date) as day,
round(sum(booking_value),2) as total_booking_revenue from uber
group by booking_date
order by booking_date;

-- Q5.For each vehicle type, calculate: Avg ride distance Avg booking value Cancellation rate Then rank them based on performance.

select vehicle_type,
round(avg(ride_distance),2) as avg_ride_distance_km, 
round(avg(booking_value),2) as avg_booking_value,

round(sum(case when booking_status != 'Success' then 1 else 0 end) / 
count(booking_id) * 100.0,2) as Cancellation_rate,  -- Cancellation rate =(cancelled rides/total rides)*100
 
RANK() OVER (ORDER BY AVG(ride_distance) desc,
AVG(booking_value) desc,
SUM(CASE WHEN booking_status != 'success' THEN 1 ELSE 0 END)) AS performance_rank
FROM uber
GROUP BY vehicle_type;

-- Q6.List all canceled rides where booking value was above average.

select booking_id,booking_value,customer_id
from uber
where booking_status in ('Cancelled by Driver', 'Cancelled by Customer')
and booking_value > 
(select avg(booking_value)
from uber 
where booking_status in ('Cancelled by Driver', 'Cancelled by Customer'));

-- Q7.Calculate daily or weekly running total of revenue.

select booking_date,
round(sum(booking_value),2) as daily_revenue,
round(sum(sum(booking_value)) over(order by booking_date), 2) as cumulative_revenue
from uber
where booking_status = 'success'
group by booking_date
order by booking_date;
