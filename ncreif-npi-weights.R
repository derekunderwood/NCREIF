# Derek Underwood
# script to pull NCREIF npi data from: https://user.ncreif.org/data-products/property/

# Install libraries if not installed
{
  list.of.packages <- c("jsonlite",
                        "data.table")
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
}

library(jsonlite)
library(data.table)

url <- "https://user.ncreif.org/api/v1/products/data-map/NPI"
data <- fromJSON(url, simplifyDataFrame = T)

data_clean <- data.frame(
  property_type = data$propertyType,
  total = data$regionData$noRegion$tmv,
  west = data$regionData$west$tmv,
  east = data$regionData$east$tmv,
  midwest = data$regionData$midwest$tmv,
  south = data$regionData$south$tmv
)

# remove $ and , from character
rmCurr <- function(x) {
  
  xx = gsub("[$,]", "", x)
  as.numeric(xx)
  
}

data_clean[,2:6] <- sapply(data_clean[,2:6], rmCurr)

total <- data_clean[1,2]

weights <- data.frame(
  property_type = data_clean$property_type[2:6],
  data_clean[-1,3:6]/total
)

weights

long <- melt(setDT(weights), id.vars = c("property_type"), variable.name = "region")
long$property_type <- as.character(long$property_type)
long$region <- as.character(long$region)
long <- long[order(long$property_type, long$region), ]

long