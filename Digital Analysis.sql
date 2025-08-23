--How many users are there?
SELECT COUNT(DISTINCT user_id) cnt_user
FROM clique_bait.users

--How many cookies does each user have on average?
WITH cnt_cookie AS (
	SELECT user_id, COUNT(cookie_id) cnt
	FROM clique_bait.users
	GROUP BY user_id
	)
SELECT AVG(cnt) avg_cookie FROM cnt_cookie

--What is the unique number of visits by all users per month?
SELECT	EOMONTH(event_time) month,
		COUNT(visit_id) cnt_visit
FROM clique_bait.events
GROUP BY EOMONTH(event_time)
ORDER BY 1

--What is the number of events for each event type?
SELECT b.event_name, COUNT(*) event_cnt
FROM clique_bait.events a
LEFT JOIN clique_bait.event_identifier b ON a.event_type=b.event_type
GROUP BY b.event_name

event_name	event_cnt
Add to Cart	211
Page View	642
Purchase	55

--What is the percentage of visits which have a purchase event?
SELECT FORMAT(ROUND(100.0* COUNT(visit_id)/ (SELECT COUNT(visit_id) FROM clique_bait.events),2),'N2') pertcen_visit
FROM clique_bait.events
WHERE event_type = 3

pertcen_visit
6.06

--What is the percentage of visits which view the checkout page but do not have a purchase event?
WITH checkout_flag AS (
SELECT a.*,
	   c.page_name, c.product_id,
	   CASE WHEN c.page_name LIKE '%Checkout%' THEN a.visit_id END AS view_checkout,
	   CASE WHEN c.page_name LIKE '%Confirm%' THEN a.visit_id END AS purchased
FROM clique_bait.events a
LEFT JOIN clique_bait.page_hierarchy c ON a.page_id = c.page_id
)
SELECT COUNT(view_checkout) checkout_cnt,
	   COUNT(purchased) purchased_cnt,
	   FORMAT(ROUND(100.0*(COUNT(view_checkout)-COUNT(purchased))/COUNT(view_checkout),2),'N2') AS convert_ratio
FROM checkout_flag

checkout_cnt	purchased_cnt	convert_ratio
70	            55	            21.43

--What are the top 3 pages by number of views?
WITH rank_visit_cnt AS (
	SELECT page_id,
			COUNT(*)  visit_cnt,
			RANK() OVER(ORDER BY COUNT(*) DESC) visit_rank
	FROM clique_bait.events
	GROUP BY page_id
)
SELECT b.page_name, a.visit_cnt, a.visit_rank
FROM rank_visit_cnt a
LEFT JOIN clique_bait.page_hierarchy b ON a.page_id = b.page_id
WHERE visit_rank <='3'
ORDER BY 3

page_name	visit_cnt	visit_rank
Home Page	93	        1
Lobster	    79          2
Kingfish	78	        3

--What is the number of views and cart adds for each product category?
WITH event_flag AS (
SELECT a.*, b.product_category, c.event_name,
		CASE WHEN c.event_name LIKE '%View%' THEN c.event_name END AS page_view,
		CASE WHEN c.event_name LIKE '%Add%' THEN c.event_name END AS add_to_cart
FROM clique_bait.events a
LEFT JOIN clique_bait.page_hierarchy b ON a.page_id = b.page_id
LEFT JOIN clique_bait.event_identifier c ON a.event_type = c.event_type
)
SELECT product_category,
		COUNT(page_view) view_cnt,
		COUNT(add_to_cart) add_cnt
FROM event_flag
WHERE product_category IS NOT NULL
GROUP BY product_category

product_category	view_cnt	add_cnt
Fish	            137	        73
Luxury	            83	        38
Shellfish	        186	        100