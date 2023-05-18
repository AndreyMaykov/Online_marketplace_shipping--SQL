



/* 
	List of all users with common type user information
*/
DROP TABLE IF EXISTS users;
CREATE TABLE users (
      id INT NOT NULL AUTO_INCREMENT
	, first_name varchar(50) NOT NULL
	, last_name varchar(50) NULL
	, PRIMARY KEY (id)
);

/*
	List of roles a user can have (one user can have any number of roles);
	includes at least customers, vendors, pickers, drivers, admins 
*/
DROP TABLE IF EXISTS roles;
CREATE TABLE roles (
	  id INT NOT NULL AUTO_INCREMENT
	, role_name varchar(20) NOT NULL
	, CONSTRAINT role_duplicate_r UNIQUE (role_id)
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
	
/*
	List containing all the roles of each user
*/
DROP TABLE IF EXISTS user_roles;
CREATE TABLE user_roles (
	  id INT NOT NULL AUTO_INCREMENT
	, user_id INT NOT NULL
	, role_id	INT NOT NULL
	, CONSTRAINT user_role_duplicate_ur UNIQUE (user_id, role_id)
	, PRIMARY KEY (id)
	, FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE CASCADE ON UPDATE CASCADE
	, FOREIGN KEY (role_id) REFERENCES roles(id)
		ON DELETE CASCADE ON UPDATE CASCADE
	, CONSTRAINT ur_duplicate UNIQUE (user_id, role_id)
);


/* 
	Details specific to drivers 
*/
DROP TABLE IF EXISTS driver_profiles;
CREATE TABLE driver_profiles (
	  id INT NOT NULL AUTO_INCREMENT
	, user_id INT NOT NULL
	, licence_class CHAR(1) NOT NULL
	, airbrake_certificate BOOLEAN NOT NULL
	, can_lift INT NOT NULL -- maximum load weight (lb) the driver can lift manually
	, CONSTRAINT driver_duplicate_dp UNIQUE (user_id)
	, PRIMARY KEY (id)
	, FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE CASCADE ON UPDATE CASCADE
);

/* 
	Details specific to pickers
*/
DROP TABLE IF EXISTS picker_profiles;
CREATE TABLE picker_profiles (
	  id INT NOT NULL AUTO_INCREMENT
	, user_id INT NOT NULL
	, can_lift INT NOT NULL -- maximum load weight (lb) the picker can lift manually
	, gift_packing BOOLEAN NOT NULL -- flag indicating whether the picker can do gift packing
	, CONSTRAINT picker_duplicate_pp UNIQUE (user_id)
	, PRIMARY KEY (id)
	, FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE CASCADE ON UPDATE CASCADE
);

/* 
	Details specific to admins
*/
DROP TABLE IF EXISTS admin_profiles;
CREATE TABLE admin_profiles (
	  id INT NOT NULL AUTO_INCREMENT
	, user_id INT NOT NULL
	, CONSTRAINT admin_duplicate_ap UNIQUE (user_id)
	, PRIMARY KEY (id)
	, FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE CASCADE ON UPDATE CASCADE
);

/*
	List of all the vehicles used for pickup and delivery
*/
DROP TABLE IF EXISTS vehicles;
CREATE TABLE vehicles (
	  id INT NOT NULL AUTO_INCREMENT
	, vehicle_type VARCHAR(15) NOT NULL
	, payload_weight DECIMAL(7,2) NOT NULL -- max cargo capacity of the vehicle -- weight (kg)
	, payload_volume DECIMAL(5,2) NOT NULL -- max cargo capacity of the vehicle -- volume (m3)
	, vehicle_make VARCHAR(25) NULL
	, vehicle_model VARCHAR(50) NULL
	, vehicle_class CHAR(1) NULL
	, licence_number CHAR(10) NULL -- the vehicle's license plate number
	, vin CHAR(17) NULL -- the vehicle's identification number
	, owner_name VARCHAR(30) -- the name of the vehicle's registered owner
	, is_leased BOOLEAN NOT NULL -- flag indicating whether the vehicle is leased
	, lease_dealer VARCHAR(30) NULL
	, leased_from DATETIME NULL
	, leased_until DATETIME NULL
	, CONSTRAINT vin_duplicate_vce UNIQUE (vin)
	, CONSTRAINT licence_number UNIQUE (licence_number)
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

/*
	Availability of each picker/driver/administrator during a regular week 
	assuming that 
	1. the availability of the user (e.i. picker/driver/administrator) can vary from day to day during the week; 
	2. several time intervals of availability within a day are possible for one user;
*/
DROP TABLE IF EXISTS staff_regular_availability;
CREATE TABLE staff_regular_availability ( 
	  id INT NOT NULL AUTO_INCREMENT
	, user_id INT NOT NULL
	, wday INT(1) NOT NULL 					-- day of the week: day = 1 for Sunday, day = 2 for Monday, etc.								
	, interval_beginning TIME NOT NULL 		
	, interval_end TIME NOT NULL
	, CONSTRAINT interval_duplicate_sra UNIQUE (user_id, wday, interval_beginning, interval_end)
	, CHECK (interval_beginning < interval_end)
	, PRIMARY KEY (id)
	, FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE CASCADE ON UPDATE CASCADE
);

/*
	Supplementary table for determining staff availability;
	contains information regarding PLANNED periods when each user will be unavailable, 
	such as vacations, leaves for medical reasons, 
	holidays specific to religious or cultural traditions (e.g. hanukkah), etc.
	In the table, each user can have several blocked periods
*/
DROP TABLE IF EXISTS blocked_periods;
CREATE TABLE blocked_periods ( 
	  id INT NOT NULL AUTO_INCREMENT
	, user_id INT NOT NULL
	, period_beginning DATETIME NOT NULL 	
	, period_end DATETIME NOT NULL	
	, CONSTRAINT period_duplicate_bp UNIQUE (user_id, period_beginning, period_end)
	, CHECK (period_beginning < period_end)
	, PRIMARY KEY (id)
	, FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE CASCADE ON UPDATE CASCADE
);

/*
	For each vehicle: planned/expected periods when the vehicle is not in service (nis)
*/
DROP TABLE IF EXISTS vehicles_not_in_service;
CREATE TABLE vehicles_not_in_service (
	  id INT NOT NULL AUTO_INCREMENT
	, vehicle_id INT NOT NULL
	, nis_beginning DATETIME NOT NULL  	
	, nis_end DATETIME NOT NULL	
	, CONSTRAINT nis_duplicate_vnis UNIQUE (vehicle_id, nis_beginning, nis_end)	
	, CHECK (nis_beginning < nis_end)
	, PRIMARY KEY (id)
	, FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
		ON DELETE CASCADE ON UPDATE CASCADE
);


/*
							WAVE -- TIMINGS AND AVAILABLE RESOURCES
*/
/*
	Wave -- time timings
*/
DROP TABLE IF EXISTS wave_timings;
CREATE TABLE wave_timings (
	  id INT NOT NULL AUTO_INCREMENT
	, wave_beginning DATETIME NOT NULL
	, wave_cutoff DATETIME NOT NULL
	, CONSTRAINT wave_duplicate_wt UNIQUE (wave_beginning, wave_cutoff)
	, CHECK (wave_beginning < wave_cutoff)
	, PRIMARY KEY (id)
);

/*
	Available resources -- users and vehicles
*/
DROP TABLE IF EXISTS wave_available_staff;
CREATE TABLE wave_available_staff (
	  id INT NOT NULL AUTO_INCREMENT
	, wave_id INT NOT NULL
	, user_id INT NOT NULL
	, PRIMARY KEY (id)
	, CONSTRAINT wave_user UNIQUE (wave_id, user_id)
	, FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE CASCADE ON UPDATE CASCADE
	, FOREIGN KEY (wave_id) REFERENCES wave_timings(id)
		ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE IF EXISTS wave_available_vehicles;
CREATE TABLE wave_available_vehicles (
	  id INT NOT NULL AUTO_INCREMENT
	, wave_id INT NOT NULL
	, vehicle_id INT NOT NULL
	, PRIMARY KEY (id)
	, CONSTRAINT wave_vehicle UNIQUE (wave_id, vehicle_id)
	, FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
		ON DELETE CASCADE ON UPDATE CASCADE
	, FOREIGN KEY (wave_id) REFERENCES wave_timings(id)
		ON DELETE CASCADE ON UPDATE CASCADE
);




