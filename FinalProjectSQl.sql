CREATE DATABASE IF NOT EXISTS restaurant_reservations;
USE restaurant_reservations;

CREATE TABLE IF NOT EXISTS Customers (
    customerId INT NOT NULL AUTO_INCREMENT,
    customerName VARCHAR(45) NOT NULL,
    contactInfo VARCHAR(200),
    PRIMARY KEY (customerId)
);

INSERT INTO Customers (customerName)
VALUES ('Derek Jeter'),
       ('Shohei Otani'), 
       ('Aaron Judge');

CREATE TABLE IF NOT EXISTS Reservations (
    reservationId INT NOT NULL AUTO_INCREMENT,
    customerId INT NOT NULL,
    reservationTime DATETIME NOT NULL,
    numberOfGuests INT NOT NULL,
    specialRequests VARCHAR(200),
    PRIMARY KEY (reservationId),
    FOREIGN KEY (customerId) REFERENCES Customers(customerId)
);

INSERT INTO Reservations (customerId, reservationTime, numberOfGuests, specialRequests)
VALUES (1, '2024-05-22 11:00:00', 2, 'Anniversity'),
       (2, '2024-05-22 11:30:00', 3, 'Graduation'),
       (3, '2024-05-22 12:00:00', 4, 'Birthday');

CREATE TABLE IF NOT EXISTS DiningPreferences (
    preferenceId INT NOT NULL AUTO_INCREMENT,
    customerId INT NOT NULL,
    favoriteTable VARCHAR(45),
    dietaryRestrictions VARCHAR(200),
    PRIMARY KEY (preferenceId),
    FOREIGN KEY (customerId) REFERENCES Customers(customerId)
);

INSERT INTO DiningPreferences (customerId, dietaryRestrictions)
VALUES (1, 'Lactose Intolerant'), 
       (2, 'Gluten-Free'),
       (3, 'Nut Free'),
       (1, 'No Pork');

SHOW TABLES;

DELIMITER $$

CREATE PROCEDURE findReservations(IN custId INT)
BEGIN
    SELECT * FROM Reservations
    WHERE customerId = custId;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE addSpecialRequest(IN resId INT, IN requests VARCHAR(200))
BEGIN
    UPDATE Reservations
    SET specialRequests = requests
    WHERE reservationId = resId;
END$$

DELIMITER ;

-- Helper procedure to get or create a customer
DELIMITER $$

CREATE PROCEDURE getOrCreateCustomer(IN custName VARCHAR(45), IN contact VARCHAR(200), OUT custId INT)
BEGIN
    DECLARE v_customerId INT;
    -- Check if customer exists
    SELECT customerId INTO v_customerId 
    FROM Customers 
    WHERE customerName = custName AND contactInfo = contact 
    LIMIT 1;

    -- If not found, add the customer
    IF v_customerId IS NULL THEN
        INSERT INTO Customers (customerName, contactInfo)
        VALUES (custName, contact);
        SET v_customerId = LAST_INSERT_ID();
    END IF;

    SET custId = v_customerId;
END$$

DELIMITER ;

-- Main procedure to add a reservation
DELIMITER $$

CREATE PROCEDURE addReservation(IN custName VARCHAR(45), IN contact VARCHAR(200), IN resTime DATETIME, IN numGuests INT, IN specRequests VARCHAR(200))
BEGIN
    DECLARE v_customerId INT;
    CALL getOrCreateCustomer(custName, contact, v_customerId);

    -- Add the reservation
    INSERT INTO Reservations (customerId, reservationTime, numberOfGuests, specialRequests)
    VALUES (v_customerId, resTime, numGuests, specRequests);
END$$

DELIMITER ;
