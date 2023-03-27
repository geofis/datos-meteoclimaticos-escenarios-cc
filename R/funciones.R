# From: https://crimebythenumbers.com/scrape-table.html
scrape_pdf <- function(list_of_tables,
                      table_number,
                      number_columns,
                      column_names) {
  data <- list_of_tables[table_number]
  data <- gsub('°', ' ', data)
  data <- trimws(data)
  data <- strsplit(data, "\n")
  data <- data[[1]]
  # data <- data[grep("Miami", data):
  #                grep("Nationwide Total", data)]
  data <- str_split_fixed(data, " {2,}", number_columns)
  data <- data.frame(data)
  names(data) <- column_names
  return(data)
}
# Limpiar coordenadas
limpiar_coord <- function(mi_vector = NULL, sufijo = NULL) {
  library(parzer)
  utm_x_valida <- !grepl(' ', mi_vector) &
    nchar(as.character(as.integer(mi_vector))) == 6 &
    grepl(paste0('^', as.character(18:65), collapse='|'), mi_vector)
  utm_y_valida <- !grepl(' ', mi_vector) &
    nchar(as.character(as.integer(mi_vector))) == 7 &
    grepl(paste0('^', as.character(185:225), collapse='|'), mi_vector)
  lon_valida <- grepl(' ', mi_vector) &
    grepl(paste0('^', as.character(68:72), collapse='|'), mi_vector)
  lat_valida <- grepl(' ', mi_vector) &
    grepl(paste0('^', as.character(17:21), collapse='|'), mi_vector)
  lat_espacios <- ifelse(lat_valida,parse_lat(mi_vector), NA) # Sexagesimal con espacios
  lon_espacios <- ifelse(lon_valida, parse_lon(mi_vector), NA) # Sexagesimal con espacios
  lon_espacios <- ifelse(lon_espacios < 0, lon_espacios, (-1) * lon_espacios)
  utm_x <- ifelse(utm_x_valida, mi_vector, NA)
  utm_y <- ifelse(utm_y_valida, mi_vector, NA)
  foo <- cbind(
    lon_dd = if(any(lon_valida)) lon_espacios else NULL,
    lat_dd = if(any(lat_valida)) lat_espacios else NULL,
    utm_x = if(any(utm_x_valida)) utm_x else NULL,
    utm_y = if(any(utm_y_valida)) utm_y else NULL)
  salida <- sapply(as.data.frame(foo), as.numeric)
  colnames(salida) <- paste0(colnames(salida), '_', sufijo)
  return(salida)
}

# Función de reclasificación
reclasificar <- function(vectorial, campo, umbrales, campo_indice = 'hex_id',
                         ord_cat = 'in', nombre = NULL){
  #' @param vectorial Objeto de clase \code{sf} que contiene
  #'   la representación territorial de la variable.
  #' @param campo Cadena de caracteres conteniendo el nombre del campo a reclasificar.
  #' @param umrables Vector de límites de superiores de cada categoría.
  #'   Los límites mínimo y máximo no necesitan incluirse. La función los deriva.
  #' @param ord_cat Caracter definiendo la opción de ordenación de categorías.
  #'   'in': altamente idóneo, mod. idóneo, marg. idóneo, no idóneo
  #'   'ni': no idóneo, marg. idóneo, mod. idóneo, altamente idóneo
  #'   'nin': no idóneo, altamente idóneo, mod. idóneo, marg. idóneo, no idóneo
  #'   'nin_rev': no idóneo, marg. idóneo, mod. idóneo, altamente idóneo, no idóneo

  #' @example
  # source('R/funciones.R')
  # library(sf)
  # res_h3 <- 7 #Escribir un valor entre 4 y 7, ambos extremos inclusive
  # ruta_ez_gh <- 'https://raw.githubusercontent.com/geofis/zonal-statistics/'
  # ez_ver <- 'da5b4ed7c6b126fce15f8980b7a0b389937f7f35/'
  # ind_esp_url <- paste0(ruta_ez_gh, ez_ver, 'out/all_sources_all_variables_res_', res_h3, '.gpkg')
  # ind_esp_url
  # if(!any(grepl('^ind_esp$', ls()))){
  #   ind_esp <- st_read(ind_esp_url, optional = T)
  #   st_geometry(ind_esp) <- "geometry"
  #   ind_esp <- st_transform(ind_esp, 32619)
  # }
  # if(!any(grepl('^pais_url$', ls()))){
  #   pais_url <- paste0(ruta_ez_gh, ez_ver, 'inst/extdata/dr.gpkg')
  #   pais <- st_read(pais_url, optional = T, layer = 'pais')
  #   st_geometry(pais) <- "geometry"
  #   pais <- st_transform(pais, 32619)
  # }
  # if(!any(grepl('^ind_esp_inters$', ls()))){
  #   ind_esp_inters <- st_intersection(pais, ind_esp)
  #   colnames(ind_esp_inters) <- colnames(ind_esp)
  #   ind_esp_inters$area_sq_m <- units::drop_units(st_area(ind_esp_inters))
  #   ind_esp_inters$area_sq_km <- units::drop_units(st_area(ind_esp_inters))/1000000
  #   ind_esp_inters
  # }
  # # Para "OSM-DIST mean"
  # if(!any(grepl('^osm_rcl$', ls()))){
  #   osm_rcl <- reclasificar(vectorial = ind_esp_inters, campo = 'OSM-DIST mean',
  #                           umbrales = c(50, 200, 500, 5000),
  #                           nombre = 'Distancia a accesos OSM',
  #                           ord_cat = 'nin_rev')
  #   osm_rcl$mapa +
  #     geom_sf(data = pais, fill = 'transparent', lwd = 0.5, color = 'grey50')
  #   osm_rcl$intervalos_y_etiquetas
  # }
  # if(any(grepl('^osm_rcl$', ls()))){
  #   clipr::write_clip(osm_rcl$intervalos_y_etiquetas)
  # }
  
  # Paquetes
  library(sf)
  library(ggplot2)
  library(dplyr)
  
  # Definir nombre
  if(is.null(nombre)) nombre <- campo
  
  # Función para construir categorías
  fuente <- c('no', 'marginalmente', 'moderadamente', 'altamente', 'idóneo')
  construir_categorias <- function(ordenacion = ord_cat){
    categorias <- switch(ordenacion,
           'nin' = c(
             paste(fuente[1:4], fuente[5]),
             paste(fuente[1], fuente[5])
             ),
           'nin_rev' = c(
             paste(fuente[1], fuente[5]),
             paste(fuente[4:1], fuente[5])
           ),
           'in' = c(paste(fuente[4:1], fuente[5])),
           'ni' = c(paste(fuente[1:4], fuente[5]))
    )
    return(categorias)
  }
  
  # Construir categorías
  categorias <- construir_categorias()
  
  # Añadir umbrales extremos
  umbrales_ampliados <- c(min(vectorial[[campo]], na.rm = T), umbrales, max(vectorial[[campo]], na.rm = T))
  umbrales_ampliados
  if(length(umbrales) + 1 != length(categorias)) 
    stop('El número de categorías es incorrecto')
  
  # Crear intervalos
  campo_salida_interv <- paste(campo, 'intervalos')
  campo_salida_etiq <- paste(campo, 'etiquetas')
  vectorial[[campo_salida_interv]] <- cut(
    vectorial[[campo]],
    umbrales_ampliados, include.lowest = T)
  vectorial[[campo_salida_etiq]] <- factor(vectorial[[campo_salida_interv]],
                                           labels = categorias)
  # vectorial[[paste(campo, 'enteros_ordenados', sep = '_')]] <- as.integer(
  vectorial[[paste(campo, 'puntuación')]] <- as.integer(
    factor(vectorial[[campo_salida_etiq]],
           levels = c(paste(fuente[1:4], fuente[5]))))
  # vectorial <- vectorial[c(campo_indice, campo_salida_interv, campo_salida_etiq, paste(campo, 'enteros_ordenados', sep = '_'))]
  vectorial <- vectorial[c(campo_indice, campo_salida_interv, campo_salida_etiq, paste(campo, 'puntuación'))]
  
  # Crear mapa
  val_col <- c("altamente idóneo" = "#018571", "moderadamente idóneo" = "#80cdc1",
               "marginalmente idóneo" = "#dfd2b3", "no idóneo" = "#a6611a")
  val_col_cat <- val_col[match(categorias, names(val_col))]
  mapa <- vectorial %>% ggplot +
    aes(fill = .data[[campo_salida_etiq]]) +
    geom_sf(lwd=0) + 
    scale_fill_manual(nombre, values = val_col) +
    labs(title = paste('Reclasificación de valores de', nombre)) +
    theme_bw() +
    theme(
      legend.position = 'bottom',
      legend.key.size = unit(0.5, 'cm'), #change legend key size
      legend.key.height = unit(0.5, 'cm'), #change legend key height
      legend.key.width = unit(0.5, 'cm'), #change legend key width
      legend.title = element_text(size=8), #change legend title font size
      legend.text = element_text(size=6) #change legend text font size
      )
    
  # Intervalos y etiquetas
  extraer_digitos_interv <- function(col) {
    as.numeric(gsub('(\\(|\\[)(\\d.*)(,.*)', '\\2', col))
  }
  intervalos_y_etiquetas <- vectorial %>% st_drop_geometry %>%
    select(all_of(campo_salida_interv),
           all_of(campo_salida_etiq),
           all_of(paste(campo, 'puntuación'))) %>% 
           # all_of(paste(campo, 'enteros_ordenados', sep = '_'))) %>%
    distinct %>% 
    na.omit() %>% 
    mutate_at(.vars = campo_salida_interv,
              .funs = list(ord = extraer_digitos_interv)) %>% 
    arrange(ord) %>%
    select(-ord)
  
  # Salida
  return(list(vectorial = vectorial, mapa = mapa, intervalos_y_etiquetas = intervalos_y_etiquetas))
}

generar_resumen_grafico_estadistico_criterios <- function(
    variable = NULL, nombre = NULL, umbrales = NULL, 
    ord_cat = NULL, kable_caption = paste('Intervalos de', nombre)){
  internal <- variable
  resumen_estadistico <- tryCatch(
    success <- summary(ind_esp_inters[, internal, drop=T]),
    error = function(cond) {
      message('Caught an error. This is the error message: ', cond, appendLF = TRUE)
      return(NA)
    }
  )
  print(resumen_estadistico)
  violin <- tryCatch(
    success <- ggplot(ind_esp_inters) +
      aes(x = '', y = !!sym(internal)) +
      geom_boxplot(alpha = 0, width = 0.3) +
      geom_violin(alpha = 0.6, width = 0.8, color = "transparent", fill = "#00BA38") +
      scale_y_continuous(trans = 'pseudo_log') +
      theme_bw() +
      ylab(nombre) +
      theme(axis.title.x = element_blank(),
            plot.margin = margin(1, 6, 1, 6, "cm"),
            plot.background = element_rect(fill = "white")
            ),
    error = function(cond) {
      message('Caught an error. This is the error message: ', cond, appendLF = TRUE)
      return(NA)
    }
  )
  reclasificacion <- tryCatch(
    success <- reclasificar(
      vectorial = ind_esp_inters, campo = internal,
      umbrales = umbrales,
      nombre = nombre,
      ord_cat = ord_cat),
    error = function(cond) {
      message('Caught an error. This is the error message: ', cond, appendLF = TRUE)
      return(NA)
    }
  )
  vectorial <- tryCatch(
    success <- reclasificacion$vectorial %>% 
      rename_with(~ stringr::str_replace(.x, 
                                         pattern = internal, 
                                         replacement = nombre), 
                  matches(internal)),
    error = function(cond) {
      message('Caught an error. This is the error message: ', cond, appendLF = TRUE)
      return(NA)
    }
  )
  area_proporcional <- tryCatch(
    success <- vectorial %>%
      mutate(
        área = units::drop_units(st_area(geometry)),
        `área total` = sum(units::drop_units(st_area(geometry)))) %>%
      st_drop_geometry %>%
      group_by(across(all_of(matches('etiquetas')))) %>%
      summarise(proporción = sum(área, na.rm = T)/first(`área total`)*100) %>%
      na.omit() %>%
      mutate(proporción = as.numeric(scale(proporción, center = FALSE,
                                scale = sum(proporción, na.rm = TRUE)/100))),
    error = function(cond) {
      message('Caught an error. This is the error message: ', cond, appendLF = TRUE)
      return(NA)
    }
  )
  area_proporcional_kable <- tryCatch(
    success <- area_proporcional %>% 
      kable(format = 'html', escape = F, booktabs = T, digits = 2,
            caption = paste('Áreas proporcionales de', nombre)) %>%
      kable_styling(bootstrap_options = c("hover", "condensed"), full_width = T),
    error = function(cond) {
      message('Caught an error. This is the error message: ', cond, appendLF = TRUE)
      return(NA)
    }
  )
  mapa_con_pais <- tryCatch(
    success <- reclasificacion$mapa +
      geom_sf(data = pais, fill = 'transparent', lwd = 0.5, color = 'grey50'),
    error = function(cond) {
      message('Caught an error. This is the error message: ', cond, appendLF = TRUE)
      return(NA)
    }
  )
  reclasificacion$intervalos_y_etiquetas <- tryCatch(
    success <- reclasificacion$intervalos_y_etiquetas %>%
      rename_with(~ stringr::str_replace(.x, 
                                       pattern = internal, 
                                       replacement = nombre), 
                matches(internal)),
    error = function(cond) {
      message('Caught an error. This is the error message: ', cond, appendLF = TRUE)
      return(NA)
    }
  )
  intervalos_y_etiquetas_kable <- tryCatch(
    success <- reclasificacion$intervalos_y_etiquetas %>% 
      kable(format = 'html', escape = F, booktabs = T, digits = 2, caption = kable_caption) %>%
      kable_styling(bootstrap_options = c("hover", "condensed"), full_width = T),
    error = function(cond) {
      message('Caught an error. This is the error message: ', cond, appendLF = TRUE)
      return(NA)
    }
  )
  return(list(
    resumen_estadistico = resumen_estadistico,
    violin = violin,
    vectorial = vectorial,
    area_proporcional = area_proporcional,
    area_proporcional_kable = area_proporcional_kable,
    mapa = reclasificacion[['mapa']],
    mapa_con_pais = mapa_con_pais,
    intervalos_y_etiquetas = reclasificacion[['intervalos_y_etiquetas']],
    intervalos_y_etiquetas_kable = intervalos_y_etiquetas_kable
  ))
}
