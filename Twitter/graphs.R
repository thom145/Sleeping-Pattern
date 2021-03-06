source('../common/common.R')
loadPackages(c('rjson', 'twitteR', 'RMySQL'))

config <- fromJSON(file = '../config.json')
settings <- fromJSON(file = '../settings.json')

conn <- dbConnect(RMySQL::MySQL(),
                  host = config$mysql$host,
                  dbname = config$mysql$database,
                  user = config$mysql$user,
                  password = config$mysql$password)
data <- dbReadTable(conn, 'tweets')
dbDisconnect(conn)

data$date <- as.POSIXct(data$date, origin = '1970-01-01')

times = as.POSIXct(format(data$date, format = '%H:%M'), format = '%H:%M')
hist(times, 'hours', format = '%H:%M', xlab = 'Hour', ylab = 'Tweet density')


timesPerDay = aggregate(as.POSIXct(format(data$date, format = '%H:%M'), format = '%H:%M'),
          list(Day = format(data$date, format = '%a')), c)
apply(timesPerDay, 1, function(row) {
  hist(row$x, 'hours', format = '%H:%M', xlab = 'Hour', ylab = 'Tweet density', main = row$Day)
})
