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
