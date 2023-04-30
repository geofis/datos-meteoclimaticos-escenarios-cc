Consolidación inicial de listas de estaciones
================
José Ramón Martínez Batlle

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

## INDRHI

``` r
indrhi_telemetricas <- read_ods('fuentes/indrhi/Red_Telem_Estacion_Coord-Sept2015.ods')
indrhi_telemetricas$longitudOK <- indrhi_telemetricas$LONGITUDE
indrhi_telemetricas$latitudOK <- indrhi_telemetricas$LATITUDE
indrhi_telemetricas$idOK <- indrhi_telemetricas$`STATION SITE`
set.seed(100);indrhi_telemetricas[sample(seq_len(nrow(indrhi_telemetricas)), 10), ] %>%
  kable(booktabs=T) %>%
  kable_styling(latex_options = c("HOLD_position", "scale_down"))
```

<table class="table" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
</th>
<th style="text-align:left;">
STATION NAME
</th>
<th style="text-align:left;">
PROJECT
</th>
<th style="text-align:left;">
STATION SITE
</th>
<th style="text-align:left;">
STATION TYPE
</th>
<th style="text-align:right;">
LATITUDE
</th>
<th style="text-align:right;">
LONGITUDE
</th>
<th style="text-align:left;">
ADDRESS
</th>
<th style="text-align:left;">
VERIFICAR/TRANS
</th>
<th style="text-align:right;">
longitudOK
</th>
<th style="text-align:right;">
latitudOK
</th>
<th style="text-align:left;">
idOK
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
74
</td>
<td style="text-align:left;">
HIDRO2
</td>
<td style="text-align:left;">
MONTE GRANDE
</td>
<td style="text-align:left;">
SABANA ALTA
</td>
<td style="text-align:left;">
Hidrométrica
</td>
<td style="text-align:right;">
18.72538
</td>
<td style="text-align:right;">
-71.10808
</td>
<td style="text-align:left;">
908692F8
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
-71.10808
</td>
<td style="text-align:right;">
18.72538
</td>
<td style="text-align:left;">
SABANA ALTA
</td>
</tr>
<tr>
<td style="text-align:left;">
78
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
INDRHI
</td>
<td style="text-align:left;">
YAQUE DEL NORTE BOMA
</td>
<td style="text-align:left;">
Hidrométrica
</td>
<td style="text-align:right;">
19.17857
</td>
<td style="text-align:right;">
-70.67452
</td>
<td style="text-align:left;">
9083864E
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
-70.67452
</td>
<td style="text-align:right;">
19.17857
</td>
<td style="text-align:left;">
YAQUE DEL NORTE BOMA
</td>
</tr>
<tr>
<td style="text-align:left;">
23
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
INDRHI
</td>
<td style="text-align:left;">
JIMA ABAJO burbuj
</td>
<td style="text-align:left;">
Hidrométrica
</td>
<td style="text-align:right;">
19.12813
</td>
<td style="text-align:right;">
-70.38149
</td>
<td style="text-align:left;">
9085350E
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
-70.38149
</td>
<td style="text-align:right;">
19.12813
</td>
<td style="text-align:left;">
JIMA ABAJO burbuj
</td>
</tr>
<tr>
<td style="text-align:left;">
70
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
INDRHI
</td>
<td style="text-align:left;">
PUENTE SAN RAFAEL(MAO)
</td>
<td style="text-align:left;">
Hidrométrica
</td>
<td style="text-align:right;">
19.58691
</td>
<td style="text-align:right;">
-71.06009
</td>
<td style="text-align:left;">
90858680
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
-71.06009
</td>
<td style="text-align:right;">
19.58691
</td>
<td style="text-align:left;">
PUENTE SAN RAFAEL(MAO)
</td>
</tr>
<tr>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
INDRHI
</td>
<td style="text-align:left;">
BAO AGUA CALIENTE
</td>
<td style="text-align:left;">
Hidrométrica
</td>
<td style="text-align:right;">
19.24246
</td>
<td style="text-align:right;">
-70.89926
</td>
<td style="text-align:left;">
9085E366
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
-70.89926
</td>
<td style="text-align:right;">
19.24246
</td>
<td style="text-align:left;">
BAO AGUA CALIENTE
</td>
</tr>
<tr>
<td style="text-align:left;">
55
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
INDRHI
</td>
<td style="text-align:left;">
PRESA DE BLANCO
</td>
<td style="text-align:left;">
Presa+Climática
</td>
<td style="text-align:right;">
18.88467
</td>
<td style="text-align:right;">
-70.56257
</td>
<td style="text-align:left;">
9080A7AC
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
-70.56257
</td>
<td style="text-align:right;">
18.88467
</td>
<td style="text-align:left;">
PRESA DE BLANCO
</td>
</tr>
<tr>
<td style="text-align:left;">
80
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
INDRHI
</td>
<td style="text-align:left;">
YUNA LA VERDE
</td>
<td style="text-align:left;">
Hidrométrica
</td>
<td style="text-align:right;">
18.95745
</td>
<td style="text-align:right;">
-70.38368
</td>
<td style="text-align:left;">
9083F0DE
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
-70.38368
</td>
<td style="text-align:right;">
18.95745
</td>
<td style="text-align:left;">
YUNA LA VERDE
</td>
</tr>
<tr>
<td style="text-align:left;">
7
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
INDRHI
</td>
<td style="text-align:left;">
CENOVI
</td>
<td style="text-align:left;">
Climática
</td>
<td style="text-align:right;">
19.31833
</td>
<td style="text-align:right;">
-70.22777
</td>
<td style="text-align:left;">
9084F2EA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
-70.22777
</td>
<td style="text-align:right;">
19.31833
</td>
<td style="text-align:left;">
CENOVI
</td>
</tr>
<tr>
<td style="text-align:left;">
81
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
INDRHI
</td>
<td style="text-align:left;">
YUNA PLATANAL
</td>
<td style="text-align:left;">
Hidrométrica
</td>
<td style="text-align:right;">
19.11913
</td>
<td style="text-align:right;">
-70.11311
</td>
<td style="text-align:left;">
9084026E
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
-70.11311
</td>
<td style="text-align:right;">
19.11913
</td>
<td style="text-align:left;">
YUNA PLATANAL
</td>
</tr>
<tr>
<td style="text-align:left;">
76
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
INDRHI
</td>
<td style="text-align:left;">
VALLE DE BAO
</td>
<td style="text-align:left;">
Pluviométrica
</td>
<td style="text-align:right;">
18.88026
</td>
<td style="text-align:right;">
-71.20339
</td>
<td style="text-align:left;">
9083005A
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
-71.20339
</td>
<td style="text-align:right;">
18.88026
</td>
<td style="text-align:left;">
VALLE DE BAO
</td>
</tr>
</tbody>
</table>

``` r
indrhi_historico <- read_excel(
  path = 'fuentes/indrhi/Listado Red Medicion INDRHI_Historico_24-10-2022_revision_jr.xlsx'
  )
indrhi_historico$longitudOK <- 0 - parse_lon(indrhi_historico$LONGITUD)
set.seed(99); indrhi_historico$longitudOK[sample(seq_len(length(indrhi_historico$longitudOK)), 10)]
```

    ##  [1] -71.12278       NaN -69.78889       NaN       NaN       NaN -71.65139
    ##  [8] -70.64584       NaN       NaN

``` r
indrhi_historico$latitudOK <- parse_lon(indrhi_historico$LATITUD)
set.seed(99); indrhi_historico$latitudOK[sample(seq_len(length(indrhi_historico$latitudOK)), 10)]
```

    ##  [1] 19.38694      NaN 19.13056      NaN      NaN      NaN 18.63139 18.45555
    ##  [9]      NaN      NaN

``` r
indrhi_historico$idOK <- indrhi_historico$ESTACION
set.seed(99); indrhi_historico[sample(seq_len(nrow(indrhi_historico)), 10), ] %>%
  kable(booktabs=T) %>%
  kable_styling(latex_options = c("HOLD_position", "scale_down"))
```

<table class="table" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:right;">
ORDEN
</th>
<th style="text-align:left;">
CODIGO
</th>
<th style="text-align:right;">
X (UTM)
</th>
<th style="text-align:right;">
Y (UTM)
</th>
<th style="text-align:right;">
ELEVACION
</th>
<th style="text-align:left;">
ESTACION
</th>
<th style="text-align:left;">
NOMBRE_CUE
</th>
<th style="text-align:left;">
UBICACION
</th>
<th style="text-align:left;">
TIPO
</th>
<th style="text-align:left;">
LATITUD
</th>
<th style="text-align:left;">
LONGITUD
</th>
<th style="text-align:right;">
PRECIPITAC
</th>
<th style="text-align:right;">
DESDE
</th>
<th style="text-align:right;">
HASTA
</th>
<th style="text-align:right;">
DESDE \<\> 0
</th>
<th style="text-align:right;">
HASTA \<\> 0
</th>
<th style="text-align:right;">
¿Tiene ambas fechas?
</th>
<th style="text-align:right;">
longitudOK
</th>
<th style="text-align:right;">
latitudOK
</th>
<th style="text-align:left;">
idOK
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
432
</td>
<td style="text-align:left;">
412
</td>
<td style="text-align:right;">
277050
</td>
<td style="text-align:right;">
2145041
</td>
<td style="text-align:right;">
220
</td>
<td style="text-align:left;">
MAGUA MONCION
</td>
<td style="text-align:left;">
Rio Yaque del Norte
</td>
<td style="text-align:left;">
MAGUA MONCION
</td>
<td style="text-align:left;">
LD INDH
</td>
<td style="text-align:left;">
19 23 13
</td>
<td style="text-align:left;">
71 07 22
</td>
<td style="text-align:right;">
1184.6
</td>
<td style="text-align:right;">
60
</td>
<td style="text-align:right;">
96
</td>
<td style="text-align:right;">
60
</td>
<td style="text-align:right;">
96
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
-71.12278
</td>
<td style="text-align:right;">
19.38694
</td>
<td style="text-align:left;">
MAGUA MONCION
</td>
</tr>
<tr>
<td style="text-align:right;">
289
</td>
<td style="text-align:left;">
493003
</td>
<td style="text-align:right;">
257305
</td>
<td style="text-align:right;">
2106719
</td>
<td style="text-align:right;">
670
</td>
<td style="text-align:left;">
Arroyo Gaji
</td>
<td style="text-align:left;">
Rio Yaque del Sur/San Juan
</td>
<td style="text-align:left;">
Arroyo Gaji
</td>
<td style="text-align:left;">
QD INDR
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:left;">
Arroyo Gaji
</td>
</tr>
<tr>
<td style="text-align:right;">
534
</td>
<td style="text-align:left;">
1814
</td>
<td style="text-align:right;">
417000
</td>
<td style="text-align:right;">
2115400
</td>
<td style="text-align:right;">
8
</td>
<td style="text-align:left;">
BARRAQUITO
</td>
<td style="text-align:left;">
Rio Yuna
</td>
<td style="text-align:left;">
Barraquito
</td>
<td style="text-align:left;">
CL INDR
</td>
<td style="text-align:left;">
19 07 50
</td>
<td style="text-align:left;">
69 47 20
</td>
<td style="text-align:right;">
2014.4
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
-69.78889
</td>
<td style="text-align:right;">
19.13056
</td>
<td style="text-align:left;">
BARRAQUITO
</td>
</tr>
<tr>
<td style="text-align:right;">
246
</td>
<td style="text-align:left;">
47003
</td>
<td style="text-align:right;">
235522
</td>
<td style="text-align:right;">
2171814
</td>
<td style="text-align:right;">
47
</td>
<td style="text-align:left;">
Santa Cruz
</td>
<td style="text-align:left;">
Yaque del Norte/Maguaca
</td>
<td style="text-align:left;">
Santa Cruz
</td>
<td style="text-align:left;">
QD INDR
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:left;">
Santa Cruz
</td>
</tr>
<tr>
<td style="text-align:right;">
226
</td>
<td style="text-align:left;">
180010
</td>
<td style="text-align:right;">
346538
</td>
<td style="text-align:right;">
2078829
</td>
<td style="text-align:right;">
582
</td>
<td style="text-align:left;">
El Pino De
</td>
<td style="text-align:left;">
Yuna/Yuna
</td>
<td style="text-align:left;">
El Pino De
</td>
<td style="text-align:left;">
QD INDR
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:left;">
El Pino De
</td>
</tr>
<tr>
<td style="text-align:right;">
128
</td>
<td style="text-align:left;">
220001
</td>
<td style="text-align:right;">
533075
</td>
<td style="text-align:right;">
2080228
</td>
<td style="text-align:right;">
9
</td>
<td style="text-align:left;">
La Guama I
</td>
<td style="text-align:left;">
Rio Maim¢n / Maim¢n
</td>
<td style="text-align:left;">
La Guama I
</td>
<td style="text-align:left;">
QD INDR
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:left;">
La Guama I
</td>
</tr>
<tr>
<td style="text-align:right;">
358
</td>
<td style="text-align:left;">
5307
</td>
<td style="text-align:right;">
220241
</td>
<td style="text-align:right;">
2062137
</td>
<td style="text-align:right;">
1100
</td>
<td style="text-align:left;">
LOS BOLOS
</td>
<td style="text-align:left;">
Lago Enriquillo
</td>
<td style="text-align:left;">
Los Bolos
</td>
<td style="text-align:left;">
LD NO
</td>
<td style="text-align:left;">
18 37 53
</td>
<td style="text-align:left;">
71 39 05
</td>
<td style="text-align:right;">
1492.1
</td>
<td style="text-align:right;">
71
</td>
<td style="text-align:right;">
96
</td>
<td style="text-align:right;">
71
</td>
<td style="text-align:right;">
96
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
-71.65139
</td>
<td style="text-align:right;">
18.63139
</td>
<td style="text-align:left;">
LOS BOLOS
</td>
</tr>
<tr>
<td style="text-align:right;">
416
</td>
<td style="text-align:left;">
4502
</td>
<td style="text-align:right;">
326194
</td>
<td style="text-align:right;">
2041403
</td>
<td style="text-align:right;">
60
</td>
<td style="text-align:left;">
ESTEBANIA
</td>
<td style="text-align:left;">
Rio Grande
</td>
<td style="text-align:left;">
Estebania
</td>
<td style="text-align:left;">
LD NO
</td>
<td style="text-align:left;">
18 27 20
</td>
<td style="text-align:left;">
70 38 45
</td>
<td style="text-align:right;">
745.1
</td>
<td style="text-align:right;">
69
</td>
<td style="text-align:right;">
96
</td>
<td style="text-align:right;">
69
</td>
<td style="text-align:right;">
96
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
-70.64584
</td>
<td style="text-align:right;">
18.45556
</td>
<td style="text-align:left;">
ESTEBANIA
</td>
</tr>
<tr>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
1601
</td>
<td style="text-align:right;">
398389
</td>
<td style="text-align:right;">
2131443
</td>
<td style="text-align:right;">
180
</td>
<td style="text-align:left;">
Cinta Negra
</td>
<td style="text-align:left;">
Rio Nagua
</td>
<td style="text-align:left;">
Cinta Negra
</td>
<td style="text-align:left;">
LH
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:left;">
Cinta Negra
</td>
</tr>
<tr>
<td style="text-align:right;">
580
</td>
<td style="text-align:left;">
N15
</td>
<td style="text-align:right;">
318339
</td>
<td style="text-align:right;">
2046669
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Azua
</td>
<td style="text-align:left;">
Rio Yaque de Sur
</td>
<td style="text-align:left;">
Azua
</td>
<td style="text-align:left;">
LD TEL
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:left;">
Azua
</td>
</tr>
</tbody>
</table>

## Fundación REDDOM

``` r
reddom <- read_excel(path = 'fuentes/reddom/Localizacion Estaciones Meterologicas CLIMARED_LT.xlsx',
                     skip = 2, col_names = T)
colnames(reddom) <- gsub('(^[0-9]$)', 'Temperatura-Humedad Suelo \\1', colnames(reddom))
(reddom$longitudOK <- reddom$Longitud)
```

    ##  [1] -71.34635 -71.56480 -71.21466 -71.61470 -71.19435 -70.60576 -70.74848
    ##  [8] -71.38353 -70.92510 -71.50160 -70.79701 -70.98673 -71.09064 -71.64626
    ## [15] -70.96859 -71.65865 -71.21455 -71.31737 -71.19988 -71.11765 -70.93845
    ## [22] -70.64679        NA -70.74990 -70.63360 -70.51910 -71.54292 -70.62268
    ## [29] -70.70682 -69.97047 -70.84041 -70.25831 -70.94145        NA

``` r
(reddom$latitudOK <- reddom$Latitud)
```

    ##  [1] 19.50247 19.50264 19.75922 19.78727 19.66831 19.12550 19.44292 19.60421
    ##  [9] 19.28876 18.71723 19.07087 19.53784 19.55873 19.84958 19.54510 19.70878
    ## [17] 19.66124 19.67714 19.63595 19.86363 19.73703 19.70652       NA 19.09705
    ## [25] 19.00903 19.23312 18.87926 19.54729 19.47227 19.00639 19.52976 19.04199
    ## [33] 18.73675       NA

``` r
reddom$idOK <- reddom$NOMBRE
set.seed(99); reddom[sample(seq_len(nrow(reddom)), 10), ] %>% 
  kable(booktabs=T) %>%
  kable_styling(latex_options = c("HOLD_position", "scale_down"))
```

<table class="table" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:right;">
NUMERO
</th>
<th style="text-align:left;">
NOMBRE
</th>
<th style="text-align:left;">
LUGAR
</th>
<th style="text-align:right;">
Latitud
</th>
<th style="text-align:right;">
Longitud
</th>
<th style="text-align:left;">
Altura
</th>
<th style="text-align:left;">
Institucion vinculada
</th>
<th style="text-align:left;">
Temperatura-Humedad Suelo 1
</th>
<th style="text-align:left;">
Temperatura-Humedad Suelo 2
</th>
<th style="text-align:left;">
Temperatura-Humedad Suelo 3
</th>
<th style="text-align:left;">
Temperatura-Humedad Suelo 4
</th>
<th style="text-align:left;">
OTROS SENSORES
</th>
<th style="text-align:right;">
longitudOK
</th>
<th style="text-align:right;">
latitudOK
</th>
<th style="text-align:left;">
idOK
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
33
</td>
<td style="text-align:left;">
Sur_Futuro_Reddom
</td>
<td style="text-align:left;">
Padre Las Casas, Azua
</td>
<td style="text-align:right;">
18.73675
</td>
<td style="text-align:right;">
-70.94145
</td>
<td style="text-align:left;">
516 MTS
</td>
<td style="text-align:left;">
SUR FUTURO
</td>
<td style="text-align:left;">
60 CM
</td>
<td style="text-align:left;">
40 CM
</td>
<td style="text-align:left;">
20 CM
</td>
<td style="text-align:left;">
Superficie
</td>
<td style="text-align:left;">
1 Sensor de hoja humedad
</td>
<td style="text-align:right;">
-70.94145
</td>
<td style="text-align:right;">
18.73675
</td>
<td style="text-align:left;">
Sur_Futuro_Reddom
</td>
</tr>
<tr>
<td style="text-align:right;">
22
</td>
<td style="text-align:left;">
Puerto Plata_REDDOM
</td>
<td style="text-align:left;">
Puerto Plata
</td>
<td style="text-align:right;">
19.70652
</td>
<td style="text-align:right;">
-70.64679
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
FEDEGANORTE
</td>
<td style="text-align:left;">
60 CM
</td>
<td style="text-align:left;">
40 CM
</td>
<td style="text-align:left;">
20 CM
</td>
<td style="text-align:left;">
Superficie
</td>
<td style="text-align:left;">
1 Sensor de hoja humedad
</td>
<td style="text-align:right;">
-70.64679
</td>
<td style="text-align:right;">
19.70652
</td>
<td style="text-align:left;">
Puerto Plata_REDDOM
</td>
</tr>
<tr>
<td style="text-align:right;">
34
</td>
<td style="text-align:left;">
Barcelo_Reddom
</td>
<td style="text-align:left;">
Hato Mayor,
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
108 MTS
</td>
<td style="text-align:left;">
Citricola BARCELO
</td>
<td style="text-align:left;">
60 CM
</td>
<td style="text-align:left;">
40 CM
</td>
<td style="text-align:left;">
20 CM
</td>
<td style="text-align:left;">
Superficie
</td>
<td style="text-align:left;">
1 Sensor de hoja humedad
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;">
Barcelo_Reddom
</td>
</tr>
<tr>
<td style="text-align:right;">
21
</td>
<td style="text-align:left;">
Guananico_REDDOM
</td>
<td style="text-align:left;">
Guananico, Puerto Plata
</td>
<td style="text-align:right;">
19.73703
</td>
<td style="text-align:right;">
-70.93845
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
FEDEGANORTE
</td>
<td style="text-align:left;">
60 CM
</td>
<td style="text-align:left;">
40 CM
</td>
<td style="text-align:left;">
20 CM
</td>
<td style="text-align:left;">
Superficie
</td>
<td style="text-align:left;">
1 Sensor de hoja humedad
</td>
<td style="text-align:right;">
-70.93845
</td>
<td style="text-align:right;">
19.73703
</td>
<td style="text-align:left;">
Guananico_REDDOM
</td>
</tr>
<tr>
<td style="text-align:right;">
3
</td>
<td style="text-align:left;">
Agua_de_Luis_Reddom
</td>
<td style="text-align:left;">
Agua de Luis, Montecristi
</td>
<td style="text-align:right;">
19.75922
</td>
<td style="text-align:right;">
-71.21466
</td>
<td style="text-align:left;">
200 mts
</td>
<td style="text-align:left;">
FEDEGANO
</td>
<td style="text-align:left;">
40 CM
</td>
<td style="text-align:left;">
20 CM
</td>
<td style="text-align:left;">
40 CM
</td>
<td style="text-align:left;">
20 CM
</td>
<td style="text-align:left;">
1 Sensor de hoja humedad
</td>
<td style="text-align:right;">
-71.21466
</td>
<td style="text-align:right;">
19.75922
</td>
<td style="text-align:left;">
Agua_de_Luis_Reddom
</td>
</tr>
<tr>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
La_Guama_Reddom
</td>
<td style="text-align:left;">
La Guama, Cercado, San Juan de la Maguana
</td>
<td style="text-align:right;">
18.71723
</td>
<td style="text-align:right;">
-71.50160
</td>
<td style="text-align:left;">
800 mts
</td>
<td style="text-align:left;">
Pastoral Social Parroquia San Pedro Acosta
</td>
<td style="text-align:left;">
60 CM
</td>
<td style="text-align:left;">
40 CM
</td>
<td style="text-align:left;">
20 CM
</td>
<td style="text-align:left;">
Superficie
</td>
<td style="text-align:left;">
1 Sensor de hoja humedad
</td>
<td style="text-align:right;">
-71.50160
</td>
<td style="text-align:right;">
18.71723
</td>
<td style="text-align:left;">
La_Guama_Reddom
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:left;">
Chacuey_Reddom
</td>
<td style="text-align:left;">
Chacuey, Dajabon
</td>
<td style="text-align:right;">
19.50264
</td>
<td style="text-align:right;">
-71.56480
</td>
<td style="text-align:left;">
133 mts
</td>
<td style="text-align:left;">
FEDEGANO
</td>
<td style="text-align:left;">
40 CM
</td>
<td style="text-align:left;">
20 CM
</td>
<td style="text-align:left;">
40 CM
</td>
<td style="text-align:left;">
20 CM
</td>
<td style="text-align:left;">
1 Sensor de hoja humedad
</td>
<td style="text-align:right;">
-71.56480
</td>
<td style="text-align:right;">
19.50264
</td>
<td style="text-align:left;">
Chacuey_Reddom
</td>
</tr>
<tr>
<td style="text-align:right;">
6
</td>
<td style="text-align:left;">
Esnamarena_Reddom
</td>
<td style="text-align:left;">
Jarabacoa, La Vega
</td>
<td style="text-align:right;">
19.12550
</td>
<td style="text-align:right;">
-70.60576
</td>
<td style="text-align:left;">
586 mts
</td>
<td style="text-align:left;">
Instituto Ambiental de Jarabacoa
</td>
<td style="text-align:left;">
60 CM
</td>
<td style="text-align:left;">
40 CM
</td>
<td style="text-align:left;">
20 CM
</td>
<td style="text-align:left;">
Superficie
</td>
<td style="text-align:left;">
1 Sensor de hoja humedad
</td>
<td style="text-align:right;">
-70.60576
</td>
<td style="text-align:right;">
19.12550
</td>
<td style="text-align:left;">
Esnamarena_Reddom
</td>
</tr>
<tr>
<td style="text-align:right;">
13
</td>
<td style="text-align:left;">
Banelino_Mao
</td>
<td style="text-align:left;">
Mao, Valverde
</td>
<td style="text-align:right;">
19.55873
</td>
<td style="text-align:right;">
-71.09064
</td>
<td style="text-align:left;">
107 mts
</td>
<td style="text-align:left;">
Banelino
</td>
<td style="text-align:left;">
no
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1 Sensor de hoja humedad
</td>
<td style="text-align:right;">
-71.09064
</td>
<td style="text-align:right;">
19.55873
</td>
<td style="text-align:left;">
Banelino_Mao
</td>
</tr>
<tr>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Novillero_Clay_REDDOM
</td>
<td style="text-align:left;">
Luperon, Puerto Plata
</td>
<td style="text-align:right;">
19.86363
</td>
<td style="text-align:right;">
-71.11765
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
FEDEGANORTE
</td>
<td style="text-align:left;">
60 CM
</td>
<td style="text-align:left;">
40 CM
</td>
<td style="text-align:left;">
20 CM
</td>
<td style="text-align:left;">
Superficie
</td>
<td style="text-align:left;">
1 Sensor de hoja humedad
</td>
<td style="text-align:right;">
-71.11765
</td>
<td style="text-align:right;">
19.86363
</td>
<td style="text-align:left;">
Novillero_Clay_REDDOM
</td>
</tr>
</tbody>
</table>

## INTEC

``` r
intec <- read_excel(path = 'fuentes/intec/Lista estaciones meteorológicas OCCR.xlsx',
                    skip = 7, col_names = T)
colnames(intec) <- c(colnames(intec)[c(1, 2)], c('longitud', 'latitud'), colnames(intec)[c(5, 6)])
#Edición manual de coordenada de Las Terrenas. ¡El dato facilitado cae en Los Haitises!
intec <- intec %>% mutate(latitud = case_when(
      `Ubicación` == 'Las Terrenas' ~  'N19 19.583',
      TRUE ~ latitud))
(intec$longitudOK <- parse_lon(intec$longitud))
```

    ## [1] -69.95306 -69.28655 -69.55257 -70.69772 -69.95045

``` r
(intec$latitudOK <- parse_lat(gsub('\\. ', '\\.', intec$latitud)))
```

    ## [1] 18.49500 18.47433 19.32638 19.49751 18.45637

``` r
intec$Marca <- intec$Marca[1]
intec$`Parámetros que miden` <- intec$`Parámetros que miden`[1]
intec$idOK <- intec$Ubicación
intec %>% 
  kable(booktabs=T) %>%
  kable_styling(latex_options = c("HOLD_position", "scale_down"))
```

<table class="table" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:right;">
Estación
</th>
<th style="text-align:left;">
Ubicación
</th>
<th style="text-align:left;">
longitud
</th>
<th style="text-align:left;">
latitud
</th>
<th style="text-align:left;">
Marca
</th>
<th style="text-align:left;">
Parámetros que miden
</th>
<th style="text-align:right;">
longitudOK
</th>
<th style="text-align:right;">
latitudOK
</th>
<th style="text-align:left;">
idOK
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:left;">
Jardín Botánico de Santo Domingo
</td>
<td style="text-align:left;">
W-69 57.18333333
</td>
<td style="text-align:left;">
N18 29.7
</td>
<td style="text-align:left;">
Davis Vantage Pro2
</td>
<td style="text-align:left;">
Presión barométrica, precipitación, velocidad y dirección del viento,
radiación solar, humedad y temperatura del ambiente. 
</td>
<td style="text-align:right;">
-69.95306
</td>
<td style="text-align:right;">
18.49500
</td>
<td style="text-align:left;">
Jardín Botánico de Santo Domingo
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:left;">
San Pedro de Macorís
</td>
<td style="text-align:left;">
W-69 17.193
</td>
<td style="text-align:left;">
N18 28.4595
</td>
<td style="text-align:left;">
Davis Vantage Pro2
</td>
<td style="text-align:left;">
Presión barométrica, precipitación, velocidad y dirección del viento,
radiación solar, humedad y temperatura del ambiente. 
</td>
<td style="text-align:right;">
-69.28655
</td>
<td style="text-align:right;">
18.47433
</td>
<td style="text-align:left;">
San Pedro de Macorís
</td>
</tr>
<tr>
<td style="text-align:right;">
3
</td>
<td style="text-align:left;">
Las Terrenas
</td>
<td style="text-align:left;">
W-69 33.153852
</td>
<td style="text-align:left;">
N19 19.583
</td>
<td style="text-align:left;">
Davis Vantage Pro2
</td>
<td style="text-align:left;">
Presión barométrica, precipitación, velocidad y dirección del viento,
radiación solar, humedad y temperatura del ambiente. 
</td>
<td style="text-align:right;">
-69.55257
</td>
<td style="text-align:right;">
19.32638
</td>
<td style="text-align:left;">
Las Terrenas
</td>
</tr>
<tr>
<td style="text-align:right;">
4
</td>
<td style="text-align:left;">
Jardín Botánico de Santiago
</td>
<td style="text-align:left;">
W-70 41.86314
</td>
<td style="text-align:left;">
N19 29.85042
</td>
<td style="text-align:left;">
Davis Vantage Pro2
</td>
<td style="text-align:left;">
Presión barométrica, precipitación, velocidad y dirección del viento,
radiación solar, humedad y temperatura del ambiente. 
</td>
<td style="text-align:right;">
-70.69772
</td>
<td style="text-align:right;">
19.49751
</td>
<td style="text-align:left;">
Jardín Botánico de Santiago
</td>
</tr>
<tr>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
Colegio Quisqueya, Santo Domingo
</td>
<td style="text-align:left;">
W -69.950447
</td>
<td style="text-align:left;">
N 18.456372
</td>
<td style="text-align:left;">
Davis Vantage Pro2
</td>
<td style="text-align:left;">
Presión barométrica, precipitación, velocidad y dirección del viento,
radiación solar, humedad y temperatura del ambiente. 
</td>
<td style="text-align:right;">
-69.95045
</td>
<td style="text-align:right;">
18.45637
</td>
<td style="text-align:left;">
Colegio Quisqueya, Santo Domingo
</td>
</tr>
</tbody>
</table>

## Guakia

``` r
guakia <- read_ods('fuentes/guakia/estaciones_guakia.ods')
(guakia$longitudOK <- guakia$LONGITUDE)
```

    ## [1] -69.9935

``` r
(guakia$latitudOK <- guakia$LATITUDE)
```

    ## [1] 19.2905

``` r
guakia$idOK <- guakia$IDENTIFICADOR
guakia %>%
  kable(booktabs=T) %>%
  kable_styling(latex_options = c("HOLD_position", "scale_down"))
```

<table class="table" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
IDENTIFICADOR
</th>
<th style="text-align:left;">
TIPO DE ESTACION
</th>
<th style="text-align:left;">
MARCA COMERCIAL
</th>
<th style="text-align:right;">
LONGITUDE
</th>
<th style="text-align:right;">
LATITUDE
</th>
<th style="text-align:left;">
FECHA DE INICIO DE OPERACIONES
</th>
<th style="text-align:left;">
FECHA DE FINALIZACIÓN DE OPERACIONES
</th>
<th style="text-align:left;">
ESTADO ACTUAL
</th>
<th style="text-align:right;">
longitudOK
</th>
<th style="text-align:right;">
latitudOK
</th>
<th style="text-align:left;">
idOK
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Vuelta Larga
</td>
<td style="text-align:left;">
climática
</td>
<td style="text-align:left;">
Pluviómetro manual (de hasta 6’’) y termómetro TESTO 176 T2
</td>
<td style="text-align:right;">
-69.9935
</td>
<td style="text-align:right;">
19.2905
</td>
<td style="text-align:left;">
01/05/15
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
activa
</td>
<td style="text-align:right;">
-69.9935
</td>
<td style="text-align:right;">
19.2905
</td>
<td style="text-align:left;">
Vuelta Larga
</td>
</tr>
</tbody>
</table>

## Consolidado

``` r
lista_estaciones <- list(
  indrhi_telemetricas = indrhi_telemetricas,
  indrhi_historico = indrhi_historico,
  intec = intec,
  reddom = reddom,
  guakia = guakia)
consolidado_estaciones <- bind_rows(lista_estaciones, .id = 'fuente')[, c('fuente', 'idOK', 'longitudOK', 'latitudOK')]
consolidado_estaciones[sample(seq_len(nrow(consolidado_estaciones)), 30), ] %>% 
  kable(booktabs=T) %>%
  kable_styling(latex_options = c("HOLD_position", "scale_down"))
```

<table class="table" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
</th>
<th style="text-align:left;">
fuente
</th>
<th style="text-align:left;">
idOK
</th>
<th style="text-align:right;">
longitudOK
</th>
<th style="text-align:right;">
latitudOK
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
580
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
LAS CUEVAS
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;">
265
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
SANTIAGO
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;">
722
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
VALLEJUELO
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;">
600
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
El Torito
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;">
158
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
El Torito
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;">
598
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
Los Mechesi
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;">
852
</td>
<td style="text-align:left;">
reddom
</td>
<td style="text-align:left;">
Agrofrontera_Reddom
</td>
<td style="text-align:right;">
-71.38353
</td>
<td style="text-align:right;">
19.60421
</td>
</tr>
<tr>
<td style="text-align:left;">
509
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
GUAYUBIN RINCON
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;">
416
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
PUERTECITO
</td>
<td style="text-align:right;">
-71.51111
</td>
<td style="text-align:right;">
18.80000
</td>
</tr>
<tr>
<td style="text-align:left;">
398
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
Fondo Negro
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;">
132
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
TIBURCIO
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;">
78
</td>
<td style="text-align:left;">
indrhi_telemetricas
</td>
<td style="text-align:left;">
YAQUE DEL NORTE BOMA
</td>
<td style="text-align:right;">
-70.67452
</td>
<td style="text-align:right;">
19.17857
</td>
</tr>
<tr>
<td style="text-align:left;">
865
</td>
<td style="text-align:left;">
reddom
</td>
<td style="text-align:left;">
Guananico_REDDOM
</td>
<td style="text-align:right;">
-70.93845
</td>
<td style="text-align:right;">
19.73703
</td>
</tr>
<tr>
<td style="text-align:left;">
7
</td>
<td style="text-align:left;">
indrhi_telemetricas
</td>
<td style="text-align:left;">
CENOVI
</td>
<td style="text-align:right;">
-70.22777
</td>
<td style="text-align:right;">
19.31833
</td>
</tr>
<tr>
<td style="text-align:left;">
877
</td>
<td style="text-align:left;">
reddom
</td>
<td style="text-align:left;">
Sur_Futuro_Reddom
</td>
<td style="text-align:right;">
-70.94145
</td>
<td style="text-align:right;">
18.73675
</td>
</tr>
<tr>
<td style="text-align:left;">
199
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
Conuquitos
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;">
606
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
EL LIMON
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;">
871
</td>
<td style="text-align:left;">
reddom
</td>
<td style="text-align:left;">
Las_Matas_de_Farfan_REDDOM
</td>
<td style="text-align:right;">
-71.54292
</td>
<td style="text-align:right;">
18.87926
</td>
</tr>
<tr>
<td style="text-align:left;">
229
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
Arroyo Limon
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;">
744
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
NARANJO DULCE
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;">
855
</td>
<td style="text-align:left;">
reddom
</td>
<td style="text-align:left;">
Plan_Yaque_Manabao_Reddom
</td>
<td style="text-align:right;">
-70.79701
</td>
<td style="text-align:right;">
19.07087
</td>
</tr>
<tr>
<td style="text-align:left;">
570
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
PRESA DE SABANETA
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;">
310
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
Los Guazaro
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;">
558
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
LA CIENEGA
</td>
<td style="text-align:right;">
-71.29333
</td>
<td style="text-align:right;">
19.08167
</td>
</tr>
<tr>
<td style="text-align:left;">
556
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
EL PALMAR
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;">
496
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
PEDERNALES
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;">
698
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
EL PLATON VILLA NIZAO
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;">
383
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
La Coja
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;">
321
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
La Boca
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;">
654
</td>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:left;">
Barahona
</td>
<td style="text-align:right;">
NaN
</td>
<td style="text-align:right;">
NaN
</td>
</tr>
</tbody>
</table>

``` r
consolidado_estaciones_sf <- st_as_sf(
  consolidado_estaciones[!with(consolidado_estaciones, is.na(longitudOK) | is.na(latitudOK)), ] %>% 
     group_by(fuente) %>% mutate(fuente = paste0(fuente, ' (', n(), ')')),
  coords = c('longitudOK', 'latitudOK'))
nrow(consolidado_estaciones_sf)
```

    ## [1] 237

``` r
table(gsub(' \\(.*$', '', consolidado_estaciones_sf$fuente)) %>%
  kable(booktabs=T, col.names = c('Fuente', 'Número de estaciones')) %>%
  kable_styling(latex_options = c("HOLD_position"))
```

<table class="table" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
Fuente
</th>
<th style="text-align:right;">
Número de estaciones
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
guakia
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
indrhi_historico
</td>
<td style="text-align:right;">
121
</td>
</tr>
<tr>
<td style="text-align:left;">
indrhi_telemetricas
</td>
<td style="text-align:right;">
78
</td>
</tr>
<tr>
<td style="text-align:left;">
intec
</td>
<td style="text-align:right;">
5
</td>
</tr>
<tr>
<td style="text-align:left;">
reddom
</td>
<td style="text-align:right;">
32
</td>
</tr>
</tbody>
</table>

``` r
st_crs(consolidado_estaciones_sf) <- 4326
# st_write(consolidado_estaciones_sf, 'out/consolidado_estaciones_sf.gpkg', delete_dsn = T)
```

## Mapa datos 2022

Versión interactiva del mapa,
[aquí](https://geofis.github.io/datos-meteoclimaticos-escenarios-cc/consolidacion-lista-estaciones.html#mapa-datos-2022)

![](consolidacion-lista-estaciones_files/figure-gfm/mapa-1.png)<!-- -->

## Consolidación estaciones INDRHI, ONAMET, REDDOM

### Telemétricas INDRHI

<!-- #### sf -->

#### Mapa de estaciones telemétricas INDRHI estudio AFD

Versión interactiva del mapa,
[aquí](https://geofis.github.io/datos-meteoclimaticos-escenarios-cc/consolidacion-lista-estaciones.html#mapa-de-estaciones-telemétricas-indrhi-estudio-afd)

![](consolidacion-lista-estaciones_files/figure-gfm/unnamed-chunk-9-1.png)<!-- -->

### Meterológicas ONAMET

<!-- #### sf -->

#### Mapa de estaciones climáticas convencionales ONAMET estudio AFD

Versión interactiva del mapa,
[aquí](https://geofis.github.io/datos-meteoclimaticos-escenarios-cc/consolidacion-lista-estaciones.html#mapa-de-estaciones-climáticas-convencionales-onamet-estudio-afd)

![](consolidacion-lista-estaciones_files/figure-gfm/unnamed-chunk-12-1.png)<!-- -->

### Automáticas ONAMET

<!-- #### sf -->

#### Mapa de estaciones automáticas ONAMET estudio AFD

Versión interactiva del mapa,
[aquí](https://geofis.github.io/datos-meteoclimaticos-escenarios-cc/consolidacion-lista-estaciones.html#mapa-de-estaciones-automáticas-onamet-estudio-afd)

![](consolidacion-lista-estaciones_files/figure-gfm/unnamed-chunk-15-1.png)<!-- -->

### Climatológicas REDDOM

<!-- #### sf -->

#### Mapa de estaciones climatológicas REDDOM estudio AFD

Versión interactiva del mapa,
[aquí](https://geofis.github.io/datos-meteoclimaticos-escenarios-cc/consolidacion-lista-estaciones.html#mapa-de-estaciones-climatológicas-reddom-estudio-afd)

![](consolidacion-lista-estaciones_files/figure-gfm/unnamed-chunk-18-1.png)<!-- -->
