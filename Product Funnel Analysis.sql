Using a single SQL query - create a new output table which has the following details:
How many times was each product viewed?
How many times was each product added to cart?
How many times was each product added to a cart but not purchased (abandoned)?
How many times was each product purchased?

SELECT	a.page_name AS product,
		COUNT(a.viewed) AS viewed,
		COUNT(a.cart_added) AS cart_added,
		COUNT(a.cart_added) - COUNT(b.purchased) AS abandoned,
		COUNT(b.purchased) AS purchased
INTO clique_bait.product_info_performance
FROM (
	SELECT d.page_name, d.product_id,
			CASE WHEN c.event_type = 1 THEN c.visit_id END AS viewed,
			CASE WHEN c.event_type = 2 THEN c.visit_id END AS cart_added
	FROM clique_bait.events c
	LEFT JOIN clique_bait.page_hierarchy d ON c.page_id = d.page_id
	)a
LEFT JOIN (
    SELECT visit_id AS purchased
    FROM clique_bait.events
    WHERE event_type = 3
	)b ON a.cart_added = b.purchased
WHERE a.product_id IS NOT NULL
GROUP BY a.page_name

product	        viewed	cart_added	abandoned	purchased
Abalone	        43	    25	        11	        14
Black Truffle	36	    19	        5	        14
Crab	        39	    24	        9	        15
Kingfish	    51	    27	        13	        14
Lobster	        52	    27	        9	        18
Oyster	        52	    24	        7	        17
Russian Caviar	47	    19	        6	        13
Salmon	        43	    25	        10	        15
Tuna	        43	    21	        9	        12

create another table which further aggregates the 
data for the above points for each product category


SELECT	a.product_category AS category,
		COUNT(a.viewed) AS viewed,
		COUNT(a.cart_added) AS cart_added,
		COUNT(a.cart_added) - COUNT(b.purchased) AS abandoned,
		COUNT(b.purchased) AS purchased
INTO clique_bait.category_info_performance
FROM (
	SELECT d.product_category, d.product_id,
			CASE WHEN c.event_type = 1 THEN c.visit_id END AS viewed,
			CASE WHEN c.event_type = 2 THEN c.visit_id END AS cart_added
	FROM clique_bait.events c
	LEFT JOIN clique_bait.page_hierarchy d ON c.page_id = d.page_id
	)a
LEFT JOIN (
    SELECT visit_id AS purchased
    FROM clique_bait.events
    WHERE event_type = 3
	)b ON a.cart_added = b.purchased
WHERE a.product_id IS NOT NULL
GROUP BY a.product_category

category	viewed	cart_added	abandoned	purchased
Fish	    137	    73	        32	        41
Luxury	    83	    38	        11	        27
Shellfish	186	    100	        36	        64

--Most viewed product
SELECT TOP 1 product most_viewed
FROM clique_bait.product_info_performance
ORDER BY viewed DESC
--Most cart adds
SELECT TOP 1 product most_adds
FROM clique_bait.product_info_performance
ORDER BY cart_added DESC
--Most purchased
SELECT TOP 1 product most_purchased
FROM clique_bait.product_info_performance
ORDER BY purchased DESC
--Most abandoned
SELECT TOP 1 product most_abandoned
FROM clique_bait.product_info_performance
ORDER BY abandoned DESC