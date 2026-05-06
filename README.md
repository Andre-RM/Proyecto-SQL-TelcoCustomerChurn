#  ProyectoSQL: Análisis de Churn en Clientes de Telecomunicaciones
## Resumen (Overview)
_Este proyecto consiste en un análisis exploratorio y descriptivo de datos (EDA) utilizando **SQL Server** para identificar los factores críticos que influyen en la deserción de clientes en una empresa de telecomunicaciones. Mi objetivo principal es transformar datos brutos en información estratégica que permita al departamento de retención tomar decisiones basadas en evidencia. A través de consultas avanzadas, se analizan patrones demográficos, tipos de contrato y comportamiento de facturación para segmentar a los clientes con mayor riesgo de abandono._

## Estructura del Proyecto
- [Sobre los Datos](#sobre-los-datos)
- [Limpieza y validación](#tareas)
- [Tareas](#limpieza-de-datos)
- [Análisis Exploratorio de Datos e Insights](#análisis-exploratorio-de-datos-e-insights)

## Sobre los datos
Los datos originales, junto con una explicacion de cada columna, se pueden encontrar [aqui](https://www.kaggle.com/datasets/abdallahwagih/telco-customer-churn).
El conjunto de datos proviene de una tabla de 33 columnas con mas de 7000 registros.

![TCC Analytics](picture\sobre-los-datos-1.PNG)

## Proceso ETL
Para este proyecto se realizo un proceso ETL lo que incluyo:
- Carga de datos mediante BULK INSERT en una tabla.
- Limpieza de datos (valores nulos, espacios en blanco)
- Conversión de tipos de datos (VARCHAR a INT, DECIMAL, BIT)
- Manejo de valores NULL en los JOINs

## Modelado de datos
A partir de una tabla inicial, se diseño un modelo relacional para organizar la informacion.
Se crearon las siguiente tablas:
- Clientes
- Ubicaciones
- Servicios
- Facturacion
- Churn
- clientes_detalle

Este enfoque permitio mejorar la integridad de los datos.
![TCC Analytics](picture\modelado-datos-1.PNG)