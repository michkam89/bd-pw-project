collect_trams_from_api(
  line_number = 7,
  time_interval = 15,
  max_calls = 3600,
  output = "data-raw/tram-7-xxx-int15s.tsv"
)

library(readr)
trams <- read_delim(
  file = "data-raw/tram-7-xxx-int15s.tsv",
  skip = 1,
  col_names = FALSE,
  show_col_types = FALSE)

# remove row indexes
trams <- trams[2:ncol(trams)]

colnames(trams) <- c("line", "lon", "vehicle_number", "time", "lat", "brigade", "get_timestamp")

head(trams)

library(dplyr)
sorted <- trams |>
  arrange(vehicle_number, get_timestamp,  time)
library(ggplot2)

sorted |>
  filter(vehicle_number == "1293+1294") |>
  ggplot(aes(x = lon, y = lat)) +
  geom_text(aes(label = get_timestamp), size = 2)+
  geom_point(alpha = .9, show.legend = FALSE)


library(geosphere)
sorted |>
  filter(vehicle_number == "1293+1294",
         as.character(get_timestamp) %in% c("2022-03-23 20:18:23",
                                            "2022-03-23 20:18:38"))

geosphere::distHaversine(c(21.04766, 52.25201), c(21.04949, 52.25262))


collect_trams_from_api(
  line_number = 7,
  time_interval = 15,
  max_calls = 2,
  output = "data-raw/test1.tsv"
)
