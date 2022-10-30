# coworkingMadrid

## Business Question
This project started when my company thought about participating in a joint venture to rent co-working spaces. Information about current prices was needed to take an informed decision, comparing prices based on the location of our building. 

## Data
Most of the offers were in the Spanish portal Milanuncios, so we decided to use it as a source of information. We will create a search in the portal and collect data from each advertisement.
The collected data included district and price in euros by square meter.
Milanuncios is not the only portal that contains this sort of information; however, we do not expect it to be substantially different from the data in other portals. Therefore, our data could be considered a fair sample.To collect the data, a web scrap process was created. This included a try catch function to avoid the complete lost of information. 
The retrieved data had all the information we needed to create a guide of the prices, according to different locations in the city. With them, the CEO could take an informed decision.


## Final Products
1. Scrap data from Milanuncios about co working spaces in Madrid, Spain.
2. Creates the average price by zone every week.

### Evolución de los precios del Coworking (may-jul, 2021)
<img src="lineasCoworking.png" alt="drawing" width="300"/>

### Precio por metro cuadrado según área de Madrid (jul. 2021)
<img src="coworking.png" alt="drawing" width="300"/>

