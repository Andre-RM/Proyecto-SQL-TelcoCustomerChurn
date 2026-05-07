#  ProyectoSQL: Análisis de Churn en Clientes de Telecomunicaciones
## Resumen (Overview)
_La empresa de telecomunicaciones **PrimeLink Network** busca reducir la pérdida de clientes y mejorar sus estrategias de retención. Sin embargo, actualmente no cuenta con una visión clara sobre los factores que influyen en el abandono de sus servicios.
El objetivo de este proyecto es utilizar **SQL Server** para analizar la información de los clientes y detectar patrones relacionados con el churn. A través de consultas y análisis de datos, se evaluarán variables como el tipo de contrato, servicios contratados, métodos de pago, cargos mensuales y antigüedad del cliente._

## Estructura del Proyecto
- [Sobre los datos](#sobre-los-datos)
- [Modelado de datos](#modelado-datos)
- [Limpieza de datos](#tareas)
- [Tareas](#limpieza-de-datos)
- [Análisis Exploratorio de Datos e Insights](#análisis-exploratorio-de-datos-e-insights)
- [Conclusiones](#conclusiones)

## Sobre los datos
Los datos originales, junto con una explicacion de cada columna, se pueden encontrar [aqui](https://www.kaggle.com/datasets/abdallahwagih/telco-customer-churn).
El conjunto de datos proviene de una tabla de 33 columnas con mas de 7000 registros.

![TCC Analytics](./picture/sobre-los-datos-1.PNG)

## Modelado de datos
A partir de una tabla inicial, se diseño un modelo relacional para organizar la informacion.
Se crearon las siguientes tablas:
- Clientes
- Ubicaciones
- Servicios
- Facturacion
- Churn
- clientes_detalle

Este enfoque permitio mejorar la integridad de los datos.

![TCC Analytics](./picture/modelado-datos-1.PNG)

## Tareas (Task)
1. ¿Cuántos clientes hay en total y cuantos aún permanecen?
2. ¿Cuántos clientes abandonaron y qué porcentaje representan del total?
3. ¿Cuál es la distribución de clientes por tipo de contrato?
4. ¿Cuál es el promedio de monthly_charges(cargos mensuales) por tipo de contrato?
5. ¿Qué método de pago tiene más clientes y que porcentaje representa?
6. ¿Cuál es la tasa de churn(abandono) por tipo de contrato?
7. ¿Qué tipo de servicio de internet tiene más churn(abandono)?
8. ¿Top 5 ciudades con mayor cantidad de clientes que abandonaron?
9. ¿Clientes con mayor CLTV que NO han hecho churn(abandono)?
10. ¿Cuáles son las razones más recurrentes por la cual los clientes abandonan dichos servicios?

## Limpieza de datos
Fue necesario realizar una etapa de limpieza y validación de la información cargada desde el archivo CSV.

Durante esta etapa se identificaron algunos problemas comunes en los datos, como valores vacíos, posibles duplicados y espacios innecesarios.

```sql
--BUSCA VACIOS O VALORES NULOS EN MI TABLA TELCO_CUSTOMER 
SELECT *
FROM Telco_Customer_Churn
WHERE Total_Charges='' OR Total_Charges IS NULL;
```
Se identifico valores vacíos por lo hubo una conversión a valores nulos.

```sql
UPDATE Telco_Customer_Churn
SET total_charges = NULL
WHERE total_charges = '';
```

También se verifico que no hubiera valores repetidos, además de una limpieza de espacios en blancos.
```sql
--SE VERIFICA SI HAY VALORES DUPLICADOS EN MI TABLA CLIENTES
SELECT customer_id, COUNT(*)
FROM Clientes
GROUP BY customer_id
HAVING COUNT(*) > 1;

--LIMPIEZA DE ESPACIOS EN BLANCO PARA LA TABLA SERVICIOS
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

--LIMPIEZA DE ESPACIOS EN BLANCO PARA LA TABLA FACTURACION
UPDATE Facturacion
SET 
    contract = LTRIM(RTRIM(contract)),
    Paperless_billing = LTRIM(RTRIM(Paperless_billing)),
    Payment_method = LTRIM(RTRIM(Payment_method));

```

## Análisis Exploratorio de Datos (EDA) e Insights
### 1. ¿Cuántos clientes hay en total y cuantos aún permanecen?

Se realizó un conteo general de clientes registrados en la base de datos y, posteriormente, un conteo específico de aquellos clientes que aún permanecen activos en la empresa.

Se utilizó la función COUNT() para obtener la cantidad total de registros y una subconsulta junto con INNER JOIN para relacionar la tabla clientes_detalle con la tabla churn, donde se identifica si un cliente abandonó o continúa utilizando el servicio.

El campo churn_value fue utilizado como indicador de estado:
- 0 -> Cliente permanece activo
- 1 -> Cliente abandono

```sql
SELECT COUNT(1) AS NRO_CLIENTES,
		(SELECT COUNT(1) 
			FROM clientes_detalle CD
			INNER JOIN Churn C ON CD.churn_id=C.churn_id
			WHERE C.churn_value=0 --0 = PERMANECEN / 1 = ABANDONARON
		) AS PERMANECEN
FROM Clientes
```
![image](/picture/preg-1.PNG)

Esta métrica sirve como punto de partida para comprender el nivel general de retención y dimensionar el impacto del churn dentro del negocio.

### 2. ¿Cuántos clientes abandonaron y qué porcentaje representan del total?

Para este análisis se utilizó una expresión común de tabla (CTE) con el objetivo de calcular primero la cantidad de clientes que abandonaron el servicio y reutilizar ese resultado posteriormente en el cálculo final.

```sql
WITH CLIENTES_ABANDONO AS(
	SELECT COUNT(CD.customer_id) AS ABANDONOS
	FROM clientes_detalle CD
	INNER JOIN Churn C ON CD.churn_id=C.churn_id
	WHERE C.churn_value=1
)
SELECT 
    COUNT(C.customer_id) AS NRO_CLIENTES,
    (SELECT ABANDONOS FROM CLIENTES_ABANDONO) AS ABANDONOS,
    CAST(((SELECT ABANDONOS FROM CLIENTES_ABANDONO) * 100.0 / COUNT(C.customer_id)) AS DECIMAL(10,2)) AS REPRESENTACION
FROM Clientes AS C;
```
![image](/picture/preg-2.PNG)

El análisis permitió identificar cuántos clientes abandonaron el servicio y qué proporción representan dentro de la cartera total de clientes. Ademas, un porcentaje elevado de abandono podría indicar problemas relacionados con satisfacción del cliente, costos, soporte técnico o condiciones contractuales.

### 3. ¿Cuál es la distribución de clientes por tipo de contrato?

Se relacionó la tabla clientes_detalle con la tabla facturacion mediante un INNER JOIN, ya que la información sobre los contratos se encuentra almacenada en esta última.

Posteriormente, se utilizó GROUP BY para agrupar a los clientes según el tipo de contrato y la función COUNT() para calcular la cantidad de clientes en cada categoría.

```sql
SELECT F.contract,
	   COUNT(CD.customer_id) AS Nro_clientes,
	   CAST(COUNT(CD.customer_id) *100.0/ (SELECT COUNT(CD.customer_id)
			FROM clientes_detalle CD) AS DECIMAL (10,2)) Representacion
FROM clientes_detalle CD
INNER JOIN Facturacion F ON CD.billing_id = F.billing_id
GROUP BY F.contract
```
![image](/picture/preg-3.PNG)

Se identificó que la mayor parte de clientes estan bajo el contrato de "Month-to-Month" siendo el 55.02 %.
La empresa podría utilizar esta información para evaluar estrategias que incentiven a los clientes a migrar hacia contratos de mayor duración mediante descuentos, beneficios exclusivos o programas de fidelización.

### 4. ¿Cuál es el promedio de monthly charges(cargos mensuales) por tipo de contrato?

Se aplicó la función AVG() para calcular el promedio de monthly_charges según cada tipo de contrato. Posteriormente, se utilizó CAST() para mostrar el resultado con dos decimales y facilitar la lectura de los datos.

```sql
SELECT contract, 
		CAST(AVG(monthly_charges) AS DECIMAL(10,2)) AS PROMEDIO_CARGOS_MENSUALES
FROM Facturacion
GROUP BY contract
```
![image](/picture/preg-4.PNG)

Según el análisis los clientes con contratos mensuales (Month-to-month) presentan el promedio de cargos mensuales más alto.

Esto podría indicar que los clientes con contratos de corta duración adquieren servicios más costosos o planes con mayor flexibilidad. Sin embargo, este tipo de contrato también suele estar asociado a mayores tasas de churn, lo que representa un posible riesgo para la empresa.

La empresa podría evaluar estrategias para incentivar a los clientes con contratos mensuales a migrar hacia contratos de mayor duración mediante descuentos, beneficios exclusivos o mejoras en el servicio.

Esto permitiría mantener ingresos recurrentes mientras se reduce el riesgo de abandono asociado a contratos de corto plazo

### 5. ¿Qué método de pago tiene más clientes y qué porcentaje representa?

Se relacionaron las tablas clientes_detalle y facturacion mediante un INNER JOIN. Luego, se utilizó COUNT() para obtener la cantidad de clientes por método de pago y TOP 1 junto con ORDER BY DESC para identificar el método más utilizado.

```sql
SELECT TOP 1 F.Payment_method,
		COUNT(CD.customer_id) AS Nro_clientes,
		CAST(COUNT(CD.customer_id) *100.0/ (SELECT COUNT(CD.customer_id)
					FROM clientes_detalle CD) AS DECIMAL (10,2)) Representacion
FROM clientes_detalle CD
INNER JOIN Facturacion F ON CD.billing_id=F.billing_id
GROUP BY F.Payment_method
ORDER BY Nro_clientes DESC
```
![image](/picture/preg-5.PNG)

El método de pago más utilizado por los clientes es "Electronic check", representando aproximadamente un tercio de toda la cartera de clientes.
