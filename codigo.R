---
  title: "Estado del COVID-19 en Costa Rica"
output: 
  flexdashboard::flex_dashboard:
  orientation: rows
social: menu
source_code: embed
vertical_layout: fill    
---
  
  ```{r setup, include=FALSE}

#-------------------- Paquetes --------------------

library(flexdashboard)
library(plotly)
library(dygraphs)
library(dplyr)
library(tidyr)
library(sf)
library(leaflet)

#-------------------- Colores ---------------------

color_positivos <- 'blue'
color_activos <- 'orange'
color_recuperados <- 'green'
color_fallecidos <- 'purple'

color_nuevos_positivos <- 'red'

color_hospitalizados <- 'teal'
color_salon <- 'teal'
color_uci <- 'teal'

#--------------------- Íconos ---------------------

icono_positivos <- 'fas fa-users'
icono_activos <- 'fas fa-users'
icono_recuperados <- ' fas fa-users'
icono_fallecidos <- 'fas fa-users'
icono_mujeres <- 'fas fa-female'
icono_hombres <- 'fas fa-male' 
icono_menor <- 'fas fa-child'
icono_adultom <- 'fas fa-blind'

icono_nuevos_positivos <- 'fas fa-users'

icono_hospitalizados <- 'fa-hospital'
icono_salon <- ' fa-hospital'
icono_uci <- 'fa-procedures'

#--------------- Otros parámetros -----------------

# Separador para lectura de datos CSV
caracter_separador <- ','

#--------------- Archivos de datos ----------------

archivo_general_pais <- 'https://raw.githubusercontent.com/geoprocesamiento-2020i/datos/master/covid19/ms/06_29_CSV_GENERAL.csv'

archivo_positivos_cantones <- 'https://raw.githubusercontent.com/geoprocesamiento-2020i/datos/master/covid19/ms/06_29_CSV_POSITIVOS.csv'

archivo_activos_cantones <- 'https://raw.githubusercontent.com/geoprocesamiento-2020i/datos/master/covid19/ms/06_29_CSV_ACTIVOS.csv'

archivo_recuperados_cantones <- 'https://raw.githubusercontent.com/geoprocesamiento-2020i/datos/master/covid19/ms/06_29_CSV_RECUP.csv'

archivo_fallecidos_cantones <- 'https://raw.githubusercontent.com/geoprocesamiento-2020i/datos/master/covid19/ms/06_29_CSV_FALLECIDOS.csv'

#---------------------- Datos País ---------------------

# Data frame de datos generales por país
df_general_pais <- read.csv(archivo_general_pais, sep = caracter_separador)
df_general_pais$FECHA <- as.Date(df_general_pais$FECHA, "%d/%m/%Y")

# Data frame de datos generales por país en la última fecha
df_general_pais_ultima_fecha <- 
  df_general_pais %>%
  filter(FECHA == max(FECHA, na.rm = TRUE))

# Data frame de datos generales por país en la penúltima fecha


# Data frame de datos generales por país en la última fecha


#---------------------- Datos Positivos ---------------------
# Data frame de casos positivos por cantón
df_positivos_cantones_ancho <- read.csv(archivo_positivos_cantones, sep = caracter_separador)
df_positivos_cantones <-
  df_positivos_cantones_ancho %>%
  pivot_longer(cols = c(-cod_provin, -provincia, -cod_canton, -canton), names_to = "fecha", values_to = "positivos")
df_positivos_cantones$fecha <- as.Date(df_positivos_cantones$fecha, "X%d.%m.%Y")

# Data frame de casos positivos por cantón en la última fecha
df_positivos_cantones_ultima_fecha <- 
  df_positivos_cantones %>%
  filter(fecha == max(fecha, na.rm = TRUE)) %>%
  select(cod_canton, positivos)

# Objeto sf de cantones
url_base_wfs_ign_5mil <- "http://geos.snitcr.go.cr/be/IGN_5/wfs?"
solicitud_wfs_ign_5mil_cantones <- "request=GetFeature&service=WFS&version=2.0.0&typeName=IGN_5:limitecantonal_5k&outputFormat=application/json"
sf_cantones <-
  st_read(paste0(url_base_wfs_ign_5mil, solicitud_wfs_ign_5mil_cantones)) %>%
  st_simplify(dTolerance = 1000) %>%
  st_transform(4326)

# Objeto sf de casos positivos en cantones en la última fecha
sf_positivos_cantones_ultima_fecha <-
  left_join(sf_cantones, df_positivos_cantones_ultima_fecha, by = c('cod_canton')) %>%
  arrange(desc(positivos))


#---------------------- Datos activos ---------------------

#Data frame de casos activos por cantón
df_activos_cantones_ancho <- read.csv(archivo_activos_cantones, sep = caracter_separador)
df_activos_cantones <-
  df_activos_cantones_ancho %>%
  pivot_longer(cols = c(-cod_provin, -provincia, -cod_canton, -canton), names_to = "fecha", values_to = "activos")
df_activos_cantones$fecha <- as.Date(df_activos_cantones$fecha, "X%d.%m.%Y")

#Data frame de casos activos por cantón en la última fecha
df_activos_cantones_ultima_fecha <- 
  df_activos_cantones %>%
  filter(fecha == max(fecha, na.rm = TRUE)) %>%
  select(cod_canton, activos)

# Objeto sf de cantones
url_base_wfs_ign_5mil <- "http://geos.snitcr.go.cr/be/IGN_5/wfs?"
solicitud_wfs_ign_5mil_cantones <- "request=GetFeature&service=WFS&version=2.0.0&typeName=IGN_5:limitecantonal_5k&outputFormat=application/json"
sf_cantones <-
  st_read(paste0(url_base_wfs_ign_5mil, solicitud_wfs_ign_5mil_cantones)) %>%
  st_simplify(dTolerance = 1000) %>%
  st_transform(4326)

# Objeto sf de casos activos en cantones en la última fecha
sf_activos_cantones_ultima_fecha <-
  left_join(sf_cantones, df_activos_cantones_ultima_fecha, by = c('cod_canton')) %>%
  arrange(desc(activos))


#---------------------- Datos Recuperados ---------------------
# Data frame de casos recuperados por cantón
df_recuperados_cantones_ancho <- read.csv(archivo_recuperados_cantones, sep = caracter_separador)
df_recuperados_cantones <-
  df_recuperados_cantones_ancho %>%
  pivot_longer(cols = c(-cod_provin, -provincia, -cod_canton, -canton), names_to = "fecha", values_to = "recuperados")
df_recuperados_cantones$fecha <- as.Date(df_recuperados_cantones$fecha, "X%d.%m.%Y")

# Data frame de casos recuperados por cantón en la última fecha
df_recuperados_cantones_ultima_fecha <- 
  df_recuperados_cantones %>%
  filter(fecha == max(fecha, na.rm = TRUE)) %>%
  select(cod_canton, recuperados)

# Objeto sf de cantones
url_base_wfs_ign_5mil <- "http://geos.snitcr.go.cr/be/IGN_5/wfs?"
solicitud_wfs_ign_5mil_cantones <- "request=GetFeature&service=WFS&version=2.0.0&typeName=IGN_5:limitecantonal_5k&outputFormat=application/json"
sf_cantones <-
  st_read(paste0(url_base_wfs_ign_5mil, solicitud_wfs_ign_5mil_cantones)) %>%
  st_simplify(dTolerance = 1000) %>%
  st_transform(4326)

# Objeto sf de casos recuperados en cantones en la última fecha
sf_recuperados_cantones_ultima_fecha <-
  left_join(sf_cantones, df_recuperados_cantones_ultima_fecha, by = c('cod_canton')) %>%
  arrange(desc(recuperados))

#---------------------- Datos Fallecidos ---------------------
# Data frame de casos fallecidos por cantón

df_fallecidos_cantones_ancho <- read.csv(archivo_fallecidos_cantones, sep = caracter_separador)
df_fallecidos_cantones <-
  df_fallecidos_cantones_ancho %>%
  pivot_longer(cols = c(-cod_provin, -provincia, -cod_canton, -canton), names_to = "fecha", values_to = "fallecidos")
df_fallecidos_cantones$fecha <- as.Date(df_fallecidos_cantones$fecha, "X%d.%m.%Y")

# Data frame de casos fallecidos por cantón en la última fecha
df_fallecidos_cantones_ultima_fecha <- 
  df_fallecidos_cantones %>%
  filter(fecha == max(fecha, na.rm = TRUE)) %>%
  select(cod_canton, fallecidos)

# Objeto sf de cantones
url_base_wfs_ign_5mil <- "http://geos.snitcr.go.cr/be/IGN_5/wfs?"
solicitud_wfs_ign_5mil_cantones <- "request=GetFeature&service=WFS&version=2.0.0&typeName=IGN_5:limitecantonal_5k&outputFormat=application/json"

sf_cantones <-
  st_read(paste0(url_base_wfs_ign_5mil, solicitud_wfs_ign_5mil_cantones)) %>%
  st_simplify(dTolerance = 1000) %>%
  st_transform(4326)

# Objeto sf de casos fallecidos en cantones en la última fecha
sf_fallecidos_cantones_ultima_fecha <-
  left_join(sf_cantones, df_fallecidos_cantones_ultima_fecha, by = c('cod_canton')) %>%
  arrange(desc(fallecidos))





```

Resumen
=======================================================================
  Row {data-height=1}
-----------------------------------------------------------------------
  ### **Última actualización: `r  df_general_pais_ultima_fecha$FECHA`**
  
  
  Row
-----------------------------------------------------------------------
  
  ### Casos positivos {.value-box}
  ```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$positivos, big.mark = ","), "", sep = " "), 
         caption = "Total de casos positivos", 
         icon = icono_positivos, 
         color = color_positivos
)
```

### Casos activos {.value-box}
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$activos, big.mark = ","), " (",
                       round(100 * df_general_pais_ultima_fecha$activos / df_general_pais_ultima_fecha$positivos, 1), 
                       "%)", sep = ""),
         caption = "Total de casos activos",
         icon = icono_activos, 
         color = color_activos
)
```

### Casos recuperados {.value-box}
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$RECUPERADOS, big.mark = ","), " (",
                       round(100 * df_general_pais_ultima_fecha$RECUPERADOS / df_general_pais_ultima_fecha$positivos, 1), 
                       "%)", sep = ""), 
         caption = "Total de casos recuperados",
         icon = icono_recuperados, 
         color = color_recuperados
)
```

### Casos fallecidos {.value-box}
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$fallecidos, big.mark = ","), " (",
                       round(100 * df_general_pais_ultima_fecha$fallecidos / df_general_pais_ultima_fecha$positivos, 1), 
                       "%)", sep = ""), 
         caption = "Total de casos fallecidos",
         icon = icono_fallecidos, 
         color = color_fallecidos
)
```

Row
-----------------------------------------------------------------------
  
  ### Hospitalizados {.value-box}
  ```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$hospital, big.mark = ","), "", sep = " "), 
         caption = "Total de hospitalizados", 
         icon = icono_hospitalizados,
         color = color_hospitalizados
)
```

### En salón {.value-box}
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$salon, big.mark = ","), " (",
                       round(100 * df_general_pais_ultima_fecha$salon / df_general_pais_ultima_fecha$hospital, 1), 
                       "%)", sep = ""), 
         caption = "Hospitalizados en salón",
         icon = icono_salon, 
         color = color_salon
)
```

### En UCI {.value-box}
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$UCI, big.mark = ","), " (",
                       round(100 * df_general_pais_ultima_fecha$UCI / df_general_pais_ultima_fecha$hospital, 1), 
                       "%)", sep = ""), 
         caption = "Hospitalizados en UCI",
         icon = icono_uci, 
         color = color_uci
)
```

Row {data-width=400}
-----------------------------------------------------------------------
  
  ### Gráfico de variación de las cantidades de casos en el tiempo
  ```{r}
plot_ly(data = df_general_pais,
        x = ~ FECHA,
        y = ~ positivos, 
        name = 'Positivos', 
        type = 'scatter',
        mode = 'lines',
        line = list(color = color_positivos)) %>%
  add_trace(y = ~ activos,
            name = 'Activos',
            mode = 'lines',
            line = list(color = color_activos)) %>%
  add_trace(y = ~ RECUPERADOS,
            name = 'Recuperados',
            mode = 'lines',
            line = list(color = color_recuperados)) %>%
  add_trace(y = ~ fallecidos,
            name = 'Fallecidos',
            mode = 'lines',
            line = list(color = color_fallecidos)) %>%  
  layout(title = "",
         yaxis = list(title = "Cantidad de casos"),
         xaxis = list(title = "Fecha"),
         legend = list(x = 0.1, y = 0.9),
         hovermode = "compare")

```

### Tabla de cantidades de casos en cantones
```{r}
st_drop_geometry(sf_positivos_cantones_ultima_fecha) %>% 
  select(Provincia = provincia, Canton = canton, Positivos = positivos) %>%
  DT::datatable(rownames = FALSE,
                options = list(searchHighlight = TRUE, 
                               language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json')
                )
  )
```

Casos positivos
=======================================================================
  Row {data-height=1}
-----------------------------------------------------------------------
  ### **Última actualización: `r  df_general_pais_ultima_fecha$FECHA`**
  
  Row
-----------------------------------------------------------------------
  
  
  ### Casos positivos {.value-box}
  ```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$positivos, big.mark = ","), "", sep = " "), 
         caption = "Total de casos positivos", 
         icon = icono_positivos, 
         color = color_positivos
)
```

### Casos mujeres {.value-box}
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$muj_posi, big.mark = ","), " (",
                       round(100 * df_general_pais_ultima_fecha$muj_posi / df_general_pais_ultima_fecha$positivos, 1), 
                       "%)", sep = ""), 
         caption = "Total de mujeres",
         icon = icono_mujeres, 
         color = color_positivos
)
```


### Casos hombres {.value-box}
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$hom_posi, big.mark = ","), " (",
                       round(100 * df_general_pais_ultima_fecha$hom_posi / df_general_pais_ultima_fecha$positivos, 1), 
                       "%)", sep = ""), 
         caption = "Total de hombres",
         icon = icono_hombres, 
         color = color_positivos
)
```

Row
-----------------------------------------------------------------------
  
  
  ### Casos menores de edad {.value-box}
  ```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$menor_posi, big.mark = ","), " (",
                       round(100 * df_general_pais_ultima_fecha$menor_posi / df_general_pais_ultima_fecha$positivos, 1), 
                       "%)", sep = ""), 
         caption = "Total de menores de edad",
         icon = icono_menor, 
         color = color_positivos
)
```


### Casos adultos {.value-box}
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$adul_posi, big.mark = ","), "(",                          round(100 * df_general_pais_ultima_fecha$adul_posi / df_general_pais_ultima_fecha$positivos, 1), 
                       "%)", sep = ""), 
         caption = "Total de Adultos", 
         icon = icono_positivos,
         color = color_positivos
)
```


### Casos adultos mayores
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$am_posi, big.mark = ","), "(",                          round(100 * df_general_pais_ultima_fecha$am_posi / df_general_pais_ultima_fecha$positivos, 1), 
                       "%)", sep = ""), 
         caption = "Total de Adultos", 
         icon = icono_adultom,
         color = color_positivos
)
```



Row {data-width=400}
-----------------------------------------------------------------------
  
  ### Mapa de casos positivos en cantones
  ```{r}

paleta_azul <- colorBin(palette = "Blues", 
                        domain = sf_positivos_cantones_ultima_fecha$positivos,
                        bins = 10
)

leaflet_cantones <- leaflet(sf_positivos_cantones_ultima_fecha) %>% 
  fitBounds(lng1 = -86, lng2 = -82, lat1 = 8, lat2 = 11) %>%
  addProviderTiles(providers$OpenStreetMap.Mapnik, group = "OpenStreetMap") %>%
  addPolygons(fillColor = ~paleta_azul(positivos), stroke=T, fillOpacity = 1,
              color="black", weight=0.2, opacity= 0.5,
              group = "Cantones",
              popup = paste("Provincia: ", sf_positivos_cantones_ultima_fecha$provincia, "<br>",
                            "Cantón: ", sf_positivos_cantones_ultima_fecha$canton, "<br>",
                            "Positivos: ", sf_positivos_cantones_ultima_fecha$positivos
              )
  ) %>%
  addLegend("bottomright", pal = paleta_azul, values = ~positivos,
            title = "Casos positivos",
            opacity = 1
  ) %>%  
  addLayersControl(
    baseGroups = c("OpenStreetMap"),
    overlayGroups = c("Cantones"),
    options = layersControlOptions(collapsed = TRUE)    
  ) %>%  
  addMiniMap(
    toggleDisplay = TRUE,
    position = "bottomleft",
    tiles = providers$OpenStreetMap.Mapnik
  )

# Despliegue del mapa
leaflet_cantones
```

### Gráfico de cantones con mayor cantidad de casos positivos
```{r}
st_drop_geometry(sf_positivos_cantones_ultima_fecha) %>%
  mutate(canton = factor(canton, levels = canton)) %>%
  top_n(n = 10, wt = positivos) %>%  
  plot_ly(x = ~ canton, 
          y = ~ positivos, 
          type = "bar", 
          text = ~ positivos,
          textposition = 'auto',
          marker = list(color = color_positivos)
  ) %>%
  layout(yaxis = list(title = "Cantidad de casos positivos"),
         xaxis = list(title = "Cantones"),
         margin = list(l = 10,
                       r = 10,
                       b = 10,
                       t = 10,
                       pad = 2
         )
  ) 
```


Casos activos
=======================================================================
  Row {data-height=1}
-----------------------------------------------------------------------
  ### **Última actualización: `r  df_general_pais_ultima_fecha$FECHA`**
  
  Row
-----------------------------------------------------------------------
  
  
  ### Casos activos {.value-box}
  ```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$activos, big.mark = ","), "", sep = " "), 
         caption = "Total de casos activos", 
         icon = icono_activos, 
         color = color_activos
)
```

### Casos mujeres {.value-box}
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$muj_acti, big.mark = ","), " (",
                       round(100 * df_general_pais_ultima_fecha$muj_acti / df_general_pais_ultima_fecha$activos, 1), 
                       "%)", sep = ""), 
         caption = "Total de mujeres",
         icon = icono_mujeres, 
         color = color_activos
)
```


### Casos hombres {.value-box}
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$hom_acti, big.mark = ","), " (",
                       round(100 * df_general_pais_ultima_fecha$hom_acti / df_general_pais_ultima_fecha$activos, 1), 
                       "%)", sep = ""), 
         caption = "Total de hombres",
         icon = icono_hombres, 
         color = color_activos
)
```


Row
-----------------------------------------------------------------------
  
  
  ### Casos menores de edad {.value-box}
  ```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$menor_acti, big.mark = ","), " (",
                       round(100 * df_general_pais_ultima_fecha$menor_acti / df_general_pais_ultima_fecha$activos, 1), 
                       "%)", sep = ""), 
         caption = "Total de menores de edad",
         icon = icono_menor, 
         color = color_activos
)
```


### Casos adultos {.value-box}
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$adul_acti, big.mark = ","), "(",                          round(100 * df_general_pais_ultima_fecha$adul_acti / df_general_pais_ultima_fecha$activos, 1), 
                       "%)", sep = ""), 
         caption = "Total de Adultos", 
         icon = icono_activos,
         color = color_activos
)
```


### Casos adultos mayores
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$am_acti, big.mark = ","), "(",                          round(100 * df_general_pais_ultima_fecha$am_acti / df_general_pais_ultima_fecha$activos, 1), 
                       "%)", sep = ""), 
         caption = "Total de Adultos Mayores", 
         icon = icono_adultom,
         color = color_activos
)
```



Row {data-width=400}
-----------------------------------------------------------------------
  
  ### Mapa de casos activos en cantones
  ```{r}

paleta_naranja <- colorBin(palette = "Oranges", 
                           domain = sf_activos_cantones_ultima_fecha$activos,
                           bins = 10
)

leaflet_cantones <- leaflet(sf_activos_cantones_ultima_fecha) %>% 
  fitBounds(lng1 = -86, lng2 = -82, lat1 = 8, lat2 = 11) %>%
  addProviderTiles(providers$OpenStreetMap.Mapnik, group = "OpenStreetMap") %>%
  addPolygons(fillColor = ~paleta_naranja(activos), stroke=T, fillOpacity = 1,
              color="black", weight=0.2, opacity= 0.5,
              group = "Cantones",
              popup = paste("Provincia: ", sf_activos_cantones_ultima_fecha$provincia, "<br>",
                            "Cantón: ", sf_activos_cantones_ultima_fecha$canton, "<br>",
                            "Activos: ", sf_activos_cantones_ultima_fecha$activos
              )
  ) %>%
  addLegend("bottomright", pal = paleta_naranja, values = ~activos,
            title = "Casos activos",
            opacity = 1
  ) %>%  
  addLayersControl(
    baseGroups = c("OpenStreetMap"),
    overlayGroups = c("Cantones"),
    options = layersControlOptions(collapsed = TRUE)    
  ) %>%  
  addMiniMap(
    toggleDisplay = TRUE,
    position = "bottomleft",
    tiles = providers$OpenStreetMap.Mapnik
  )

# Despliegue del mapa
leaflet_cantones
```

### Gráfico de cantones con mayor cantidad de casos activos
```{r}
st_drop_geometry(sf_activos_cantones_ultima_fecha) %>%
  mutate(canton = factor(canton, levels = canton)) %>%
  top_n(n = 10, wt = activos) %>%  
  plot_ly(x = ~ canton, 
          y = ~ activos, 
          type = "bar", 
          text = ~ activos,
          textposition = 'auto',
          marker = list(color = color_activos)
  ) %>%
  layout(yaxis = list(title = "Cantidad de casos activos"),
         xaxis = list(title = "Cantones"),
         margin = list(l = 10,
                       r = 10,
                       b = 10,
                       t = 10,
                       pad = 2
         )
  ) 
```


Casos recuperados
=======================================================================
  Row {data-height=1}
-----------------------------------------------------------------------
  ### **Última actualización: `r  df_general_pais_ultima_fecha$FECHA`**
  
  Row
-----------------------------------------------------------------------
  
  
  ### Casos recuperados {.value-box}
  ```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$RECUPERADOS, big.mark = ","), "", sep = " "), 
         caption = "Total de casos recuperados", 
         icon = icono_recuperados, 
         color = color_recuperados
)
```

### Casos mujeres {.value-box}
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$MUJ_RECUP, big.mark = ","), " (",
                       round(100 * df_general_pais_ultima_fecha$MUJ_RECUP / df_general_pais_ultima_fecha$RECUPERADOS, 1), 
                       "%)", sep = ""), 
         caption = "Total de mujeres",
         icon = icono_mujeres, 
         color = color_recuperados
)
```



### Casos hombres {.value-box}
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$HOM_RECUP, big.mark = ","), " (",
                       round(100 * df_general_pais_ultima_fecha$HOM_RECUP / df_general_pais_ultima_fecha$RECUPERADOS, 1), 
                       "%)", sep = ""), 
         caption = "Total de hombres",
         icon = icono_hombres, 
         color = color_recuperados
)
```


Row
-----------------------------------------------------------------------
  
  ### Casos menores de edad {.value-box}
  ```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$MENOR_RECUP, big.mark = ","), " (",
                       round(100 * df_general_pais_ultima_fecha$MENOR_RECUP / df_general_pais_ultima_fecha$RECUPERADOS, 1), 
                       "%)", sep = ""), 
         caption = "Total de menores de edad",
         icon = icono_menor, 
         color = color_recuperados
)
```


### Casos adultos {.value-box}
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$ADUL_RECUP, big.mark = ","), "(",                          round(100 * df_general_pais_ultima_fecha$ADUL_RECUP / df_general_pais_ultima_fecha$RECUPERADOS, 1), 
                       "%)", sep = ""), 
         caption = "Total de Adultos", 
         icon = icono_recuperados,
         color = color_recuperados
)
```


### Casos adultos mayores
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$AM_RECUP, big.mark = ","), "(",                          round(100 * df_general_pais_ultima_fecha$AM_RECUP / df_general_pais_ultima_fecha$RECUPERADOS, 1), 
                       "%)", sep = ""), 
         caption = "Total de Adultos Mayores", 
         icon = icono_adultom,
         color = color_recuperados
)
```


Row {data-width=400}
-----------------------------------------------------------------------
  
  ### Mapa de casos recuperados en cantones
  ```{r}

paleta_verde <- colorBin(palette = "Greens", 
                         domain = sf_recuperados_cantones_ultima_fecha$recuperados,
                         bins = 10
)

leaflet_cantones <- leaflet(sf_recuperados_cantones_ultima_fecha) %>% 
  fitBounds(lng1 = -86, lng2 = -82, lat1 = 8, lat2 = 11) %>%
  addProviderTiles(providers$OpenStreetMap.Mapnik, group = "OpenStreetMap") %>%
  addPolygons(fillColor = ~paleta_verde(recuperados), stroke=T, fillOpacity = 1,
              color="black", weight=0.2, opacity= 0.5,
              group = "Cantones",
              popup = paste("Provincia: ", sf_recuperados_cantones_ultima_fecha$provincia, "<br>",
                            "Cantón: ", sf_recuperados_cantones_ultima_fecha$canton, "<br>",
                            "Recuperados: ", sf_recuperados_cantones_ultima_fecha$recuperados
              )
  ) %>%
  addLegend("bottomright", pal = paleta_verde, values = ~recuperados,
            title = "Casos recuperados",
            opacity = 1
  ) %>%  
  addLayersControl(
    baseGroups = c("OpenStreetMap"),
    overlayGroups = c("Cantones"),
    options = layersControlOptions(collapsed = TRUE)    
  ) %>%  
  addMiniMap(
    toggleDisplay = TRUE,
    position = "bottomleft",
    tiles = providers$OpenStreetMap.Mapnik
  )

# Despliegue del mapa
leaflet_cantones
```

### Gráfico de cantones con mayor cantidad de casos recuperados
```{r}
st_drop_geometry(sf_recuperados_cantones_ultima_fecha) %>%
  mutate(canton = factor(canton, levels = canton)) %>%
  top_n(n = 10, wt = recuperados) %>%  
  plot_ly(x = ~ canton, 
          y = ~ recuperados, 
          type = "bar", 
          text = ~ recuperados,
          textposition = 'auto',
          marker = list(color = color_recuperados)
  ) %>%
  layout(yaxis = list(title = "Cantidad de casos recuperados"),
         xaxis = list(title = "Cantones"),
         margin = list(l = 10,
                       r = 10,
                       b = 10,
                       t = 10,
                       pad = 2
         )
  )

```

Casos fallecidos
=======================================================================
  Row {data-height=1}
-----------------------------------------------------------------------
  ### **Última actualización: `r  df_general_pais_ultima_fecha$FECHA`**
  
  Row
-----------------------------------------------------------------------
  
  
  ### Casos fallecidos {.value-box}
  ```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$fallecidos, big.mark = ","), "", sep = " "), 
         caption = "Total de casos fallecidos", 
         icon = icono_fallecidos, 
         color = color_fallecidos
)
```

### Casos mujeres {.value-box}
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$muj_fall, big.mark = ","), " (",
                       round(100 * df_general_pais_ultima_fecha$muj_fall / df_general_pais_ultima_fecha$fallecidos, 1), 
                       "%)", sep = ""), 
         caption = "Total de mujeres",
         icon = icono_mujeres, 
         color = color_fallecidos
)
```


### Casos hombres {.value-box}
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$hom_fall, big.mark = ","), " (",
                       round(100 * df_general_pais_ultima_fecha$hom_fall / df_general_pais_ultima_fecha$fallecidos, 1), 
                       "%)", sep = ""), 
         caption = "Total de hombres",
         icon = icono_hombres, 
         color = color_fallecidos
)
```


Row
-----------------------------------------------------------------------
  
  
  ### Casos menores de edad {.value-box}
  ```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$menor_fall, big.mark = ","), " (",
                       round(100 * df_general_pais_ultima_fecha$menor_fall / df_general_pais_ultima_fecha$fallecidos, 1), 
                       "%)", sep = ""), 
         caption = "Total de menores de edad",
         icon = icono_menor, 
         color = color_fallecidos
)
```


### Casos adultos {.value-box}
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$adul_fall, big.mark = ","), "(",                          round(100 * df_general_pais_ultima_fecha$adul_fall/ df_general_pais_ultima_fecha$fallecidos, 1), 
                       "%)", sep = ""), 
         caption = "Total de Adultos", 
         icon = icono_fallecidos,
         color = color_fallecidos
)
```


### Casos adultos mayores
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$am_fall, big.mark = ","), "(",                          round(100 * df_general_pais_ultima_fecha$am_fall/ df_general_pais_ultima_fecha$fallecidos, 1), 
                       "%)", sep = ""), 
         caption = "Total de Adultos Mayores", 
         icon = icono_adultom,
         color = color_fallecidos
)
```


Row {data-width=400}
-----------------------------------------------------------------------
  
  ### Mapa de casos fallecidos en cantones
  ```{r}

paleta_morado <- colorBin(palette = "Purples", 
                          domain = sf_fallecidos_cantones_ultima_fecha$fallecidos,
                          bins = 10
)

leaflet_cantones <- leaflet(sf_fallecidos_cantones_ultima_fecha) %>% 
  fitBounds(lng1 = -86, lng2 = -82, lat1 = 8, lat2 = 11) %>%
  addProviderTiles(providers$OpenStreetMap.Mapnik, group = "OpenStreetMap") %>%
  addPolygons(fillColor = ~paleta_morado(fallecidos), stroke=T, fillOpacity = 1,
              color="black", weight=0.2, opacity= 0.5,
              group = "Cantones",
              popup = paste("Provincia: ", sf_fallecidos_cantones_ultima_fecha$provincia, "<br>",
                            "Cantón: ", sf_fallecidos_cantones_ultima_fecha$canton, "<br>",
                            "Recuperados: ", sf_fallecidos_cantones_ultima_fecha$fallecidos
              )
  ) %>%
  addLegend("bottomright", pal = paleta_morado, values = ~fallecidos,
            title = "Casos fallecidos",
            opacity = 1
  ) %>%  
  addLayersControl(
    baseGroups = c("OpenStreetMap"),
    overlayGroups = c("Cantones"),
    options = layersControlOptions(collapsed = TRUE)    
  ) %>%  
  addMiniMap(
    toggleDisplay = TRUE,
    position = "bottomleft",
    tiles = providers$OpenStreetMap.Mapnik
  )

# Despliegue del mapa
leaflet_cantones
```

### Gráfico de cantones con mayor cantidad de casos fallecidos
```{r}
st_drop_geometry(sf_fallecidos_cantones_ultima_fecha) %>%
  mutate(canton = factor(canton, levels = canton)) %>%
  top_n(n = 10, wt = fallecidos) %>%  
  plot_ly(x = ~ canton, 
          y = ~ fallecidos, 
          type = "bar", 
          text = ~ fallecidos,
          textposition = 'auto',
          marker = list(color = color_fallecidos)
  ) %>%
  layout(yaxis = list(title = "Cantidad de casos fallecidos"),
         xaxis = list(title = "Cantones"),
         margin = list(l = 10,
                       r = 10,
                       b = 10,
                       t = 10,
                       pad = 2
         )
  )

```
