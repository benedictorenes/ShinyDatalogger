library(tidyverse)
library(ggplot2)
library(scales)
library(gridExtra)
library(svglite)
library(gridSVG)
library(svgPanZoom)


fname = "log/sensor_log.csv"
datiles = read.table(fname,header = T,sep = ",")



p1 = ggplot(data = tail(datiles,10), aes(x=as.POSIXct(strptime(Time,format = "%Y-%m-%d %H:%M:%S")))) +
  geom_point(aes(y=Temperature),col = 2, pch = 18, size = 3) + 
  geom_path(aes(y=Temperature))+
  geom_point(aes(y=Humidity/4),col = 3, pch = 16, size = 2) + 
  geom_path(aes(y=Humidity/4),col = 3)+
  scale_x_datetime(labels = date_format("%Y-%m-%d %H:%M:%S")) +
  theme_minimal()  + 
  theme(plot.title = element_text(size=10)) +
  ggtitle("Lab temperature") +
  ylab("Temperature (celsius)") +
  xlab("Time stamp") +
  scale_y_continuous(sec.axis = sec_axis(trans=~.*2., name="Rel. Humidity (5)")) +
  theme(axis.title.y = element_text(color = 2, size=10),
        axis.title.y.right = element_text(color = 3, size=10)) 


p2 = ggplot(data = tail(datiles,10), aes(x=as.POSIXct(strptime(Time,format = "%Y-%m-%d %H:%M:%S")))) +
  geom_point(aes(y=Temperature),col = 2, pch = 18, size = 3) + 
  geom_path(aes(y=Temperature))+
  scale_x_datetime(labels = date_format("%Y-%m-%d %H:%M:%S")) +
  theme_minimal()  + 
  theme(plot.title = element_text(size=10)) +
  ggtitle("Lab temperature") +
  ylab("Temperature (celsius)") +
  xlab("Time stamp") 


svgPanZoom(p1)
#grid.arrange(p1,p2,ncol = 2)

