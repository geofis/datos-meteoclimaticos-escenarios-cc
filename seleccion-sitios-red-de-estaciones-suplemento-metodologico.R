## ----supsetup, include=FALSE--------------------------------------------------
knitr::opts_chunk$set(
  cache = F, 
  echo = TRUE,
  warning = FALSE,
  message = FALSE,
  out.width = '100%',
  dpi = 300)
# options(digits = 3)


## ----suppaquetes--------------------------------------------------------------
library(raster)
library(psych)
library(kableExtra)
library(tidyverse)
library(ahpsurvey)
library(janitor)
estilo_kable <- function(df, titulo = '', cubre_anchura = T) {
  df %>% kable(format = 'html', escape = F, booktabs = T, digits = 2, caption = titulo) %>%
  kable_styling(bootstrap_options = c("hover", "condensed"), full_width = cubre_anchura)
}


## ----supvariables-------------------------------------------------------------
variables <- c(
    acce = "distancia a accesos",
    temp = "estacionalidad térmica",
    pluv = "estacionalidad pluviométrica",
    habi = "heterogeneidad de hábitat",
    agua = "distancia a cuerpos de agua",
    pend = "pendiente",
    inso = "horas de insolación",
    elev = "elevación"
)
col_ord <- as.vector(sapply(as.data.frame(combn(names(variables), 2)), paste0, collapse = '_'))


## ----suptabequivalencias------------------------------------------------------
valor_formulario <- c('(100)', '(66)', '(33)', '0', '33', '66', '100')
recod_repartida <- FALSE
if(recod_repartida) {
    recodificado_ahp <- round(c(0-(2+3*((9-2)/3)), 0-(2+2*((9-2)/3)), 0-(2+((9-2)/3)),
                              1,
                              2+((9-2)/3), 2+2*((9-2)/3), 2+3*((9-2)/3)
                              ),
                            2)

} else {
  recodificado_ahp <- c(-9, -6, -3,
                        1,
                        3, 6, 9)
}
data.frame(
  `Valor en formulario` = valor_formulario,
  `Recodificado a escala AHP original` = recodificado_ahp,
  check.names = F) %>% 
  kable(format = 'html', escape = F, booktabs = T,
        caption = 'Tabla de recodificación de puntaciones de formulario a escala AHP original') %>%
  kable_styling(bootstrap_options = c("hover", "condensed"), full_width = T)


## ----supimpresiontabequivalencias---------------------------------------------
as.data.frame(variables) %>% 
  rownames_to_column() %>% 
  setNames(nm = c('Código', 'Nombre completo')) %>% 
  kable(format = 'html', escape = F, booktabs = T,
        caption = 'Tabla de equivalencias de nombres de las variables evaluadas') %>%
  kable_styling(bootstrap_options = c("hover", "condensed"), full_width = T)


## ----suptablaresultadosenbruto------------------------------------------------
tabla_original <- read_csv('fuentes/respuestas-ahp/respuestas.csv')
tabla_en_bruto <- tabla_original[, -grep('Marca|Opcionalmente', colnames(tabla_original))]
tabla_en_bruto %>% 
    kable(format = 'html', escape = F, booktabs = T,
        caption = 'Tabla de resultados en bruto (anonimizada) obtenida a partir del rellenado del "Formulario de comparación pareada de criterios de identificación de sitios idóneos para una red de observación climática"') %>%
  kable_styling(bootstrap_options = c("hover", "condensed"), full_width = T)


## ----suptablaresultadosrecodificados------------------------------------------
tabla_recodificada <- sapply(
  tabla_en_bruto[, grep('^Valora.*', colnames(tabla_en_bruto))],
  function(x){
   sustituido <- gsub('(^[0-9]*|\\([0-9]*\\)):.*', '\\1', x)
   # paste(sustituido, '=', reescalado[match(sustituido, valor_formulario)]) #For testing
   recodificado_ahp[match(sustituido, valor_formulario)]
  })
tabla_recodificada %>% 
    kable(format = 'html', escape = F, booktabs = T,
        caption = 'Tabla de puntaciones recodificadas') %>%
  kable_styling(bootstrap_options = c("hover", "condensed"), full_width = T)


## ----suptablaresultadosparamatrizpareada--------------------------------------
tabla_col_renom <- tabla_recodificada
cambiar_nombre_por_variable <- function(primera=T) {
  names(
    variables[match(
      gsub('(^.*variables )(.*?)( y )(.*$)',
           ifelse(primera, '\\2', '\\4'),
           colnames(tabla_col_renom)),
      variables)])
}
colnames(tabla_col_renom) <- paste0(
  cambiar_nombre_por_variable(),
  '_',
  cambiar_nombre_por_variable(primera = F)
)
tabla_col_renom %>% 
  kable(format = 'html', escape = F, booktabs = T,
        caption = 'Tabla de columnas renombradas (adaptada para la generación de  la matriz de comparación en parejas)') %>%
  kable_styling(bootstrap_options = c("hover", "condensed"), full_width = T)


## ----supmatrizahp, results='asis'---------------------------------------------
matriz_ahp <- tabla_col_renom[, col_ord] %>%
  ahp.mat(atts = names(variables), negconvert = TRUE)
map(matriz_ahp,
  ~ kable(x = .x, format = 'html', escape = F, booktabs = T, digits = 2) %>%
  kable_styling(bootstrap_options = c("hover", "condensed"), full_width = T)
)


## ----supdiferenciasmaximas, fig.cap='Diferencias de los promedios de preferencias individuales entre los métodos "media aritmética" y "valor propio"'----
eigentrue <- ahp.indpref(matriz_ahp, atts = names(variables), method = "eigen")
geom <- ahp.indpref(matriz_ahp, atts = names(variables), method = "arithmetic")
error <- data.frame(id = 1:length(matriz_ahp), maxdiff = apply(abs(eigentrue - geom), 1, max))
error %>%
  ggplot(aes(x = id, y = maxdiff)) +
  geom_point() +
  geom_hline(yintercept = 0.05, linetype = "dashed", color = "red") +
  geom_hline(yintercept = 0, color = "gray50") +
  scale_x_continuous(breaks = seq_len(nrow(tabla_col_renom)), "ID de persona consultada") +
  scale_y_continuous("Diferencia máxima") +
  theme_minimal()


## ----suprisimuladospaqahpsurvey-----------------------------------------------
ri_sim <- t(data.frame(RI = c(0.0000000, 0.0000000, 0.5251686, 0.8836651, 1.1081014, 1.2492774, 1.3415514, 1.4048466, 1.4507197, 1.4857266, 1.5141022,1.5356638, 1.5545925, 1.5703498, 1.5839958)))
colnames(ri_sim) <- 1:15
ri_sim %>%
  kable(format = 'html', escape = F, booktabs = T, digits = 2,
        caption = 'Índices aleatorios generados por la función ahp.ri con 500000 simulaciones para 1 a 15 atributos') %>%
  kable_styling(bootstrap_options = c("hover", "condensed"), full_width = T)


## ----supprobandori------------------------------------------------------------
tiempo_10k <- system.time(probandoRI <- ahp.ri(nsims = 10000, dim = 8, seed = 99))


## ----supdefri-----------------------------------------------------------------
RI <- ri_sim[8]


## ----suprazondeconsistencia---------------------------------------------------
cr <- matriz_ahp %>% ahp.cr(atts = names(variables), ri = RI)
data.frame(`Persona consultada` = seq_along(cr), CR = cr, check.names = F) %>%
  estilo_kable(titulo = 'Razones de consistencia (consistency ratio) por persona consultada',
               cubre_anchura = F) %>% 
  kable_styling(position = 'left') %>% 
  column_spec(column = 1:2, width = "10em")


## ----supumbrales--------------------------------------------------------------
umbral_saaty <- 0.1
umbral_alterno <- 0.15
umbral <- ifelse(recod_repartida, umbral_alterno, umbral_saaty)


## ----supnumconsistinconsist---------------------------------------------------
table(ifelse(cr <= umbral, 'Consistente', 'Inconsistente')) %>% as.data.frame() %>% 
  setNames(nm = c('Tipo', 'Número de cuestionarios')) %>% 
  estilo_kable(titulo = 'Número de cuestionarios según consistencia',
               cubre_anchura = F) %>% 
  kable_styling(position = 'left') %>% 
  column_spec(column = 1:2, width = "10em")


## ----supatributopesocrboxplot, fig.cap='Preferencias individuales por atributo y ratio de consistencia', out.width='100%'----
cr_indicador <- cr %>% 
  data.frame() %>% 
  mutate(`Persona consultada` = seq_along(cr), `CR indicador` = as.factor(ifelse(cr <= umbral, 1, 0))) %>%
  select(`CR indicador`, `Persona consultada`)

matriz_ahp %>% 
  ahp.indpref(names(variables), method = "eigen") %>% 
  mutate(`Persona consultada` = seq_along(cr)) %>%
  left_join(cr_indicador, by = 'Persona consultada') %>%
  gather(-matches('Persona|CR'), key = "var", value = "pref") %>%
  ggplot(aes(x = var, y = pref)) + 
  geom_violin(alpha = 0.6, width = 0.8, color = "transparent", fill = "gray") +
  geom_jitter(alpha = 0.6, height = 0, width = 0.1, aes(color = `CR indicador`)) +
  geom_boxplot(alpha = 0, width = 0.3, color = "#808080") +
  scale_x_discrete("Atributo", labels = stringr::str_wrap(variables[sort(names(variables))], width = 10)) +
  scale_y_continuous("Peso (valor propio dominante)", 
                     labels = scales::percent, 
                     breaks = c(seq(0,0.7,0.1))) +
  guides(color=guide_legend(title=NULL)) +
  scale_color_discrete(breaks = c(0,1),
                       type = c("#F8766D", "#00BA38"),
                       labels = c(paste("CR >", umbral), 
                                  paste("CR <", umbral))) +
  labs(NULL, caption = paste("n =", nrow(tabla_col_renom), ",", "CR promedio =",
                           round(mean(cr),3))) +
  theme_minimal() +
  theme(legend.position = 'bottom', axis.text.x = element_text(size = 7))


## ----supatributopesocrboxplotsolocons, fig.cap='Preferencias individuales por atributo y ratio de consistencia, sólo respuestas consistentes', out.width='100%'----
matriz_ahp[cr_indicador[,1]==1] %>% 
  ahp.indpref(names(variables), method = "eigen") %>% 
  mutate(`Persona consultada` = cr_indicador[cr_indicador[,1]==1, 'Persona consultada']) %>%
  inner_join(cr_indicador[cr_indicador[,1]==1,], by = 'Persona consultada') %>%
  gather(-matches('Persona|CR'), key = "var", value = "pref") %>%
  ggplot(aes(x = var, y = pref)) + 
  geom_violin(alpha = 0.6, width = 0.8, color = "transparent", fill = "gray") +
  geom_jitter(alpha = 0.6, height = 0, width = 0.1, color = "#00BA38") +
  geom_boxplot(alpha = 0, width = 0.3, color = "#808080") +
  scale_x_discrete("Atributo", labels = stringr::str_wrap(variables[sort(names(variables))], width = 10)) +
  scale_y_continuous("Peso (valor propio dominante)", 
                     labels = scales::percent, 
                     breaks = c(seq(0,0.7,0.1))) +
  guides(color=guide_legend(title=NULL)) +
  labs(NULL, caption = paste("n =", nrow(cr_indicador[cr_indicador[,1]==1,]),
                             ",", "CR promedio =",
                           round(mean(cr[cr_indicador[,1]==1]),3))) +
  theme_minimal() +
  theme(legend.position = 'bottom', axis.text.x = element_text(size = 7))


## ----supflujocompletoahp------------------------------------------------------
flujo_completo_ahp <- ahp(df = tabla_col_renom[, col_ord], 
                          atts = names(variables), 
                          negconvert = TRUE, 
                          reciprocal = TRUE,
                          method = 'arithmetic', 
                          aggmethod = "arithmetic", 
                          qt = 0.2,
                          censorcr = umbral,
                          agg = TRUE)
# sum(flujo_completo_ahp$aggpref[,1]) == 1


## ----prefind------------------------------------------------------------------
kable_prefind <- flujo_completo_ahp$indpref %>% 
  mutate(`Persona consultada` = cr_indicador[cr_indicador[,1]==1, 'Persona consultada']) %>% 
  relocate(`Persona consultada`) %>% 
  estilo_kable(titulo = 'Preferencias individuales',
               cubre_anchura = F) %>% 
  kable_styling(position = 'left') %>% 
  column_spec(column = 1:2, width = "10em")
kable_prefind


## ----prefagg------------------------------------------------------------------
prefagg <- flujo_completo_ahp$aggpref %>%
  as.data.frame() %>% 
  rename(`Preferencias agregadas` = AggPref, `Desviación estándar` = SD.AggPref) %>% 
  rownames_to_column('Variable') %>% 
  mutate(Variable = factor(Variable, labels = variables[sort(names(variables))])) %>% 
  arrange(desc(`Preferencias agregadas`))
kable_prefagg <- prefagg %>% 
  estilo_kable(titulo = 'Preferencias agregadas',
               cubre_anchura = F) %>% 
  kable_styling(position = 'left') %>% 
  column_spec(column = 1:2, width = "10em")
kable_prefagg


## ----funcionesfuentescartograficas--------------------------------------------
source('R/funciones.R')
library(sf)
library(spdep)
library(kableExtra)
res_h3 <- 7 #Escribir un valor entre 4 y 7, ambos extremos inclusive
ruta_ez_gh <- 'https://raw.githubusercontent.com/geofis/zonal-statistics/'
# ez_ver <- 'da5b4ed7c6b126fce15f8980b7a0b389937f7f35/'
ez_ver <- 'd7f79365168e688f0d78f521e53fbf2da19244ef/'
ind_esp_url <- paste0(ruta_ez_gh, ez_ver, 'out/all_sources_all_variables_res_', res_h3, '.gpkg')
ind_esp_url
if(!any(grepl('^ind_esp$', ls()))){
  ind_esp <- st_read(ind_esp_url, optional = T, quiet = T)
  st_geometry(ind_esp) <- "geometry"
  ind_esp <- st_transform(ind_esp, 32619)
}
if(!any(grepl('^pais_url$', ls()))){
  pais_url <- paste0(ruta_ez_gh, ez_ver, 'inst/extdata/dr.gpkg')
  pais <- invisible(st_read(pais_url, optional = T, layer = 'pais', quiet = T))
  st_geometry(pais) <- "geometry"
  pais <- st_transform(pais, 32619)
}
if(!any(grepl('^ind_esp_inters$', ls()))){
  ind_esp_inters <- st_intersection(pais, ind_esp)
  colnames(ind_esp_inters) <- colnames(ind_esp)
  ind_esp_inters$area_sq_m <- units::drop_units(st_area(ind_esp_inters))
  ind_esp_inters$area_sq_km <- units::drop_units(st_area(ind_esp_inters))/1000000
}
if(!any(grepl('^ind_esp_inters$', ls())) && interactive()){
  print(ind_esp_inters)
}


## -----------------------------------------------------------------------------
# Objeto que acogerá nombres de objetos
objetos <- character()


## ----osmdist------------------------------------------------------------------
objeto <- 'osm_rcl'
assign(
  objeto,
  generar_resumen_grafico_estadistico_criterios(
    variable = 'OSM-DIST mean',
    umbrales = c(50, 200, 500, 5000),
    nombre = variables[[1]],
    ord_cat = 'mim_rev')
)
get(objeto)[c('violin', 'mapa_con_pais')]
get(objeto)[['area_proporcional_kable']]
get(objeto)[['intervalos_y_etiquetas_kable']]
# clipr::write_clip(get(objeto)$intervalos_y_etiquetas)
if(!objeto %in% objetos) objetos <- c(objetos, objeto)


## ----estacionalidadtermica----------------------------------------------------
objeto <- 'tseasonizzo_rcl'
assign(
  objeto,
  generar_resumen_grafico_estadistico_criterios(
    variable = 'TSEASON-IZZO mean',
    umbrales = c(1.1, 1.3, 1.5),
    nombre = variables[[2]],
    ord_cat = 'mi')
)
get(objeto)[c('violin', 'mapa_con_pais')]
get(objeto)[['intervalos_y_etiquetas_kable']]
get(objeto)[['area_proporcional_kable']]
# clipr::write_clip(get(objeto)$intervalos_y_etiquetas)
if(!objeto %in% objetos) objetos <- c(objetos, objeto)


## ----estacionalidadpluvio-----------------------------------------------------
objeto <- 'pseasonizzo_rcl'
assign(
  objeto,
  generar_resumen_grafico_estadistico_criterios(
    variable = 'PSEASON-IZZO mean',
    umbrales = c(30, 40, 50),
    nombre = variables[[3]],
    ord_cat = 'mi')
)
get(objeto)[c('violin', 'mapa_con_pais')]
get(objeto)[['intervalos_y_etiquetas_kable']]
get(objeto)[['area_proporcional_kable']]
# clipr::write_clip(get(objeto)$intervalos_y_etiquetas)
if(!objeto %in% objetos) objetos <- c(objetos, objeto)


## ----heterogeneidadhabitat----------------------------------------------------
objeto <- 'hethab_rcl'
assign(
  objeto,
  generar_resumen_grafico_estadistico_criterios(
    variable = 'GHH coefficient_of_variation_1km',
    umbrales = c(300, 450, 600),
    nombre = variables[[4]],
    ord_cat = 'im')
)
get(objeto)[c('violin', 'mapa_con_pais')]
get(objeto)[['intervalos_y_etiquetas_kable']]
get(objeto)[['area_proporcional_kable']]
# clipr::write_clip(get(objeto)$intervalos_y_etiquetas)
if(!objeto %in% objetos) objetos <- c(objetos, objeto)


## ----cuerposaguadist----------------------------------------------------------
objeto <- 'wbwdist_rcl'
assign(
  objeto,
  generar_resumen_grafico_estadistico_criterios(
    variable = 'WBW-DIST mean',
    umbrales = c(1000, 2000, 3000),
    nombre = variables[[5]],
    ord_cat = 'mi')
)
get(objeto)[c('violin', 'mapa_con_pais')]
get(objeto)[['intervalos_y_etiquetas_kable']]
get(objeto)[['area_proporcional_kable']]
# clipr::write_clip(get(objeto)$intervalos_y_etiquetas)
if(!objeto %in% objetos) objetos <- c(objetos, objeto)


## ----pendiente----------------------------------------------------------------
objeto <- 'slope_rcl'
assign(
  objeto,
  generar_resumen_grafico_estadistico_criterios(
    variable = 'G90 Slope',
    umbrales = c(3, 9, 15),
    nombre = variables[[6]],
    ord_cat = 'im')
)
get(objeto)[c('violin', 'mapa_con_pais')]
get(objeto)[['intervalos_y_etiquetas_kable']]
get(objeto)[['area_proporcional_kable']]
# clipr::write_clip(get(objeto)$intervalos_y_etiquetas)
if(!objeto %in% objetos) objetos <- c(objetos, objeto)


## -----------------------------------------------------------------------------
objeto <- 'insol_rcl'
assign(
  objeto,
  generar_resumen_grafico_estadistico_criterios(
    variable = 'YINSOLTIME mean',
    umbrales = c(3900, 4100, 4300),
    nombre = variables[[7]],
    ord_cat = 'mi')
)
get(objeto)[c('violin', 'mapa_con_pais')]
get(objeto)[['intervalos_y_etiquetas_kable']]
get(objeto)[['area_proporcional_kable']]
# clipr::write_clip(get(objeto)$intervalos_y_etiquetas)
if(!objeto %in% objetos) objetos <- c(objetos, objeto)


## -----------------------------------------------------------------------------
objeto <- 'ele_rcl'
assign(
  objeto,
  generar_resumen_grafico_estadistico_criterios(
    variable = 'CGIAR-ELE mean',
    umbrales = c(200, 400, 800),
    nombre = variables[[8]],
    ord_cat = 'mi')
)
get(objeto)[c('violin', 'mapa_con_pais')]
get(objeto)[['intervalos_y_etiquetas_kable']]
get(objeto)[['area_proporcional_kable']]
# clipr::write_clip(get(objeto)$intervalos_y_etiquetas)
if(!objeto %in% objetos) objetos <- c(objetos, objeto)


## ----umbralesapuntuaciones----------------------------------------------------
puntuaciones_umbrales <- map(objetos, function(x) get(x)[['intervalos_y_etiquetas']] %>% 
  pivot_longer(cols = -matches('puntuación|etiquetas'), names_to = 'criterio') %>%
  mutate(criterio = gsub(' intervalos', '', criterio)) %>% 
  group_by(across(all_of(matches('etiquetas|criterio')))) %>% 
  summarise(value = paste(value, collapse = ' y ')) %>% 
  pivot_wider(names_from = contains('etiquetas'), values_from = value) %>% 
  select(criterio, `altamente idóneo`, `idóneo`, `moderadamente idóneo`, `marginalmente idóneo`)
) %>% bind_rows()
readODS::write_ods(puntuaciones_umbrales, 'fuentes/umbrales-criterios-ahp/puntuaciones.ods')
puntuaciones_umbrales_kable <- puntuaciones_umbrales %>% kable(format = 'html', escape = F, booktabs = T, digits = 2,
        caption = 'Puntuaciones de criterios para la selección de sitios de estaciones meteoclimáticas') %>%
  kable_styling(bootstrap_options = c("hover", "condensed"), full_width = T)
puntuaciones_umbrales_kable


## ----areasproporcionales------------------------------------------------------
areas_proporcionales <- map(objetos, function(x) get(x)[['area_proporcional']] %>% 
  pivot_longer(cols = -matches('proporción'), names_to = 'criterio') %>%
  mutate(criterio = gsub(' etiquetas', '', criterio)) %>% 
  pivot_wider(names_from = value, values_from = proporción)) %>% bind_rows() %>% 
  select(criterio, `altamente idóneo`, `idóneo`, `moderadamente idóneo`, `marginalmente idóneo`) %>% 
  adorn_totals('col') 
readODS::write_ods(x = areas_proporcionales,
                   path = 'fuentes/umbrales-criterios-ahp/areas_proporcionales.ods')
areas_proporcionales_kable <- areas_proporcionales %>% kable(format = 'html', escape = F, booktabs = T, digits = 2,
        caption = 'Áreas proporcionales por cada criterios para la selección de sitios de estaciones meteoclimáticas') %>%
  kable_styling(bootstrap_options = c("hover", "condensed"), full_width = T)
areas_proporcionales_kable


## -----------------------------------------------------------------------------
all_criteria <- map(objetos[2:length(objetos)], ~ get(.x)[['vectorial']] %>% st_drop_geometry) %>% 
  prepend(list(get(objetos[1])[['vectorial']])) %>% 
  reduce(left_join, by = "hex_id")
all_criteria %>% st_write('out/intervalos_etiquetas_puntuaciones_AHP_criterios_separados.gpkg', delete_dsn = T)


## ---- fig.width=8, fig.height=12----------------------------------------------
paleta <- c("altamente idóneo" = "#018571", "idóneo" = "#80cdc1",
               "moderadamente idóneo" = "#dfd2b3", "marginalmente idóneo" = "#a6611a")
all_criteria_mapa <- all_criteria %>%
  select(all_of(contains('etiquetas'))) %>% 
  rename_with(~ stringr::str_replace(.x, 
                                       pattern = ' etiquetas', 
                                       replacement = ''), 
                matches('etiquetas')) %>% 
  pivot_longer(cols = -geometry) %>% 
  ggplot +
  aes(fill = value) +
  geom_sf(lwd=0) + 
  scale_fill_manual(values = paleta) +
  labs(title = paste('Reclasificación de valores de criterios')) +
  geom_sf(data = pais, fill = 'transparent', lwd = 0.5, color = 'grey50') +
  facet_wrap(~ name, ncol = 2) +
  theme_bw() +
  theme(
    legend.position = 'bottom',
    legend.key.size = unit(0.5, 'cm'), #change legend key size
    legend.key.height = unit(0.5, 'cm'), #change legend key height
    legend.key.width = unit(0.5, 'cm'), #change legend key width
    legend.title = element_blank(), #change legend title font size
    legend.text = element_text(size=5) #change legend text font size
    )
if(interactive()) dev.new()
all_criteria_mapa


## -----------------------------------------------------------------------------
nombres_ahp_obj_sf <- data.frame(
  `Nombre objeto sf` = paste(variables, 'puntuación'),
  Etiqueta = variables, check.names = F) %>%
  rownames_to_column('Nombre AHP')
pesos <- flujo_completo_ahp$aggpref %>% as.data.frame %>%
  rownames_to_column('Nombre AHP') %>% 
  inner_join(nombres_ahp_obj_sf)
all_criteria_scores <- all_criteria %>%
  st_drop_geometry() %>% 
  select(all_of(c('hex_id', grep(' puntuación', colnames(all_criteria), value = T)))) %>%
  pivot_longer(-hex_id, names_to = 'Nombre objeto sf', values_to = 'Puntuación') %>% 
  inner_join(pesos %>% select(`Nombre objeto sf`, Etiqueta, peso=AggPref)) %>% 
  mutate(`Puntuación ponderada` = peso * `Puntuación`) %>% 
  group_by(hex_id) %>%
  summarise(`Puntuación agregada` = sum(`Puntuación ponderada`, na.rm = T)) %>%
  inner_join(all_criteria) %>% 
  st_sf(sf_column_name = 'geometry') %>% 
  mutate(`Puntuación agregada escalada` = scale(`Puntuación agregada`)[,1]) %>% 
  mutate(`Categoría agregada` = cut(`Puntuación agregada escalada`,
                                    breaks = c(min(`Puntuación agregada escalada`, na.rm = T),
                                               -1, 0, 1,
                                               max(`Puntuación agregada escalada`, na.rm = T)),
                                    labels = rev(names(paleta)),
                                    include.lowest = T)
  ) %>% 
  relocate(c(`Puntuación agregada escalada`, `Categoría agregada`), .after = `Puntuación agregada`)
if(interactive()) summary(all_criteria_scores$`Puntuación agregada`)
if(interactive()) table(all_criteria_scores$`Categoría agregada`)
all_criteria_scores %>% st_write('out/intervalos_etiquetas_puntuaciones_AHP_criterios_agregados.gpkg', delete_dsn = T)


## -----------------------------------------------------------------------------
areas_proporcionales_all_criteria <- all_criteria_scores %>% select(`Categoría agregada`) %>% 
  mutate(
    área = units::drop_units(st_area(geometry)),
    `área total` = sum(units::drop_units(st_area(geometry)))) %>%
  st_drop_geometry %>%
  group_by(`Categoría agregada`) %>%
  summarise(proporción = sum(área, na.rm = T)/first(`área total`)*100) %>%
  na.omit() %>%
  mutate(proporción = as.numeric(scale(proporción, center = FALSE,
                            scale = sum(proporción, na.rm = TRUE)/100)))
areas_proporcionales_all_criteria %>% 
    kable(format = 'html', escape = F, booktabs = T, digits = 2,
        caption = 'Áreas proporcionales de categorías agregadas para la selección de sitios de estaciones meteoclimáticas') %>%
      kable_styling(bootstrap_options = c("hover", "condensed"), full_width = T)


## -----------------------------------------------------------------------------
if(interactive()) dev.new()
all_criteria_scores_mapa <- all_criteria_scores %>% 
  ggplot +
  aes(fill = `Categoría agregada`) +
  geom_sf(lwd=0) + 
  scale_fill_manual(values = paleta) +
  # scale_fill_fermenter(palette = 'BrBG', direction = 1, breaks = c(-1, 0, 1)) +
  labs(title = paste('Categorías agregadas')) +
  geom_sf(data = pais, fill = 'transparent', lwd = 0.5, color = 'grey50') +
  theme_bw() +
  theme(
    legend.position = 'bottom',
    legend.key.size = unit(0.5, 'cm'), #change legend key size
    legend.key.height = unit(0.5, 'cm'), #change legend key height
    legend.key.width = unit(0.5, 'cm'), #change legend key width
    legend.title = element_blank(), #change legend title font size
    legend.text = element_text(size=5) #change legend text font size
    )
all_criteria_scores_mapa


## -----------------------------------------------------------------------------
all_criteria_scores_excluded <- all_criteria_scores %>% 
  mutate(
    `Puntuación agregada` = ifelse(
      `distancia a accesos etiquetas` == 'marginalmente idóneo' | `distancia a cuerpos de agua etiquetas` == 'marginalmente idóneo',
      min(`Puntuación agregada`, na.rm = T), `Puntuación agregada`),
    `Puntuación agregada escalada` = ifelse(
      `distancia a accesos etiquetas` == 'marginalmente idóneo' | `distancia a cuerpos de agua etiquetas` == 'marginalmente idóneo',
      min(`Puntuación agregada escalada`, na.rm = T), `Puntuación agregada escalada`),
    `Categoría agregada` = cut(`Puntuación agregada escalada`,
                                    breaks = c(min(`Puntuación agregada escalada`, na.rm = T),
                                               -1, 0, 1,
                                               max(`Puntuación agregada escalada`, na.rm = T)),
                                    labels = rev(names(paleta)),
                                    include.lowest = T))
all_criteria_scores_excluded %>% st_write('out/intervalos_etiquetas_puntuaciones_AHP_criterios_agregados_excluded.gpkg', delete_dsn = T)
hexagonos_imputados <- sum(!(all_criteria_scores %>% pull(`Categoría agregada`) ==
                               all_criteria_scores_excluded %>% pull(`Categoría agregada`)))


## -----------------------------------------------------------------------------
if(interactive()) dev.new()
all_criteria_scores_excluded_mapa <- all_criteria_scores_excluded %>% 
  ggplot +
  aes(fill = `Categoría agregada`) +
  geom_sf(lwd=0) + 
  scale_fill_manual(values = paleta) +
  # scale_fill_fermenter(palette = 'BrBG', direction = 1, breaks = c(-1, 0, 1)) +
  labs(title = paste('Categorías agregadas (exclusión por factores limitantes)')) +
  geom_sf(data = pais, fill = 'transparent', lwd = 0.5, color = 'grey50') +
  theme_bw() +
  theme(
    legend.position = 'bottom',
    legend.key.size = unit(0.5, 'cm'), #change legend key size
    legend.key.height = unit(0.5, 'cm'), #change legend key height
    legend.key.width = unit(0.5, 'cm'), #change legend key width
    legend.title = element_blank(), #change legend title font size
    legend.text = element_text(size=5) #change legend text font size
    )
all_criteria_scores_excluded_mapa


## -----------------------------------------------------------------------------
areas_proporcionales_all_criteria_excluded <- all_criteria_scores_excluded %>%
  select(`Categoría agregada`) %>% 
  mutate(
    área = units::drop_units(st_area(geometry)),
    `área total` = sum(units::drop_units(st_area(geometry)))) %>%
  st_drop_geometry %>%
  group_by(`Categoría agregada`) %>%
  summarise(proporción = sum(área, na.rm = T)/first(`área total`)*100) %>%
  na.omit() %>%
  mutate(proporción = as.numeric(scale(proporción, center = FALSE,
                            scale = sum(proporción, na.rm = TRUE)/100)))
areas_proporcionales_all_criteria_excluded %>% 
    kable(format = 'html', escape = F, booktabs = T, digits = 2,
        caption = 'Áreas proporcionales de categorías agregadas para la selección de sitios de estaciones meteoclimáticas con exclusión por factores limitantes') %>%
      kable_styling(bootstrap_options = c("hover", "condensed"), full_width = T)


## -----------------------------------------------------------------------------
escenarios <- c(100, 150, 250) #Cada estación debe cubrir dichas áreas en km2
n_esc <- length(escenarios)


## -----------------------------------------------------------------------------
# Categorías agregadas
categorias_elegidas <- c('altamente idóneo', 'idóneo')
names(categorias_elegidas) <- rep('categorías de idoneidad', length(categorias_elegidas))
# Criterio de separación (en este caso, kilómetros cuadrados por estación) 
names(escenarios) <- paste('Escenario:', escenarios, 'km2 por estación')
# Primero realizamos los cálculos
resumen_calculos_escenarios <- map(escenarios, 
    ~ generar_centroides_distantes(
      geom = all_criteria_scores_excluded %>%
        filter(`Categoría agregada` %in% categorias_elegidas),
      km2_por_puntos = .x, solo_calculos = T))
# Finalmente, creamos los objetos que exportaremos para visualización en SIG
escenarios_ai_mi <- map(
  escenarios,
  ~ generar_centroides_distantes(
    geom = all_criteria_scores_excluded %>%
      filter(`Categoría agregada` %in% categorias_elegidas),
    km2_por_puntos = .x))
# Mapas
escenarios_ai_mi_mapas <- map(names(escenarios_ai_mi),
    function(x) {
      escenarios_ai_mi[[x]] %>% ggplot + geom_sf(alpha = 0.8) +
        geom_sf(data = all_criteria_scores_excluded,
                aes(fill = `Categoría agregada`), lwd = 0, alpha = 0.4) +
        scale_fill_manual(values = paleta) +
        labs(title = x) +
        theme_bw()
    })
escenarios_ai_mi_mapas
# Exportar
map(names(escenarios_ai_mi),
    function(x) {
      sin_especiales <- iconv(names(escenarios_ai_mi[x]),
                              from = 'utf-8', to = 'ASCII//TRANSLIT')
      nombre_archivo <- tolower(paste0(gsub(' |: ', '_', sin_especiales), '.gpkg'))
      escenarios_ai_mi[[x]] %>% st_write(paste0('out/', nombre_archivo), delete_dsn = T)
    })


## -----------------------------------------------------------------------------
map(escenarios_ai_mi, estadisticos_distancias_orden_1)
# Los valores de separación inicialmente esperados se obtuvieron


## -----------------------------------------------------------------------------
onamet_para_vecindad <- st_read('out/con_indicacion_estatus_onamet.gpkg') %>% 
  filter(estado == 'activa')
estadisticos_distancias_orden_1(onamet_para_vecindad)


## -----------------------------------------------------------------------------
indrhi_para_vecindad_b <- st_read('out/con_indicacion_estatus_climaticas_indrhi.gpkg') %>% 
  filter(Estado == 'Bueno')
estadisticos_distancias_orden_1(indrhi_para_vecindad_b)


## -----------------------------------------------------------------------------
indrhi_para_vecindad_br <- st_read('out/con_indicacion_estatus_climaticas_indrhi.gpkg') %>% 
  filter(Estado == 'Bueno' | Estado == 'Regular')
estadisticos_distancias_orden_1(indrhi_para_vecindad_br)


## -----------------------------------------------------------------------------
rgdal::setCPLConfigOption("GDAL_PAM_ENABLED", "FALSE")
actbue <- c(indrhi_para_vecindad_b %>% st_geometry(),
                onamet_para_vecindad %>% st_geometry()) %>% st_transform(32619)
actbue_r <- rasterize(x = as(actbue, 'Spatial'),
                                      y = raster(extent(ind_esp),
                                                 resolution = 500, crs = 'EPSG:32619'),
                                      field = 1)
actbue_d <- distance(actbue_r)
actbue_d %>% writeRaster('out/onamet_indrhi_actbue_dist_500x500_distancia.tif',
                         overwrite = T, setStatistics = F)

actbuereg <- c(indrhi_para_vecindad_br %>% st_geometry(),
                onamet_para_vecindad %>% st_geometry()) %>% st_transform(32619)
actbuereg_r <- rasterize(x = as(actbuereg, 'Spatial'),
                                      y = raster(extent(ind_esp),
                                                 resolution = 500, crs = 'EPSG:32619'),
                                      field = 1)
actbuereg_d <- distance(actbuereg_r)
actbuereg_d %>% writeRaster('out/onamet_indrhi_actbuereg_dist_500x500_distancia.tif',
                            overwrite = T, setStatistics = F)


## -----------------------------------------------------------------------------
indice <- 1; escenario <- '100'
redundancia <- 'activas_buenas'; estaciones <- actbue; distancia <- actbue_d
esc_d <- raster::extract(distancia, escenarios_ai_mi[[indice]])
esc <- escenarios_ai_mi[[indice]] %>%
  mutate(dist_onamet_indrhi = esc_d) %>% 
  filter(dist_onamet_indrhi > resumen_calculos_escenarios[[indice]]$`Distancia esperada entre vecinos`*1000) %>%
  st_join(all_criteria_scores_excluded, left = T)
esc %>%
  st_write(paste0('out/escenario_', escenario, '_km2_por_estacion_exclusion_redundancia_', redundancia, '.gpkg'), delete_dsn = T)
obj <- paste0('esc_', escenario, '_', redundancia, '_mapa')
assign(obj,
       bind_rows(esc %>% st_geometry %>% st_as_sf() %>%
                   mutate(id='sitios propuestos'),
                 estaciones %>% st_geometry %>% st_as_sf() %>%
                   mutate(id='estaciones existentes')) %>%
         ggplot +
         geom_sf(data = pais, fill = 'transparent', color = 'grey50') +
         geom_sf(alpha = 0.8, aes(fill = id, shape = id), size = 1.5) +
         scale_fill_manual(values = c('grey70', 'black')) +
         scale_shape_manual(values = c(25, 21)) +
         # geom_sf(data = all_criteria_scores_excluded,
         #         aes(fill = `Categoría agregada`), lwd = 0, alpha = 0.4) +
         # scale_fill_manual(values = paleta) +
         labs(title = paste0(trimws(names(escenarios)[indice]),'\n',
                             'Eliminación de redundancia respecto de estaciones ',
                             gsub('_', '+', redundancia))) +
         theme_bw() + 
         ggspatial::annotation_scale(style = 'ticks') +
         theme(legend.title = element_blank())) 
get(obj) #Mapa


## -----------------------------------------------------------------------------
obj <- paste0('esc_', escenario, '_', redundancia, '_df_resumen')
assign(obj,
       esc %>% st_drop_geometry %>%
         dplyr::select(`Categoría agregada`) %>% count(`Categoría agregada`) %>% 
         mutate(`Monto (US$)` = ifelse(`Categoría agregada` == 'idóneo', n*7000, n*35000)) %>% 
         adorn_totals())
get(obj) #Tabla


## -----------------------------------------------------------------------------
indice <- 1; escenario <- '100'
redundancia <- 'activas_buenas_regulares'; estaciones <- actbuereg; distancia <- actbuereg_d
esc_d <- raster::extract(distancia, escenarios_ai_mi[[indice]])
esc <- escenarios_ai_mi[[indice]] %>%
  mutate(dist_onamet_indrhi = esc_d) %>% 
  filter(dist_onamet_indrhi > resumen_calculos_escenarios[[indice]]$`Distancia esperada entre vecinos`*1000) %>%
  st_join(all_criteria_scores_excluded, left = T)
esc %>%
  st_write(paste0('out/escenario_', escenario, '_km2_por_estacion_exclusion_redundancia_', redundancia, '.gpkg'), delete_dsn = T)
obj <- paste0('esc_', escenario, '_', redundancia, '_mapa')
assign(obj,
       bind_rows(esc %>% st_geometry %>% st_as_sf() %>%
                   mutate(id='sitios propuestos'),
                 estaciones %>% st_geometry %>% st_as_sf() %>%
                   mutate(id='estaciones existentes')) %>%
         ggplot +
         geom_sf(data = pais, fill = 'transparent', color = 'grey50') +
         geom_sf(alpha = 0.8, aes(fill = id, shape = id), size = 1.5) +
         scale_fill_manual(values = c('grey70', 'black')) +
         scale_shape_manual(values = c(25, 21)) +
         labs(title = paste0(trimws(names(escenarios)[indice]),'\n',
                             'Eliminación de redundancia respecto de estaciones ',
                             gsub('_', '+', redundancia))) +
         theme_bw() + 
         ggspatial::annotation_scale(style = 'ticks') +
         theme(legend.title = element_blank())) 
get(obj) #Mapa


## -----------------------------------------------------------------------------
obj <- paste0('esc_', escenario, '_', redundancia, '_df_resumen')
assign(obj,
       esc %>% st_drop_geometry %>%
         dplyr::select(`Categoría agregada`) %>% count(`Categoría agregada`) %>% 
         mutate(`Monto (US$)` = ifelse(`Categoría agregada` == 'idóneo', n*7000, n*35000)) %>% 
         adorn_totals())
get(obj) #Tabla


## -----------------------------------------------------------------------------
indice <- 2; escenario <- '150'
redundancia <- 'activas_buenas'; estaciones <- actbue; distancia <- actbue_d
esc_d <- raster::extract(distancia, escenarios_ai_mi[[indice]])
esc <- escenarios_ai_mi[[indice]] %>%
  mutate(dist_onamet_indrhi = esc_d) %>% 
  filter(dist_onamet_indrhi > resumen_calculos_escenarios[[indice]]$`Distancia esperada entre vecinos`*1000) %>%
  st_join(all_criteria_scores_excluded, left = T)
esc %>%
  st_write(paste0('out/escenario_', escenario, '_km2_por_estacion_exclusion_redundancia_', redundancia, '.gpkg'), delete_dsn = T)
obj <- paste0('esc_', escenario, '_', redundancia, '_mapa')
assign(obj,
       bind_rows(esc %>% st_geometry %>% st_as_sf() %>%
                   mutate(id='sitios propuestos'),
                 estaciones %>% st_geometry %>% st_as_sf() %>%
                   mutate(id='estaciones existentes')) %>%
         ggplot +
         geom_sf(data = pais, fill = 'transparent', color = 'grey50') +
         geom_sf(alpha = 0.8, aes(fill = id, shape = id), size = 1.5) +
         scale_fill_manual(values = c('grey70', 'black')) +
         scale_shape_manual(values = c(25, 21)) +
         # geom_sf(data = all_criteria_scores_excluded,
         #         aes(fill = `Categoría agregada`), lwd = 0, alpha = 0.4) +
         # scale_fill_manual(values = paleta) +
         labs(title = paste0(trimws(names(escenarios)[indice]),'\n',
                             'Eliminación de redundancia respecto de estaciones ',
                             gsub('_', '+', redundancia))) +
         theme_bw() + 
         ggspatial::annotation_scale(style = 'ticks') +
         theme(legend.title = element_blank())) 
get(obj) #Mapa


## -----------------------------------------------------------------------------
obj <- paste0('esc_', escenario, '_', redundancia, '_df_resumen')
assign(obj,
       esc %>% st_drop_geometry %>%
         dplyr::select(`Categoría agregada`) %>% count(`Categoría agregada`) %>% 
         mutate(`Monto (US$)` = ifelse(`Categoría agregada` == 'idóneo', n*7000, n*35000)) %>% 
         adorn_totals())
get(obj) #Tabla


## -----------------------------------------------------------------------------
indice <- 2; escenario <- '150'
redundancia <- 'activas_buenas_regulares'; estaciones <- actbuereg; distancia <- actbuereg_d
esc_d <- raster::extract(distancia, escenarios_ai_mi[[indice]])
esc <- escenarios_ai_mi[[indice]] %>%
  mutate(dist_onamet_indrhi = esc_d) %>% 
  filter(dist_onamet_indrhi > resumen_calculos_escenarios[[indice]]$`Distancia esperada entre vecinos`*1000) %>%
  st_join(all_criteria_scores_excluded, left = T)
esc %>%
  st_write(paste0('out/escenario_', escenario, '_km2_por_estacion_exclusion_redundancia_', redundancia, '.gpkg'), delete_dsn = T)
obj <- paste0('esc_', escenario, '_', redundancia, '_mapa')
assign(obj,
       bind_rows(esc %>% st_geometry %>% st_as_sf() %>%
                   mutate(id='sitios propuestos'),
                 estaciones %>% st_geometry %>% st_as_sf() %>%
                   mutate(id='estaciones existentes')) %>%
         ggplot +
         geom_sf(data = pais, fill = 'transparent', color = 'grey50') +
         geom_sf(alpha = 0.8, aes(fill = id, shape = id), size = 1.5) +
         scale_fill_manual(values = c('grey70', 'black')) +
         scale_shape_manual(values = c(25, 21)) +
         labs(title = paste0(trimws(names(escenarios)[indice]),'\n',
                             'Eliminación de redundancia respecto de estaciones ',
                             gsub('_', '+', redundancia))) +
         theme_bw() + 
         ggspatial::annotation_scale(style = 'ticks') +
         theme(legend.title = element_blank())) 
get(obj) #Mapa


## -----------------------------------------------------------------------------
obj <- paste0('esc_', escenario, '_', redundancia, '_df_resumen')
assign(obj,
       esc %>% st_drop_geometry %>%
         dplyr::select(`Categoría agregada`) %>% count(`Categoría agregada`) %>% 
         mutate(`Monto (US$)` = ifelse(`Categoría agregada` == 'idóneo', n*7000, n*35000)) %>% 
         adorn_totals())
get(obj) #Tabla


## -----------------------------------------------------------------------------
indice <- 3; escenario <- '250'
redundancia <- 'activas_buenas'; estaciones <- actbue; distancia <- actbue_d
esc_d <- raster::extract(distancia, escenarios_ai_mi[[indice]])
esc <- escenarios_ai_mi[[indice]] %>%
  mutate(dist_onamet_indrhi = esc_d) %>% 
  filter(dist_onamet_indrhi > resumen_calculos_escenarios[[indice]]$`Distancia esperada entre vecinos`*1000) %>%
  st_join(all_criteria_scores_excluded, left = T)
esc %>%
  st_write(paste0('out/escenario_', escenario, '_km2_por_estacion_exclusion_redundancia_', redundancia, '.gpkg'), delete_dsn = T)
obj <- paste0('esc_', escenario, '_', redundancia, '_mapa')
assign(obj,
       bind_rows(esc %>% st_geometry %>% st_as_sf() %>%
                   mutate(id='sitios propuestos'),
                 estaciones %>% st_geometry %>% st_as_sf() %>%
                   mutate(id='estaciones existentes')) %>%
         ggplot +
         geom_sf(data = pais, fill = 'transparent', color = 'grey50') +
         geom_sf(alpha = 0.8, aes(fill = id, shape = id), size = 1.5) +
         scale_fill_manual(values = c('grey70', 'black')) +
         scale_shape_manual(values = c(25, 21)) +
         # geom_sf(data = all_criteria_scores_excluded,
         #         aes(fill = `Categoría agregada`), lwd = 0, alpha = 0.4) +
         # scale_fill_manual(values = paleta) +
         labs(title = paste0(trimws(names(escenarios)[indice]),'\n',
                             'Eliminación de redundancia respecto de estaciones ',
                             gsub('_', '+', redundancia))) +
         theme_bw() + 
         ggspatial::annotation_scale(style = 'ticks') +
         theme(legend.title = element_blank())) 
get(obj) #Mapa


## -----------------------------------------------------------------------------
obj <- paste0('esc_', escenario, '_', redundancia, '_df_resumen')
assign(obj,
       esc %>% st_drop_geometry %>%
         dplyr::select(`Categoría agregada`) %>% count(`Categoría agregada`) %>% 
         mutate(`Monto (US$)` = ifelse(`Categoría agregada` == 'idóneo', n*7000, n*35000)) %>% 
         adorn_totals())
get(obj) #Tabla


## -----------------------------------------------------------------------------
indice <- 3; escenario <- '250'
redundancia <- 'activas_buenas_regulares'; estaciones <- actbuereg; distancia <- actbuereg_d
esc_d <- raster::extract(distancia, escenarios_ai_mi[[indice]])
esc <- escenarios_ai_mi[[indice]] %>%
  mutate(dist_onamet_indrhi = esc_d) %>% 
  filter(dist_onamet_indrhi > resumen_calculos_escenarios[[indice]]$`Distancia esperada entre vecinos`*1000) %>%
  st_join(all_criteria_scores_excluded, left = T)
esc %>%
  st_write(paste0('out/escenario_', escenario, '_km2_por_estacion_exclusion_redundancia_', redundancia, '.gpkg'), delete_dsn = T)
obj <- paste0('esc_', escenario, '_', redundancia, '_mapa')
assign(obj,
       bind_rows(esc %>% st_geometry %>% st_as_sf() %>%
                   mutate(id='sitios propuestos'),
                 estaciones %>% st_geometry %>% st_as_sf() %>%
                   mutate(id='estaciones existentes')) %>%
         ggplot +
         geom_sf(data = pais, fill = 'transparent', color = 'grey50') +
         geom_sf(alpha = 0.8, aes(fill = id, shape = id), size = 1.5) +
         scale_fill_manual(values = c('grey70', 'black')) +
         scale_shape_manual(values = c(25, 21)) +
         labs(title = paste0(trimws(names(escenarios)[indice]),'\n',
                             'Eliminación de redundancia respecto de estaciones ',
                             gsub('_', '+', redundancia))) +
         theme_bw() + 
         ggspatial::annotation_scale(style = 'ticks') +
         theme(legend.title = element_blank())) 
get(obj) #Mapa


## -----------------------------------------------------------------------------
obj <- paste0('esc_', escenario, '_', redundancia, '_df_resumen')
assign(obj,
       esc %>% st_drop_geometry %>%
         dplyr::select(`Categoría agregada`) %>% count(`Categoría agregada`) %>% 
         mutate(`Monto (US$)` = ifelse(`Categoría agregada` == 'idóneo', n*7000, n*35000)) %>% 
         adorn_totals())
get(obj) #Tabla

