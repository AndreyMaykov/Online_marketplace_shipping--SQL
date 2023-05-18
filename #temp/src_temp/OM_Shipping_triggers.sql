/* Automatically delete a user's picker profile
   from the picker_profiles table 
   if the user's picker role has been deleted 
   from the user_role table */

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


/* Automatically delete a user's driver profile
   from the driver_profiles table	
   if the user's driver role has been deleted 
   from the user_role table */

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


/* Automatically delete a user's admin profile
   from the admin_profiles table 
   if the user's admin role has been deleted 
   from the user_role table */

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


/* Automatically delete 
   from the staff_regular_availability table
   all the the rows related to a user 
   if a DELETE operation performed
   on the user_roles tables resulted in
   the user not having any employee role 
   (i.e. picker, driver or admin). */

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

/* Automatically delete 
   from the blocked_periods table
   all the the rows related to a user 
   if a DELETE operation performed
   on the user_roles tables resulted in
   the user not having any employee role 
   (i.e. picker, driver or admin). */


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


/* Automatically delete 
   from the wave_available_staff table
   all the the rows related to a user 
   if a DELETE operation performed
   on the user_roles tables resulted in
   the user not having any employee role 
   (i.e. picker, driver or admin). */

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


DELIMITER ;

   
/* Prevent inserting rows related to a user
   into the staff_regular_availability table
   if the user does not have an employee role
   (i.e. picker, driver or admin)   
   in the user_roles table */

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


/* Prevent inserting rows related to a user
   into the blocked_periods table
   if the user does not have an employee role
   (i.e. picker, driver or admin)   
   in the user_roles table */

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


/* Prevent inserting rows related to a user
   into the wave_available_staff table
   if the user does not have an employee role
   (i.e. picker, driver or admin)   
   in the user_roles table */

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


/* Prevent inserting a user's picker profile
   into the picker_profiles table
   if the user does not have the picker role   
   in the user_roles table */

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


/* Prevent inserting a user's driver profile
   into the driver_profiles table
   if the user does not have the picker role   
   in the user_roles table */

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


/* Prevent inserting a user's picker profile
   into the picker_profiles table
   if the user does not have the picker role   
   in the user_roles table */

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

/* Prevent direct changing a user's role 
	if the role is picker, driver or admin. 
	The role can be changed by deleting the old one 
	and inserting a row specifying the new one */

DELIMITER $$

CREATE TRIGGER prevent_user_role_update
BEFORE UPDATE
ON user_roles FOR EACH ROW
BEGIN
    DECLARE errorMessage VARCHAR(255);
    SET errorMessage = 'UPDATE operations are not allowed 
	on user_roles for pickers, drivers and admins. 
	Please use DELETE and INSERT instead.';
                        
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

	