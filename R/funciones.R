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
limpiar_coord <- function(mi_vector = NULL) {
  library(parzer)
  utm_x_valida <- !grepl(' ', mi_vector) &
    nchar(as.character(mi_vector)) == 6 &
    grepl(paste0('^', as.character(18:65), collapse='|'), mi_vector)
  utm_y_valida <- !grepl(' ', mi_vector) &
    nchar(as.character(mi_vector)) == 7 &
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
  foo <- as.data.frame(cbind(
    if(any(lon_valida)) lon_espacios,
    if(any(lat_valida)) lat_espacios,
    if(any(utm_x_valida)) utm_x,
    if(any(utm_y_valida)) utm_y))
  salida <- sapply(foo, as.numeric)
  return(salida)
}
