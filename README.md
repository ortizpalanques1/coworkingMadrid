# coworkingMadrid

## Business Question
This project started when my company thought about participating in a joint venture to rent co-working spaces. Information about current prices was needed to take an informed decision, comparing prices based on the location of our building. 

## Data
Most of the offers were in the Spanish portal Milanuncios, so we decided to use it as a source of information. We will create a search in the portal and collect data from each advertisement.

The collected data included district and price in euros by square meter.
Milanuncios is not the only portal that contains this sort of information; however, we do not expect it to be substantially different from the data in other portals. Therefore, our data could be considered a fair sample.To collect the data, a web scrap process was created. This included a try catch function to avoid the complete lost of information. 

The retrieved data had all the information we needed to create a guide of the prices, according to different locations in the city. With them, the CEO could take an informed decision.

## Processing the Data
Once we had an idea of our data, the process of collecting and store them began. We chose R and RStudio because both tools allow us to get the data from the web and assess them in a single process. 

Data were scraped from Milanuncios following a definite pattern:
1. The number of pages to scrap were determined with an initial order that capture the information in the first page of a simulated search result. Afterwards, we created a loop to read the information from the second to the last web page with information.
2. In the same process of collecting the information, the corresponding format (date, numeric, character) was added.
3. A try catch process guarantees that problematic data (incomplete mainly) were discarded.
4. After several tests, all the cleaning process was done inside the script. No additionally operations were needed.

## Analysis
Data were stored in a data frame containing the following information: quarter in Madrid (according the add), the price for square meter in each quarter and the weighted average for all the region. Data were formatted accordingly.
Most of the data were classified under the generic label "Madrid", therefore we missed one important piece of information. Our company was located in the South part of Madrid, where prices were lower; therefore, we were interested in a segmentation that could reflect these differences. Only one add made direct reference to the South, and it was very low compared to the global average. Other important aspect was the absence of clear trends in the quarters. 
Despite these hindrances, we could obtain a good picture of the prices. The high prices in Madrid and Pozuelo del Alarcón clearly contrasted with the low value found for the Southern municipality of Parla. Those high prices, also, raise the global average in such a way that, using it, we obtain a biased picture of the marked.



## Share
Our original question was what were the prices of different co-working spaces in Madrid? Our data addressed this question and, with the right analysis could present a clear picture of the situation from May to July, 2021. Although some data were missing, the trend was clear. The high prices in the city of Madrid contrasted with the low prices in the South of the province.
The participant in the short lived joint venture had information, in the form of charts, that allowed them to be informed, week by week, of the evolution of the prices. We presented our findings in two charts. The first one presented the evolution by quarters in Madrid; whilst the second gave us the picture for every week. The charts were send via email, so each member had the information when nedeed.

### Evolución de los precios del Coworking (may-jul, 2021)
<img src="lineasCoworking.png" alt="drawing" width="500"/>

### Precio por metro cuadrado según área de Madrid (jul. 2021)
<img src="coworking.png" alt="drawing" width="300"/>

