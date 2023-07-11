/*

Object: SQL script 

MySQL version: 8.0

Author: Andrey Maykov

Script Date: 2023-07-05

Description:
 
The script demonstrates maintaing the project's data integrity
through the schema constraints

To get the results specified below, it is required that: 
  a. the DB tables has been populated
     by executing the table_populating.sql script;
  b. the statements below are executed 
	 in the same order as they are arranged here.    

*/

							/* wave_timings --> wave_available_staff */

SELECT * FROM wave_timings
ORDER BY id; 
/* returns
  (1,	2023-12-19 09:00:00,	2023-12-19 16:00:00)
, (2,	2023-12-20 10:00:00,	2023-12-20 14:00:00)
, (3,	2023-06-08 16:00:00,	2023-06-08 19:00:00)
*/

SELECT wave_id, user_id FROM wave_available_staff;
/* returns (2,	3) */


UPDATE wave_timings 
SET id = 4 WHERE id = 2;

SELECT * FROM wave_timings
ORDER BY id;
/* returns
  (1,	2023-12-19 09:00:00,	2023-12-19 16:00:00)
, (3,	2023-06-08 16:00:00,	2023-06-08 19:00:00)
, (4,	2023-12-20 10:00:00,	2023-12-20 14:00:00)
*/

SELECT wave_id, user_id FROM wave_available_staff;
/* returns (4,	3) */

DELETE FROM wave_timings 
WHERE id = 4;

SELECT * FROM wave_timings
ORDER BY id;
/* returns
  (1,	2023-12-19 09:00:00,	2023-12-19 16:00:00)
, (3,	2023-06-08 16:00:00,	2023-06-08 19:00:00)
*/

SELECT wave_id, user_id 
FROM wave_available_staff;
/* returns nothing */


INSERT INTO wave_available_staff (wave_id, user_id)
VALUES (2,	3);
/* returns an error message, as wave_timings does not containg a wave with id = 2 */

INSERT INTO wave_timings (id, wave_beginning, wave_cutoff)
VALUES (2,	'2023-12-20 10:00:00',	'2023-12-20 14:00:00');

INSERT INTO wave_available_staff (wave_id, user_id)
VALUES (2,	3);
/* no an error message */

SELECT wave_id, user_id 
FROM wave_available_staff;
/* returns (2, 3) */


							/* users 	--> user_roles, 
							 * 				driver_profiles, 
							 * 				staff_regular_availability, 
							 * 				blocked_periods, 
							 * 				wave_available_staff
						     */

SELECT * FROM users
WHERE id = 3;
/* returns (3,	Armand,	Duplantis) */


SELECT user_id, role_id 
FROM user_roles 
WHERE user_id = 3;
/* returns (3,	4) */

SELECT user_id, licence_class 
FROM driver_profiles
WHERE user_id = 3;
/* returns (3, 3) */

SELECT user_id, wday FROM staff_regular_availability
WHERE user_id = 3;
/* returns 
  (3,	3)
  (3,	3)
  (3,	4) 
 */

SELECT id, user_id 
FROM blocked_periods
WHERE user_id = 3;
/* returns 
 *   (1, 3)
 * , (2, 3) 
 */

SELECT wave_id, user_id 
FROM wave_available_staff
WHERE user_id = 3;
/* returns 
 *   (2, 3) 
 */

DELETE FROM users
WHERE id = 3;

SELECT * FROM users
WHERE id = 3;
/* returns nothing -- the user has been manually deleted from the users table*/


SELECT user_id, role_id 
FROM user_roles 
WHERE user_id = 3;
/* returns nothing -- the user has been automatically deleted from use_roles */

SELECT user_id, licence_class 
FROM driver_profiles
WHERE user_id = 3;
/* returns nothing -- the user has been automatically deleted from driver_profiles */

SELECT user_id, wday 
FROM staff_regular_availability
WHERE user_id = 3;
/* returns nothing -- the user has been automatically deleted from staf_regular_availability */

SELECT id, user_id 
FROM blocked_periods
WHERE user_id = 3;
/* returns nothing -- the user has been automatically deleted from blocked_periods */

SELECT wave_id, user_id 
FROM wave_available_staff
WHERE user_id = 3;
/* returns nothing -- the user has been automatically deleted from wave_available_staff */



							/* users 	--> admin_profiles, 
							 * 				picker_profiles
						     */

SELECT * FROM users
WHERE id = 4;
/* returns (4,	Alexander,	the Great) */


SELECT * FROM admin_profiles
WHERE user_id = 4;
/* returns (1,	4) */

SELECT * FROM picker_profiles
WHERE user_id = 4;
/* returns (1,	4,	80,	1) */

DELETE FROM users
WHERE id = 4;

SELECT * FROM admin_profiles
WHERE user_id = 4;
/* returns nothing -- the user has been manually deleted from admin_profiles */

SELECT * FROM picker_profiles
WHERE user_id = 4;
/* returns nothing -- the user has been automatically deleted from picker_profiles*/


						/* vehicles 	--> vehicles_not_in_service, 
							 * 				wave_available_vehicles
						     */

INSERT INTO vehicles_not_in_service 
		  (vehicle_id, nis_beginning, nis_end)
VALUES
		  (3, '2023-10-19 00:00', 	'2023-11-19 00:00');
		 
INSERT INTO wave_available_vehicles 	
		  (wave_id, vehicle_id)
VALUES
		  (2, 2)
		, (3, 3)
;

SELECT id FROM vehicles
ORDER BY id;
/* returns 
 * 	(1)
 *  (2)
 * 	(3) 
 */

SELECT vehicle_id FROM vehicles_not_in_service;
/* returns (3) 
 */

SELECT wave_id, vehicle_id 
FROM wave_available_vehicles
WHERE vehicle_id = 3;
/* returns (3, 3) */

DELETE FROM vehicles 
WHERE id = 3;

SELECT id FROM vehicles
WHERE id = 3
ORDER BY id;
/* returns nothing -- the vehicle has been manually deleted form vehicles_not_in_service */

SELECT vehicle_id FROM vehicles_not_in_service;
/* returns nothing -- the vehicle has been automatically deleted form vehicles_not_in_service */

SELECT wave_id, vehicle_id FROM wave_available_vehicles
WHERE vehicle_id = 3;
/* returns nothing -- the vehicle has been deleted form vehicles_not_in_service */

						/* wave_timings 	--> wave_available_vehicles */

DELETE FROM wave_timings 
WHERE id = 2; 

SELECT id FROM wave_timings
ORDER BY id;
/* returns 
 * 	(1)
 * 	(3) 
 -- the wave with id = 2 has been manually deleted
 */

SELECT wave_id, vehicle_id 
FROM wave_available_vehicles
WHERE wave_id = 2;
/* returns nothing -- the wave has been automatically deleted from wave_available_vehicles */
