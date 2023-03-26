## ----supsetup, include=FALSE------------------------------------------------------------------------------------------------
knitr::opts_chunk$set(
  cache = F, 
  echo = TRUE,
  warning = FALSE,
  message = FALSE,
  out.width = '100%',
  dpi = 300)
# options(digits = 3)


## ----suppaquetes------------------------------------------------------------------------------------------------------------
library(kableExtra)
library(tidyverse)
library(ahpsurvey)
estilo_kable <- function(df, titulo = '', cubre_anchura = T) {
  df %>% kable(format = 'html', escape = F, booktabs = T, digits = 2, caption = titulo) %>%
  kable_styling(bootstrap_options = c("hover", "condensed"), full_width = cubre_anchura)
}


## ----supvariables-----------------------------------------------------------------------------------------------------------
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


## ----suptabequivalencias----------------------------------------------------------------------------------------------------
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


## ----supimpresiontabequivalencias-------------------------------------------------------------------------------------------
as.data.frame(variables) %>% 
  rownames_to_column() %>% 
  setNames(nm = c('Código', 'Nombre completo')) %>% 
  kable(format = 'html', escape = F, booktabs = T,
        caption = 'Tabla de equivalencias de nombres de las variables evaluadas') %>%
  kable_styling(bootstrap_options = c("hover", "condensed"), full_width = T)


## ----suptablaresultadosenbruto----------------------------------------------------------------------------------------------
tabla_original <- read_csv('fuentes/respuestas-ahp/respuestas.csv')
tabla_en_bruto <- tabla_original[, -grep('Marca|Opcionalmente', colnames(tabla_original))]
tabla_en_bruto %>% 
    kable(format = 'html', escape = F, booktabs = T,
        caption = 'Tabla de resultados en bruto (anonimizada) obtenida a partir del rellenado del "Formulario de comparación pareada de criterios de identificación de sitios idóneos para una red de observación climática"') %>%
  kable_styling(bootstrap_options = c("hover", "condensed"), full_width = T)


## ----suptablaresultadosrecodificados----------------------------------------------------------------------------------------
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


## ----suptablaresultadosparamatrizpareada------------------------------------------------------------------------------------
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


## ----supmatrizahp, results='asis'-------------------------------------------------------------------------------------------
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


## ----suprisimuladospaqahpsurvey---------------------------------------------------------------------------------------------
ri_sim <- t(data.frame(RI = c(0.0000000, 0.0000000, 0.5251686, 0.8836651, 1.1081014, 1.2492774, 1.3415514, 1.4048466, 1.4507197, 1.4857266, 1.5141022,1.5356638, 1.5545925, 1.5703498, 1.5839958)))
colnames(ri_sim) <- 1:15
ri_sim %>%
  kable(format = 'html', escape = F, booktabs = T, digits = 2,
        caption = 'Índices aleatorios generados por la función ahp.ri con 500000 simulaciones para 1 a 15 atributos') %>%
  kable_styling(bootstrap_options = c("hover", "condensed"), full_width = T)


## ----supprobandori----------------------------------------------------------------------------------------------------------
tiempo_10k <- system.time(probandoRI <- ahp.ri(nsims = 10000, dim = 8, seed = 99))


## ----supdefri---------------------------------------------------------------------------------------------------------------
RI <- ri_sim[8]


## ----suprazondeconsistencia-------------------------------------------------------------------------------------------------
cr <- matriz_ahp %>% ahp.cr(atts = names(variables), ri = RI)
data.frame(`Persona consultada` = seq_along(cr), CR = cr, check.names = F) %>%
  estilo_kable(titulo = 'Razones de consistencia (consistency ratio) por persona consultada',
               cubre_anchura = F) %>% 
  kable_styling(position = 'left') %>% 
  column_spec(column = 1:2, width = "10em")


## ----supumbrales------------------------------------------------------------------------------------------------------------
umbral_saaty <- 0.1
umbral_alterno <- 0.15
umbral <- ifelse(recod_repartida, umbral_alterno, umbral_saaty)


## ----supnumconsistinconsist-------------------------------------------------------------------------------------------------
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


## ----supflujocompletoahp----------------------------------------------------------------------------------------------------
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

