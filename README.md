# Ventas de una cadena de supermercados en Estados Unidos
### Python + SQL

---

![](https://github.com/jisoto4/ventas-supermercado/blob/main/supermarket.webp)



El análisis de ventas y márgenes es fundamental para la toma de decisiones estratégicas en cualquier negocio, especialmente en el sector minorista. Este proyecto se centra en el estudio del desempeño de una cadena de supermercados en Estados Unidos que comercializa muebles, artículos de oficina y artículos tecnológicos. A través del análisis de datos de ventas y márgenes de ganancia, se busca identificar patrones, evaluar la rentabilidad de los diferentes productos y categorías, y detectar oportunidades de mejora.

En un mercado altamente competitivo y en constante evolución, comprender el comportamiento de las ventas y la eficiencia en la gestión de los márgenes permite optimizar la estrategia comercial, mejorar la planificación del inventario y diseñar promociones efectivas. Además, el auge del comercio electrónico y los cambios en las preferencias de los consumidores hacen que este tipo de análisis sea aún más relevante para garantizar la sostenibilidad y el crecimiento del negocio.

Este proyecto busca proveer insights valiosos que ayuden a los equipos relevantes a tomar decisiones más informadas sobre qué productos son más y menos rentables, en qué periodos hay mayor venta, qué tipo de productos vender y cómo orientar posibles campañas de marketing.

El dataset considera información detallada de las operaciones de un supermercado, abarcando información transaccional, demográfica y geográfica. 

- Los datos fueron obtenidos desde [Kaggle](https://www.kaggle.com/datasets/aditirai2607/super-market-dataset)
- Considera análisis principalmente exploratorio
- Se utilizó K-means para generar una segmentación de clientes
- Se limpiaron los datos en python y se analizó la información en PostgreSQL

---

Al analizar el dataset, se plantea responder las siguientes preguntas:

1. ¿Cuáles son los 10 productos que más ingresos generan?
2. ¿Cuáles son los 5 productos más vendidos en cada región?
3. Determinar el crecimiento mensual de ventas para cada año (2021 a 2024)
4. Para cada categoría determinar en qué mes se obtuvieron las mayores ventas
5. ¿Qué sub-categoría tuvo mayor crecimiento de margen en cada año?
6. ¿Cuántos días demora en promedio cada método de despacho? ¿Hay diferencias por region?
7. ¿Cuáles son los 3 Clientes que más compran en cada año? ¿Cómo se comportan a través del tiempo?
8. Describir el comportamiento de los segmentos generados por K-means
