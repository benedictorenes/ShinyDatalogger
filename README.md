# ShinyDatalogger


## Description

This project contains 3 main files:
  1. app.R : Shiny application
  2. DHT11_sensor.ino : arduino due programming file
  3. serial_com_test.r : script for serial communication between r and arduino

It also contains a *.css* file to define the style of the app (feel free to make it look nicer!)

## How to use

It requires that you connect the arduino Due through the programming port and upload the DHT11_sensor.ino file. This file was originally found at:.... and it has been modified to print out to the serial port the data in appropriate format. 

Open a session in R. 
Within serial_com_test.r, you need to specify the port over which communication is happening. This can be checked using the r function **listPorts()** to identify the name of the port which is used by arduino. Also in this file, you need to set up the desired time over which you want to read data from Arduino. Once you run it, it will create/modify the **serial_data2.txt** file used for communication with the app. 

Within a different R session, launch the **app.R**. This will automatically look for modifications  in the **serial_data2.txt** file and append this data to a data frame. To log this data frame.... (in progress)

## Other notes

  