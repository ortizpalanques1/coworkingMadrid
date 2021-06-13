# Librerías
library(rvest)
library(tidyverse)
library(ggrepel)

# Cargar datos
datoSemanal <- readRDS("datoSemanal.Rds")
# Funciones
nombrePropio <- function(x){
  separador <- c(unlist(strsplit(x,"\\s")))
  for(l in 1:length(separador)){
    substr(separador[l], 1, 1) <- toupper(substr(separador[l], 1, 1))
    separador[l]
  }
  nombreAqui <- paste(separador,collapse=" ")
}

# Crear el vector con los nombres de las páginas
# Número 1
# https://www.milanuncios.com/alquiler-de-oficinas-en-madrid/coworking.htm?demanda=n
# subsiguientes hasta el 5
# https://www.milanuncios.com/alquiler-de-oficinas-en-madrid/coworking.htm?demanda=n&pagina=2
paginaPrimera <- "https://www.milanuncios.com/alquiler-de-oficinas-en-madrid/coworking.htm?demanda=n"
arrancador <- read_html(paginaPrimera)
tengoBody <- html_nodes(arrancador,".adlist-paginator-pages")
tengoPaginas <- html_text(tengoBody)
tengoPaginas <- gsub("\\\t\\\t","",tengoPaginas)
tengoPaginas <- gsub("\\\n","",tengoPaginas)
tengoPaginas <- gsub("[[:alpha:]]","",tengoPaginas)
tengoPaginas <- trimws(unlist(strsplit(tengoPaginas,"\\\t")))
tengoPaginas <- as.numeric(max(tengoPaginas))
paginaSubsiguiente <- c(paste0("https://www.milanuncios.com/alquiler-de-oficinas-en-madrid/coworking.htm?demanda=n&pagina=",seq(2:tengoPaginas)))
todasLasPaginas <- c(paginaPrimera,paginaSubsiguiente)
diaDeHoy <- Sys.Date()
diaDeHoy <- as.character.Date(format(diaDeHoy,"%d/%m/%Y"))

# Cargar la información de las páginas web
coworkingInfo <- list()
for(p in 1:length(todasLasPaginas)){
  leida <- read_html(todasLasPaginas[p]) 
  coworkingInfo[[paste0("element", p)]] <- leida
}

# Reproducibilidad
# save(coworkingInfo, file="coworkingInfo2.RData")
# load("coworkingInfo2.RData")

# Procesar la información
granTotal <- NULL
for(k in 1:length(coworkingInfo)){ 
  todo <- html_nodes(coworkingInfo[[paste0("element",k)]],".aditem-detail-image-container")
  todoPrecio <- NULL
  todoTitulo <- NULL
  todoRegion <- NULL
  todoPonderado <- NULL
  for(i in 1:length(todo)){
    tryCatch({ 
      extractorTitulo <- html_node(todo[[i]],".aditem-detail-title")
      intermedioTitulo <- html_text(extractorTitulo)
      todoTitulo <- c(todoTitulo,intermedioTitulo)
      
      extractorRegion <- html_node(todo[[i]],".list-location-region")
      intermedioRegion <- html_text(extractorRegion)
      todoRegion <- c(todoRegion,intermedioRegion)
      
      extractorPrecio <- html_node(todo[[i]],".aditem-price")
      intermedioPrecio <- html_text(extractorPrecio)
      todoPrecio <- c(todoPrecio,intermedioPrecio)
      
      extractorPonderado <- html_node(todo[[i]],".tag-mobile")
      intermedioPonderado <- html_text(extractorPonderado)
      todoPonderado <- c(todoPonderado,intermedioPonderado)
      
      todoPagina <- data.frame(todoTitulo,todoRegion,todoPrecio,todoPonderado)
     
    }, error = function(e) NA)  
  }
  granTotal <- rbind(granTotal,todoPagina)
}

# Arreglo de los textos
granTotal$todoRegion <- sapply(granTotal$todoRegion,nombrePropio)
granTotal$todoPrecio <- gsub("\\.","",granTotal$todoPrecio)
granTotal$todoPrecio <- gsub("€","",granTotal$todoPrecio)
granTotal$todoPrecio <- as.numeric(as.character(granTotal$todoPrecio))
granTotal$todoPonderado <- gsub("m2","",granTotal$todoPonderado)
granTotal$todoPonderado <- as.numeric(as.character(granTotal$todoPonderado))

# Graficar
## 1. Precio promedio total por metro cuadrado: sólo el número
granTotal$promedioM2 <- (granTotal$todoPrecio/granTotal$todoPonderado)
granTotal <- granTotal %>% 
  dplyr::filter(promedioM2 >=8)
promedioTotal <- mean(granTotal$promedioM2,na.rm = TRUE)

## 2. Precio promedio por zona anunciada por metro cuadrado: gráfico de barras 

totalPorZona <- granTotal %>% 
  dplyr::select(-1) %>% 
  mutate(promedioM2=todoPrecio/todoPonderado) %>% 
  group_by(todoRegion) %>% 
  dplyr::select(todoRegion,promedioM2) %>%   
  summarise(PromedioM2 = mean(round(promedioM2,2),na.rm=TRUE)) %>% 
  dplyr::filter(!is.nan(PromedioM2)) %>% 
  add_row(todoRegion = "Promedio", PromedioM2=promedioTotal) %>% 
  mutate(tipo=ifelse(todoRegion=="Promedio","A","B")) 

graphBar <-   ggplot(totalPorZona,aes(x=reorder(todoRegion, PromedioM2),y=PromedioM2, fill=tipo,label=round(PromedioM2,1))) +
  geom_col() +
  geom_text(aes(y=5), fontface="bold", color="#393b45") +
  scale_fill_manual(values=c("A"="#6e7889","B"="#f3b54a"))+
  labs(title="Coworking en Madrid. Precio promedio por m2",
       subtitle = paste0("Información de los propios anunciantes ",diaDeHoy),
       y = "Euros por metro cuadrado",
       x = "",
       caption = "Fuente: Milanuncios"
       )+
  coord_flip()+
  theme(
    plot.caption = element_text(hjust = 0, face= "italic", color="#393b45"), #Default is hjust=1
    plot.title.position = "plot", #NEW parameter. Apply for subtitle too.
    plot.caption.position =  "plot",
    title = element_text(size = 8),
    text = element_text(color="#393b45", face="bold"),
    axis.text.y = element_text(size = 6),
    axis.text.x = element_blank(),
    axis.ticks = element_blank(),
    legend.position = "none",
    plot.background = element_rect(fill="#d8d9de"),
    panel.background = element_rect(fill="#d8d9de"),
    panel.grid = element_line(color="#d8d9de")
  )
ggsave("coworking.png", graphBar, height = 10, width = 10, units = "cm")

  
tablaSintesis <- totalPorZona[c("todoRegion", "PromedioM2")]  
colnames(tablaSintesis)[2] <- diaDeHoy
datoSemanal <- full_join(datoSemanal,tablaSintesis,by="todoRegion") 
saveRDS(datoSemanal, file = "datoSemanal.Rds")



## 3.Trend
### 3.1. Cread Data Frame
trend <- datoSemanal %>% 
  pivot_longer(cols = 2:ncol(datoSemanal),
               names_to = "Fecha", 
               values_to = "Precio") %>% 
  mutate(Fecha=as.Date(Fecha, format = "%d/%m/%Y"),
         esPromedio=ifelse(todoRegion=="Promedio","A","B"),
         Texto = paste0(todoRegion,", € ",round(Precio,1)),
         Texto = gsub("\\.",",",Texto))
trend$Texto <- sapply(trend$Texto,nombrePropio)

### 3.2. Asignar colores: https://statisticsglobe.com/r-assign-fixed-colors-to-categorical-variables-in-ggplot2-plot
colores <- c("#6e7889", "#f3b54a")
names(colores) <- levels(factor(c(levels(trend$esPromedio)))) 

### 3.3. El gráfico
trendGraph <- ggplot(trend,aes(x=Fecha,y=Precio,group=todoRegion, color=factor(esPromedio)))+
  geom_line(data=trend[!is.na(trend$Precio),],size=1.5) + 
  geom_text_repel(data = subset(trend, Fecha == max(Fecha)),
            aes(label = Texto, color="blue"), direction = "y", hjust = "left")+
  xlim(min(trend$Fecha),max(trend$Fecha)+7)+
  labs(title = "Madrid: Evolución del precio de espacios coworking",
       subtitle = paste0("Información de los propios anunciantes ",diaDeHoy),
       y = "Euros por metro cuadrado",
       caption = "Fuente: Milanuncios y cálculos propios")+
  scale_color_manual(name = trend$esPromedio, values = c(colores,"#393b45"))+
  theme(axis.title.x = element_blank(),
        legend.position = "none",
        plot.background = element_rect(fill="#d8d9de"),
        panel.background = element_rect(fill="#d8d9de"),
        panel.grid.major.x  = element_line(color="#d8d9de"),
        panel.grid.minor.x  = element_line(color="#d8d9de"),
        panel.grid.minor.y  = element_line(color="#d8d9de"),
        text = element_text(color = "#393b45")
        )
 ggsave("lineasCoworking.png",trendGraph, width = 10, height = 5, units = "in", device = "png") 
 