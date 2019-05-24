args <- commandArgs(TRUE)

file <- args[1]

series.info <- read.csv(file, stringsAsFactors = F)

t2.description <- 'FSE T2_GOOD'

cat(series.info$SeriesDirName[series.info$SeriesDescription == t2.description])
