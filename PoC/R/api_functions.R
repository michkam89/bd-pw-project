#' Make single api call for trams geolocalisation
#'
#' @param api_key personal key to API
#' @param tram_number number of a tram to track; default NULL call for all trams
#'
#' @return single call transforms JSON to tibble and saves to .tsv file
#'
#' @importFrom purrr map_df
#' @importFrom dplyr mutate
#' @importFrom httr GET content
#' @export

collect_trams_from_api <- function(api_key=NULL,
                                   line_number = NULL,
                                   time_interval = 60L,
                                   max_calls = NULL,
                                   output = "./data-raw/api_tram_out.tsv") {
  N <- 0
  if (is.null(max_calls)) {
    usethis::ui_info("max_calls not provided, API will make calls until interuption")
    condition <- TRUE
  } else {
    usethis::ui_info(paste("API will make", max_calls, "calls"))
    condition <- N < max_calls
  }

  url_base <- paste(
    "https://api.um.warszawa.pl/api/action/busestrams_get/?resource_id=%20f2e5503e-927d-4ad3-9500-4ab9e55deb59",
    "&apikey=", Sys.getenv("UM_WAW_PERSONAL_API_KEY"),
    "&type=2" # 2 for trams, 1 for buses
  )

  if (!is.null(line_number)) {
    url <- paste(url_base, "&line=", line_number)
  } else {
    url <- base_url
  }

  while(condition) {
    # update counter and condition
    N <- N + 1
    condition <- N < max_calls

    get_out <- GET(url)
    x <- content(get_out)$result |>
      map_df(~ .x) |>
      mutate(get_timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"))

    if (N == 1){
      write.table(x, file = output)
    } else {
      write.table(x, file = output, append = TRUE, col.names = FALSE)
    }

    Sys.sleep(time_interval)
  }
}

# readr::read_delim("tram_out.tsv", )
#
# data <- lst |> purrr::map_df(~ dplyr::bind_rows(.x))
#
# library(ggplot2)
# library(dplyr)
# data %>% as.data.frame() |>
#   #dplyr::mutate(Lines = as.integer(Lines)) |>
#   #dplyr::filter(VehicleNumber == 3016) |>
#   ggplot(aes(x = Lon, y=Lat)) +
#   geom_point(aes(color = Lines), alpha=.3, show.legend = FALSE)
