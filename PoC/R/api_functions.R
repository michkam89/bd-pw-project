#' Get GPS coordinates of all trams in WWA
#'
#' @param line_number tram line number to call, default NULL will call all trams
#' @param time_interval time between API calls in seconds
#' @param max_calls maximum number of calls to make
#' @param output output file path and name
#' @param api_key personal key to API
#'
#' @return single call transforms JSON to tibble and saves to .tsv file
#'
#' @importFrom purrr map_df
#' @importFrom dplyr mutate
#' @importFrom httr GET content
#' @importFrom usethis ui_info ui_value ui_done
#' @export

get_trams_gps <- function(line_number = NULL,
                                   time_interval = 60L,
                                   max_calls = NULL,
                                   output = "./data-raw/api_tram_out.tsv",
                                   api_key = Sys.getenv("UM_WAW_PERSONAL_API_KEY")) {
  proj <- usethis::proj_get()
  save_path <- fs::path(proj, output)

  N <- 0
  if (is.null(max_calls)) {
    ui_info("max_calls not provided, API will make calls until interuption")
    condition <- TRUE
  } else {
    ui_info(paste("API will make", max_calls, "calls"))
    condition <- N < max_calls
  }

  url_base <- paste0(
    "https://api.um.warszawa.pl/api/action/busestrams_get/?resource_id=%20f2e5503e-927d-4ad3-9500-4ab9e55deb59",
    "&apikey=", api_key,
    "&type=2" # 2 for trams, 1 for buses
  )

  if (!is.null(line_number)) {
    url <- paste0(url_base, "&line=", line_number)
  } else {
    url <- base_url
  }

  while(condition) {
    # update counter and condition
    N <- N + 1
    prc <- N / max_calls * 100
    usethis::ui_info("Making {ui_value(N)} API call. {ui_value(prc)} done.")
    condition <- N < max_calls

    df <- tryCatch(
      {
        get_out <- GET(url)
        df <- content(get_out)$result |>
          map_df(~ .x)

        # stop("Fake error")

      }, error = function(e) {

        usethis::ui_oops("Failed to retreive data for {ui_value(N)} API call. Error {e}")

        df_with_NAs <- tibble(
          Lines = NA_character_,
          Lon = NA_real_,
          VehicleNumber = NA_character_,
          Time = NA_character_,
          Lat = NA_real_,
          Brigade = NA_character_
        )

      }, finally = function(f) {print("Hello")}
    )

    print(df)
    x <- df |> mutate(get_timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"))

    print(x)

    if (N == 1){
      write.table(x, file = save_path, row.names = FALSE)
    } else {
      write.table(x, file = save_path, append = TRUE, col.names = FALSE, row.names = FALSE)
    }

    Sys.sleep(time_interval)
  }
  usethis::ui_done("All done!")
}

#' Get GPS coordinates for all stops in WWA
#'
#' @param api_key personal api key
#' @export
#'
get_all_stops_gps <- function(api_key = Sys.getenv("UM_WAW_PERSONAL_API_KEY")){
  url <- paste0(
    "https://api.um.warszawa.pl/api/action/dbstore_get?id=1c08a38c-ae09-46d2-8926-4f9d25cb0630",
    "&apikey=", api_key)

  przystanki <- GET(url)

  przystanki <- content(przystanki)

  key_names <- c("zespol", "slupek", "nazwa_zespolu", "id_ulicy", "szer_geo", "dlug_geo", "kierunek", "obowiazuje_od")
  # get values for keys
  przystanki_flat <- przystanki |> purrr::flatten() |> purrr::flatten()

  przystanki_clean_list <- przystanki_flat |>
    map(~map(.x, ~pluck(.x$value))) |>
    modify_depth(.depth = 1, ~ set_names(.x,nm = key_names))

  # convert list to data.frame
  przystanki_df <- przystanki_clean_list |> map_df(~unlist(.x))

  english_keys <- c("team", "pole", "team_name", "street_id", "lat", "lon", "direction", "valid_from")
  names(przystanki_df) <- english_keys

  przystanki_df <- przystanki_df |>
    mutate(
      lat = as.numeric(lat),
      lon = as.numeric(lon),
      valid_from = as.POSIXct(valid_from)
    )
  przystanki_df
}

#' Get all lines available for particular stop
#'
#' @param unique_stop_instances dataframe with unique set of team and pole
#'  combination
#' @param max max api calls, NULL makes as much calls as combinations in
#'  unique_stop_instances
#' @param api_key personal api key
#'
#' @return
#' @export

get_all_lines_at_stop <- function(unique_stop_instances,
                                  max = NULL,
                                  api_key = Sys.getenv("UM_WAW_PERSONAL_API_KEY")) {
  # get all lines available for a team-pole cmbination which is single busstop instance
  urls <- paste0(
    "https://api.um.warszawa.pl/api/action/dbtimetable_get/?id=88cd555f-6f31-43ca-9de4-66c479ad5942",
    "&busstopId=",
    unique_stop_instances$team,
    "&busstopNr=",
    unique_stop_instances$pole,
    "&apikey=",
    Sys.getenv("UM_WAW_PERSONAL_API_KEY")
  )

  requests <- unique_stop_instances |>
    mutate(request_url = urls)

  # check if limit number of requests
  if (is.null(max)) {
    take <- length(urls)
  } else {
    take <- max
  }
  usethis::ui_info("will try {take} requests")

  request_placeholder <- vector(mode = "list", length = take)

  for (i in seq_along(1:take)) {
    request <- requests[i, ]

    usethis::ui_info("Done {round(i / take * 100, 2)}%")

    tryCatch({
      get_out <- GET(request$request_url)
      request_result <- content(get_out)$result |>
        map( ~ .x$values) |>
        flatten() |> map_df( ~ .x)

      x <-
        full_join(
          request,
          request_result,
          by = character() # all vs all
          ) |>
        nest(data = c(value, key))

      # grow list
      request_placeholder[[i]] <- x

    }, error = function(e)
      usethis::ui_oops("nie działa {e}"))

    Sys.sleep(1)
  }

  # collapse list into single dataframe
  map_df(request_placeholder, ~ .x)

}

#' Get timetable for single stop and line
#'
#' @param url  single api request
#'
#' @return single dataframe with timetable
#' @export
get_single_timetable <- function(url) {
  tryCatch({

    timetable_GET <- GET(url)
    timetable_raw <- content(timetable_GET)$result |>
      flatten()

    timetable <-
      set_names(timetable_raw, nm = paste0("time", 1:length(timetable_raw))) |>
      map_depth(.depth = 2, ~ list(.x$value) |> set_names(.x$key)) |>
      map( ~ flatten(.x)) |>
      map_df( ~ .x)

    timetable
  }, error = function(e) {

    usethis::ui_oops("Failed to retreive data for {ui_value(url)}. Error {e}")

    empty_timetable <- tibble(
      symbol_2 = NA_character_,
      symbol_1 = NA_character_,
      brygada = NA_character_,
      kierunek = NA_character_,
      trasa = NA_character_,
      czas = NA_character_
    )

    empty_timetable

  })

}

#' Get timetables for many stops and lines
#'
#' @param unique_stop_instances unique set of team and pole
#' @param lines lines
#' @param api_key personal api key
#'
#' @return nested dataframe with timetables
#' @export
#'
get_timetables <- function(unique_stop_instances,
                           lines,
                           api_key = Sys.getenv("UM_WAW_PERSONAL_API_KEY")) {
  urls <- paste0(
    "https://api.um.warszawa.pl/api/action/dbtimetable_get?id=e923fa0e-d96c-43f9-ae6e-60518c9f3238",
    "&busstopId=",
    unique_stop_instances$team,
    "&busstopNr=",
    unique_stop_instances$pole,
    "&line=",
    lines,
    "&apikey=",
    api_key
  )

  request_table <- unique_stop_instances |>
    mutate(
      url = urls,
      line = lines
    )

  timetable <- mutate(request_table, timetable = map(url, ~ get_single_timetable(.x)))

  timetable

}
