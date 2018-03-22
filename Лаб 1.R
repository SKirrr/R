library('XML')            
library('RCurl')  
library('jsonlite')   


s1 <- "https://www.google.ru/search?newwindow=1&dcr=0&ei=e-2nWtidMcePsAGTk6nYBg&q="
s2 <- "&oq="
s3 <- "&gs_l=psy-ab.3..0j0i22i30k1l9.72726.75440.0.75714.5.5.0.0.0.0.104.364.4j1.5.0....0...1c.1.64.psy-ab..0.5.360...0i67k1.0.RAc7C0c9Mfk"
#вектор поиска по данным
searchtext <- c('IBM',
                'Apple',
                'Samsung')
#задаём нижнюю и верхнюю границы поиска
lowerbound <- 2007
highbound <- 2017
#фрейм данных для результатов поиска
data <- data.frame()

for (searching in searchtext) {
  for (year in lowerbound:highbound){
    fileURL <- paste0(s1, paste(searchtext, year), s2, paste(searchtext, year), s3)
    #fileURL <- URLencode(fileURL)
    
    html <- getURL(fileURL)
    doc <- htmlTreeParse(html, useInternalNodes = T)
    rootNode <- xmlRoot(doc)
    
    headers <- xpathSApply(rootNode, '//h3[contains(@class, "r")]',
                           xmlValue)
    sources <- xpathSApply(rootNode, '//cite[@class="_Rm"]',
                           xmlValue)
    links <- xpathSApply(rootNode, '//h3[contains(@class, "r")]',
                         xmlGetAttr, 'href')
    data <- data.frame(Header = headers, Source = sources, URL = links)
    
    Sys.sleep(0.1)
  }
  data <- data.frame(Year = year)
}
file.output <- './Timeline.csv'
write.csv(data, file = file.output, row.names = F)


