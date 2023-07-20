-- Question 1: What are the total number of claims per month, per product in 2020?

SELECT DATE_TRUNC(claim_date, month) AS month, 
  product_name, 
  COUNT(DISTINCT claim_id) AS num_of_claims
FROM data.claims
WHERE EXTRACT(year FROM claim_date) = 2020
GROUP BY 1,2
ORDER BY 1;

-- Yearly Trends for Number of claims
SELECT DATE_TRUNC(claim_date, year) AS year, 
  COUNT(DISTINCT claim_id) AS num_of_claims
FROM data.claims
GROUP BY 1
ORDER BY 1;


-- Question 2: What was the total number of claims, total claim cost, and total covered cost in June 2023?

SELECT
  COUNT(DISTINCT claim_id) AS total_claims,
  ROUND(SUM(claim_amount),2) AS total_claim_cost,
  ROUND(SUM(covered_amount),2) AS total_covered_cost,
FROM data.claims
WHERE DATE_TRUNC(claim_date, month) = '2023-06-01';

-- Reimbursement Rate across all years
SELECT
  COUNT(DISTINCT claim_id) AS total_claims,
  ROUND(SUM(claim_amount),2) AS total_claim_cost,
  ROUND(SUM(covered_amount),2) AS total_covered_cost,
  ROUND(((SUM(covered_amount)/ SUM(claim_amount)) * 100),2) AS reimbusement_rate
FROM data.claims;


-- Question 3: What were the top 3 hair products in June 2023?

SELECT 
  DISTINCT(product_name),
  COUNT(DISTINCT claim_id) AS total_claims
FROM data.claims
WHERE LOWER(product_name) LIKE '%hair%'
  AND DATE_TRUNC(claim_date, month) = '2023-06-01'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

-- Products with most claims from 2019-2023
SELECT 
  DISTINCT(product_name),
  COUNT(DISTINCT claim_id) AS total_claims
FROM data.claims
WHERE LOWER(product_name) LIKE '%hair%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;


-- Question 4: Which state had the highest number of claims in the program in 2023? 

SELECT
  customers.state,
  COUNT(DISTINCT claims.claim_id) as total_claims
FROM data.claims AS claims
LEFT JOIN data.customers AS customers
  ON claims.customer_id = customers.customer_id
WHERE EXTRACT(year from claims.claim_date) = 2023
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

-- Question 5
-- How would you compare this to the state with the highest claim amounts?

SELECT
  customers.state,
  ROUND(SUM(claims.claim_amount),2) AS total_claim_amount
FROM data.claims AS claims
LEFT JOIN data.customers AS customers
  ON claims.customer_id = customers.customer_id
WHERE EXTRACT(year FROM claims.claim_date) = 2023
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;


-- Question 6: Which category had the highest covered amount on Christmas in 2022: Hair supplements, Biotin supplements, or Vitamin B supplements? 
-- Assume each product has the keyword in its name.

-- Assume Christmas in 2022 is only 2022-12-25
-- Claims only created on 12-25
SELECT
  DATE_TRUNC(claim_date,day) AS date,
  CASE
    WHEN lower(product_name) LIKE '%hair%' THEN 'Hair Supplements'
    WHEN lower(product_name) LIKE '%biotin%' THEN 'Biotin supplments'
    WHEN lower(product_name) LIKE '%vitamin b%' THEN 'Vitamin B Supplements'
    ELSE 'Other'
  END AS Categories,
  ROUND(SUM(covered_amount),2) AS total_covered_amount,
  COUNT(DISTINCT claim_id) AS total_claims
FROM data.claims
WHERE DATE_TRUNC(claim_date, day) = '2022-12-25'
GROUP BY 1, 2;

-- Assume Christmas runs from 2022-12-20 to 2022-12-30
-- Claim dates created between 12-20 to 12-30
SELECT
  CASE
    WHEN lower(product_name) LIKE '%hair%' THEN 'Hair Supplements'
    WHEN lower(product_name) LIKE '%biotin%' THEN 'Biotin supplments'
    WHEN lower(product_name) LIKE '%vitamin b%' THEN 'Vitamin B Supplements'
    ELSE 'Other'
  END AS Categories,
  ROUND(SUM(covered_amount),2) AS total_covered_amount,
  COUNT(DISTINCT claim_id) AS total_claims
FROM data.claims
WHERE DATE_TRUNC(claim_date, day) BETWEEN '2022-12-20' AND '2022-12-30'
GROUP BY 1
ORDER BY 1;


-- Question 7:How many customers either have a platinum plan and signed up in 2023, or signed up in 2022?

SELECT 
  COUNT(DISTINCT customer_id) AS num_of_customers
FROM data.customers
WHERE (plan = 'platinum'
  AND EXTRACT(year from signup_date) = 2023)
  OR EXTRACT(year from signup_date) = 2022;

-- Plans and their customers
SELECT 
  plan,
  COUNT(DISTINCT customer_id) AS num_of_customers
FROM data.customers
GROUP BY 1;


-- Question 8. Which 10 customers have the most claims across all time? Return their first and last name as one field.

SELECT 
  CONCAT(customers.first_name, ' ', customers.last_name) AS full_name,
  COUNT(DISTINCT claims.claim_id) AS claim_count
FROM data.claims AS claims
LEFT JOIN data.customers AS customers
  ON claims.customer_id = customers.customer_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


-- Question 9: What was the average percent reimbursement across all years for 
-- products that were either hair related and sold in NY, or a supplement product?

SELECT 
  ROUND(AVG(CASE
        WHEN claims.claim_amount <> 0 THEN (claims.covered_amount) / (claims.claim_amount) * 100 
        ELSE 0
      END),2) AS average_reimbursement_percent
FROM data.claims AS claims
LEFT JOIN data.customers AS customers
  ON claims.customer_id = customers.customer_id
WHERE
  (LOWER(claims.product_name) LIKE '%hair%' AND customers.state = 'NY')
  OR (LOWER(claims.product_name) LIKE '%supplement%');


-- Question 10: What are the campaigns that have highest amount of campaigns? Find the average cost and average click rate.
SELECT 
  DISTINCT campaign_type,
  platform,
  COUNT(DISTINCT campaign_id) AS total_campaigns,
  ROUND(AVG(cost),2) AS average_cost,
  ROUND(AVG((clicks/impressions)*100),2) AS average_click_rate
FROM data.campaigns
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5;


-- Question 11: What are the platforms that have highest amount of campaigns? Find the average cost and average click rate.
SELECT 
  DISTINCT platform,
  COUNT(DISTINCT campaign_id) AS total_campaigns,
  ROUND(AVG(cost),2) AS average_cost,
  ROUND(AVG((clicks/impressions)*100),2) AS average_click_rate
FROM data.campaigns
GROUP BY 1
ORDER BY 2 DESC;

