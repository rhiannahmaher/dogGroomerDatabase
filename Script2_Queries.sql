/*
	Name: Rhiannah Maher
    Student Number: W20085527
    
    Script Two: Contains most used queries when searching the database.
*/

USE dog_groomer;

/*
	Returns Customers deleted from database.
*/
SELECT * FROM Customer
WHERE IsDeleted = 1;

/*
	Returns Dogs associated with each Customer.
    Uses GROUP_CONCAT() & GROUP BY clause
*/
SELECT FullName, GROUP_CONCAT(DogId) AS DogId, GROUP_CONCAT(DogName) AS DogName
FROM DogOwners
GROUP BY FullName;

/*
	Returns large dogs in the system and if they have any upcoming appointments. Important query as larger dogs require more staff.
    Uses Join, WHERE ... IN clause & ORDER BY clause.
*/
SELECT DogId, DogName, BreedName, Size
FROM Dog JOIN Breed
ON Dog.BreedId = Breed.BreedId
WHERE Breed.Size IN ('L', 'XL', 'XXL')
ORDER BY DogId;

/*
	Returns Dogs deleted from database.
*/
SELECT * FROM Dog
WHERE IsDeleted = 1;

/*
	Multi-table JOIN that returns complete summary of each appointment includng Dog info, App info, Grooming Service(s), and Customer info
*/
SELECT Appointment.ReferenceNo, DogName, AppDate, AppTime, ServiceName, Dog.CustomerId, CONCAT(FName, ' ', LName) AS FullName, GROUP_CONCAT(PhoneNo) AS PhoneNo, Email
FROM Dog
JOIN Appointment ON Dog.DogId = Appointment.DogId
JOIN Customer ON Dog.CustomerId = Customer.CustomerId
JOIN CustomerPhones ON Customer.CustomerId = CustomerPhones.CustomerId
JOIN Includes ON Appointment.ReferenceNo = Includes.ReferenceNo
JOIN GroomingServices ON Includes.ServiceId = GroomingServices.ServiceId
WHERE AppDate > CURDATE()
OR (AppDate = CURDATE() AND AppTime > CURTIME()) -- Ensures if an appointment is today, it is greater than the current time and filtered [Ref #5]
AND IsCancelled = 0 -- Searches for active appointments only
GROUP BY Appointment.ReferenceNo, DogName, AppDate, AppTime, ServiceName, Dog.CustomerId, Email
ORDER BY AppDate;

/*
	Counts number of future appointments with each dog.
    Uses GROUP_CONCAT() to merge the dates if a dog has multiple upcoming appointments and COUNT() to count number of upcoming appointments. 
    Uses GROUP BY clause & ORDER BY clause.
    Uses JOIN clause to return Appointment and Dog information.
    Uses date function to filter out appointments that are greater than the current time and greater or equal to today's date
*/
SELECT DogName, GROUP_CONCAT(AppDate) as UpcomingAppointments, COUNT(ReferenceNo) AS AppointmentCount
FROM Dog
JOIN Appointment ON Dog.DogId = Appointment.DogId
WHERE AppDate > CURDATE()
OR (AppDate = CURDATE() AND AppTime > CURTIME())  -- Ensures if an appointment is today, it is greater than the current time and filtered [Ref #5]
AND IsCancelled = 0 -- Searches for active appointments
GROUP BY DogName
ORDER BY AppointmentCount DESC;

/*
	Returns Cancelled Appointments
    Uses ORDER BY clause
*/
SELECT * FROM Appointment
WHERE IsCancelled = 1
ORDER BY AppDate DESC;

/*
	Returns staff with below average wages
    Uses aggregate funtion AVG()
    Uses sub-query
*/
SELECT * FROM Staff
WHERE RatePerHour <= 
	(SELECT AVG(RatePerHour) FROM Staff);

/*
	Returns total hours worked for each staff member.
    Uses aggregate function SUM()
    Uses GROUP BY and ORDER BY clauses
*/
SELECT FullName, RatePerHour, ROUND(SUM(TIME_TO_SEC(AppLength)) / 3600, 2) AS TotalHoursWorked
FROM StaffHoursWorked
GROUP BY FullName, RatePerHour
ORDER BY TotalHoursWorked DESC;

/*
	Returns most popular to least popular Grooming Services
    Uses aggregate function COUNT()
    Uses OUTER LEFT JOIN and has multiple table JOINS
    Includes GROUP BY & ORDER BY clauses
*/
SELECT ServiceName, COUNT(Appointment.ReferenceNo) AS AppointmentCount 
FROM GroomingServices 
-- LEFT JOIN ensures Grooming Services that have not been booked are also displayed
LEFT JOIN Includes
    ON GroomingServices.ServiceId = Includes.ServiceId
LEFT JOIN Appointment
    ON Includes.ReferenceNo = Appointment.ReferenceNo
GROUP BY ServiceName
ORDER BY AppointmentCount DESC;


/*
	Returns low stock products from SalesStock and InternalStock Views for users to easily keep track of.
    Uses UNION clause.
*/
SELECT * FROM InternalStock
WHERE Quantity < 10
UNION
SELECT * FROM SalesStock
WHERE Quantity < 10
ORDER BY Quantity;

/*
	Returns collars in database. Useful as dog groomers can hold many types and sizes.
    Uses WHERE ... LIKE clause and JOIN clause.
    Uses pattern matching to search for all products including 'Collar' in their ProductName
*/
SELECT ProductName, Size, Quantity 
FROM Accessory JOIN Stock
ON Accessory.ProductId = Stock.ProductId
WHERE ProductName LIKE '%Collar%'
ORDER BY ProductName;

/*
	Returns shampoo in database. Useful as dog groomer can hold many types.
    Uses WHERE ... LIKE clause and JOIN clause.
    Uses pattern matching to search for all products including 'Shampoo' in their ProductName
*/
SELECT ProductName, ExpiryDate, Quantity 
FROM Consumable JOIN Stock
ON Consumable.ProductId = Stock.ProductId
WHERE ProductName LIKE '%Shampoo%'
ORDER BY ProductName;

/*
	Returns conditioner in database. Useful as dog groomers can hold many types.
    Uses WHERE ... LIKE clause and JOIN clause.
    Uses pattern matching to search for all products including 'Conditioner' in their ProductName
*/
SELECT ProductName, ExpiryDate, Quantity 
FROM Consumable JOIN Stock
ON Consumable.ProductId = Stock.ProductId
WHERE ProductName LIKE '%Conditioner%'
ORDER BY ProductName;

/*
	Returns the most expensive Stock item's details.
    Uses UNION clause that combines results of ProductName from Accessory, Consumable & Equipment under the same column [Ref #1]
    Uses sub-query
*/
SELECT ProductName, 'Accessory' AS ProductType, Quantity, Price
FROM Stock JOIN Accessory
ON Stock.ProductId = Accessory.ProductId
WHERE Stock.Price >= ALL 
	(SELECT Price FROM Stock)
UNION
SELECT ProductName, 'Consumable' AS ProductType, Quantity, Price
FROM Stock JOIN Consumable
    ON Stock.ProductId = Consumable.ProductId
WHERE Stock.Price >= ALL 
(SELECT Price FROM Stock)
UNION
SELECT ProductName, 'Equipment' AS ProductType, Quantity, Price
FROM Stock JOIN Equipment
    ON Stock.ProductId = Equipment.ProductId
WHERE Stock.Price >= ALL 
	(SELECT Price FROM Stock);

/*
	Returns number of days since an equipment's last service, if the last service date has exceeded 30 days. Can be used to keep track of equipment that need to be serviced.
    Uses DATEDIFF() date function and IS NOT NULL clause (as some equipment does not need to be serviced such as combs).
*/
SELECT ProductName, ServiceDate, DATEDIFF(CURDATE(), ServiceDate) AS DaysSinceLastService  
FROM EquipmentService
WHERE ProductName IS NOT NULL AND ServiceDate IS NOT NULL
AND DATEDIFF(CURDATE(), ServiceDate) >= 30;

/*
	Returns Consumable Stock that will expire within 30 days. 
    Uses DATE_ADD() date function to filter Consumables between current date + 30 days
    Uses ORDER BY clause and BETWEEN ... AND clause
*/
SELECT ProductId, ProductName, ExpiryDate FROM ExpiredConsumables
WHERE ExpiryDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY) 
ORDER BY ExpiryDate;

/*
	Returns Dogs who have had more than 10 appointments at the groomer. Useful to see frequent customers/dogs.
    Uses COUNT() aggregate function, multi-table JOIN clause, and GROUP BY ... HAVING clause
*/
SELECT DogName, CONCAT(FName, ' ', LName) AS FullName, COUNT(ReferenceNo) AS TotalAppointmentCount
FROM Dog
JOIN Appointment ON Dog.DogId = Appointment.DogId
JOIN Customer
ON Dog.CustomerId = Customer.CustomerId
GROUP BY DogName, FullName
HAVING COUNT(ReferenceNo) >= 10;

/*
	Returns Orders that have not been delivered
*/
SELECT * FROM DueDeliveries;

/*
	Returns delivered Orders, ordered by delivery date.
    Uses IS NOT NULL clause and ORDER BY clause
*/
SELECT OrderNo, DeliveryDate, Quantity, SupplierName 
FROM OrdersBySuppliers
WHERE DeliveryDate IS NOT NULL
ORDER BY DeliveryDate DESC;

/*
	Returns number of Orders with each Supplier
    Uses aggregate function COUNT()
    LEFT OUTER JOIN ensures that Suppliers where no order has been placed are still displayed
    Uses GROUP BY & ORDER BY clauses
*/
SELECT SupplierName, COUNT(OrderNo) AS OrdersPerSupplier
FROM Supplier 
LEFT JOIN OrderDetails
ON Supplier.SupplierId = OrderDetails.SupplierId
GROUP BY SupplierName
ORDER BY OrdersPerSupplier DESC;



	