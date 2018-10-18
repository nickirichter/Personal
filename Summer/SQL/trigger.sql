use school
delimiter //
CREATE TRIGGER upd_grades BEFORE UPDATE ON Enrollment
FOR EACH ROW
BEGIN
	IF NEW.Grade NOT IN ('A','A-','B+','B','B-','C+','C',
    'C-','D+','D','D-','F','W') THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Invalid Grade';
	END IF;
END;
//
