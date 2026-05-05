-----------------CREACIÓN DE BASE DE DATOS--------------
--------------------------------------------------------
CREATE DATABASE ProyectoSQL_Tcc
use ProyectoSQL_Tcc

--------CREACIÓN DE LA TABLA Telco_Customer_Churn-------
--------------------------------------------------------

CREATE TABLE Telco_Customer_Churn (
    CustomerID VARCHAR(50),
    Country VARCHAR(50),
    State VARCHAR(50),
    City VARCHAR(50),
    Zip_Code VARCHAR(10),
    Latitude VARCHAR(50),
    Longitude VARCHAR(50),
    Gender VARCHAR(10),
    Senior_Citizen VARCHAR(10),
    Partner VARCHAR(10),
    Dependents VARCHAR(10),
    Tenure_Months VARCHAR(10),
    Phone_Service VARCHAR(10),
    Multiple_Lines VARCHAR(20),
    Internet_Service VARCHAR(20),
    Online_Security VARCHAR(20),
    Online_Backup VARCHAR(20),
    Device_Protection VARCHAR(20),
    Tech_Support VARCHAR(20),
    Streaming_TV VARCHAR(20),
    Streaming_Movies VARCHAR(20),
    Contract VARCHAR(20),
    Paperless_Billing VARCHAR(10),
    Payment_Method VARCHAR(50),
    Monthly_Charges VARCHAR(50),
    Total_Charges VARCHAR(50),
    Churn_Label VARCHAR(10),
    Churn_Value VARCHAR(10),
    Churn_Score VARCHAR(10),
    CLTV VARCHAR(50),
    Churn_Reason VARCHAR(255)
);

BULK INSERT Telco_Customer_Churn
FROM 'C:\Users\AndréRM\Desktop\CICLO-2026-1\CURSO-ADICIONAL\SQL\REPOSITORIO\Proyecto-SQL-TelcoCustomerChurn\data\Telco_customer_churn.csv'
WITH (
	FORMAT = 'CSV',
    FIRSTROW = 2,           
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n' 
);

--PRUEBA DE CARGA DE DATOS
SELECT TOP 10 * FROM Telco_Customer_Churn
SELECT COUNT(1) FROM Telco_Customer_Churn

--BUSCAR VALORES VACIOS O NULOS
SELECT *
FROM Telco_Customer_Churn
WHERE Total_Charges='' OR Total_Charges IS NULL;

--SE CONVIERTE LOS VACIOS A NULL
UPDATE Telco_Customer_Churn
SET total_charges = NULL
WHERE total_charges = '';

--------------CREACIÓN DE TABLAS NORMALIZADAS-----------
--------------------------------------------------------
CREATE TABLE Clientes (
    customer_id VARCHAR(50) PRIMARY KEY,
    gender VARCHAR(10),
    senior_citizen VARCHAR(5),
    partner VARCHAR(5),
    dependents VARCHAR(5)
);

CREATE TABLE Ubicaciones (
    location_id INT IDENTITY(1,1) PRIMARY KEY,
    country VARCHAR(50),
    state VARCHAR(50),
    city VARCHAR(50),
    zip_code VARCHAR(10),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6)
);

CREATE TABLE Servicios (
    service_id INT IDENTITY(1,1) PRIMARY KEY,
    phone_service VARCHAR(10),
    multiple_lines VARCHAR(20),
    internet_service VARCHAR(20),
    online_security VARCHAR(20),
    online_backup VARCHAR(20),
    device_protection VARCHAR(20),
    tech_support VARCHAR(20),
    streaming_tv VARCHAR(20),
    streaming_movies VARCHAR(20)
);


CREATE TABLE Facturacion (
    billing_id INT IDENTITY(1,1) PRIMARY KEY,
    contract VARCHAR(20),
    Paperless_billing VARCHAR(10),
    Payment_method VARCHAR(50),
    monthly_charges DECIMAL(10,2),
    total_charges DECIMAL(10,2)
);

CREATE TABLE Churn (
    churn_id INT IDENTITY(1,1) PRIMARY KEY,
    churn_value BIT,
    churn_score INT,
    churn_reason VARCHAR(255),
    cltv INT
);

CREATE TABLE clientes_detalle (
    detalle_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id VARCHAR(50),
    location_id INT,
    service_id INT,
    billing_id INT,
    churn_id INT,
    tenure_months INT,

    FOREIGN KEY (customer_id) REFERENCES clientes(customer_id),
    FOREIGN KEY (location_id) REFERENCES ubicaciones(location_id),
    FOREIGN KEY (service_id) REFERENCES servicios(service_id),
    FOREIGN KEY (billing_id) REFERENCES facturacion(billing_id),
    FOREIGN KEY (churn_id) REFERENCES churn(churn_id)
);
--------------------------------------------------------

-----------INSERTAR DATOS A LA TABLA CLIENTES-----------
INSERT INTO Clientes (customer_id, gender, senior_citizen, partner, dependents)
SELECT DISTINCT
    CustomerID,
    Gender,
    Senior_Citizen,
    Partner,
    Dependents
FROM Telco_Customer_Churn;

--SE VERIFICA LA INSERCIÓN DE DATOS
SELECT * FROM clientes;

--SE VERIFICA SI HAY VALORES DUPLICADOS
SELECT customer_id, COUNT(*)
FROM Clientes
GROUP BY customer_id
HAVING COUNT(*) > 1;
--------------------------------------------------------

---------INSERTAR DATOS A LA TABLA UBICACIONES----------
INSERT INTO Ubicaciones(country,state,city,zip_code,latitude,longitude)
SELECT DISTINCT
	Country,
	State,
	City,
	Zip_Code,
	TRY_CAST(latitude AS DECIMAL(9,6)),
    TRY_CAST(longitude AS DECIMAL(9,6))
FROM Telco_Customer_Churn;

--SE VERIFICA LA INSERCIÓN DE DATOS
SELECT * FROM Ubicaciones

--------------------------------------------------------

---------INSERTAR DATOS A LA TABLA SERVICIOS------------
INSERT INTO Servicios(phone_service,multiple_lines,internet_service,online_security,online_backup,device_protection,
tech_support,streaming_tv,streaming_movies)
SELECT DISTINCT
	Phone_Service,
	Multiple_Lines,
	Internet_Service,
	Online_Security,
	Online_Backup,
	Device_Protection,
	Tech_Support,
	Streaming_TV,
	Streaming_Movies
FROM Telco_Customer_Churn

--LIMPIEZA DE DATOS (ESPACIADOS IZQUIERDO Y DERECHO)
UPDATE Servicios
SET 
    phone_service = LTRIM(RTRIM(phone_service)),
    multiple_lines = LTRIM(RTRIM(multiple_lines)),
    internet_service = LTRIM(RTRIM(internet_service)),
    online_security = LTRIM(RTRIM(online_security)),
    online_backup = LTRIM(RTRIM(online_backup)),
    device_protection = LTRIM(RTRIM(device_protection)),
    tech_support = LTRIM(RTRIM(tech_support)),
    streaming_tv = LTRIM(RTRIM(streaming_tv)),
    streaming_movies = LTRIM(RTRIM(streaming_movies));

--SE VERIFICA LA INSERCIÓN DE DATOS
SELECT * FROM Servicios

----------------------------------------------------------

---------INSERTAR DATOS A LA TABLA FACTURACIÓN------------
INSERT INTO FACTURACION(contract,Paperless_billing,Payment_method,monthly_charges,
total_charges)
SELECT DISTINCT
	Contract,
	Paperless_Billing,
	Payment_Method,
	TRY_CAST(monthly_charges AS DECIMAL(10,2)),
    TRY_CAST(total_charges AS DECIMAL(10,2))
FROM Telco_Customer_Churn

--SE VERIFICA LA INSERCIÓN DE DATOS
SELECT * FROM facturacion;

--LIMPIEZA DE DATOS (ESPACIADOS IZQUIERDO Y DERECHO)
UPDATE Facturacion
SET 
    contract = LTRIM(RTRIM(contract)),
    Paperless_billing = LTRIM(RTRIM(Paperless_billing)),
    Payment_method = LTRIM(RTRIM(Payment_method));

--------------------------------------------------------

-----------INSERTAR DATOS A LA TABLA CHURN--------------
INSERT INTO Churn(churn_value,churn_score,churn_reason,cltv)
SELECT DISTINCT
	TRY_CAST(churn_value AS BIT),
    TRY_CAST(churn_score AS INT),
    churn_reason,
    TRY_CAST(cltv AS INT)
FROM Telco_Customer_Churn

--SE VERIFICA LA INSERCIÓN DE DATOS
SELECT * FROM Churn

--------------------------------------------------------

------INSERTAR DATOS A LA TABLA CLIENTES DETALLE--------
--HACEMOS LA RELACION CON CADA TABLA NORMALIZADA PARA QUE PODAMOS OBTENER SU ID
--Y DE ESA MANERA MANDARLO A MI TABLA CLIENTES DETALLE
INSERT INTO clientes_detalle(customer_id,location_id,service_id,billing_id,churn_id,tenure_months)
SELECT
	TC.CustomerID,
    U.location_id,
    S.service_id,
    F.billing_id,
    C.churn_id,
    TRY_CAST(TC.tenure_months AS INT)
FROM Telco_Customer_Churn TC

INNER JOIN Ubicaciones U
    ON TC.Country = U.country
   AND TC.State = U.state
   AND TC.City = U.city
   AND TC.Zip_Code = U.zip_code
   AND TRY_CAST(TC.Latitude AS DECIMAL(9,6)) = U.latitude
   AND TRY_CAST(TC.Longitude AS DECIMAL(9,6)) = U.longitude

INNER JOIN Servicios S
    ON TC.Phone_Service = S.phone_service
   AND TC.Multiple_Lines = S.multiple_lines
   AND TC.Internet_Service= S.internet_service
   AND TC.Online_Security = S.online_security
   AND TC.Online_Backup = S.online_backup
   AND TC.Device_Protection = S.device_protection
   AND TC.Tech_Support = S.tech_support
   AND TC.Streaming_TV = S.streaming_tv
   AND TC.Streaming_Movies = S.streaming_movies

INNER JOIN Facturacion F
    ON TC.Contract = F.contract
   AND TC.Paperless_Billing = F.Paperless_billing
   AND TC.Payment_Method = F.Payment_method
   AND TRY_CAST(TC.Monthly_Charges AS DECIMAL(10,2)) = F.monthly_charges
   --AND TRY_CAST(TC.Total_Charges AS DECIMAL(10,2)) = F.total_charges
   AND ISNULL(TRY_CAST(TC.Total_Charges AS DECIMAL(10,2)), -1)
       = ISNULL(F.total_charges, -1)

INNER JOIN Churn C
    ON TRY_CAST(TC.Churn_Value AS BIT) = C.churn_value
   AND TRY_CAST(TC.Churn_Score AS INT) = C.churn_score
   AND (
		TC.Churn_Reason = C.churn_reason 
		OR (TC.Churn_Reason IS NULL AND C.churn_reason IS NULL)
		)
   AND TRY_CAST(TC.CLTV AS INT) = C.cltv;

   --SE VERIFICA LA INSERCIÓN DE DATOS
SELECT COUNT(1) FROM clientes_detalle
SELECT * FROM clientes_detalle