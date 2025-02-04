########################## Data Cleaning: Stored Procedure ##########################
DROP PROCEDURE IF EXISTS copy_and_clean_data;
DELIMITER $$
CREATE PROCEDURE copy_and_clean_data() 
BEGIN 
	-- Creating Table
	# right click table --> copy to clipboard --> create statement
	# add one column "TimeStamp"
    # add "IF NOT EXISTS" after "CREATE TABLE"
	CREATE TABLE IF NOT EXISTS `ushouseholdincome_cleaned` (
	  `row_id` int DEFAULT NULL,
	  `id` int DEFAULT NULL,
	  `State_Code` int DEFAULT NULL,
	  `State_Name` text,
	  `State_ab` text,
	  `County` text,
	  `City` text,
	  `Place` text,
	  `Type` text,
	  `Primary` text,
	  `Zip_Code` int DEFAULT NULL,
	  `Area_Code` varchar(10) DEFAULT NULL,
	  `ALand` bigint DEFAULT NULL,
	  `AWater` bigint DEFAULT NULL,
	  `Lat` double DEFAULT NULL,
	  `Lon` double DEFAULT NULL, 
	  `TimeStamp` timestamp DEFAULT NULL
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
    
    -- Copy data to new table
    INSERT INTO ushouseholdincome_cleaned 
    SELECT *, CURRENT_TIMESTAMP # everything in original data + current timestamp
    FROM ushouseholdincome;
    
    -- Data Cleaning
    -- Remove Duplicates
	DELETE FROM ushouseholdincome_cleaned 
	WHERE 
		row_id IN (
		SELECT row_id
	FROM (
		SELECT row_id, id,
			ROW_NUMBER() OVER (
				PARTITION BY id, `TimeStamp`
				ORDER BY id, `TimeStamp`) AS row_num
		FROM 
			ushouseholdincome_cleaned
	) duplicates
	WHERE 
		row_num > 1
	);

	-- Fixing some data quality issues by fixing typos and general standardization
	UPDATE ushouseholdincome_cleaned
	SET State_Name = 'Georgia'
	WHERE State_Name = 'georia';

	UPDATE ushouseholdincome_cleaned
	SET County = UPPER(County);

	UPDATE ushouseholdincome_cleaned
	SET City = UPPER(City);

	UPDATE ushouseholdincome_cleaned
	SET Place = UPPER(Place);

	UPDATE ushouseholdincome_cleaned
	SET State_Name = UPPER(State_Name);

	UPDATE ushouseholdincome_cleaned
	SET `Type` = 'CDP'
	WHERE `Type` = 'CPD';

	UPDATE ushouseholdincome_cleaned
	SET `Type` = 'Borough'
	WHERE `Type` = 'Boroughs';
END $$
DELIMITER ;

-- Call Stored Procedure
CALL copy_and_clean_data;


-- Debugging & Check if Stored Procedure Work
SELECT *
FROM ushouseholdincome_cleaned
WHERE 
	row_id IN (
	SELECT row_id
FROM (
	SELECT row_id, id,
		ROW_NUMBER() OVER (
			PARTITION BY id
			ORDER BY id) AS row_num
	FROM 
		ushouseholdincome_cleaned
) duplicates
WHERE 
	row_num > 1
);

SELECT COUNT(row_id) 
FROM ushouseholdincome_cleaned
;

SELECT State_Name, COUNT(State_Name) 
FROM ushouseholdincome_cleaned
GROUP BY State_Name
;


########################## Data Cleaning: Event ##########################
/*
Note: This part is just an example.
Calling copy_and_clean_data() will keep adding data with new TimeStamp into ushouseholdincome_cleaned 
	(i.e. you will have multiple same data with different TimeStamp in ushouseholdincome_cleaned), 
	which might not be what you want!
*/
CREATE EVENT run_data_cleaning
	ON SCHEDULE EVERY 2 MINUTE 
DO 
	CALL copy_and_clean_data()
;

DROP EVENT IF EXISTS run_data_cleaning;


########################## Data Cleaning: Trigger ##########################
/*
Note: This part will NOT WORK (MySQL doesn't work like this)
Also, even if it works, calling copy_and_clean_data() will keep adding data with new TimeStamp into 
	ushouseholdincome_cleaned whenever a new data comes in, which is NOT WHAT YOU WANT
*/

DELIMITER $$
CREATE TRIGGER tansfer_clean_data 
	AFTER INSERT ON ushouseholdincome
    FOR EACH ROW
BEGIN
	CALL copy_and_clean_data();
END $$
DELIMITER ;

INSERT INTO ushouseholdincome 
VALUES 
('32534', '60213249', '6', 'California', 'CA', 'Alameda County', 
'Los Angeles', 'Alameda city', 'Track', 'Track', '90018', '323', 
'655700', '0', '34.0218914', '-118.3132782')
;








