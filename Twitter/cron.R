source('../common/common.R')
loadPackages(c('rjson'))

config <- fromJSON(file = '../config.json')
settings <- fromJSON(file = '../settings.json')

setup_twitter_oauth(
  config$twitter$api_key,
  config$twitter$api_secret,
  config$twitter$access_token,
  config$twitter$access_token_secret)

toDataFrame <- function(result, longitude, latitude) {
  do.call(rbind,
    lapply(result,
      function(x) {
        long <- x$getLongitude()
        if(is.null(long) || is.character(long) && length(long) == 0) {
          long <- longitude
        }
        lat <- x$getLatitude()
        if(is.null(lat) || is.character(lat) && length(lat) == 0) {
          lat <- latitude
        }
        c(
          id = x$getId(),
          date = x$getCreated(),
          longitude = long,
          latitude = lat,
          retweet = x$getIsRetweet(),
          name = x$getScreenName(),
          tweet = x$getText()
        )
      }
    )
  )
}

getData <- function(country, region, term) {
  result <- searchTwitter(
    term,
    lang = country$language,
    n = settings$results,
    since = Sys.Date() - 1,
    until = Sys.Date(),
    geocode = paste(region$longitude, region$latitude, paste(region$radius, 'km', sep = ''), sep = ',')
  )
  toDataFrame(result, region$longitude, region$latitude)
}

data <- NULL

for(country in settings$countries) {
  for(region in country$regions) {
    for(term in country$terms) {
      data <- rbind(data, getData(country, region, term))
    }
  }
}
#remove duplicates
data <- as.data.frame(data)
data <- data[duplicated(data$id),]
#TODO: insert into db