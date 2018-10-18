use northwinds;

#lists all info in customer table
select * from nwCustomers;
select * from nwOrders;

#list OrderID and OrderDate for all orders, ordered by most recent OrderDate
SELECT OrderID, OrderDate 
FROM nwOrders
ORDER BY OrderDate DESC;

#list CustomerID for customers with orders>20
SELECT COUNT(CustomerID) as OrderCount, CustomerID
FROM nwOrders
GROUP BY (CustomerID)
ORDER BY OrderCount DESC;

#count number of customers not from France
SELECT COUNT(CustomerID) FROM nwCustomers
WHERE Country!='France';

#list unique cities from employee table and count of employees living in each city
SELECT COUNT(City) as EmployeeCount, City
FROM nwEmployees
GROUP BY (City)
ORDER BY EmployeeCount ASC;

#avg price of all products sold by northwinds
SELECT ROUND(AVG(UnitPrice),2) from nwProducts;

#list company name customers who purchased orders from employee w EmployeeID=1
SELECT * FROM nwCustomers;
SELECT * FROM nwOrders;
SELECT C.CompanyName
FROM nwCustomers C, nwOrders O
WHERE C.CustomerID=O.CustomerID AND O.EmployeeID=1
ORDER BY C.CompanyName ASC;


#list ProductID, ProductName, InventoryValue w/ inventory value>2000: UnitPrice*UnitsinStock
SELECT * FROM nwProducts;
SELECT ProductID, ProductName, SUM(UnitsInStock*UnitPrice) AS InventoryValue
FROM nwProducts
WHERE UnitsInStock*UnitPrice > 2000
GROUP BY ProductID
ORDER BY InventoryValue ASC;


#TopCustomers List w Customer CompanyName, CustomerCountry, Value(UnitPrice*Quantity-Discount) of all orders descending >30,000
SELECT * FROM nwCustomers; #CustomerID, CompanyName, Country
SELECT * FROM nwOrderDetails; #UnitPrice, Quantity, Discount, OrderID
SELECT * FROM nwOrders; #CustomerID, OrderID
SELECT C.CompanyName, C.Country, SUM(D.UnitPrice*D.Quantity-D.Discount) AS Value
FROM nwCustomers C, nwOrderDetails D
WHERE (UnitPrice*Quantity-Discount)>30000
GROUP BY C.CompanyName
ORDER BY Value ASC;

#List CustomerID, CompanyName, OrderIDs for customers
SELECT * FROM nwOrders;
SELECT * FROM nwCustomers;
SELECT C.CompanyName, C.CustomerID, O.OrderID
FROM nwCustomers C
LEFT JOIN nwOrders O 
	ON C.CustomerID=O.CustomerID
ORDER BY C.CustomerID;


#list product name and quantity per unit of all products that come in boxes
SELECT * FROM nwProducts;
SELECT ProductName, QuantityPerUnit
FROM nwProducts
WHERE QuantityPerUnit LIKE '%box%';


#view listing employees lastname, firstname, and total count of orders employee has placed
SELECT * FROM nwEmployees;
SELECT * FROM nwOrders;
CREATE VIEW EmployeeOrders AS
SELECT COUNT(O.EmployeeID) AS OrderCount, E.FirstName, E.LastName
FROM nwEmployees E, nwOrders O
WHERE E.EmployeeID=O.EmployeeID
GROUP BY E.EmployeeID
ORDER BY OrderCount DESC;

SELECT * FROM EmployeeOrders;

#find top three sellers in EmployeeOrders
SELECT * FROM EmployeeOrders
ORDER BY OrderCount DESC
LIMIT 3; #gives top 3 employees, top seller is Margaret Peacock

#create table of topItems
CREATE TABLE topItems(
ItemID INT NOT NULL,
ItemCode INT NOT NULL,
ItemName VARCHAR(40) NOT NULL,
InventoryDate DATE NOT NULL,
SupplierID INT NOT NULL,
ItemQuantity INT NOT NULL DEFAULT 0,
ItemPrice DECIMAL(9,2) NOT NULL DEFAULT 0.00,
PRIMARY KEY(ItemID));

#populate table with w columns from nwProducts, delete any with discontinued products
INSERT INTO topItems(ItemID, ItemCode, ItemName, ItemQuantity, ItemPrice, SupplierID, InventoryDate)
SELECT ProductID, CategoryID, ProductName, UnitsInStock, UnitPrice, SupplierID, CURDATE()
FROM nwProducts
WHERE UnitsInStock*UnitPrice>2500 AND Discontinued=0;
SELECT * FROM topItems;

#Add new column to topItems (called InventoryValue) after inventory date
ALTER TABLE topItems
ADD COLUMN InventoryValue DECIMAL(9,2) AFTER InventoryDate;

#Update topItems setting InventoryValue column to ItemPrice*ItemQuantity
SET SQL_SAFE_UPDATES=0;
UPDATE topItems SET InventoryValue=ItemPrice*ItemQuantity;

#drop the topItems table
DROP TABLE topItems;







