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
