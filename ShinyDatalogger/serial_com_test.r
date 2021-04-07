library(serial)


con_name = "cu.usbmodem1421"
mainDir = "/Users/daniel/Documents/Barcelona/ShinyDatalogger/ShinyDatalogger"
setwd(mainDir)

con <- serialConnection(name = "prueba",
                        port = con_name,
                        mode = "9600,n,8,1",
                        buffering = "none",
                        newline = TRUE,
                        translation = "cr")
isOpen(con)
open(con)
myline = read.serialConnection(con)
print(myline)


stopTime <- Sys.time() + 300
foo <- ""
textSize <- 0
while(Sys.time() < stopTime)
{
  newText <- read.serialConnection(con)
  if(0 < nchar(newText))
  {
    mytext = newText
    tm = as.character(Sys.time())
    temp = strsplit(mytext,",")[[1]][3]
    hum = strsplit(mytext,",")[[1]][4]
    temp_data = data.frame(tm,temp,hum)
    print(temp_data)
    cat(c(tm,temp,hum),file="test/serial_data2.txt", sep = "\t", append=F)
    cat("",file="test/serial_data2.txt",sep = "\n",append = T)
  }
}


close(con)


