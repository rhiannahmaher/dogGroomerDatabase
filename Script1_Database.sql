/*
	Name: Rhiannah Maher
    Student Number: W20085527
    
    Script One: Includes database design elements including creation of database, tables, columns, views, indexes, and triggers.
				Tables have been populated with records.
                Several users have been created with varying permissions.
*/

DROP DATABASE IF EXISTS dog_groomer;
CREATE DATABASE IF NOT EXISTS dog_groomer;
USE dog_groomer;

-- Tables created in Dog Groomer Database

-- Customer Table
CREATE TABLE IF NOT EXISTS Customer
(
	CustomerId INT AUTO_INCREMENT,
    FName VARCHAR(20),
    LName VARCHAR(20),
    Street VARCHAR(20),
    Town VARCHAR(20),
    County VARCHAR(20),
    Email VARCHAR(30),
    Added DATE NULL,
	IsDeleted TINYINT(1) DEFAULT 0,
    PRIMARY KEY(CustomerId)
);

-- Customer Phones Table: Accounts for multi-valued attribute as a Customer can have 1-2 phone numbers
CREATE TABLE IF NOT EXISTS CustomerPhones
(
	PhoneNo VARCHAR(15),
	CustomerId INT NOT NULL,
	PRIMARY KEY(PhoneNo),
	CONSTRAINT fk_CustomerId 
		FOREIGN KEY(CustomerId) 
		REFERENCES Customer(CustomerId)
		ON UPDATE NO ACTION
		ON DELETE CASCADE
);

-- Payments Table
CREATE TABLE IF NOT EXISTS Payment
(
	PaymentId INT AUTO_INCREMENT,
	PaymentDate DATE,
	Amount DECIMAL(5,2),
	CustomerId INT, 
	PRIMARY KEY(PaymentId),
	CONSTRAINT fk_Payment_CustomerId 
		FOREIGN KEY(CustomerId)
		REFERENCES Customer(CustomerId)
		ON UPDATE NO ACTION
		ON DELETE SET NULL
);

-- Dog Breed Table
CREATE TABLE IF NOT EXISTS Breed
(
	BreedId INT AUTO_INCREMENT, 
	BreedName VARCHAR(30),
    Size ENUM('XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL'),
    HairType ENUM('Hairless', 'Smooth', 'Short', 'Wire', 'Curly', 'Double', 'Long'),
    PRIMARY KEY(BreedId)
);

-- Dog Table
CREATE TABLE IF NOT EXISTS Dog
(
	DogId INT AUTO_INCREMENT,
    DogName VARCHAR(15),
    Age VARCHAR(15),
    CustomerId INT NOT NULL,
    BreedId INT NULL,
    Added DATE NULL,
    IsDeleted TINYINT(1) DEFAULT 0,
    PRIMARY KEY(DogId),
    CONSTRAINT fk_Dog_CustomerId
		FOREIGN KEY(CustomerId)
        REFERENCES Customer(CustomerId)
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
	CONSTRAINT fk_Dog_BreedId
		FOREIGN KEY(BreedId)
        REFERENCES Breed(BreedId)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- Appointment Table
CREATE TABLE IF NOT EXISTS Appointment
(
	ReferenceNo INT AUTO_INCREMENT,
    AppDate DATE NOT NULL,
    AppTime TIME NOT NULL, 
    DogId INT NOT NULL, 
    IsCancelled TINYINT(1) DEFAULT 0,
    CancelDate DATE NULL,
    PRIMARY KEY(ReferenceNo),
    CONSTRAINT fk_App_DogId
		FOREIGN KEY(DogId)
		REFERENCES Dog(DogId)
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

-- Staff Table
CREATE TABLE IF NOT EXISTS Staff
(
	StaffId INT AUTO_INCREMENT,
    PPSNo VARCHAR(9) NOT NULL,
    FName VARCHAR(20),
    LName VARCHAR(20),
    Street VARCHAR(20),
    Town VARCHAR(20),
    County VARCHAR(20),
    RatePerHour DECIMAL(6,2),
    Manager INT NULL,
    PRIMARY KEY(StaffId),
    CONSTRAINT fk_Manager
		FOREIGN KEY(Manager)
		REFERENCES Staff(StaffId)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

-- Staff Phones Table: Accounts for multi-valued attribute as a Staff member can have 1-2 phone numbers
CREATE TABLE IF NOT EXISTS StaffPhones
(
	PhoneNo VARCHAR(15),
    StaffId INT NOT NULL,
    PRIMARY KEY(PhoneNo),
    CONSTRAINT fk_StaffId
		FOREIGN KEY(StaffId)
		REFERENCES Staff(StaffId)
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

-- Handles Table: Accounts for many-to-many relationship between Staff & Appointment
CREATE TABLE IF NOT EXISTS Handles
(
	ReferenceNo INT NOT NULL,
    StaffId INT NOT NULL,
    AppLength TIME,
    StaffRole VARCHAR(20),
    PRIMARY KEY(ReferenceNo, StaffId),
    CONSTRAINT fk_Handles_ReferenceNo
		FOREIGN KEY(ReferenceNo)
        REFERENCES Appointment(ReferenceNo)
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
	CONSTRAINT fk_Handles_StaffId
		FOREIGN KEY(StaffId)
        REFERENCES Staff(StaffId)
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

-- Grooming Services Table
CREATE TABLE IF NOT EXISTS GroomingServices
(
	ServiceId INT AUTO_INCREMENT,
    ServiceName VARCHAR(30),
    PriceSmall DECIMAL(5,2),
    PriceMedium DECIMAL(5,2),
    PriceLarge DECIMAL(5,2),
    PRIMARY KEY(ServiceId)
);

-- Includes Table: Accounts for many-to-many relationship between Appointment & GroomingServices
CREATE TABLE IF NOT EXISTS Includes
(
	ReferenceNo INT NOT NULL,
    ServiceId INT NOT NULL,
    PRIMARY KEY(ReferenceNo, ServiceId),
    CONSTRAINT fk_Includes_ReferenceNo
		FOREIGN KEY(ReferenceNo)
        REFERENCES Appointment(ReferenceNo)
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
	CONSTRAINT fk_Includes_ServiceId
		FOREIGN KEY(ServiceId)
		REFERENCES GroomingServices(ServiceId)
        ON UPDATE NO ACTION 
        ON DELETE CASCADE
);

-- Stock Table
CREATE TABLE IF NOT EXISTS Stock
(
	ProductId INT AUTO_INCREMENT,
    ProductType ENUM('Accessory', 'Consumable', 'Equipment'),
    Quantity TINYINT,
    Price DECIMAL(6,2),
    PRIMARY KEY(ProductId)
);

-- Accessory Table: Inherits ProductId from Stock Table
CREATE TABLE IF NOT EXISTS Accessory
(
	ProductId INT NOT NULL,
    ProductName VARCHAR(20),
    Size ENUM('XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL'),
    PRIMARY KEY(ProductId),
    CONSTRAINT fk_Accessory_ProductId
		FOREIGN KEY(ProductId)
        REFERENCES Stock(ProductId)
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

-- Consumable Table: Inherits ProductId from Stock Table
CREATE TABLE IF NOT EXISTS Consumable
(
	ProductId INT NOT NULL,
    ProductName VARCHAR(30),
    ExpiryDate DATE NOT NULL,
    PRIMARY KEY(ProductId),
    CONSTRAINT fk_Consumable_ProductId
		FOREIGN KEY(ProductId)
        REFERENCES Stock(ProductId)
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

-- Equipment Table: Inherits ProductId from Stock Table
CREATE TABLE IF NOT EXISTS Equipment
(
	ProductId INT NOT NULL,
    ProductName VARCHAR(20),
    OrderDate DATE NOT NULL,
    ServiceDate DATE NULL,
    PRIMARY KEY(ProductId),
    CONSTRAINT fk_Equipment_ProductId
		FOREIGN KEY(ProductId)
        REFERENCES Stock(ProductId)
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

-- Uses Table: Accounts for many-to-many relationship between GroomingServices & Stock
CREATE TABLE IF NOT EXISTS Uses
(
	ServiceId INT NOT NULL,
    ProductId INT NOT NULL,
    PRIMARY KEY(ServiceId, ProductId),
    CONSTRAINT fk_Uses_ServiceId
		FOREIGN KEY(ServiceId)
        REFERENCES GroomingServices(ServiceId)
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
	CONSTRAINT fk_Uses_ProductId
		FOREIGN KEY(ProductId)
        REFERENCES Stock(ProductId)
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

-- Supplier Table
CREATE TABLE IF NOT EXISTS Supplier
(
	SupplierId INT AUTO_INCREMENT,
    SupplierName VARCHAR(35),
    Street VARCHAR(30),
    Town VARCHAR(20),
    County VARCHAR(20),
    Email VARCHAR(35),
    PRIMARY KEY(SupplierId)
);

-- Supplier Phones Table: Accounts for multi-valued attribute as a Supplier can have 1-2 phone numbers
CREATE TABLE IF NOT EXISTS SupplierPhones
(
	PhoneNo VARCHAR(15),
	SupplierId INT NOT NULL,
	PRIMARY KEY(PhoneNo),
	CONSTRAINT fk_SupplierId 
		FOREIGN KEY(SupplierId) 
		REFERENCES Supplier(SupplierId)
		ON UPDATE NO ACTION
		ON DELETE CASCADE
);

-- Order Details Table
CREATE TABLE IF NOT EXISTS OrderDetails
(
	OrderNo INT AUTO_INCREMENT,
    OrderDate DATE NOT NULL,
    DeliveryDate DATE NULL,
    Quantity TINYINT, 
    SupplierId INT NOT NULL,
    PRIMARY KEY(OrderNo),
    CONSTRAINT fk_Order_SupplierId
		FOREIGN KEY(SupplierId)
        REFERENCES Supplier(SupplierId)
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

-- Carries Table: Accounts for many-to-many relationship between OrderDetails & Stock
CREATE TABLE IF NOT EXISTS Carries
(
	OrderNo INT NOT NULL,
    ProductId INT NOT NULL,
    PRIMARY KEY(OrderNo, ProductId),
    CONSTRAINT fk_Contains_OrderNo
		FOREIGN KEY(OrderNo)
        REFERENCES OrderDetails(OrderNo)
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
	CONSTRAINT fk_Contains_ProductId
		FOREIGN KEY(ProductId)
		REFERENCES Stock(ProductId)
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

-- Views

-- Combines Customer's with their associated Dogs
CREATE VIEW DogOwners AS
	SELECT CONCAT(FName, ' ', LName) AS FullName, DogId, DogName
		FROM Customer JOIN Dog
		ON Customer.CustomerId = Dog.CustomerId;

-- Combines Customer and CustomerPhones to filter contact information
CREATE VIEW CustomerContactInfo AS
	SELECT CONCAT(FName, ' ', LName) AS FullName, PhoneNo, Email
	FROM Customer JOIN CustomerPhones
	ON Customer.CustomerId = CustomerPhones.CustomerId;

-- Filters Appointments in the database that are greater than the current time and date
CREATE VIEW UpcomingAppointments AS
	SELECT ReferenceNo, AppDate, AppTime, DogId
	FROM Appointment 
	WHERE CONCAT(AppDate, ' ', AppTime) > NOW();
    
-- Combines Staff and StaffPhones to filter contact information
CREATE VIEW StaffContactInfo AS
	SELECT CONCAT(FName, ' ', LName) AS FullName, PhoneNo
    FROM Staff JOIN StaffPhones
    ON Staff.StaffId = StaffPhones.StaffId;

-- Calculates Staff's TotalHoursWorked
CREATE VIEW StaffHoursWorked AS
	-- Converts AppLength to seconds, then hours, then multiples by Staff's RatePerHour and rounds to 2 decimal places [Ref #1] [Ref #2]
	SELECT Handles.StaffId, CONCAT(FName, ' ', LName) AS FullName, Handles.ReferenceNo, AppDate, AppLength, RatePerHour, ROUND(TIME_TO_SEC(AppLength) / 3600 * RatePerHour, 2) AS TotalPayEarned 
    FROM Staff JOIN Handles
    ON Staff.StaffId = Handles.StaffId
    JOIN Appointment
    ON Handles.ReferenceNo = Appointment.ReferenceNo;

-- Orders Internal Stock items by Quantity
CREATE VIEW InternalStock AS
    SELECT Stock.ProductId, ProductName, 'Consumable' AS ProductType, Quantity
	FROM Stock 
	JOIN Consumable ON Stock.ProductId = Consumable.ProductId
	WHERE Stock.ProductType = 'Consumable'
    -- Combines results of ProductName from Consumable & Equipment under the same column [Ref #3]
	UNION
    SELECT Stock.ProductId, ProductName, 'Equipment' AS ProductType, Quantity
	FROM Stock
	JOIN Equipment ON Stock.ProductId = Equipment.ProductId
	WHERE Stock.ProductType = 'Equipment'
	ORDER BY Quantity;

-- Orders Sales Stock by Quantity 
CREATE VIEW SalesStock AS
	SELECT Accessory.ProductId, Accessory.ProductName, 'Accessory' AS ProductType, Quantity
	FROM Stock JOIN Accessory
    ON Stock.ProductId = Accessory.ProductId
	ORDER BY Quantity;

-- Returns Equipment by ServiceDate 
CREATE VIEW EquipmentService AS
	SELECT ProductId, ProductName, ServiceDate
    FROM Equipment
    -- Filters equipment whose service date is over 30 days
    WHERE DATEDIFF(CURDATE(), ServiceDate) >= 30
    ORDER BY ServiceDate;

-- Orders Consumable by ExpiryDate >= CURDATE
CREATE VIEW ExpiredConsumables AS
	SELECT ProductId, ProductName, ExpiryDate
    FROM Consumable
    WHERE ExpiryDate >= CURDATE()
    ORDER BY ExpiryDate;

-- Merges Suppliers with their associated Orders
CREATE VIEW OrdersBySuppliers AS
	SELECT SupplierName, OrderNo, OrderDate, DeliveryDate, Quantity
	FROM Supplier JOIN OrderDetails
	ON Supplier.SupplierId = OrderDetails.SupplierId
	ORDER BY SupplierName;

-- Combines Supplier and SupplierPhones to filter contact information
CREATE VIEW SupplierContactInfo AS
	SELECT SupplierName, PhoneNo, Email
    FROM Supplier JOIN SupplierPhones
    ON Supplier.SupplierId = SupplierPhones.SupplierId;

-- Filters Orders not delivered/with a NULL DeliveryDate
CREATE VIEW DueDeliveries AS
	SELECT OrderNo, OrderDate, Quantity, SupplierName
	FROM OrderDetails JOIN Supplier
	ON OrderDetails.SupplierId = Supplier.SupplierId
	-- Uses IS NULL clause to return orders with no DeliveryDate
	WHERE DeliveryDate IS NULL; 

-- Indexes

CREATE INDEX CustomerFNameInd ON Customer(FName);
CREATE INDEX CustomerLNameInd ON Customer(LName);
CREATE INDEX CustomerEmailInd ON Customer(Email);

CREATE INDEX CustomerPhoneInd ON CustomerPhones(CustomerId);

CREATE INDEX PaymentIdInd ON Payment(PaymentId);
CREATE INDEX PaymentDateInd ON Payment(PaymentDate);

CREATE INDEX DogNameInd ON Dog(DogName);
CREATE INDEX DogCustomerIdInd ON Dog(CustomerId);
CREATE INDEX DogBreedIdInd ON Dog(BreedId);

CREATE INDEX BreedNameInd ON Breed(BreedName);
CREATE INDEX BreedSizeInd ON Breed(Size);

CREATE INDEX AppDateInd ON Appointment(AppDate);
CREATE INDEX AppDogIdInd ON Appointment(DogId);
CREATE INDEX AppCancelInd ON Appointment(IsCancelled);

CREATE INDEX HandlesStaffInd ON Handles(StaffId);
CREATE INDEX HandlesApp ON Handles(ReferenceNo);

CREATE INDEX StaffFNameInd ON Staff(FName);
CREATE INDEX StaffLNameInd ON Staff(LName);
CREATE INDEX StaffPayInd ON Staff(RatePerHour);

CREATE INDEX StaffPhoneInd ON StaffPhones(StaffId);

CREATE INDEX IncludesServiceInd ON Includes(ServiceId);
CREATE INDEX IncludesAppInd ON Includes(ReferenceNo);

CREATE INDEX GroomingServicesNameInd ON GroomingServices(ServiceName);

CREATE INDEX UsesServiceInd ON Uses(ServiceId);
CREATE INDEX UsesStockInd ON Uses(ProductId);

CREATE INDEX StockTypeInd ON Stock(ProductType);
CREATE INDEX StockQuantityInd ON Stock(Quantity);
CREATE INDEX StockPriceInd ON Stock(Price);

CREATE INDEX AccessoryNameInd ON Accessory(ProductName);

CREATE INDEX ConsumableNameInd ON Consumable(ProductName);
CREATE INDEX ConsumableExpiryInd ON Consumable(ExpiryDate);

CREATE INDEX EquipmentNameInd ON Equipment(ProductName);
CREATE INDEX EquipmentServiceInd ON Equipment(ServiceDate);

CREATE INDEX CarriesOrderInd ON Carries(OrderNo);
CREATE INDEX CarriesStockInd ON Carries(ProductId);

CREATE INDEX OrderNoInd ON OrderDetails(OrderNo);
CREATE INDEX OrderDeliveryInd ON OrderDetails(DeliveryDate);
CREATE INDEX OrderQuantityInd ON OrderDetails(Quantity);

CREATE INDEX SuplierNameInd ON Supplier(SupplierName);
CREATE INDEX SupplierEmailInd ON Supplier(Email);

CREATE INDEX SupplierPhoneInd ON SupplierPhones(SupplierId);

--  Triggers

-- Adds a date when a Customer is added to the database
DELIMITER $$
CREATE TRIGGER BeforeCustomerInsert
    BEFORE INSERT ON Customer
    FOR EACH ROW
BEGIN
    -- Updates the Added column with the current date
    SET NEW.Added = CURDATE();
END $$
DELIMITER ;

-- Adds a date when a Dog is added to the database
DELIMITER $$
CREATE TRIGGER BeforeDogInsert
    BEFORE INSERT ON Dog
    FOR EACH ROW
BEGIN
    -- Updates the Added column with the current date
    SET NEW.Added = CURDATE();
END $$
DELIMITER ;

-- Updates CancelDate with current time if an Appointment is updated from the default 0 to 1 (Cancelled)
DELIMITER $$
CREATE TRIGGER BeforeCancelledAppointment
	BEFORE UPDATE ON Appointment
	FOR EACH ROW
BEGIN
    IF NEW.IsCancelled = 1 THEN -- [Ref #4]
        SET NEW.CancelDate = CURDATE();
    END IF;
END $$
DELIMITER ;

-- Checks that an Appointment is set to 1 (Cancelled) before deleting
DELIMITER $$
CREATE TRIGGER BeforeAppointmentDelete
    BEFORE DELETE ON Appointment
    FOR EACH ROW
BEGIN
    IF OLD.IsCancelled = 0 THEN -- [Ref #4]
        -- Marks Appointment as cancelled first
        UPDATE Appointment
        SET IsCancelled = 1
        WHERE ReferenceNo = OLD.ReferenceNo;
    END IF;
END $$
DELIMITER ;

-- Sets Stock to 0 if it goes under 0
DELIMITER $$
CREATE TRIGGER NegativeStockAlert
    BEFORE UPDATE ON Stock
    FOR EACH ROW
BEGIN
    IF NEW.Quantity < 0 THEN -- [Ref #4]
	SET New.Quantity = 0;
    END IF;
END $$
DELIMITER ;

-- User Management

DROP USER Manager;
DROP USER StaffId2;
DROP USER StaffId3;
DROP USER StaffId4;

CREATE USER Manager IDENTIFIED BY 'StaffId1';
CREATE USER StaffId2 IDENTIFIED BY 'StaffId2';
CREATE USER StaffId3 IDENTIFIED BY 'StaffId3';
CREATE USER StaffId4 IDENTIFIED BY 'StaffId4';

GRANT ALL ON dog_groomer.* TO Manager WITH GRANT OPTION;

GRANT INSERT, UPDATE, SELECT ON Customer TO StaffId2;
GRANT INSERT, UPDATE, SELECT ON Customer TO StaffId3;
GRANT INSERT, UPDATE, SELECT ON Customer TO StaffId4;

GRANT SELECT ON CustomerPhones TO StaffId2;
GRANT SELECT ON CustomerPhones TO StaffId3;
GRANT SELECT ON CustomerPhones TO StaffId4;

GRANT SELECT ON CustomerPhones TO StaffId2;
GRANT SELECT ON CustomerPhones TO StaffId3;
GRANT SELECT ON CustomerPhones TO StaffId4;

GRANT INSERT, SELECT ON Payment TO StaffId2;
GRANT INSERT, SELECT ON Payment TO StaffId3;
GRANT INSERT, SELECT ON Payment TO StaffId4;

GRANT INSERT, UPDATE, SELECT ON Dog TO StaffId2;
GRANT INSERT, UPDATE, SELECT ON Dog TO StaffId3;
GRANT INSERT, UPDATE, SELECT ON Dog TO StaffId4;

GRANT SELECT ON Breed TO StaffId2;
GRANT SELECT ON Breed TO StaffId3;
GRANT SELECT ON Breed TO StaffId4;

GRANT INSERT, UPDATE, SELECT ON Appointment TO StaffId2;
GRANT INSERT, UPDATE, SELECT ON Appointment TO StaffId3;
GRANT INSERT, UPDATE, SELECT ON Appointment TO StaffId4;

GRANT SELECT ON GroomingServices TO StaffId2;
GRANT SELECT ON GroomingServices TO StaffId3;
GRANT SELECT ON GroomingServices TO StaffId4;

GRANT UPDATE, SELECT ON Stock TO StaffId2;
GRANT UPDATE, SELECT ON Stock TO StaffId3;
GRANT UPDATE, SELECT ON Stock TO StaffId4;

GRANT SELECT ON Accessory TO StaffId2;
GRANT SELECT ON Accessory TO StaffId3;
GRANT SELECT ON Accessory TO StaffId4;

GRANT UPDATE, SELECT ON Consumable TO StaffId2;
GRANT UPDATE, SELECT ON Consumable TO StaffId3;
GRANT UPDATE, SELECT ON Consumable TO StaffId4;

GRANT UPDATE, SELECT ON Equipment TO StaffId2;
GRANT UPDATE, SELECT ON Equipment TO StaffId3;
GRANT UPDATE, SELECT ON Equipment TO StaffId4;

GRANT SELECT ON OrderDetails TO StaffId2;
GRANT SELECT ON OrderDetails TO StaffId3;
GRANT SELECT ON OrderDetails TO StaffId4;

GRANT UPDATE, SELECT ON Supplier TO StaffId2;
GRANT UPDATE, SELECT ON Supplier TO StaffId3;
GRANT UPDATE, SELECT ON Supplier TO StaffId4;

GRANT UPDATE, SELECT ON SupplierPhones TO StaffId2;
GRANT UPDATE, SELECT ON SupplierPhones TO StaffId3;
GRANT UPDATE, SELECT ON SupplierPhones TO StaffId4;

-- Records inserted into each Table

INSERT INTO Customer (FName, LName, Street, Town, County, Email)
VALUES
	('Mary', 'O''Connor', '12 Mary Street', 'Galway City', 'Galway', 'moc83@gmail.com'),
    ('Tom', 'Mahoney', 'Baurscoob Cross', 'Dunnamaggin', 'Kilkenny', 'tommahoney20@hotmail.com'),
    ('Ashley', 'Healy', '6 Eyre Square', 'Galway City', 'Galway', 'healtotoepodiatry@gmail.com'),
    ('Melissa', 'McNeill', '10 Gortard', 'Salthill', 'Galway', 'mmcn45ire@outlook.ie'),
    ('Amy', 'Keane', 'Bohoona East', 'An Spidéal', 'Galway', 'amy97keane@hotmail.com'),
    ('Michael', 'Donoghue', '4 Ballyquirke', 'Moyullen', 'Galway', 'mdonoghue@yahoo.com'),
    ('Greg', 'Waters', '2 Church Street', 'Corofin', 'Clare', 'gregorywater_s@outlook.com'),
    ('Claire', 'Power', 'Teergonean', 'Doolin', 'Clare', 'thepowerofclaire@gmail.com'),
    ('Jonathan', 'Harris', '10 Nymphsfield', 'Cong', 'Mayo', 'jpharris87@outlook.com'),
    ('Mags', 'Foley', '6 Beechpark', 'Claremorris', 'Mayo', 'margaretfoley89@yahoo.com'),
	('Joseph', 'Brophy', '26 Coill Tíre', 'Doughiska', 'Galway', 'jb1990@outook.com'),
    ('Marcus', 'Keane', '7 Lough Atalia Road', 'Renmore', 'Galway', 'marcu50@gmail.com'),
    ('Lizzy', 'Byrne', '16 Shop Street', 'Galway City', 'Galway', 'notthinlizzy@yahoo.com'),
    ('Margaret', 'Lowe', '28 Ballybane Road', 'Ballybane', 'Galway', 'maggiel1987@hotmail.com'),
    ('William', 'Bergin', '4 Knocknarea View', 'Strandhill', 'Sligo', 'williebergin@outlook.ie'),
    ('Séamus', 'O''Hara', '17 Mary Street', 'Galway City', 'Galway', 'shamohara@gmail.com');

INSERT INTO CustomerPhones 
VALUES
	('087 7409935', 4),
    ('089 7381574', 10),
    ('087 4536721', 7),
    ('085 9216347', 1),
    ('056 9761545', 2),
    ('085 6721945', 1),
    ('089 2348765', 8),
    ('094 3362616 ​', 10),
    ('091 4201731', 5),
    ('086 5638902', 2),
    ('087 2945710', 3),
    ('085 7481623', 9),
    ('089 6352104', 11),
    ('086 4798321', 6),
    ('065 9259929', 7),
    ('087 1729684', 5),
    ('089 3341096', 15),
    ('071 1199672', 15),
    ('083 0204783', 13),
    ('089 6665454', 12), 
    ('086 1199672', 14),
    ('087 6273762', 16);
    
INSERT INTO Payment (PaymentDate, Amount, CustomerId)
VALUES
	('2024-11-01', 90.00, 9),
    ('2024-11-01', 60.00, 8),
    ('2024-11-02', 35.00, 1),
    ('2024-11-02', 14.50, 1),
    ('2024-11-04', 70.00, 6),
    ('2024-11-07', 26.50, 5),
    ('2024-11-08', 75.00, 4),
    ('2024-11-08', 15.00, 3),
    ('2024-11-10', 68.00, 11),
    ('2024-11-10', 60.00, 9),
    ('2024-11-10', 70.00, 7),
    ('2024-11-11', 40.00, 2),
    ('2024-11-12', 50.00, 10),
    ('2024-11-12', 50.00, 10),
    ('2024-11-15', 41.50, 8),
    ('2024-11-19', 14.50, 3),
    ('2024-11-16', 70.00, 1),
    ('2024-11-19', 35.00, 13),
    ('2024-11-19', 59.99, 12),
    ('2024-11-20', 90.00, 14),
    ('2024-11-20', 50.00, 1),
    ('2024-11-21', 50.00, 15),
    ('2024-11-22', 50.00, 15),
    ('2024-11-22', 30.00, 13),
    ('2024-11-23', 40.00, 1),
    ('2024-11-23', 50.00, 13),
    ('2024-11-30', 15.00, 1),
    ('2024-11-25', 15.00, 13),
    ('2024-11-28', 20.00, 10);

INSERT INTO Breed (BreedName, Size, Hairtype)
VALUES
	('Dachshund', 'XS', 'Smooth'),
    ('Golden Retriever', 'M', 'Double'),
    ('Labrador Retriever', 'M', 'Short'),
    ('German Shepherd', 'L', 'Double'),
    ('Cockapoo', 'S', 'Curly'),
    ('Cocker Spaniel', 'S', 'Long'),
    ('Jack Russell Terrier', 'XS', 'Short'),
    ('Cavapoo', 'S', 'Curly'),
    ('French Bulldog', 'S', 'Smooth'),
    ('Cavalier King Charles', 'S', 'Long'),
    ('Bichon Frise', 'XS', 'Curly'),
    ('Chihuahua', 'XXS', 'Smooth'),
    ('Irish Wolfhound', 'XXL', 'Wire'),
    ('West Highland Terrier', 'S', 'Long'),
    ('Siberian Husky', 'XL', 'Double'),
    ('Great Dane', 'XXL', 'Smooth'),
    ('Border Collie', 'M', 'Long'),
    ('Poodle', 'L', 'Curly'),
    ('Yorkshire Terrier', 'XS', 'Long'),
    ('Rottweiler', 'L', 'Smooth'),
    ('Pomeranian', 'XXS', 'Long'),
    ('Shih Tzu', 'XS', 'Long');
    
INSERT INTO Dog (DogName, Age, CustomerId, BreedId)
VALUES
	('Teddy', '8 Months', 8, 4),
    ('Bob', '8 Years', 9, 13),
    ('Frodo', '2 Years', 5, 19),
    ('Tim', '7 Years', 1, 11),
    ('Jim', '5 Years', 1, 11),
    ('Kim', '5 Years', 1, 11),
    ('Benji', '7 Years', 3, 7),
    ('Lily', '2 Years', 10, 12),
    ('Daisy', '4 Years', 10, 21),
    ('Greg Jr.', '9 Years', 7, 17),
    ('Sam', '3 Years', 2, 4),
    ('Penny', '5 Months', 4, 18),
    ('Otis', '3 Years', 6, 3),
    ('Benny', '4 Years', 11, 14),
    ('Rufus', '10 Months', 11, 2),
    ('Princess Peanut', '8 Months', 7, 1),
    ('Walter', '5 Years', 15, 17),
    ('Tobias', '3 Years', 15, 17),
    ('Coco', '6 Months', 14, 20),
    ('Sir Chewy', '12 Years', 12, 10),
    ('Mica', '10 Years', 13, 3),
    ('Lavender', '4 Years', 13, 8),
    ('Boru', '1 Year', 13, 7),
    ('Séamus Beag', '5 Years', 16, 9);

INSERT INTO Appointment (AppDate, AppTime, DogId)
VALUES
	('2024-11-01', '09:00:00', 2),
    ('2024-11-01', '12:30:00', 1), 
    ('2024-11-02', '10:30:00', 4),
    ('2024-11-04', '13:00:00', 13),
    ('2024-11-07', '09:00:00', 3),
    ('2024-11-08', '11:00:00', 12),
    ('2024-11-08', '14:00:00', 7),
    ('2024-11-10', '10:30:00', 15),
    ('2024-11-10', '13:00:00', 2),
    ('2024-11-10', '16:00:00', 10),
    ('2024-11-11', '09:30:00', 11),
    ('2024-11-12', '09:00:00', 8),
    ('2024-11-12', '10:00:00', 9),
    ('2024-11-15', '11:00:00', 1),
    ('2024-11-16', '12:00:00', 4),
    ('2024-12-20', '09:30:00', 4),
    ('2024-12-10', '14:30:00', 14),
    ('2024-11-19', '09:30:00', 23),
    ('2024-11-19', '11:00:00', 20),
    ('2024-11-20', '13:00:00', 19),
    ('2024-11-20', '15:15:00', 4),
    ('2024-11-21', '10:30:00', 17),
    ('2024-11-22', '11:30:00', 18),
    ('2024-11-22', '14:30:00', 21),
    ('2024-11-23', '09:30:00', 4),
    ('2024-11-23', '12:15:00', 22),
    ('2024-11-30', '09:00:00', 4),
    ('2024-11-25', '10:45:00', 23),
    ('2024-11-28', '11:30:00', 9),
    ('2024-12-02', '11:30:00', 8),
    ('2024-12-06', '11:30:00', 4),
    ('2024-12-07', '14:00:00', 7),
    ('2024-12-14', '15:00:00', 10),
    ('2024-12-15', '16:00:00', 4),
    ('2024-12-25', '10:30:00', 4),
    ('2025-01-10', '10:00:00', 4),
    ('2025-01-01', '12:00:00', 24);
    
INSERT INTO Staff (PPSNo, FName, LName, Street, Town, County, RatePerHour, Manager)
VALUES
	('1234567A', 'Anne', 'McLoughlin', '12 Maree Road', 'Rinville East', 'Galway', 40.00, NULL),
    ('87654321B', 'Sammy', 'Keane', '146 Clochóg', 'Oranmore', 'Galway', 22.00, 1),
    ('11223344C', 'Jenny', 'Lynch', '9 New Estate', 'Clarinbridge', 'Galway', 19.00, 1),
    ('9876543D', 'Mike', 'Flanagan', '5 Ceadars Ave', 'Portumna', 'Galway', 19.00, 1);

INSERT  INTO StaffPhones
VALUES
	('087 7614154', 1),
	('083 3200709', 2),
	('086 2007896', 2),
	('086 3087547', 3),
	('085 5709946', 1),
	('085 7728711', 4);

INSERT INTO Handles (ReferenceNo, StaffId, AppLength, StaffRole)
VALUES
	(1, 1, '03:20:00', 'Manager'),
	(1, 2, '03:20:00', 'Groomer'),
	(1, 3, '03:20:00', 'Bather'),
    (2, 1, '02:00:00', 'Manager/Bather'),
    (2, 4, '02:00:00', 'Groomer'),
    (3, 1, '01:30:00', 'Groomer'),
    (4, 1, '02:40:00', 'Manager'),
    (4, 3, '02:40:00', 'Bather'),
    (4, 4, '02:40:00', 'Groomer'),
    (5, 1, '02:00:00', 'Groomer'),
    (6, 1, '02:00:00', 'Manager/Groomer'),
    (6, 3, '02:00:00', 'Bather'),
    (7, 1, '01:00:00', 'Manager'),
    (7, 3, '01:00:00', 'Groomer'),
    (8, 1, '02:00:00', 'Manager/Bather'),
    (8, 3, '02:00:00', 'Groomer'),
    (9, 1, '03:00:00', 'Manager'),
	(9, 2, '03:00:00', 'Bather/Groomer'),
	(9, 3, '03:00:00', 'Bather'),
	(10, 1, '02:00:00', 'Manager'),
    (10, 3, '02:00:00', 'Groomer'),
    (11, 1, '02:30:00', 'Groomer'),
    (12, 1, '01:00:00', 'Groomer'),
    (13, 1, '01:20:00', 'Groomer'),
    (14, 1, '01:50:00', 'Manager/Bather'),
    (14, 4, '01:50:00', 'Groomer'),
    (15, 1, '02:00:00', 'Manager/Groomer'),
	(16, 1, '01:00:00', 'Manager'),
    (16, 2, '01:00:00', 'Groomer'),
    (17, 1, '02:30:00', 'Manager'),
    (17, 2, '02:30:00', 'Bather/Groomer'),
    (18, 1, '02:00:00', 'Manager/Bather'),
    (18, 4, '02:00:00', 'Groomer'),
    (19, 1, '02:00:00', 'Manager'),
    (19, 3, '02:00:00', 'Groomer/Bather'),
    (20, 1, '02:45:00', 'Manager'),
    (20, 3, '02:45:00', 'Bather'),
    (20, 4, '02:45:00', 'Groomer'),
    (21, 1, '02:45:00', 'Bather/Groomer'),
    (22, 1, '02:30:00', 'Manager'),
    (22, 3, '02:30:00', 'Groomer/Bather'),
    (23, 1, '02:30:00', 'Manager/Groomer'),
    (23, 2, '02:00:00', 'Bather'),
    (24, 1, '03:00:00', 'Manager'),
    (24, 2, '03:00:00', 'Groomer'),
    (24, 4, '03:00:00', 'Bather'),
    (25, 1, '01:45:00', 'Groomer'),
    (26, 1, '02:30:00', 'Manager/Bather'),
    (26, 3, '02:30:00', 'Groomer'),
    (27, 1, '02:00:00', 'Groomer/Bather'),
    (28, 1, '01:45:00', 'Groomer'),
    (29, 1, '02:20:00', 'Bather/Groomer'),
    (30, 1, '01:50:00', 'Manager'),
	(30, 2, '01:50:00', 'Groomer'),
    (31, 1, '01:50:00', 'Manager'),
	(31, 2, '01:50:00', 'Bather/Groomer'),
    (32, 1, '02:20:00', 'Manager'),
	(32, 3, '02:20:00', 'Bather/Groomer'),
    (33, 1, '03:00:00', 'Manager/Bather'),
    (33, 4, '03:00:00', 'Groomer'),
    (33, 3, '03:00:00', 'Groomer'),
    (34, 1, '02:30:00', 'Bather/Groomer'),
    (35, 1, '01:40:00', 'Bather/Groomer'),
    (36, 1, '02:00:00', 'Groomer'),
    (37, 1, '02:00:00', 'Manager/Bather'),
    (37, 2, '02:00:00', 'Groomer');

INSERT INTO GroomingServices (ServiceName, PriceSmall, PriceMedium, PriceLarge)
VALUES
	('Bath & Shampoo', 20.00, 30.00, 40.00),
    ('Medicated Bath & Shampoo', 25.00, 35.00, 45.00),
    ('Hair Cut/Trim', 20.00, 30.00, 40.00),
    ('Nail Clipping', 15.00, 25.00, 35.00),
    ('Ear Cleaning', 20.00, 20.00, 20.00),
    ('Teeth Brushing', 15.00, 15.00, 15.00),
    ('Flea/Tick Treatment', 20.00, 25.00, 30.00),
    ('Full Grooming Package', 50.00, 70.00, 90.00),
    ('Full Grooming Package - Puppy', 40.00, 60.00, 80.00),
    ('Full Grooming Package - Senior', 40.00, 60.00, 80.00),
    ('De-shedding Treatment', 40.00, 50.00, 60.00),
    ('Paw Pad Trim & Condition', 15.00, 15.00, 15.00),
    ('Face & Feet Trim', 20.00, 20.00, 20.00),
    ('Conditioning Treatment', 20.00, 30.00, 40.00),
    ('Matt Removal', 40.00, 50.00, 60.00);

INSERT INTO Includes (ReferenceNo, ServiceId)
VALUES
	(1, 8),
    (2, 1),
    (2, 5),
    (3, 4),
    (3, 5),
    (4, 8),
    (5, 7),
    (6, 3),
    (6, 4),
    (7, 4),
    (8, 9),
    (9, 6),
    (9, 2),
    (10, 8),
    (11, 1),
    (12, 8),
    (13, 8),
    (14, 4),
    (15, 8),
    (18, 7),
    (18, 4),
    (19, 8),
    (20, 8),
    (21, 8),
    (22, 15),
    (23, 15),
    (24, 14),
    (25, 11),
    (26, 8),
    (27, 15),
    (28, 6),
    (29, 14),
    (16, 8),
    (17, 10),
    (30, 4),
    (31, 2),
    (32, 2),
    (33, 3),
    (34, 8),
    (35, 4),
    (35, 7),
    (36, 1),
    (36, 13);
    
INSERT INTO Stock (ProductType, Quantity, Price)
VALUES
	('Accessory', 15, 12.99), 
	('Consumable', 50, 4.49), 
	('Equipment', 5, 75.00), 
	('Accessory', 8, 25.99), 
	('Consumable', 30, 7.50), 
	('Equipment', 3, 150.00), 
	('Accessory', 20, 18.99), 
	('Consumable', 40, 5.49), 
	('Equipment', 10, 90.00), 
	('Accessory', 25, 13.50), 
	('Consumable', 60, 6.25), 
	('Equipment', 2, 200.00), 
	('Accessory', 10, 30.00), 
	('Consumable', 100, 3.99), 
	('Equipment', 6, 120.00), 
	('Accessory', 12, 19.99), 
	('Consumable', 75, 5.75), 
	('Equipment', 4, 110.00), 
	('Accessory', 18, 22.49), 
	('Consumable', 35, 8.99),
    ('Consumable', 15, 7.50), 
    ('Consumable', 15, 7.50), 
    ('Consumable', 4, 7.50),
    ('Consumable', 5, 7.50),
    ('Consumable', 8, 7.50),
    ('Equipment', 5, 12.00),
    ('Accessory', 6, 12.99),
    ('Accessory', 12, 10.99),
    ('Accessory', 18, 8.99),
    ('Consumable', 6, 11.50),
    ('Consumable', 8, 12.50),
    ('Consumable', 15, 14.99),
    ('Equipment', 10, 53.00),
    ('Equipment', 3, 134.00),
    ('Equipment', 18, 5.99),
    ('Equipment', 4, 65.99),
    ('Accessory', 15, 10.99),
    ('Accessory', 18, 11.99),
    ('Accessory', 22, 12.99),
    ('Accessory', 11, 13.50),
    ('Accessory', 9, 14.99),
    ('Accessory', 16, 14.59),
    ('Accessory', 19, 10.09),
    ('Accessory', 3, 9.89),
    ('Accessory', 8, 8.99),
    ('Accessory', 17, 15.99),
    ('Accessory', 20, 11.99),
    ('Accessory', 2, 13.29);

INSERT INTO Accessory (ProductId, ProductName, Size)
VALUES
	(1, 'Cotton Collar', 'S'),
	(4, 'Nylon Leash', 'M'),
	(7, 'Nylon Collar', 'L'),
	(10, 'Paisley Bandana', 'M'),
	(13, 'Block Bandana', 'XS'),
	(16, 'Harness', 'XXL'),
	(19, 'Bow', 'XL'),
    (27, 'Cotton Collar', 'M'),
    (28, 'Bow', 'M'),
    (29, 'Bow', 'S'),
    (37, 'Harness', 'XS'),
    (38, 'Harness', 'XXS'),
    (39, 'Harness', 'S'),
    (40, 'Nylon Collar', 'M'),
    (41, 'Nylon Collar', 'XL'),
    (42, 'Paisley Bandana', 'L'),
    (43, 'Paisley Bandana', 'S'),
    (44, 'Paisley Bandana', 'XL'),
    (45, 'Nylon Leash', 'XS'),
    (46, 'Nylon Leash', 'XXL'),
    (47, 'Block Bandana', 'S'),
    (48, 'Block Bandana', 'L');
    
INSERT INTO Consumable (ProductId, ProductName, ExpiryDate)
VALUES
    (2, 'Conditioner', '2025-12-31'),
    (5, 'Shampoo', '2024-08-15'),
    (8, 'Toothpaste', '2024-06-30'),
    (11, 'Flea/Tick Treatment', '2024-12-16'),
    (14, 'Dog Perfume', '2025-02-14'),
    (17, 'Dental Chews', '2025-05-10'),
    (20, 'Hair Oil', '2025-09-25'),
    (21, 'Medicated Shampoo', '2025-02-20'),
    (22, 'Medicated Conditioner', '2025-04-01'),
    (23, 'Wipes', '2025-11-10'),
    (24, 'Wax Softener', '2026-01-04'),
    (25, 'Cotton Pads', '2025-08-09'),
    (30, 'Moisturising Shampoo', '2025-02-19'),
    (31, 'Moisturising Conditioner', '2025-09-05'),
    (32, 'Dandruff Shampoo', '2025-06-22');

INSERT INTO Equipment (ProductId, ProductName, OrderDate, ServiceDate)
VALUES
    (3, 'Grooming Table', '2023-09-01', '2024-09-01'),
    (6, 'Shears', '2023-08-15', '2024-08-15'),
    (9, 'Nail Trimmer', '2023-07-20', '2024-07-20'),
    (12, 'Dryer', '2023-10-05', '2024-10-05'),
    (15, 'Shears', '2023-11-10', '2024-11-10'),
    (18, 'Bathing Station', '2023-06-12', '2024-06-12'),
    (26, 'Comb', '2024-04-12', NULL),
    (33, 'Clippers', '2024-10-01', '2024-11-03'),
    (34, 'Scale', '2024-08-06', '2024-11-15'),
    (35, 'Spray Bottle', '2024-01-10', NULL),
    (36, 'Vacuum', '2023-09-30', '2024-10-28');

INSERT INTO Uses (ServiceId, ProductId)
VALUES
	(1, 2),
    (1, 5),
    (1, 12),
    (1, 18),
    (2, 21),
    (2, 22),
    (2, 12),
    (2, 18),
    (3, 3),
    (3, 6),
    (3, 15),
    (4, 9),
    (5, 23),
	(5, 24),
	(5, 25),
    (6, 8),
    (7, 11),
    (7, 26),
    (8, 2),
    (8, 5),
    (8, 8),
    (8, 11),
    (8, 14),
    (8, 20),
    (8, 23),
    (8, 24),
    (8, 25),
    (8, 3),
    (8, 6),
    (8, 9),
    (8, 12),
    (8, 15),
    (8, 18),
    (8, 26),
    (9, 2),
    (9, 5),
    (9, 8),
    (9, 11),
    (9, 14),
    (9, 20),
    (9, 23),
    (9, 24),
    (9, 25),
    (9, 3),
    (9, 6),
    (9, 9),
    (9, 12),
    (9, 15),
    (9, 18),
    (9, 26),
    (10, 2),
    (10, 5),
    (10, 8),
    (10, 11),
    (10, 14),
    (10, 20),
    (10, 23),
    (10, 24),
    (10, 25),
    (10, 3),
    (10, 6),
    (10, 9),
    (10, 12),
    (10, 15),
    (10, 18),
    (10, 26),
    (11, 2),
    (11, 5),
    (11, 20),
    (11, 36),
    (12, 6),
    (12, 9),
    (12, 14),
    (12, 20),
    (13, 6),
    (13, 9),
    (13, 20),
    (13, 14),
    (14, 30),
    (14, 31),
    (14, 20),
    (14, 35),
    (15, 6),
    (15, 26),
    (15, 33);
    
INSERT INTO Supplier (SupplierName, Street, Town, County, Email)
VALUES
	('Mason & Olsen', 'Headford Road', 'Galway City', 'Galway', 'orders@mason&olsen.ie'),
    ('Caulfield Industrial', 'Tuam Road Business Park', 'Galway City', 'Galway', 'contact@caulfieldsgalway.com'),
    ('PetSmart Supply', 'Deerpark Industrial Estate', 'Oranmore', 'Galway', 'enquiries@petsmartco.com'),
    ('The Pet Pantry', 'Westside Business Park', 'Galway City', 'Galway', 'contactus@petpantryire.com'),
    ('FurryFriendz Suppliez', 'Ballybane Industrial Estate', 'Ballybane', 'Galway', 'contactuz@furryfriendzsuppliez.ie'),
    ('Harrington Industrial Solutions', 'Tuam Road Business Park', 'Galway City', 'Galway', 'enquiries@harringtonis.com'),
    ('Bradford Co. Supplies', 'Ennis Business Park', 'Ennis', 'Clare', 'contactus@bradfordcosupplies.com'),
    ('Precision Pet Supplies', 'Shannon Industrial Estate', 'Shannon', 'Clare', 'precisionpetsupplies@gmail.com');
    
INSERT INTO SupplierPhones 
VALUES
	('091 234567', 1),
    ('087 2345678', 1),
    ('091 876543', 2),
    ('086 5432109', 2),
    ('091 112334', 3),
    ('089 8764321', 3),
    ('087 7408876', 4),
    ('091 7407440', 4),
    ('091 6767666', 5),
    ('086 3409814', 5),
    ('087 7045321', 6),
    ('091 9994444', 6),
    ('065 8082222', 7),
    ('085 4582881', 7),
    ('083 0267281', 8),
    ('065 7362836', 8);
    
INSERT INTO OrderDetails (OrderDate, DeliveryDate, Quantity, SupplierId)
VALUES
	('2024-09-16', '2024-09-20', 5, 5),
	('2024-09-30', '2024-10-02', 10, 8),
	('2024-10-01', '2024-10-03', 3, 5),
	('2024-10-15', '2024-10-20', 8, 4),
	('2024-10-23', '2024-10-25', 4, 1),
    ('2024-10-29', '2024-11-03', 10, 2),
    ('2024-11-03', '2024-11-10', 2, 1),
    ('2024-11-10', '2024-11-12', 3, 3),
    ('2024-11-20', '2024-11-23', 2, 3),
    ('2024-11-23', NULL, 4, 1),
    ('2024-11-26', NULL, 6, 3),
    ('2024-11-28', NULL, 15, 7),
	('2024-11-29', NULL, 3, 5);

INSERT INTO Carries (OrderNo, ProductId)
VALUES
	(1, 1),
    (2, 5),
    (2, 2),
    (3, 9),
    (4, 26),
    (5, 19),
    (6, 17),
    (7, 34),
    (8, 26),
    (9, 27),
    (10, 35),
    (11, 20),
    (12, 28);
    
-- Update queries to populate tables with examples of deleted records
UPDATE Customer
SET isDeleted = 1
WHERE FName LIKE 'Séam%';

UPDATE Dog 
SET isDeleted = 1
WHERE CustomerId = 16;

UPDATE Appointment
SET isCancelled = 1
WHERE DogId = 24;

COMMIT;




