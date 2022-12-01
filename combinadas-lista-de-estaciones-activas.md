Estaciones combinadas y activas
================
José Ramón Martínez Batlle

Versión HTML (más legible e interactiva),
[aquí](https://geofis.github.io/datos-meteoclimaticos-escenarios-cc/combinadas-lista-de-estaciones-activas.html)

## Paquetes

``` r
library(sf)
library(leaflet)
library(mapview)
library(readODS)
library(readxl)
library(parzer)
library(tidyverse)
library(kableExtra)
library(pdftools)
library(datapasta)
source('R/funciones.R')
leaflet_map_view <- . %>% setView(lat = 18.7, lng = -70.3, zoom = 8)
```

## Resultados

En el archivo `combinadas_v0.9.xlsx` se consolidaron los resultados de
los archivos aportados por ONAMET e INDRHI en un único archivo
combinado. Este producto derivado es, por lo tanto, una relación de
estaciones (en filas) con un conjunto de atributos (columnas)
específicos de cada una. Hasta el momento, se han consolidado las de
ONAMET (primeras cuatro hojas) e INDRHI (últimas dos hojas).

### ONAMET

ONAMET aportó dos archivos, cada uno conteniendo listas de estaciones
que entendemos son comunes. El primero contiene una relación de
estaciones con indicación de coordenadas
(`COORDENADAS 2022 DIVISION INSTRUMENTOS.xlsx`), mientras que el segundo
indica los periodos de medición de cada variable de cada estación
(`LISTADO PERIODO DE MEDICION DE CADA ESTACION(22)-1.xlsx`). El objetivo
de este análisis es producir un mapa de las estaciones que se consideran
activas, para lo cual necesitamos las coordenadas del primer archivo, y
el periodo de medición del segundo.

Para decidir cuáles estaciones se consideran activas, se buscó, mediante
expresión regular, la cadena de caracteres “2021” en las columnas que
contenían fechas (e.g. columnas PR, TX, etc.) de las listas de
estaciones con indicación de periodos de medición. Cada coincidencia
señalaba una estación que colecta datos hasta 2022. Se buscó “2021” como
equivalente de 2022 porque, como bien explicó ONAMET en el archivo
fuente, el año actual (2022) no se hace constar hasta tanto haya
transcurrido al completo.

``` r
onamet <- map(1:4, ~ read_xlsx('fuentes/combinadas/combinadas_v0.9.xlsx', sheet = .x))
lista_con_periodo <- bind_rows(sapply(2:4, function(x) onamet[[x]], simplify = F)) %>% 
   rename_at(., vars(-'id',-'nombre'), ~ paste('var_', .))
indice_2022 <- sapply(lista_con_periodo %>% select(3:last_col()),
       function(x) grep('2021', x), simplify = F) %>%
  unlist(use.names = F) %>% unique %>% sort
total_2022 <- length(indice_2022)
#Estaciones que colectaban hasta 2022
lista_con_periodo_2022 <- lista_con_periodo[indice_2022,]
#Estaciones que colectaban hasta 2022 con correspondencia en tabla EMC (coordenadas)
lista_con_periodo_2022_coord <- lista_con_periodo_2022 %>% inner_join(onamet[[1]], by='nombre')
anadidas <- which(lista_con_periodo_2022_coord %>% pull(lat) %>% is.na())
```

En la lista de estaciones meteorológicas convencionales con indicación
de coordenadas, se encontraron 85, mientras que la lista de estaciones
con indicación de periodo de medición contenía 77 estaciones. De las
estaciones con indicación de periodo, se encontraron un total de 36
estaciones registrando datos hasta 2022. De estas, a 33 estaciones se
les localizaron sus homólogas en la lista de coordenadas, y a 3 (CABO
ENGAÑO, LOYOLA (SCR ), SANTIAGO) no se les pudo localizar sus
correspondientes homólogas con coordenadas. En el caso de SANTIAGO, la
incertidumbre se debió a que hay varias estaciones en dicha ciudad, lo
cual hacía difícil determinar con cuál de todas hacerla corresponder.

Como se puede notar, el mayor desafío que presentaron los datos de
ONAMET fue determinar la correspondencia de las estaciones entre listas,
debido a la ausencia de un código (clave) común. Si bien cada lista de
estaciones disponía de códigos únicos por estación, estos no eran
consistentes entre listas. Aunque muchas estaciones pudieron
emparejarse, en algunos casos hicimos la correspondencia con
incertidumbre o, directamente, no se pudo hacer la relación como ya se
refirió (ver también comentarios en globos en el archivo
`combinadas_v0.9.xlsx`). Entendemos que si cada estación contase con un
identificador único, la correspondencia hubiese sido más eficiente y
certera.

Generamos una columna de estado, asignando estado “activa” a las que
recogen datos hasta 2022. Al mismo tiempo, para elaborar el mapa en
secciones posteriores, asignamos coordenadas *ad hoc* a las estaciones
que carecen de ellas.

``` r
lista_con_periodo_2022_coord_todas <- lista_con_periodo_2022 %>%
  right_join(onamet[[1]], by='nombre') %>% rowwise() %>% 
  mutate(inactiva = all(is.na(c_across(starts_with('var_'))))) %>% 
  mutate(estado = ifelse(inactiva, 'inactiva', 'activa')) %>%
  select(id, nombre_onamet, starts_with('var_'), lat, lon, h_m, estado) %>% 
  mutate(
    lat = case_when(
      nombre_onamet == 'LOYOLA (SCR )' ~ 18.411929,
      nombre_onamet == 'SANTIAGO'  ~ 19.50054,
      nombre_onamet == 'CABO ENGAÑO'  ~ 18.616784,
      TRUE ~ lat),
    lon = case_when(
      nombre_onamet == 'LOYOLA (SCR )' ~ -70.112727,
      nombre_onamet == 'SANTIAGO'  ~ -70.69806,
      nombre_onamet == 'CABO ENGAÑO'  ~ -68.325500,
      TRUE ~ lon)
    )
```

Incluimos la tabla resumen a continuación:

``` r
lista_con_periodo_2022_coord_todas %>% 
  arrange(nombre_onamet) %>% 
  kable(booktabs=T) %>%
  kable_styling(latex_options = c("HOLD_position", "scale_down"))
```

<table class="table" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:right;">
id
</th>
<th style="text-align:left;">
nombre_onamet
</th>
<th style="text-align:left;">
var\_ pr
</th>
<th style="text-align:left;">
var\_ tx
</th>
<th style="text-align:left;">
var\_ tm
</th>
<th style="text-align:left;">
var\_ pe
</th>
<th style="text-align:left;">
var\_ hs
</th>
<th style="text-align:left;">
var\_ dv
</th>
<th style="text-align:left;">
var\_ vv
</th>
<th style="text-align:left;">
var\_ vvmx
</th>
<th style="text-align:left;">
var\_ nb
</th>
<th style="text-align:left;">
var\_ hr
</th>
<th style="text-align:left;">
var\_ ro
</th>
<th style="text-align:left;">
var\_ tv
</th>
<th style="text-align:left;">
var\_ ev
</th>
<th style="text-align:right;">
lat
</th>
<th style="text-align:right;">
lon
</th>
<th style="text-align:right;">
h_m
</th>
<th style="text-align:left;">
estado
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
ALTAMIRA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.67516
</td>
<td style="text-align:right;">
-70.83400
</td>
<td style="text-align:right;">
272
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
ANGELINA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.13138
</td>
<td style="text-align:right;">
-70.21977
</td>
<td style="text-align:right;">
54
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
78466
</td>
<td style="text-align:left;">
ARPT. ARROYO BARRIL
</td>
<td style="text-align:left;">
1976-88. 91-2021
</td>
<td style="text-align:left;">
1976-2021
</td>
<td style="text-align:left;">
1976-2021
</td>
<td style="text-align:left;">
1980-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1976-2021
</td>
<td style="text-align:left;">
1995-2021
</td>
<td style="text-align:left;">
1976-2021
</td>
<td style="text-align:left;">
1980-2021
</td>
<td style="text-align:left;">
1977-2021
</td>
<td style="text-align:left;">
1976-2021
</td>
<td style="text-align:left;">
1976-2006
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.20050
</td>
<td style="text-align:right;">
-69.43144
</td>
<td style="text-align:right;">
37
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
21199
</td>
<td style="text-align:left;">
ARPT. DE LA ROMANA
</td>
<td style="text-align:left;">
1919, 1923-27, 1931-80, 2006-2021
</td>
<td style="text-align:left;">
1924-27, 1931-80, 2006-2021
</td>
<td style="text-align:left;">
1924-27, 1931-80, 2006-2021
</td>
<td style="text-align:left;">
2006-2021
</td>
<td style="text-align:left;">
2006-14
</td>
<td style="text-align:left;">
2006-2021
</td>
<td style="text-align:left;">
2006-2021
</td>
<td style="text-align:left;">
2006-2021
</td>
<td style="text-align:left;">
2006-2021
</td>
<td style="text-align:left;">
2006-2021
</td>
<td style="text-align:left;">
2006-2021
</td>
<td style="text-align:left;">
2006-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.44853
</td>
<td style="text-align:right;">
-68.90925
</td>
<td style="text-align:right;">
62
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
78485
</td>
<td style="text-align:left;">
ARPT. DE LAS AMÉRICAS
</td>
<td style="text-align:left;">
1957-2021
</td>
<td style="text-align:left;">
1960-2021
</td>
<td style="text-align:left;">
1960-2021
</td>
<td style="text-align:left;">
1957-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1957-2021
</td>
<td style="text-align:left;">
1957-2021
</td>
<td style="text-align:left;">
1956-13
</td>
<td style="text-align:left;">
1956-2021
</td>
<td style="text-align:left;">
1961-2021
</td>
<td style="text-align:left;">
1968-2021
</td>
<td style="text-align:left;">
1968-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.43306
</td>
<td style="text-align:right;">
-69.67959
</td>
<td style="text-align:right;">
7
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
ARPT. DE PUNTA CANA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.56400
</td>
<td style="text-align:right;">
-68.35941
</td>
<td style="text-align:right;">
7
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
ARPT. DEL CIBAO
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.40305
</td>
<td style="text-align:right;">
-70.59781
</td>
<td style="text-align:right;">
170
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
ARPT. EL CATEY
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.26700
</td>
<td style="text-align:right;">
-69.73366
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
78457
</td>
<td style="text-align:left;">
ARPT. GREGORIO LUPERÓN
</td>
<td style="text-align:left;">
1977-2021
</td>
<td style="text-align:left;">
1977-2021
</td>
<td style="text-align:left;">
1977-2021
</td>
<td style="text-align:left;">
1976-2021
</td>
<td style="text-align:left;">
1977-83
</td>
<td style="text-align:left;">
1977-2021
</td>
<td style="text-align:left;">
1977-2021
</td>
<td style="text-align:left;">
1977-2021
</td>
<td style="text-align:left;">
1977-2021
</td>
<td style="text-align:left;">
1977-2021
</td>
<td style="text-align:left;">
1977-2014
</td>
<td style="text-align:left;">
1977-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.75416
</td>
<td style="text-align:right;">
-70.56316
</td>
<td style="text-align:right;">
16
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
ARPT. LA ISABELA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.57696
</td>
<td style="text-align:right;">
-69.98158
</td>
<td style="text-align:right;">
22
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
78482
</td>
<td style="text-align:left;">
ARPT. MARÍA MONTEZ
</td>
<td style="text-align:left;">
1931-2021
</td>
<td style="text-align:left;">
1951-95-2021
</td>
<td style="text-align:left;">
1951-2021
</td>
<td style="text-align:left;">
1975-2021
</td>
<td style="text-align:left;">
1975-88
</td>
<td style="text-align:left;">
1951-2021
</td>
<td style="text-align:left;">
1961-2021
</td>
<td style="text-align:left;">
1960-2021
</td>
<td style="text-align:left;">
1957-2021
</td>
<td style="text-align:left;">
1960-2021
</td>
<td style="text-align:left;">
1968-2021
</td>
<td style="text-align:left;">
1968-2021
</td>
<td style="text-align:left;">
1976-95
</td>
<td style="text-align:right;">
18.24861
</td>
<td style="text-align:right;">
-71.12288
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
ARROYO LORO
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.81403
</td>
<td style="text-align:right;">
-71.27818
</td>
<td style="text-align:right;">
419
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
BANÍ
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.27867
</td>
<td style="text-align:right;">
-70.31014
</td>
<td style="text-align:right;">
57
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
BÁNICA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.08156
</td>
<td style="text-align:right;">
-71.69836
</td>
<td style="text-align:right;">
285
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
BASE AÉREA DE SAN ISIDRO
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.49944
</td>
<td style="text-align:right;">
-69.76989
</td>
<td style="text-align:right;">
33
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
78473
</td>
<td style="text-align:left;">
BAYAGUANA
</td>
<td style="text-align:left;">
1938-2021
</td>
<td style="text-align:left;">
1958-2021
</td>
<td style="text-align:left;">
1958-2021
</td>
<td style="text-align:left;">
1976-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1952-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1987-2021
</td>
<td style="text-align:left;">
1977-2021
</td>
<td style="text-align:left;">
1976-2021
</td>
<td style="text-align:left;">
1975-2021
</td>
<td style="text-align:left;">
1975-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.74216
</td>
<td style="text-align:right;">
-69.63083
</td>
<td style="text-align:right;">
53
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
BOHECHÍO
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.77747
</td>
<td style="text-align:right;">
-70.99150
</td>
<td style="text-align:right;">
478
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
BONAO
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.93317
</td>
<td style="text-align:right;">
-70.40500
</td>
<td style="text-align:right;">
175
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
78478
</td>
<td style="text-align:left;">
CABO ENGAÑO
</td>
<td style="text-align:left;">
1951-2021
</td>
<td style="text-align:left;">
1951-2021
</td>
<td style="text-align:left;">
1951-2021
</td>
<td style="text-align:left;">
1976-2021
</td>
<td style="text-align:left;">
1976-77
</td>
<td style="text-align:left;">
1951-2021
</td>
<td style="text-align:left;">
1951-2021
</td>
<td style="text-align:left;">
1976-2021
</td>
<td style="text-align:left;">
1951-2021
</td>
<td style="text-align:left;">
1952-2021
</td>
<td style="text-align:left;">
1968-2021
</td>
<td style="text-align:left;">
1968-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.61678
</td>
<td style="text-align:right;">
-68.32550
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
CABRAL
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.24784
</td>
<td style="text-align:right;">
-71.21920
</td>
<td style="text-align:right;">
26
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
78464
</td>
<td style="text-align:left;">
CABRERA
</td>
<td style="text-align:left;">
1938-2003,06-07,09-2021
</td>
<td style="text-align:left;">
1960-83,06-07,096-2021
</td>
<td style="text-align:left;">
1960-83,06-07,096-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1981 -94,13-2021
</td>
<td style="text-align:left;">
1981 -94,13-2021
</td>
<td style="text-align:left;">
1975-90
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1976-1999
</td>
<td style="text-align:left;">
1975-1986
</td>
<td style="text-align:left;">
1975-86
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.64436
</td>
<td style="text-align:right;">
-69.90633
</td>
<td style="text-align:right;">
18
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
22584
</td>
<td style="text-align:left;">
CONSTANZA
</td>
<td style="text-align:left;">
1931-91, 94-2013,2021
</td>
<td style="text-align:left;">
1931-2021
</td>
<td style="text-align:left;">
1931-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1966-91
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1966-2007
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.91173
</td>
<td style="text-align:right;">
-70.71619
</td>
<td style="text-align:right;">
1202
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
COTUÍ
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.04825
</td>
<td style="text-align:right;">
-70.15273
</td>
<td style="text-align:right;">
79
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
DAJABÓN
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.54325
</td>
<td style="text-align:right;">
-71.70436
</td>
<td style="text-align:right;">
44
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
DUVERGÉ
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.37666
</td>
<td style="text-align:right;">
-71.51814
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
EL CERCADO
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.72556
</td>
<td style="text-align:right;">
-71.51884
</td>
<td style="text-align:right;">
739
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
EL SEIBO
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.77438
</td>
<td style="text-align:right;">
-69.03995
</td>
<td style="text-align:right;">
94
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
ELÍAS PIÑA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.87600
</td>
<td style="text-align:right;">
-71.70133
</td>
<td style="text-align:right;">
402
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
ENRIQUILLO
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
17.89165
</td>
<td style="text-align:right;">
-71.24173
</td>
<td style="text-align:right;">
14
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
GASPAR HERNÁNDEZ
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.62383
</td>
<td style="text-align:right;">
-70.27311
</td>
<td style="text-align:right;">
13
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
GURABO
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.49794
</td>
<td style="text-align:right;">
-70.66713
</td>
<td style="text-align:right;">
244
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
HATO MAYOR
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.77005
</td>
<td style="text-align:right;">
-69.25557
</td>
<td style="text-align:right;">
104
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
HIGÜEY
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.62045
</td>
<td style="text-align:right;">
-68.70098
</td>
<td style="text-align:right;">
86
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
22754
</td>
<td style="text-align:left;">
HONDO VALLE
</td>
<td style="text-align:left;">
1953-2021
</td>
<td style="text-align:left;">
1953-1998,13-2021
</td>
<td style="text-align:left;">
1953-1998,13-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.71213
</td>
<td style="text-align:right;">
-71.69364
</td>
<td style="text-align:right;">
882
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
IMBERT
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.75626
</td>
<td style="text-align:right;">
-70.83042
</td>
<td style="text-align:right;">
128
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
23523
</td>
<td style="text-align:left;">
JARABACOA
</td>
<td style="text-align:left;">
1931-2021
</td>
<td style="text-align:left;">
1932-82,86-01,11-2021
</td>
<td style="text-align:left;">
1932-82,86-01,11-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1976-95
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.12551
</td>
<td style="text-align:right;">
-70.60572
</td>
<td style="text-align:right;">
570
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
JARDÍN BOTÁNICO NACIONAL
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.49489
</td>
<td style="text-align:right;">
-69.95293
</td>
<td style="text-align:right;">
48
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
78480
</td>
<td style="text-align:left;">
JIMANÍ
</td>
<td style="text-align:left;">
1948-2021
</td>
<td style="text-align:left;">
1961-2021
</td>
<td style="text-align:left;">
1961-2021
</td>
<td style="text-align:left;">
1985-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1948-2021
</td>
<td style="text-align:left;">
1979-2021
</td>
<td style="text-align:left;">
1976-2021
</td>
<td style="text-align:left;">
1976-2021
</td>
<td style="text-align:left;">
1976-2013
</td>
<td style="text-align:left;">
1977-2013
</td>
<td style="text-align:left;">
1976-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.49278
</td>
<td style="text-align:right;">
-71.85301
</td>
<td style="text-align:right;">
45
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
JUMA BONAO
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.90047
</td>
<td style="text-align:right;">
-70.38549
</td>
<td style="text-align:right;">
181
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
23551
</td>
<td style="text-align:left;">
LA VEGA - IATESA
</td>
<td style="text-align:left;">
1924-2006,09-2021
</td>
<td style="text-align:left;">
1941-92, 94-06,09-2021
</td>
<td style="text-align:left;">
1941-92, 94-06,09-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1941-06
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1941-99,11-2021
</td>
<td style="text-align:left;">
1977-99,11-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.25230
</td>
<td style="text-align:right;">
-70.55246
</td>
<td style="text-align:right;">
133
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
LA VEGA - M. A.
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.19920
</td>
<td style="text-align:right;">
-70.49850
</td>
<td style="text-align:right;">
82
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
22346
</td>
<td style="text-align:left;">
LA VICTORIA
</td>
<td style="text-align:left;">
1938-89,10-13,2021
</td>
<td style="text-align:left;">
1958-89,95, 97,10-13,2021
</td>
<td style="text-align:left;">
1958-89,95, 97,10-13,2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.59779
</td>
<td style="text-align:right;">
-69.83956
</td>
<td style="text-align:right;">
17
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
LAS MATAS DE FARFÁN
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.87478
</td>
<td style="text-align:right;">
-71.52819
</td>
<td style="text-align:right;">
430
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
LAS MATAS DE SANTA CRUZ
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.65356
</td>
<td style="text-align:right;">
-71.50686
</td>
<td style="text-align:right;">
44
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
LIMÓN DEL YUNA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.11985
</td>
<td style="text-align:right;">
-69.78488
</td>
<td style="text-align:right;">
11
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
LOMA DE CABRERA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.41925
</td>
<td style="text-align:right;">
-71.61228
</td>
<td style="text-align:right;">
227
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
22239
</td>
<td style="text-align:left;">
LOS LLANOS
</td>
<td style="text-align:left;">
1940-03,2013-2021
</td>
<td style="text-align:left;">
1977-86, 95, 97
</td>
<td style="text-align:left;">
1977-86, 95, 97
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.62499
</td>
<td style="text-align:right;">
-69.49096
</td>
<td style="text-align:right;">
41
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
LOYOLA (SCR )
</td>
<td style="text-align:left;">
1981-2021
</td>
<td style="text-align:left;">
1981-2021
</td>
<td style="text-align:left;">
1981-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1981-99
</td>
<td style="text-align:left;">
1981-99
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1981-99
</td>
<td style="text-align:right;">
18.41193
</td>
<td style="text-align:right;">
-70.11273
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
LUPERÓN
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.88717
</td>
<td style="text-align:right;">
-70.96424
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
MAO
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.58833
</td>
<td style="text-align:right;">
-71.04966
</td>
<td style="text-align:right;">
65
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
MICHES
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.98099
</td>
<td style="text-align:right;">
-69.04221
</td>
<td style="text-align:right;">
14
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
23591
</td>
<td style="text-align:left;">
MOCA
</td>
<td style="text-align:left;">
1931-2021
</td>
<td style="text-align:left;">
38-87, 95-2021
</td>
<td style="text-align:left;">
1938-87,95-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.38811
</td>
<td style="text-align:right;">
-70.53213
</td>
<td style="text-align:right;">
179
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
23693
</td>
<td style="text-align:left;">
MONCIÓN
</td>
<td style="text-align:left;">
1931-2007,2014-2021
</td>
<td style="text-align:left;">
31-42, 51-96,14-2021
</td>
<td style="text-align:left;">
1931-42, 51-96,14-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.40988
</td>
<td style="text-align:right;">
-71.16163
</td>
<td style="text-align:right;">
382
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
78451
</td>
<td style="text-align:left;">
MONTE CRISTI
</td>
<td style="text-align:left;">
1933-2021
</td>
<td style="text-align:left;">
1951-2021
</td>
<td style="text-align:left;">
1951-2021
</td>
<td style="text-align:left;">
1976-95,2007-2021
</td>
<td style="text-align:left;">
1976-88
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1976-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1976-2021
</td>
<td style="text-align:left;">
1976-2021
</td>
<td style="text-align:left;">
1976-2021
</td>
<td style="text-align:left;">
1976-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.84988
</td>
<td style="text-align:right;">
-71.65350
</td>
<td style="text-align:right;">
8
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
MONTE PLATA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.80243
</td>
<td style="text-align:right;">
-69.78160
</td>
<td style="text-align:right;">
47
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
NAVARRETE
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.56062
</td>
<td style="text-align:right;">
-70.86739
</td>
<td style="text-align:right;">
137
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
NEIBA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.48347
</td>
<td style="text-align:right;">
-71.41889
</td>
<td style="text-align:right;">
32
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
20668
</td>
<td style="text-align:left;">
OVIEDO
</td>
<td style="text-align:left;">
1963-87, 94-03,2009-2021
</td>
<td style="text-align:left;">
1965-85,13-2021
</td>
<td style="text-align:left;">
1965-85,13,2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
17.80205
</td>
<td style="text-align:right;">
-71.40403
</td>
<td style="text-align:right;">
35
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
22559
</td>
<td style="text-align:left;">
PADRE LAS CASAS
</td>
<td style="text-align:left;">
1937-2014
</td>
<td style="text-align:left;">
1950-82,13-2021
</td>
<td style="text-align:left;">
1950-82,13-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.73026
</td>
<td style="text-align:right;">
-70.94115
</td>
<td style="text-align:right;">
505
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
PARQUE MIRADOR NORTE
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.52763
</td>
<td style="text-align:right;">
-69.93112
</td>
<td style="text-align:right;">
22
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
PARQUE MIRADOR SUR
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.45298
</td>
<td style="text-align:right;">
-69.93416
</td>
<td style="text-align:right;">
44
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
PERALTA
</td>
<td style="text-align:left;">
1939-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.57806
</td>
<td style="text-align:right;">
-70.75596
</td>
<td style="text-align:right;">
556
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
21626
</td>
<td style="text-align:left;">
POLO
</td>
<td style="text-align:left;">
1948-2021
</td>
<td style="text-align:left;">
1951-2021
</td>
<td style="text-align:left;">
1951-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1978-84
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1976-99
</td>
<td style="text-align:left;">
1966-99
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.08746
</td>
<td style="text-align:right;">
-71.27231
</td>
<td style="text-align:right;">
713
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
RADIOSONDA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.47416
</td>
<td style="text-align:right;">
-69.87016
</td>
<td style="text-align:right;">
16
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
22449
</td>
<td style="text-align:left;">
RANCHO ARRIBA
</td>
<td style="text-align:left;">
1939-2021
</td>
<td style="text-align:left;">
1961-81,2002,2021
</td>
<td style="text-align:left;">
1961-81,2002,2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1971-00
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1976-00
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.69438
</td>
<td style="text-align:right;">
-70.44973
</td>
<td style="text-align:right;">
681
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
RESTAURACIÓN
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.31497
</td>
<td style="text-align:right;">
-71.68913
</td>
<td style="text-align:right;">
579
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
24421
</td>
<td style="text-align:left;">
RÍO SAN JUAN
</td>
<td style="text-align:left;">
1948-2021
</td>
<td style="text-align:left;">
1961-83,14-2021
</td>
<td style="text-align:left;">
1961-83,14-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.63251
</td>
<td style="text-align:right;">
-70.07475
</td>
<td style="text-align:right;">
17
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
78467
</td>
<td style="text-align:left;">
SABANA DE LA MAR
</td>
<td style="text-align:left;">
1939-2021
</td>
<td style="text-align:left;">
1940-2021
</td>
<td style="text-align:left;">
1940-2021
</td>
<td style="text-align:left;">
1976-2021
</td>
<td style="text-align:left;">
1976-88
</td>
<td style="text-align:left;">
1951-2021
</td>
<td style="text-align:left;">
1957-2021
</td>
<td style="text-align:left;">
1951-2021
</td>
<td style="text-align:left;">
1951-2021
</td>
<td style="text-align:left;">
1957-2021
</td>
<td style="text-align:left;">
1968-2014
</td>
<td style="text-align:left;">
1969-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.05267
</td>
<td style="text-align:right;">
-69.38883
</td>
<td style="text-align:right;">
11
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
SABANA GRANDE DE BOYÁ
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.94384
</td>
<td style="text-align:right;">
-69.80099
</td>
<td style="text-align:right;">
280
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
23489
</td>
<td style="text-align:left;">
SALCEDO
</td>
<td style="text-align:left;">
1931-2021
</td>
<td style="text-align:left;">
1939-2011
</td>
<td style="text-align:left;">
1939-2011
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.37531
</td>
<td style="text-align:right;">
-70.41498
</td>
<td style="text-align:right;">
193
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
23256
</td>
<td style="text-align:left;">
SAMANÁ
</td>
<td style="text-align:left;">
1931-2021
</td>
<td style="text-align:left;">
1951-87,10-2021
</td>
<td style="text-align:left;">
1951-87,10-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.20438
</td>
<td style="text-align:right;">
-69.33286
</td>
<td style="text-align:right;">
9
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
SAN CRISTÓBAL
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.40710
</td>
<td style="text-align:right;">
-70.09011
</td>
<td style="text-align:right;">
23
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
22510
</td>
<td style="text-align:left;">
SAN JOSÉ DE OCOA
</td>
<td style="text-align:left;">
1931-2002,10-2021
</td>
<td style="text-align:left;">
1931-86,10-2021
</td>
<td style="text-align:left;">
1931-86,10-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.54200
</td>
<td style="text-align:right;">
-70.50950
</td>
<td style="text-align:right;">
469
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
21193
</td>
<td style="text-align:left;">
SAN RAFAEL DEL YUMA
</td>
<td style="text-align:left;">
1943-2021
</td>
<td style="text-align:left;">
1952-2021
</td>
<td style="text-align:left;">
1952-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.42610
</td>
<td style="text-align:right;">
-68.67416
</td>
<td style="text-align:right;">
51
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
23352
</td>
<td style="text-align:left;">
SÁNCHEZ
</td>
<td style="text-align:left;">
1931-2021
</td>
<td style="text-align:left;">
1939-84,12-2021
</td>
<td style="text-align:left;">
1939-84,12-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.23314
</td>
<td style="text-align:right;">
-69.61311
</td>
<td style="text-align:right;">
32
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
78460
</td>
<td style="text-align:left;">
SANTIAGO
</td>
<td style="text-align:left;">
1931-2021
</td>
<td style="text-align:left;">
1941-2021
</td>
<td style="text-align:left;">
1941-2021
</td>
<td style="text-align:left;">
1976-2021
</td>
<td style="text-align:left;">
1975-86
</td>
<td style="text-align:left;">
1943-2021
</td>
<td style="text-align:left;">
1959-2021
</td>
<td style="text-align:left;">
1959-2021
</td>
<td style="text-align:left;">
1941-2021
</td>
<td style="text-align:left;">
1959-2021
</td>
<td style="text-align:left;">
1968-2021
</td>
<td style="text-align:left;">
1968-2021
</td>
<td style="text-align:left;">
1976-95
</td>
<td style="text-align:right;">
19.50054
</td>
<td style="text-align:right;">
-70.69806
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
SANTIAGO RODRÍGUEZ
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.47712
</td>
<td style="text-align:right;">
-71.33899
</td>
<td style="text-align:right;">
130
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
78486
</td>
<td style="text-align:left;">
SANTO DOMINGO ESTE
</td>
<td style="text-align:left;">
1931-2021
</td>
<td style="text-align:left;">
1936-2021
</td>
<td style="text-align:left;">
1936-2021
</td>
<td style="text-align:left;">
1975-2021
</td>
<td style="text-align:left;">
1984-95
</td>
<td style="text-align:left;">
1947-2021
</td>
<td style="text-align:left;">
1951-14
</td>
<td style="text-align:left;">
1951-2021
</td>
<td style="text-align:left;">
1931-2021
</td>
<td style="text-align:left;">
1951-2021
</td>
<td style="text-align:left;">
1968-2021
</td>
<td style="text-align:left;">
1968-2021
</td>
<td style="text-align:left;">
1960-2021
</td>
<td style="text-align:right;">
18.47339
</td>
<td style="text-align:right;">
-69.87053
</td>
<td style="text-align:right;">
14
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
TÁBARA ABAJO
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.46438
</td>
<td style="text-align:right;">
-70.86903
</td>
<td style="text-align:right;">
126
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
TAMBORIL
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.48342
</td>
<td style="text-align:right;">
-70.61141
</td>
<td style="text-align:right;">
257
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
22443
</td>
<td style="text-align:left;">
VILLA ALTAGRACIA
</td>
<td style="text-align:left;">
1938-2021
</td>
<td style="text-align:left;">
1951-95,13-2021
</td>
<td style="text-align:left;">
1951-95,13-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.67582
</td>
<td style="text-align:right;">
-70.17060
</td>
<td style="text-align:right;">
183
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
VILLA ISABELA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.82111
</td>
<td style="text-align:right;">
-71.05694
</td>
<td style="text-align:right;">
32
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
VILLA LOS ALMÁCIGOS
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.41080
</td>
<td style="text-align:right;">
-71.44328
</td>
<td style="text-align:right;">
214
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
<tr>
<td style="text-align:right;">
23358
</td>
<td style="text-align:left;">
VILLA RIVA
</td>
<td style="text-align:left;">
39-40, 52-80,87-2021
</td>
<td style="text-align:left;">
39-40, 52-73, 77-81,14-2021
</td>
<td style="text-align:left;">
39-40, 52-73, 77-81,14-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.17993
</td>
<td style="text-align:right;">
-69.91483
</td>
<td style="text-align:right;">
25
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
24659
</td>
<td style="text-align:left;">
VILLA VÁSQUEZ
</td>
<td style="text-align:left;">
1939-2021
</td>
<td style="text-align:left;">
1951-1986,13-2021
</td>
<td style="text-align:left;">
1951-1986,13-2021
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
19.74207
</td>
<td style="text-align:right;">
-71.45730
</td>
<td style="text-align:right;">
32
</td>
<td style="text-align:left;">
activa
</td>
</tr>
<tr>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
YAMASÁ
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
18.77271
</td>
<td style="text-align:right;">
-70.02175
</td>
<td style="text-align:right;">
84
</td>
<td style="text-align:left;">
inactiva
</td>
</tr>
</tbody>
</table>

El mapa de las estaciones de ONAMET según su estado actual (colecta
datos hasta actualmente o no), se muestra a continuación. <span
id="mapa-datos-2022"></span>

Versión interactiva del mapa,
[aquí](https://geofis.github.io/datos-meteoclimaticos-escenarios-cc/combinadas-lista-de-estaciones-activas.html#mapa-datos-2022)

``` r
lista_con_periodo_2022_coord_todas_sf <- st_as_sf(lista_con_periodo_2022_coord_todas,
                                                  coords = c('lon', 'lat'), crs = 4326)

fpal_estado <- colorFactor(
  palette = RColorBrewer::brewer.pal(length(unique(lista_con_periodo_2022_coord_todas_sf$estado)), 'Set1'),
  domain = unique(lista_con_periodo_2022_coord_todas_sf$estado), reverse = T)
leaflet(lista_con_periodo_2022_coord_todas_sf) %>%
  addCircleMarkers(
    radius = 5, label = ~ nombre_onamet, group = ~ estado,
    color = ~ fpal_estado(estado),
    stroke = F, fillOpacity = 1
  ) %>%
  addLegend(pal = fpal_estado, values = ~ estado, opacity = 1,title = "Estaciones<br>Meteorológicas<br>Convencionales<br>ONAMET<br>Estado") %>% 
  addTiles(group = 'OSM') %>%
  addProviderTiles("Esri.NatGeoWorldMap", group="ESRI Mapa") %>%
  addProviderTiles("Esri.WorldImagery", group="ESRI Imagen") %>%
  addProviderTiles("CartoDB.Positron", group= "CartoDB") %>%
  addLayersControl(
    baseGroups = c("OSM", "ESRI Mapa", "CartoDB", "ESRI Imagen"),
    overlayGroups = ~ estado, position = 'bottomright',
    options = layersControlOptions(collapsed = FALSE)) %>% 
  leaflet_map_view
```

![](combinadas-lista-de-estaciones-activas_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

### INDRHI

En el caso de INDRHI se utilizó un único archivo como fuente
(`Informe Final inventario estaciones hidrometeorológicas INDRHI, Rep. Dom..pdf`),
el cual producido por personal técnico de dicha institución en 2019, con
el objetivo de documentar el estado de sus estaciones hidroclimáticas.
El documento fue servido en formato PDF, por lo que hubo que extraer la
información programáticamente. Las informaciones sobre el estado de las
estaciones fueron complementadas por medio de comunicaciones directas
con personal del INDRHI.
