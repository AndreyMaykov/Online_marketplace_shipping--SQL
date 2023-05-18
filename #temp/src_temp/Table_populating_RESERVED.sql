


/* 
	List of employees; contain details not specific to the employee's role(s) -- REQUIRES ADDING COLUMNS 
*/
/*
CREATE TABLE users (
      id INT NOT NULL AUTO_INCREMENT
	, first_name varchar(50) NOT NULL
	, last_name varchar(50) NULL
	, PRIMARY KEY (id)
);
*/
INSERT INTO users 
		(first_name, 	last_name)
	VALUES
		('Alexander', 	'the Great'),
		('Alexander', 	'the Small'),
		('Alexander', 	'the Middle'),
		('Samuel', 	  	'Clemens');

/*
	List of roles an employee can have (one employee can have any number of roles)
*/
/*
CREATE TABLE roles (
	  id INT NOT NULL AUTO_INCREMENT
	, role_name varchar(20) NOT NULL
	, PRIMARY KEY (id)
);
INSERT INTO roles
(role_name)
VALUES 
	  ('customer')
	, ('vendor')
	, ('admin')
	, ('driver')
	, ('picker');
*/
	
/*
	List containing all the roles of each employee
*/
/*
CREATE TABLE user_roles (
	  id INT NOT NULL AUTO_INCREMENT
	, user_id INT NOT NULL
	, role_id	INT NOT NULL
	, PRIMARY KEY (id)
	, FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE CASCADE ON UPDATE CASCADE
	, FOREIGN KEY (role_id) REFERENCES roles(id)
		ON DELETE CASCADE ON UPDATE CASCADE
);
*/

INSERT INTO employee_roles
		(user_id, 	role_id)
	VALUES
		(1,			3),
		(2, 		3),
		(2, 		4),
		(2, 		5),
		(3,			4),
		(3,			5),
		(4,			4);


/* 
	Details specific for drivers 
*/
/*
CREATE TABLE driver_profiles (
	  id INT NOT NULL AUTO_INCREMENT
	, user_id INT NOT NULL
	, licence_class CHAR(1) NOT NULL
	, airbrake_certificate BOOLEAN NOT NULL
	, can_lift INT NOT NULL -- maximum load weight (lb) the driver can lift manually
	, CONSTRAINT user_driver UNIQUE (user_id)
	, PRIMARY KEY (id)
	, FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE CASCADE ON UPDATE CASCADE
);
*/

INSERT INTO driver_profiles
		(user_id, 	licence_class, 	airbrake_certificate, 	can_lift)
	VALUES
		(1,			'7',			0,						5),
		(2, 		'5',			1,						500),
		(3,			'2',			1,						1000),
		(4,			'4',			1,						10);

/* 
	Details specific for pickers
*/
/*
CREATE TABLE picker_profiles (
	  id INT NOT NULL AUTO_INCREMENT
	, user_id INT NOT NULL
	, can_lift INT NOT NULL -- maximum load weight (lb) the picker can lift manually
	, gift_packing BOOLEAN NOT NULL -- flag indicating whether the picker can do gift packing
	, CONSTRAINT user_picker UNIQUE (user_id)
	, PRIMARY KEY (id)
	, FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE CASCADE ON UPDATE CASCADE
);
*/
INSERT INTO picker_profiles
		(employee_id, 	can_lift,	gift_packing	)
	VALUES
		(1,			5,					0),
		(2,			50,					1),
		(3, 		3, 					1);

/* 
	Details specific for admins -- REQUIRES ADDING COLUMNS 
*/
/*
CREATE TABLE admin_profiles (
	  id INT NOT NULL AUTO_INCREMENT
	, user_id INT NOT NULL
	, CONSTRAINT user_admin UNIQUE (user_id)
	, PRIMARY KEY (id)
	, FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE CASCADE ON UPDATE CASCADE
);
*/
INSERT INTO	admin_profiles	
		(employee_id)
	VALUES	
		(2);


/*
	List of all vehicles
*/
/*
CREATE TABLE vehicles (
	  id INT NOT NULL AUTO_INCREMENT
	, vehicle_type VARCHAR(15) NOT NULL
	, payload_weight DECIMAL(7,2) NOT NULL -- max cargo capacity of the vehicle -- weight (kg)
	, payload_volume DECIMAL(5,2) NOT NULL -- max cargo capacity of the vehicle -- volume (m3)
	, vehicle_make VARCHAR(25) NULL
	, vehicle_model VARCHAR(50) NULL
	, vehicle_class CHAR(1) NULL
	, license_number CHAR(10) NULL -- the vehicle's license plate number
	, vin CHAR(17) NULL -- the vehicle's identification number
	, owner_name VARCHAR(30) -- the name of the vehicle's registered owner
	, is_leased BOOLEAN NOT NULL -- flag indicating whether the vehicle is leased
	, lease_dealer VARCHAR(30) NULL
	, leased_from DATETIME NULL
	, leased_until DATETIME NULL
	, CONSTRAINT vin UNIQUE (vin)
	, CONSTRAINT licence_number UNIQUE (license_number)
	, CONSTRAINT lease_status -- ensure that, if the vehicle is NOT leased, all of lease_dealer, leased_from and lease_until are NULL
		CHECK (
			(CASE
				WHEN (is_leased = 0)
				THEN (
					CASE
						WHEN ((lease_dealer IS NULL) AND (leased_from IS NULL) AND (leased_until IS NULL))
						THEN 1
						ELSE 0
					END
				)
				ELSE 1
			END) =1
		)
	, PRIMARY KEY (id)
);
*/

/*
	Availability of each picker/driver/administrator during a regular week 
	assuming that 
	1. the availability of the user (e.i. picker/driver/administrator) can vary from day to day during the week; 
	2. several time intervals of availability within a day are possible for one user;
	3. exeptions from the regular availability can take place temporarily for any interval (field: exceptions), e.g. "Will be 5 min. late";
	4. the user can be temporarily unavailable for the interval.
*/
/*
CREATE TABLE staff_regular_availability ( 
	  id INT NOT NULL AUTO_INCREMENT
	, user_id INT NOT NULL
	, wday INT(1) NOT NULL 					-- day of the week: day = 1 for Sunday, day = 2 for Monday, etc.								
	, interval_beginning TIME NOT NULL 		
	, interval_end TIME NOT NULL							
	, CHECK (interval_beginning < interval_end)
	, CONSTRAINT user_wday UNIQUE (user_id, wday)
	, PRIMARY KEY (id)
	, FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE CASCADE ON UPDATE CASCADE
);
*/

INSERT INTO staff_regular_availability 
		(user_id,	wday,	interval_beginning_time,	interval_end_time)
	VALUES	
		(1,				1,				'09:00:00',					"12:00:00"),
		(1,				3,				'15:00:00',					"18:00:00"),
		(2,				1,				'09:00:00',					"20:00:00"),
		(2,				2,				'10:00:00',					"18:00:00"),
		(2,				3,				'10:00:00',					"18:00:00"),
		(2,				4,				'10:00:00',					"18:00:00"),
		(2,				5,				'10:00:00',					"18:00:00"),
		(2,				6,				'10:00:00',					"18:00:00"),
		(2,				7,				'10:00:00',					"18:00:00"),
		(1, 			7, 				'10:30', 					'11:00'),
		(1, 			7, 				'11:30', 					'12:00'),
		(1, 			7, 				'12:30', 					'21:30');

/*
	Supplementary table for determining staff availability;
	contains information regarding the PLANNED periods when each employee will be unavailable, 
	such as vacations, leaves for medical reasons, 
	holidays specific to religious or cultural traditions (e.g. hanuka), etc.
	In the table, each employee can have several blocked periods
*/
/*
CREATE TABLE blocked_periods ( 
	  id INT NOT NULL AUTO_INCREMENT
	, user_id INT NOT NULL
	, period_beginnig DATETIME NOT NULL 	
	, period_end DATETIME NOT NULL			
	, CHECK (period_beginnig < period_end)
	, PRIMARY KEY (id)
	, FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE CASCADE ON UPDATE CASCADE
);
*/

INSERT INTO blocked_periods 
		(user_id,	blocked_period_beginning,	blocked_period_end)
	VALUES
		(1,			'2023-12-30 00:00:00',			'2023-12-29 12:00:00'),
		(1,			'2024-12-30 00:00:00',			'2024-12-29 03:00:00'),
		(2,			'2019-05-05 00:00:00',			'2019-05-08 03:00:00');
		
/*
	For each vehicle: planned/expected periods when the vehicle is not in service (nis)
*/
/*
CREATE TABLE vehicles_not_in_service (
	  id INT NOT NULL AUTO_INCREMENT
	, vehicle_id INT NOT NULL
	, nis_beginning DATETIME NOT NULL  	
	, nis_end DATETIME NOT NULL			
	, CHECK (nis_beginning < nis_end)
	, PRIMARY KEY (id)
	, FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
		ON DELETE CASCADE ON UPDATE CASCADE
);
*/

/*
							TABLES FOR WAVE PLANNING
*/
/*
	Waves -- time parameters
*/
/*
CREATE TABLE wave_timings (
	  id INT NOT NULL AUTO_INCREMENT
	, wave_beginning DATETIME NOT NULL
	, wave_cutoff DATETIME NOT NULL
	, CHECK (wave_beginning < wave_cutoff)
	, PRIMARY KEY (id)
);
*/

INSERT INTO slot_timings 
		(slot_beginning_time,	slot_end_time)
	VALUES	
		('2020-06-07 09:00',		'2020-06-07 21:00'),  
		('2023-06-07 09:00',		'2023-06-07 21:00'),
		('2023-06-08 09:00',		'2023-06-08 11:00'),
		('2023-06-08 12:00',		'2023-06-08 17:00');


