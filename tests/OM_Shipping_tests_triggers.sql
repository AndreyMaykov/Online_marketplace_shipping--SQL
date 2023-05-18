/********************* TRIGGERS *********************/
/* 
 * to get the test results specified below,
 * it is required that the DB tables has been populated
 * via executing the table_populating.sql script  
 */

							/* prevent_user_role_update */

SELECT role_id FROM user_roles 
WHERE id = 1;
/* returns 1 */

UPDATE user_roles 
SET role_id = 2 WHERE id = 1;

SELECT role_id FROM user_roles 
WHERE id = 1;
/* returns 2 */

UPDATE user_roles 
SET role_id = 1 WHERE id = 1;

SELECT role_id FROM user_roles 
WHERE id = 1;
/* returns 1 */

UPDATE user_roles 
SET role_id = 3 WHERE id = 1;
/* returns error message */

SELECT role_id FROM user_roles 
WHERE id = 4;
/* returns 4 */

UPDATE user_roles 
SET role_id = 1 WHERE id = 4;
/* returns error message */

UPDATE user_roles 
SET role_id = 5 WHERE id = 4;
/* returns error message */


							/* delete_picker_profile */

SELECT id, role_id FROM user_roles 
WHERE user_id = 4;
/* returns (5,	3)
 *       , (6,	4)
 * 		 , (7,	5)
 */

SELECT * FROM picker_profiles
WHERE user_id = 4;
/* returns (1, 4, 80, 1) */

SELECT * FROM driver_profiles
WHERE user_id = 4;
/* returns (2, 4, 5, 0, 80) */

SELECT * FROM admin_profiles
WHERE user_id = 4;
/* returns (1, 4) */

DELETE FROM user_roles
WHERE id = 7;

SELECT id, role_id FROM user_roles 
WHERE user_id = 4;
/* returns (5,	3)
 *       , (6,	4)
  -- the picker role has been deleted for user_id = 4 */

SELECT * FROM picker_profiles
WHERE user_id = 4;
/* returns nothing -- the record has been deleted */

SELECT * FROM driver_profiles
WHERE user_id = 4;
/* returns (2, 4, 5, 0, 80) -- no change */

SELECT * FROM admin_profiles
WHERE user_id = 4;
/* returns (1, 4) -- no change */

							/* delete_driver_profile */

SELECT id, role_id FROM user_roles 
WHERE user_id = 4;
/* returns (5,	3)
 *       , (6,	4)
 */

SELECT * FROM driver_profiles
WHERE user_id = 4;
/* returns (2, 4, 5, 0, 80) */


SELECT * FROM admin_profiles
WHERE user_id = 4;
/* returns (1, 4) */

DELETE FROM user_roles
WHERE id = 6;

SELECT id, role_id FROM user_roles 
WHERE user_id = 4;
/* returns (5,	3)
  -- the driver role has been deleted for user_id = 4 */

SELECT * FROM driver_profiles
WHERE user_id = 4;
/* returns nothing -- the record has been deleted */


SELECT * FROM admin_profiles
WHERE user_id = 4;
/* returns (1, 4) -- no change */

							/* delete_admin_profile */

SELECT id, role_id FROM user_roles 
WHERE user_id = 4;
/* returns (5,	3)
 */

SELECT * FROM admin_profiles
WHERE user_id = 4;
/* returns (1, 4) */


DELETE FROM user_roles
WHERE id = 5;

SELECT id, role_id FROM user_roles 
WHERE user_id = 4;
/* returns nothing
  -- the admin role has been deleted for user_id = 4 */

SELECT * FROM admin_profiles
WHERE user_id = 4;
/* returns nothing -- the record has been deleted */

							/* prevent_picker_profile_insert */

SELECT user_id, can_lift, gift_packing FROM picker_profiles 
WHERE user_id = 3;
/* returns nothing */

SELECT role_id FROM user_roles 
WHERE user_id = 3;
/* returns (4) -- the user does not have the picker role
 */

INSERT INTO picker_profiles (user_id, can_lift, gift_packing)
VALUES (3, 100, 0);
/* returns error message */

INSERT INTO user_roles (user_id, role_id)
VALUES (3, 5);
/* add the user the picker role */

SELECT role_id FROM user_roles 
WHERE user_id = 3;
/* returns (4),	(5) -- the user has been assigned the picker role
 */

INSERT INTO picker_profiles (user_id, can_lift, gift_packing)
VALUES (3, 100, 0);
/* no error message */

SELECT user_id, can_lift, gift_packing FROM picker_profiles 
WHERE user_id = 3;
/* returns (3, 100, 0) -- the profile has been added */

							/* prevent_driver_profile_insert */

SELECT user_id, licence_class, airbrake_certificate, can_lift FROM driver_profiles 
WHERE user_id = 4;
/* returns nothing */

SELECT role_id FROM user_roles 
WHERE user_id = 4;
/* returns nothing -- the user does not have the driver role */

INSERT INTO driver_profiles (user_id, licence_class, airbrake_certificate, can_lift)
VALUES (4, 4, 1, 80);
/* returns error message */

INSERT INTO user_roles (user_id, role_id)
VALUES (4, 4);
/* add the user the driver role */

SELECT role_id FROM user_roles 
WHERE user_id = 4;
/* returns (4) -- the user has been assigned the driver role
 */

INSERT INTO driver_profiles (user_id, licence_class, airbrake_certificate, can_lift)
VALUES (4, 4, 1, 80);
/* no error message */

SELECT user_id, licence_class, airbrake_certificate, can_lift FROM driver_profiles 
WHERE user_id = 4;
/* returns (4, 4, 1, 80) -- the profile has been added */


							/* prevent_admin_profile_insert */

SELECT user_id FROM admin_profiles 
WHERE user_id = 4;
/* returns nothing */

SELECT role_id FROM user_roles 
WHERE user_id = 4;
/* returns (4) -- the user does not have the admin role */

INSERT INTO admin_profiles (user_id)
VALUES (4);
/* returns error message */

INSERT INTO user_roles (user_id, role_id)
VALUES (4, 3);
/* add the user the admin role */

SELECT role_id FROM user_roles 
WHERE user_id = 4;
/* returns (3), (4) -- the user has been assigned the admin role
 */

INSERT INTO admin_profiles (user_id)
VALUES (4);
/* no error message */

SELECT user_id FROM admin_profiles 
WHERE user_id = 4;
/* returns (4) -- the profile has been added */

     					/* prevent_user_insert_sra */

SELECT user_id FROM staff_regular_availability 
WHERE user_id = 1;
/* returns nothing */

SELECT role_id FROM user_roles 
WHERE user_id = 1;
/* returns (1) -- the user does not have an employee role (admin, driver or picker) */

INSERT INTO staff_regular_availability (user_id, wday, interval_beginning, interval_end)
VALUES (1, 5, '08:30:00', '16:30:00');
/* returns error message */

INSERT INTO user_roles (user_id, role_id)
VALUES (1, 3);
/* add the user the admin role */

SELECT role_id FROM user_roles 
WHERE user_id = 1;
/* returns (1), (3) -- the user has been assigned the admin role
 */

INSERT INTO staff_regular_availability (user_id, wday, interval_beginning, interval_end)
VALUES (1, 5, '08:30:00', '16:30:00');
/* no error message */

SELECT user_id, wday, interval_beginning, interval_end FROM staff_regular_availability 
WHERE user_id = 1;
/* returns (1, 5, 08:30:00, 16:30:00) -- the interval has been added */

     					/* prevent_user_insert_bp */

SELECT role_id FROM user_roles 
WHERE user_id = 2;
/* returns (1), (2) -- the user does not have an employee role (admin, driver or picker) */

INSERT INTO blocked_periods (user_id, period_beginning, period_end)
VALUES (2, '2023-12-03 11:00:00', '2023-12-10 20:00:00');
/* returns error message */

INSERT INTO user_roles (user_id, role_id)
VALUES (2, 4);
/* add the user the driver role */

SELECT role_id FROM user_roles 
WHERE user_id = 2;
/* returns (1), (2), (4) -- the user has been assigned the admin role
 */

INSERT INTO blocked_periods (user_id, period_beginning, period_end)
VALUES (2, '2023-12-03 11:00:00', '2023-12-10 20:00:00');
/* no error message */

SELECT user_id, period_beginning, period_end FROM blocked_periods
WHERE user_id = 2;
/* returns (2, 2023-12-03 11:00:00, 2023-12-10 20:00:00) -- the period has been added */

     					/* prevent_user_insert_ws */

SELECT wave_id, user_id FROM wave_available_staff
WHERE user_id = 6;
/* returns nothing */

SELECT role_id FROM user_roles 
WHERE user_id = 6;
/* returns nothing -- the user does not have an employee role (admin, driver or picker) */

INSERT INTO wave_available_staff (wave_id, user_id)
VALUES (1, 6);
/* returns error message */

INSERT INTO user_roles (user_id, role_id)
VALUES (6, 5);
/* add the user the driver role */

SELECT role_id FROM user_roles 
WHERE user_id = 6;
/* returns (5) -- the user has been assigned the admin role
 */

INSERT INTO wave_available_staff (wave_id, user_id)
VALUES (1, 6);
/* no error message */

SELECT wave_id, user_id FROM wave_available_staff
WHERE user_id = 6;
/* returns (1, 6) -- the record has been added */

					/* delete_user_from_ws */

SELECT wave_id, user_id FROM wave_available_staff
WHERE user_id = 6;
/* returns (1, 6)  -- the user is available for the wave with wave_id = 1*/

SELECT role_id FROM user_roles 
WHERE user_id = 6;
/* returns (5) -- the user has the picker role */

DELETE FROM user_roles
WHERE user_id = 6;
/* delete the user's roles */

SELECT wave_id, user_id FROM wave_available_staff
WHERE user_id = 6;
/* returns nothing -- the user is is not available for any wave*/

				/* delete_user_from_bp */

SELECT user_id, period_beginning, period_end FROM blocked_periods
WHERE user_id = 2;
/* returns (2,	2023-12-03 11:00:00,	2023-12-10 20:00:00)  -- the user has one blocked period */

SELECT role_id FROM user_roles 
WHERE user_id = 2;
/* returns (1), (2), (4) -- the user has the driver role and two non-employee roles */

DELETE FROM user_roles
WHERE user_id = 2 AND role_id = 1;
/* delete one non-employee role of the user*/

SELECT user_id, period_beginning, period_end FROM blocked_periods
WHERE user_id = 2;
/* returns (2,	2023-12-03 11:00:00,	2023-12-10 20:00:00) -- the user's blocked periods remain unchanged*/

DELETE FROM user_roles
WHERE user_id = 2 AND role_id = 4;
/* delete the only non-employee role of the user*/

SELECT user_id, period_beginning, period_end FROM blocked_periods
WHERE user_id = 2;
/* returns nothing -- the user's blocked period has been removed*/

				/* delete_user_from_sra */

SELECT user_id, wday, interval_beginning, interval_end FROM staff_regular_availability
WHERE user_id = 3;
/* returns (3,	3,	10:00:00,	14:00:00)
         , (3,	3,	15:00:00,	18:00:00)
         , (3,	4,	10:00:00,	18:00:00)  -- the user has three regular availability intervals */

SELECT role_id FROM user_roles 
WHERE user_id = 3;
/* returns (4), (5) -- the user has the driver and the picker roles */

DELETE FROM user_roles
WHERE user_id = 3 AND role_id = 4;
/* delete the user's picker role */

SELECT user_id, wday, interval_beginning, interval_end FROM staff_regular_availability
WHERE user_id = 3;
/* returns (3,	3,	10:00:00,	14:00:00)
         , (3,	3,	15:00:00,	18:00:00)
         , (3,	4,	10:00:00,	18:00:00)  -- no change */

DELETE FROM user_roles
WHERE user_id = 3 AND role_id = 5;
/* delete the last user's employee role */

SELECT user_id, wday, interval_beginning, interval_end FROM staff_regular_availability
WHERE user_id = 3;
/* returns nothing -- all of the user's availability intervals have been deleted */


										/* ON DELETE CASCADE ON UPDATE CASCADE */

