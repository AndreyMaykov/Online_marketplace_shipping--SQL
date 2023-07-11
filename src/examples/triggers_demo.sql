/*

Object: SQL script 

MySQL version: 8.0

Author: Andrey Maykov

Script Date: 2023-07-05

Description:
 
The script demonstrates maintaing the project's data integrity
through the schema triggers

To get the results specified below, it is required that: 
  a. the DB tables has been populated
     by executing the table_populating.sql script;
  b. the statements below are executed 
	 in the same order as they are arrenged here.  

*/


SELECT * FROM roles;
SELECT * FROM users;


							/* prevent_user_role_update */

SELECT role_id FROM user_roles 
WHERE id = 1;
/* returns 1 -- the user has the 'customer' role */

UPDATE user_roles 
SET role_id = 2 WHERE id = 1;
/* changes the user's role from 'customer' to 'vendor' */

SELECT role_id FROM user_roles 
WHERE id = 1;
/* returns 2 -- the role has been succesfuuly changed */

UPDATE user_roles 
SET role_id = 1 WHERE id = 1;
/* changes the user's role back to 'customer' */

SELECT role_id FROM user_roles 
WHERE id = 1;
/* returns 1 -- the role has been succesfuuly changed back*/

UPDATE user_roles 
SET role_id = 3 WHERE id = 1;
/* returns an error message since the role 'admin' cannot 
   be assigned to a user through the UPDATE operation 
*/

SELECT role_id FROM user_roles 
WHERE id = 4;
/* returns 4 -- the user has the 'driver' role */

UPDATE user_roles 
SET role_id = 1 WHERE id = 4;
/* returns an error message */

UPDATE user_roles 
SET role_id = 5 WHERE id = 4;
/* returns an error message since the role 'driver' cannot 
   be assigned to a user through the UPDATE operation 
*/


							/* delete_picker_profile */

SELECT id, role_id 
FROM user_roles 
WHERE user_id = 4
ORDER BY id;
/* returns (5,	3)
         , (6,	4)
   		 , (7,	5)
 --  the user has the 'admin', 'driver', and 'picker' roles 
 */

SELECT * FROM picker_profiles
WHERE user_id = 4;
/* returns (1, 4, 80, 1) 
   --  the user has a picker profile
 */

SELECT * FROM driver_profiles
WHERE user_id = 4;
/* returns (2, 4, 5, 0, 80) 
  --  the user has a driver profile
*/

SELECT * FROM admin_profiles
WHERE user_id = 4;
/* returns (1, 4) 
  --  the user has an admin profile
*/

DELETE FROM user_roles
WHERE id = 7;
/*  deprives the user of the 'picker' role */

SELECT id, role_id 
FROM user_roles 
WHERE user_id = 4;
/* returns (5,	3)
         , (6,	4)
  -- the user doesn't have the 'picker' role anymore 
*/

SELECT * FROM picker_profiles
WHERE user_id = 4;
/* returns nothing 
  -- the user's picker profile 
   has been automatically deleted 
*/

SELECT * FROM driver_profiles
WHERE user_id = 4;
/* returns (2, 4, 5, 0, 80) 
  -- the user's driver profile 
   has not been deleted
*/

SELECT * FROM admin_profiles
WHERE user_id = 4;
/* returns (1, 4) 
  -- the user's admin profile 
   has not been deleted
*/

							/* delete_driver_profile */

SELECT id, role_id 
FROM user_roles 
WHERE user_id = 4
ORDER BY id;
/* returns (5,	3)
         , (6,	4)
  --  the user has the 'admin' and 'driver' roles 
 */

SELECT * FROM driver_profiles
WHERE user_id = 4;
/* returns (2, 4, 5, 0, 80) 
  --  the user has a driver profile
*/


SELECT * FROM admin_profiles
WHERE user_id = 4;
/* returns (1, 4) 
  --  the user has an admin profile 
 */

DELETE FROM user_roles
WHERE id = 6;
/*  deprives the user of the 'driver' role */

SELECT id, role_id 
FROM user_roles 
WHERE user_id = 4;
/* returns (5,	3)
  -- the user doesn't have the 'driver' role anymore 
*/

SELECT * FROM driver_profiles
WHERE user_id = 4;
/* returns nothing 
  -- the user's driver profile 
   has been automatically deleted 
*/


SELECT * FROM admin_profiles
WHERE user_id = 4;
/* returns (1, 4) 
  -- the user's admin profile 
   has not been deleted
*/

							/* delete_admin_profile */

SELECT id, role_id 
FROM user_roles 
WHERE user_id = 4;
/* returns (5,	3)
  --  the user has the 'admin' role 
*/

SELECT * FROM admin_profiles
WHERE user_id = 4;
/* returns (1, 4) 
  --  the user has an admin profile
*/

DELETE FROM user_roles
WHERE id = 5;
/*  deprives the user of the 'admin' role */

SELECT id, role_id 
FROM user_roles 
WHERE user_id = 4;
/* returns nothing
  -- the user doesn't have the 'admin' role anymore 
*/

SELECT * FROM admin_profiles
WHERE user_id = 4;
/* returns nothing 
  -- the user's admin profile 
   has been automatically deleted 
*/

							/* prevent_picker_profile_insert */

SELECT user_id, can_lift, gift_packing 
FROM picker_profiles 
WHERE user_id = 3;
/* returns nothing 
 -- the user does not have a picker profile 
*/

SELECT role_id 
FROM user_roles 
WHERE user_id = 3;
/* returns (4) 
  -- the user does not have the 'picker' role either
*/

INSERT INTO picker_profiles (user_id, can_lift, gift_packing)
VALUES (3, 100, 0);
/* returns an error message 
 -- the trigger prevents creating the user's picker profile 
 	as the user does not have the 'picker' role
*/


INSERT INTO user_roles (user_id, role_id)
VALUES (3, 5);
/* adds the user the 'picker' role */

SELECT role_id 
FROM user_roles 
WHERE user_id = 3;
/* returns (4),	(5) 
  -- the user has been assigned the 'picker' role
*/

INSERT INTO picker_profiles (user_id, can_lift, gift_packing)
VALUES (3, 100, 0);
/* no an error message 
  -- now that the user has the 'picker' role,
     the picker profile has been succesfully created
*/

SELECT user_id, can_lift, gift_packing 
FROM picker_profiles 
WHERE user_id = 3;
/* returns (3, 100, 0) 
  -- confirms that the profile has been created 
*/

							/* prevent_driver_profile_insert */

SELECT user_id, licence_class, airbrake_certificate, can_lift 
FROM driver_profiles
WHERE user_id = 4;
/* returns nothing 
 -- the user does not have a driver profile 
*/

SELECT role_id 
FROM user_roles 
WHERE user_id = 4;
/* returns nothing 
  -- the user does not have the 'driver' role either
*/

INSERT INTO driver_profiles (user_id, licence_class, airbrake_certificate, can_lift)
VALUES (4, 4, 1, 80);
/* returns an error message 
 -- the trigger prevents creating the user's driver profile 
 	as the user does not have the 'driver' role
*/

INSERT INTO user_roles (user_id, role_id)
VALUES (4, 4);
/* adds the user the 'driver' role */

SELECT role_id 
FROM user_roles 
WHERE user_id = 4;
/* returns (4) 
  -- the user has been assigned the 'driver' role
 */

INSERT INTO driver_profiles (user_id, licence_class, airbrake_certificate, can_lift)
VALUES (4, 4, 1, 80);
/* no an error message 
  -- now that the user has the 'driver' role,
     the driver profile has been succesfully created
*/

SELECT user_id, licence_class, airbrake_certificate, can_lift 
FROM driver_profiles 
WHERE user_id = 4;
/* returns (4, 4, 1, 80) 
  -- confirms that the profile has been created 
*/


							/* prevent_admin_profile_insert */

SELECT user_id 
FROM admin_profiles 
WHERE user_id = 4;
/* returns nothing
   -- the user does not have an admin profile 
*/

SELECT role_id 
FROM user_roles 
WHERE user_id = 4;
/* returns (4) 
  -- the user does not have the 'admin' role either
 */

INSERT INTO admin_profiles (user_id)
VALUES (4);
/* returns an error message 
 -- the trigger prevents creating the user's admin profile 
 	as the user does not have the 'admin' role
*/

INSERT INTO user_roles (user_id, role_id)
VALUES (4, 3);
/* adds the user the 'admin' role */

SELECT role_id FROM user_roles 
WHERE user_id = 4;
/* returns (3), (4) 
  -- confirms that the user has been assigned the 'admin' role
 */

INSERT INTO admin_profiles (user_id)
VALUES (4);
/* no an error message
  -- now that the user has the 'admin' role,
     the admin profile has been succesfully created
*/

SELECT user_id 
FROM admin_profiles 
WHERE user_id = 4;
/* returns (4)
  -- confirms that the profile has been created 
*/

     					/* prevent_user_insert_sra */

SELECT user_id 
FROM staff_regular_availability 
WHERE user_id = 1;
/* returns nothing 
  -- the user is not available at all
*/

SELECT role_id 
FROM user_roles 
WHERE user_id = 1;
/* returns (1) 
  -- role_id = 1 corresponds to 'customer',
     so the user does not have any employee role (i.e. 'admin', 'driver', or 'picker') 
*/

INSERT INTO staff_regular_availability (user_id, wday, interval_beginning, interval_end)
VALUES (1, 5, '08:30:00', '16:30:00');
/* returns an error message 
  -- the trigger prevents adding the user an availability interval
 	 as the user does not have an employee role
*/

INSERT INTO user_roles (user_id, role_id)
VALUES (1, 3);
/* adds the user the 'admin' role */

SELECT role_id 
FROM user_roles 
WHERE user_id = 1;
/* returns (1), (3) 
  -- confirms that the user has been added the 'admin' role
*/

INSERT INTO staff_regular_availability (user_id, wday, interval_beginning, interval_end)
VALUES (1, 5, '08:30:00', '16:30:00');
/* no an error message 
  -- now that the user has an employee role,
     the availability ingterval has been succesfully added
*/

SELECT user_id, wday, interval_beginning, interval_end 
FROM staff_regular_availability 
WHERE user_id = 1;
/* returns (1, 5, 08:30:00, 16:30:00) 
    -- confirms that the availbility interval has been added  
*/

     					/* prevent_user_insert_bp */

SELECT role_id 
FROM user_roles 
WHERE user_id = 2;
/* returns (1), (2) 
  -- role_id = 1 and role_id = 2 correspond to 'customer' and 'vendor' respectively,
     so the user does not have an employee role (i.e. 'admin', 'driver' or 'picker') 
*/

INSERT INTO blocked_periods (user_id, period_beginning, period_end)
VALUES (2, '2023-12-03 11:00:00', '2023-12-10 20:00:00');
/* returns an error message 
  -- the trigger prevents adding the user a blocked period
 	 as the user does not have an employee role
*/

INSERT INTO user_roles (user_id, role_id)
VALUES (2, 4);
/* adds the user the 'driver' role */

SELECT role_id 
FROM user_roles 
WHERE user_id = 2;
/* returns (1), (2), (4) 
  -- confirms that the user has been added the 'driver' role
 */

INSERT INTO blocked_periods (user_id, period_beginning, period_end)
VALUES (2, '2023-12-03 11:00:00', '2023-12-10 20:00:00');
/* no an error message 
  -- now that the user has an employee role,
     the blocked period has been succesfully added
*/

SELECT user_id, period_beginning, period_end 
FROM blocked_periods
WHERE user_id = 2;
/* returns (2, 2023-12-03 11:00:00, 2023-12-10 20:00:00) 
  -- confirms that the blocked period has been added 
*/

     					/* prevent_user_insert_ws */

SELECT wave_id, user_id FROM wave_available_staff
WHERE user_id = 6;
/* returns nothing 
  -- the user is not available for any wave
*/

SELECT role_id 
FROM user_roles 
WHERE user_id = 6;
/* returns nothing 
  -- the user does not have any role at all -- needless to say,
     an employee one (i.e. 'admin', 'driver' or 'picker') 
*/

INSERT INTO wave_available_staff (wave_id, user_id)
VALUES (1, 6);
/* returns an error message 
  -- the trigger prevents adding the user 
     to the employees available for the wave
 	 as the user does not have an employee role
*/

INSERT INTO user_roles (user_id, role_id)
VALUES (6, 5);
/* adds the user the 'driver' role */

SELECT role_id 
FROM user_roles 
WHERE user_id = 6;
/* returns (5) -- the user has been assigned the admin role
 */

INSERT INTO wave_available_staff (wave_id, user_id)
VALUES (1, 6);
/* no an error message 
  -- now that the user has an employee role,
     the the user is successfully added 
     to the employees available for the wave
*/

SELECT wave_id, user_id 
FROM wave_available_staff
WHERE user_id = 6;
/* returns (1, 6) 
  -- confirms that the user has been added 
     to the employees available for the wave
*/

					/* delete_user_from_ws */

SELECT role_id 
FROM user_roles 
WHERE user_id = 6;
/* returns (5) 
  -- the user has the 'picker' role 
*/

SELECT wave_id, user_id FROM wave_available_staff
WHERE user_id = 6;
/* returns (1, 6)  
  -- the user is available for the wave with wave_id = 1
*/

DELETE FROM user_roles
WHERE user_id = 6;
/* delete the user's roles */

SELECT wave_id, user_id 
FROM wave_available_staff
WHERE user_id = 6;
/* returns nothing 
  -- the user availability for the wave
     has been automatically cancelled by the trigger 
     as the user does not have any employee role anymore
*/

				  /* delete_user_from_bp */

SELECT role_id FROM user_roles 
WHERE user_id = 2;
/* returns (1), (2), (4) 
  -- the user has the 'driver' role and two non-employee roles 
*/

SELECT user_id, period_beginning, period_end 
FROM blocked_periods
WHERE user_id = 2;
/* returns (2,	2023-12-03 11:00:00,	2023-12-10 20:00:00)  
  -- the user has one blocked period */

DELETE FROM user_roles
WHERE user_id = 2 AND role_id = 1;
/* deletes one non-employee role of the user */

SELECT user_id, period_beginning, period_end 
FROM blocked_periods
WHERE user_id = 2;
/* returns (2,	2023-12-03 11:00:00,	2023-12-10 20:00:00) 
  -- the user's blocked periods have not changed
*/

DELETE FROM user_roles
WHERE user_id = 2 AND role_id = 4;
/* deletes the only non-employee role of the user*/

SELECT user_id, period_beginning, period_end FROM blocked_periods
WHERE user_id = 2;
/* returns nothing 
  -- the user's blocked period has been automatically deleted
     by the trigger
*/

				/* delete_user_from_sra */

SELECT role_id FROM user_roles 
WHERE user_id = 3;
/* returns (4), (5) 
  -- the user has the 'driver' and the 'picker' roles 
*/

SELECT user_id, wday, interval_beginning, interval_end 
FROM staff_regular_availability
WHERE user_id = 3;
/* returns (3,	3,	10:00:00,	14:00:00)
         , (3,	3,	15:00:00,	18:00:00)
         , (3,	4,	10:00:00,	18:00:00)  
   -- the user has three regular availability intervals */

DELETE FROM user_roles
WHERE user_id = 3 AND role_id = 4;
/* deletes the user's 'driver' role */

SELECT user_id, wday, interval_beginning, interval_end 
FROM staff_regular_availability
WHERE user_id = 3;
/* returns (3,	3,	10:00:00,	14:00:00)
         , (3,	3,	15:00:00,	18:00:00)
         , (3,	4,	10:00:00,	18:00:00)  
  -- no change, as the user still has an employee role ('picker')
*/

DELETE FROM user_roles
WHERE user_id = 3 AND role_id = 5;
/* deletes the last user's employee role */

SELECT user_id, wday, interval_beginning, interval_end 
FROM staff_regular_availability
WHERE user_id = 3;
/* returns nothing 
  -- all of the user's availability intervals have been automatically deleted
     by the trigger as the user does not have any employee role anymor */



