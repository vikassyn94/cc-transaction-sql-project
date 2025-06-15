set search_path to practice;


'''
Top 5 cities with highest spends and their percentage contribution of total credit card spends 
'''

SELECT
	CITY,
	CITY_SPENT,
	ROUND((CITY_SPENT / SUM(CITY_SPENT) OVER ()) * 100, 2) AS SPENT_RATIO
FROM
	(
		SELECT
			(STRING_TO_ARRAY(CITY, ',')) [1] AS CITY,
			SUM(AMOUNT) AS CITY_SPENT
		FROM
			CREDIT_CARD
		GROUP BY
			1
	) AS FINAL
ORDER BY
	2 DESC
LIMIT
	5;



'''
Highest spend month and amount spent in that month for each card type
'''

SELECT
	CARD_TYPE, 
	SPENT_MONTH, 
	TO_CHAR(TOT_SPENT, 'FM99,99,99,999') TOT_SPENT
FROM
	(
		SELECT
			CARD_TYPE,
			DATE_PART('month', DATE) AS SPENT_MONTH,
			SUM(AMOUNT) AS TOT_SPENT,
			RANK() OVER (
				PARTITION BY
					CARD_TYPE
				ORDER BY
					SUM(AMOUNT) DESC
			) AS RNK
		FROM
			CREDIT_CARD
		GROUP BY
			1,
			2
	) AS FINAL
WHERE
	RNK = 1;


''' 
Transaction details for each card type when it reaches a cumulative of 1000000 or above total spends
'''

WITH
	FINAL AS (
		SELECT
			CITY,
			DATE,
			CARD_TYPE,
			EXP_TYPE,
			GENDER,
			AMOUNT,
			CUM_SUM,
			RANK() OVER (
				PARTITION BY
					CARD_TYPE
				ORDER BY
					CUM_SUM
			) AS RNK
		FROM
			(
				SELECT
					CITY,
					DATE,
					CARD_TYPE,
					EXP_TYPE,
					GENDER,
					AMOUNT,
					SUM(AMOUNT) OVER (
						PARTITION BY
							CARD_TYPE
						ORDER BY
							DATE ASC ROWS BETWEEN UNBOUNDED PRECEDING
							AND CURRENT ROW
					) AS CUM_SUM
				FROM
					CREDIT_CARD
			) AS B
		WHERE
			CUM_SUM >= 1000000
	)
SELECT
	CITY,
	DATE,
	CARD_TYPE,
	EXP_TYPE,
	GENDER,
	AMOUNT,
	CUM_SUM
FROM
	FINAL
WHERE
	RNK = 1;


'''
City which had lowest percentage spend for gold card type
'''


WITH
	FINAL AS (
		SELECT
			*,
			ROUND(
				TOT_SPENT / SUM(TOT_SPENT) OVER (
					PARTITION BY
						CITY
				) * 100,
				2
			) AS PERC
		FROM
			(
				SELECT
					(STRING_TO_ARRAY(CITY, ',')) [1] AS CITY,
					CARD_TYPE,
					SUM(AMOUNT) AS TOT_SPENT
				FROM
					CREDIT_CARD
				GROUP BY
					1,
					2
			) AS PRE_CALC
	)
SELECT
	*
FROM
	(
		SELECT
			*,
			RANK() OVER (
				ORDER BY
					PERC
			) AS RNK
		FROM
			FINAL
		WHERE
			CARD_TYPE = 'Gold'
	)
WHERE
	RNK = 1;



'''
City with highest_expense_type and lowest_expense_type 
'''

WITH
	FINAL AS (
		SELECT
			CITY,
			FIRST_VALUE(EXP_TYPE) OVER (
				PARTITION BY
					CITY
				ORDER BY
					TOT DESC
			) AS HIGHEST_EXPENSE_TYPE,
			LAST_VALUE(EXP_TYPE) OVER (
				PARTITION BY
					CITY
				ORDER BY
					TOT DESC ROWS BETWEEN UNBOUNDED PRECEDING
					AND UNBOUNDED FOLLOWING
			) AS LOWEST_EXPENSE_TYPE
		FROM
			(
				SELECT
					(STRING_TO_ARRAY(CITY, ',')) [1] AS CITY,
					EXP_TYPE,
					COUNT(*) AS TOT
				FROM
					CREDIT_CARD
				GROUP BY
					1,
					2
			) AS CALC
	)
SELECT
	*
FROM
	FINAL
GROUP BY
	1,
	2,
	3
ORDER BY
	1;



'''
Percentage contribution of spends by females for each expense type
'''

SELECT
	EXP_TYPE,
	PERC_CONT
FROM
	(
		SELECT
			EXP_TYPE,
			GENDER,
			ROUND(
				TOT_EXP / SUM(TOT_EXP) OVER (
					PARTITION BY
						EXP_TYPE
				) * 100,
				2
			) AS PERC_CONT
		FROM
			(
				SELECT
					EXP_TYPE,
					GENDER,
					SUM(AMOUNT) AS TOT_EXP
				FROM
					CREDIT_CARD
				GROUP BY
					1,
					2
			) AS B
	) AS C
WHERE
	GENDER = 'F'
ORDER BY
	2;


'''
Card and expense type combination with highest month over month growth in Jan-2014
'''

WITH
	FINAL AS (
		SELECT
			CARD_TYPE,
			EXP_TYPE,
			MONTH,
			YEAR,
			TOT,
			LEAD(TOT) OVER (
				PARTITION BY
					CARD_TYPE,
					EXP_TYPE
				ORDER BY
					MONTH,
					YEAR
			) AS PRV
		FROM
			(
				SELECT
					CARD_TYPE,
					EXP_TYPE,
					DATE_PART('month', DATE) AS MONTH,
					DATE_PART('year', DATE) AS YEAR,
					SUM(AMOUNT) AS TOT
				FROM
					CREDIT_CARD
				WHERE
					(
						DATE_PART('month', DATE) = 12
						AND DATE_PART('year', DATE) = 2013
					)
					OR (
						DATE_PART('month', DATE) = 1
						AND DATE_PART('year', DATE) = 2014
					)
				GROUP BY
					1,
					2,
					3,
					4
			) AS CALC
	)
SELECT
	CARD_TYPE,
	EXP_TYPE,
	GROWTH_JAN
FROM
	(
		SELECT
			CARD_TYPE,
			EXP_TYPE,
			((TOT - PRV) * 100 / COALESCE(PRV, 0)) AS GROWTH_JAN
		FROM
			FINAL
		WHERE
			YEAR = 2014
	)
ORDER BY GROWTH_JAN DESC
LIMIT 1;



'''
City with highest total spend to total no of transcations ratio during weekends.
'''


SELECT
	(STRING_TO_ARRAY(CITY, ',')) [1] AS CITY,
	(SUM(AMOUNT) / COUNT(AMOUNT)) SPEND_TO_TRAN_RATIO
FROM
	CREDIT_CARD
WHERE
	TRIM(TO_CHAR(DATE, 'day')) IN ('sunday', 'saturday') --TO_CHAR(date, 'day') returns padded names like 'sunday ', not 'sunday'
GROUP BY
	1
ORDER BY 
	2 DESC
LIMIT 1;


'''
City with least number of days to reach its 500th transaction after the first transaction in that city
'''

WITH
	FINAL AS (
		SELECT
			CITY,
			TRANS_NO,
			(NXT_DATE - FIRST_DATE) AS NO_OF_DAYS
		FROM
			(
				SELECT
					(STRING_TO_ARRAY(CITY, ',')) [1] AS CITY,
					DATE,
					LEAD(DATE) OVER (
						PARTITION BY
							(STRING_TO_ARRAY(CITY, ',')) [1]
						ORDER BY
							DATE
					) AS NXT_DATE,
					ROW_NUMBER() OVER (
						PARTITION BY
							(STRING_TO_ARRAY(CITY, ',')) [1]
						ORDER BY
							DATE
					) AS TRANS_NO,
					MIN(DATE) OVER (
						PARTITION BY
							(STRING_TO_ARRAY(CITY, ',')) [1]
					) AS FIRST_DATE
				FROM
					CREDIT_CARD
			) AS CALC
		WHERE
			TRANS_NO = 500
	)
SELECT
	*
FROM
	FINAL
ORDER BY
	NO_OF_DAYS
LIMIT
	1;

