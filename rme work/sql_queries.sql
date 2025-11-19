SELECT 
	county,
	SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_drug_cost END) AS opioid_spending,
	SUM(CASE WHEN opioid_drug_flag <> 'Y' THEN total_drug_cost END) AS nonopioid_spending
FROM prescription LEFT JOIN drug USING(drug_name)
				  LEFT JOIN prescriber USING(npi)
				  LEFT JOIN zip_fips ON nppes_provider_zip5 = zip
				  LEFT JOIN fips_county USING(fipscounty)
GROUP BY county
;

SELECT
	nppes_provider_zip5,
	SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_drug_cost END) AS opioid_spending,
	SUM(CASE WHEN opioid_drug_flag <> 'Y' THEN total_drug_cost END) AS nonopioid_spending
FROM prescription 
	LEFT JOIN drug USING(drug_name)
	LEFT JOIN prescriber USING(npi)
	LEFT JOIN zip_fips ON nppes_provider_zip5 = zip
WHERE fipscounty IS NULL
GROUP BY nppes_provider_zip5
; -- zip codes 35870, 37111, 37780, 37992, 38163, 38507, and 39129 are not associated with a fipscounty

SELECT county, year, overdose_deaths
FROM overdose_deaths FULL JOIN fips_county ON overdose_deaths.fipscounty = fips_county.fipscounty::integer
WHERE state = 'TN'
;


SELECT npi, nppes_provider_first_name, nppes_provider_last_org_name, opioid_claims, county
FROM (
	SELECT
		npi,
	SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count END) AS opioid_claims
	FROM prescription LEFT JOIN drug USING(drug_name)				  
	GROUP BY npi
	ORDER BY opioid_claims DESC NULLS LAST
	) AS opioid_prescribers
	LEFT JOIN prescriber USING(npi)
	LEFT JOIN zip_fips ON nppes_provider_zip5 = zip
	LEFT JOIN fips_county USING(fipscounty)
WHERE STATE = 'TN'
;


SELECT county, zip, SUM(opioid_claims) AS total_opioid_claims
FROM fips_county LEFT JOIN zip_fips USING(fipscounty)
				 LEFT JOIN prescriber ON nppes_provider_zip5 = zip
				 LEFT JOIN (SELECT npi, sum(total_claim_count) AS opioid_claims FROM prescription LEFT JOIN drug USING (drug_name) WHERE opioid_drug_flag = 'Y' GROUP BY npi) AS opioid_claims USING(npi)
WHERE county = 'DAVIDSON' AND state = 'TN'
GROUP BY county, zip
;
