/*********** prevent_user_role_update ***********/

							DROP TRIGGER prevent_user_role_update

DELIMITER $$

CREATE TRIGGER prevent_user_role_update
BEFORE UPDATE
ON user_roles FOR EACH ROW
BEGIN
    DECLARE errorMessage VARCHAR(255);
    SET errorMessage = 'UPDATE operations are not allowed on user_roles for pickers, drivers and admins. Please use DELETE and INSERT instead.';
                        
    IF 
    	OLD.role_id = 3 OR 
    	OLD.role_id = 4 OR 
    	OLD.role_id = 5 OR
    	NEW.role_id = 3 OR 
    	NEW.role_id = 4 OR 
    	NEW.role_id = 5
    THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = errorMessage;
    END IF;
END $$

DELIMITER ;




/*********** delete_picker_profile ***********/

DELIMITER $$

CREATE TRIGGER delete_picker_profile
AFTER DELETE
ON user_roles FOR EACH ROW
BEGIN
    IF OLD.role_id = 5 THEN
        DELETE FROM picker_profiles 
		WHERE user_id = OLD.user_id;
    END IF;
END$$

DELIMITER ;

/*********** delete_driver_profile ***********/

				DROP TRIGGER delete_driver_profile;

DELIMITER $$

CREATE TRIGGER delete_driver_profile
AFTER DELETE
ON user_roles FOR EACH ROW
BEGIN
    IF OLD.role_id = 4 THEN
        DELETE FROM driver_profiles 
		WHERE user_id = OLD.user_id;
    END IF;
END$$

DELIMITER ;

/*********** delete_admin_profile ***********/

							DROP TRIGGER delete_admin_profile;

DELIMITER $$

CREATE TRIGGER delete_admin_profile
AFTER DELETE
ON user_roles FOR EACH ROW
BEGIN
    IF OLD.role_id = 3 THEN
        DELETE FROM admin_profiles 
		WHERE user_id = OLD.user_id;
    END IF;
END$$

DELIMITER ;
	
/**************************************************************************/

						DROP TRIGGER delete_user_from_sra;

CREATE TRIGGER delete_user_from_sra
AFTER DELETE
ON user_roles FOR EACH ROW
    DELETE FROM staff_regular_availability
    WHERE 
    	staff_regular_availability.user_id = OLD.user_id AND 
    	NOT EXISTS(
    		SELECT 1 FROM user_roles 
    		WHERE 
    			user_roles.user_id = OLD.user_id AND (
    				user_roles.role_id = 3 OR 
    				user_roles.role_id = 4 OR 
    				user_roles.role_id = 5
    			)
    	)
;

						DROP TRIGGER delete_user_from_bp;

CREATE TRIGGER delete_user_from_bp
AFTER DELETE
ON user_roles FOR EACH ROW
    DELETE FROM blocked_periods
    WHERE 
    	blocked_periods.user_id = OLD.user_id AND 
    	NOT EXISTS(
    		SELECT 1 FROM user_roles 
    		WHERE 
    			user_roles.user_id = OLD.user_id AND (
    				user_roles.role_id = 3 OR 
    				user_roles.role_id = 4 OR 
    				user_roles.role_id = 5
    			)
    	)
;

						DROP TRIGGER delete_user_from_ws;

CREATE TRIGGER delete_user_from_ws
AFTER DELETE
ON user_roles FOR EACH ROW
    DELETE FROM wave_available_staff
    WHERE 
    	wave_available_staff.user_id = OLD.user_id AND 
    	NOT EXISTS(
    		SELECT 1 FROM user_roles 
    		WHERE 
    			user_roles.user_id = OLD.user_id AND (
    				user_roles.role_id = 3 OR 
    				user_roles.role_id = 4 OR 
    				user_roles.role_id = 5
    			)
    	)
;
   
/**************************************************************************/
/************************* prevent INSERT *************************/
   
/********************  prevent_user_insert_sra  **********************************/

   
   						DROP TRIGGER prevent_user_insert_sra;

DELIMITER $$
   
CREATE TRIGGER prevent_user_insert_sra
BEFORE INSERT
ON staff_regular_availability FOR EACH ROW
BEGIN
    DECLARE errorMessage VARCHAR(255);
    SET errorMessage = CONCAT('The user with user_id = ', NEW.user_id, ' does not have an employee role (admin, picker or driver) in user_roles');

    IF NOT EXISTS (
    	SELECT 1 FROM user_roles 
    	WHERE 
    		user_roles.user_id = NEW.user_id AND (
    			user_roles.role_id = 3 OR 
    			user_roles.role_id = 4 OR 
    			user_roles.role_id = 5
    		)
    )
    THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = errorMessage;
    END IF;
END $$

DELIMITER ;

INSERT INTO staff_regular_availability (user_id, wday, interval_beginning, interval_end)
VALUES 
	 /* (4, 4, '14:30:00', '18:00:00')
	, (4, 4, '19:00:00', '21:00:00')
	
	, */(3, 3, '10:00:00', '14:00:00')/*
	, (3, 3, '15:00:00', '18:00:00')
	, (3, 4, '10:00:00', '14:00:00')
	, (4, 1, '12:30:00', '16:30:00')
	, (4, 3, '08:30:00', '12:30:00')
	, (4, 3, '14:30:00', '16:30:00')
	, (5, 3, '14:00:00', '21:00:00')
	, (5, 6, '12:00:00', '18:00:00')
	, (5, 7, '08:00:00', '23:00:00')
	*/
;

SELECT * FROM staff_regular_availability;


/********************  prevent_user_insert_bp  **********************************/

   						DROP TRIGGER prevent_user_insert_bp;

DELIMITER $$
   
CREATE TRIGGER prevent_user_insert_bp
BEFORE INSERT
ON blocked_periods FOR EACH ROW
BEGIN
    DECLARE errorMessage VARCHAR(255);
    SET errorMessage = CONCAT('The user with user_id = ', NEW.user_id, ' does not have an employee role (admin, picker or driver) in user_roles');

    IF NOT EXISTS (
    	SELECT 1 FROM user_roles 
    	WHERE 
    		user_roles.user_id = NEW.user_id AND (
    			user_roles.role_id = 3 OR 
    			user_roles.role_id = 4 OR 
    			user_roles.role_id = 5
    		)
    )
    THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = errorMessage;
    END IF;
END $$

DELIMITER ;

/********************  prevent_user_insert_bp  **********************************/

   						DROP TRIGGER prevent_user_insert_ws;

DELIMITER $$
   
CREATE TRIGGER prevent_user_insert_ws
BEFORE INSERT
ON wave_available_staff FOR EACH ROW
BEGIN
    DECLARE errorMessage VARCHAR(255);
   	-- SET @user_id_ins = NEW.user_id;
    SET errorMessage = CONCAT('The user with user_id = ', NEW.user_id, '  does not have an employee role (admin, picker or driver) in user_roles');

    IF NOT EXISTS (
    	SELECT 1 FROM user_roles 
    	WHERE 
    		user_roles.user_id = NEW.user_id AND (
    			user_roles.role_id = 3 OR 
    			user_roles.role_id = 4 OR 
    			user_roles.role_id = 5
    		)
    )
    THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = errorMessage;
    END IF;
END $$

DELIMITER ;

INSERT INTO staff_regular_availability (user_id, wday, interval_beginning, interval_end)
VALUES 
	  (4, 4, '14:30:00', '18:00:00') 
;

/********************  prevent_picker_profile_insert  **********************************/


							DROP TRIGGER prevent_picker_profile_insert;

DELIMITER $$
   
CREATE TRIGGER prevent_picker_profile_insert
BEFORE INSERT
ON picker_profiles FOR EACH ROW
BEGIN
    DECLARE errorMessage VARCHAR(255);
    SET errorMessage = CONCAT('The user with user_id = ', NEW.user_id, ' does not have the picker role in user_roles');

    IF NOT EXISTS (SELECT 1 FROM user_roles WHERE (user_roles.user_id = NEW.user_id AND user_roles.role_id = 5))
    THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = errorMessage;
    END IF;
END $$

DELIMITER ;

/********************  prevent_driver_profile_insert  **********************************/


							DROP TRIGGER prevent_driver_profile_insert;

DELIMITER $$
   
CREATE TRIGGER prevent_driver_profile_insert
BEFORE INSERT
ON driver_profiles FOR EACH ROW
BEGIN
    DECLARE errorMessage VARCHAR(255);
    SET errorMessage = CONCAT('The user with user_id = ', NEW.user_id, ' does not have the driver role in user_roles');

    IF NOT EXISTS (SELECT 1 FROM user_roles WHERE (user_roles.user_id = NEW.user_id AND user_roles.role_id = 4))
    THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = errorMessage;
    END IF;
END $$

DELIMITER ;


/********************  prevent_admin_profile_insert  **********************************/


							DROP TRIGGER prevent_admin_profile_insert;

DELIMITER $$
   
CREATE TRIGGER prevent_admin_profile_insert
BEFORE INSERT
ON admin_profiles FOR EACH ROW
BEGIN
    DECLARE errorMessage VARCHAR(255);
    SET errorMessage = CONCAT('The user with user_id = ', NEW.user_id, ' does not have the admin role in user_roles');

    IF NOT EXISTS (SELECT 1 FROM user_roles WHERE user_roles.user_id = NEW.user_id AND user_roles.role_id = 3)
    THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = errorMessage;
    END IF;
END $$

DELIMITER ;



/**************************************************************************/
/**************************************************************************/

/* version 2 -- a row is deleted from wave_available_staff if 
	wave_available_staff.driver_id = driver_profiles.driver_id for the row being deleted from driver_profiles 
	AND the wave begins after the current time -- For some reason, this version won't work correctly: the second condition never meets.
DROP TRIGGER delete_driver_from_wave;

CREATE TRIGGER delete_driver_from_wave
AFTER DELETE
ON driver_profiles FOR EACH ROW
	DELETE FROM wave_available_staff 
		WHERE (
			/* user_id = OLD.user_id */
			/* AND */
			((SELECT wave_beginning_time FROM wave_timings 
				WHERE wave_id = wave_available_staff.wave_id)
				> NOW()
			)
		);
	
/* version 3 -- a row is deleted from wave_available_staff if 
	wave_available_staff.driver_id = driver_profiles.driver_id for the row being deleted from driver_profiles 
	AND the wave begins after the current time
*/
CREATE TRIGGER delete_driver_from_wave
AFTER DELETE
ON driver_profiles FOR EACH ROW
	DELETE FROM wave_available_staff 
		WHERE (
			user_id = OLD.user_id
			AND 
				wave_id IN (SELECT wave_id FROM wave_timings WHERE wave_beginning_time > NOW ())
		);
	

SELECT ((SELECT * FROM driver_profiles WHERE driver_id = 1) NOT NULL );

SELECT((SELECT COUNT(driver_id) FROM driver_profiles WHERE user_id = 1) + (SELECT COUNT(picker_id) FROM picker_profiles WHERE user_id = 1));

/* Verification whether the user has a driver profile or a picker profile (or both) */

(SELECT user_id FROM driver_profiles) UNION (SELECT user_id FROM picker_profiles);

CREATE TRIGGER delete_driver_from_wave
AFTER DELETE
ON driver_profiles FOR EACH ROW
	DELETE FROM wave_available_staff 
		WHERE (
				wave_available_staff.user_id = OLD.user_id
			AND 
				wave_available_staff.user_id NOT IN 
				-- ((SELECT user_id FROM driver_profiles) UNION 
				(SELECT user_id FROM picker_profiles)
				-- )
			AND 
				wave_available_staff.wave_id IN (SELECT wave_id FROM wave_timings WHERE wave_beginning_time > NOW ())			
		);
	
DROP TRIGGER delete_driver_from_wave;

(SELECT user_id FROM driver_profiles) UNION (SELECT user_id FROM picker_profiles);

UPDATE users 
SET id = 1 WHERE id = 7;

/* ****************************************** */

SET @driver_id := 1; 													/* (q.1.1) */

SET @user_id := 							
	(SELECT user_id FROM driver_profiles 
	WHERE driver_id = @driver_id);
/* the variable @user_id is required to check 
 * whether the rows with the user_id corresponding to the @driver_id 
 * were correctly deleted from the wave_available_staff table 
 * after deleting the driver from driver_profiles table 
 * (without storing as a variable the value of user_id corresponding to the driver_id, 
 * it would be impossible to determine that value after deleting the driver, 
 * as the only way to determine it from the database tables 
 * was the row deleted from driver_profiles */

SELECT * FROM driver_profiles WHERE driver_id = @driver_id; 			/* (q.1.2) */
																	

SELECT 
	wave_available_staff.user_id, 
	driver_profiles.driver_id, 
	picker_profiles.picker_id, 
	wave_beginning_time, 
	wave_cutoff_time 
FROM (
	wave_available_staff
	LEFT JOIN driver_profiles
	ON wave_available_staff.user_id = driver_profiles.user_id 
	LEFT JOIN picker_profiles
	ON (picker_profiles.user_id = wave_available_staff.user_id)
	LEFT JOIN wave_timings 
	ON wave_available_staff.wave_id = wave_timings.wave_id
)
WHERE wave_available_staff.user_id = @user_id;							/* (q.1.3) */

/*  VERIFICATION: Before executing query (q.1.4) below,
executing (q.1.2) must return 1 row (as the user has a driver profile),
and (q.1.3) must return 5 rows
(all the waves the user is available for)
*/

DELETE FROM driver_profiles 
WHERE driver_id = @driver_id;											/* (q.1.4) */
	
/*  VERIFICATION: After executing query (q.1.4) above,
execute (q.1.2). It must return 0 rows (as the user lost his driver profile).
Execute (q.1.3). The result must be the same as before deletion, i.e. 5 rows 
(since the user with driver_id = 1 also has a picker profile),
*/

/* Choose another driver:	*/

SET @driver_id := 4; 													/* (q.1.5) */

SET @user_id := 							
	(SELECT user_id FROM driver_profiles 
	WHERE driver_id = @driver_id);

SELECT @user_id;
SELECT @driver_id;

DROP DATABASE shipping_6_4;
CREATE DATABASE shipping_6_4;
USE shipping_6_4;

DELETE FROM picker_profiles 
WHERE picker_id = 2;

SELECT * FROM driver_profiles
WHERE driver_id = 3;

DELETE FROM users WHERE user_id = 3;

SELECT NOW();

DROP TRIGGER delete_user_from_wave;
DROP TRIGGER delete_driver_from_wave;
	