USE MVM_Shipping;

SELECT CONNECTION_ID();

SHOW CREATE TABLE users;

SELECT * FROM users;

DELETE FROM users WHERE id = 3;

SELECT * FROM users;

SELECT * FROM wave_timings;

INSERT INTO users 
		(first_name, 	last_name)
	VALUES
		('Samuel', 	'Clemens')
;
		
DELETE FROM users
WHERE last_name = 'Clemens';

