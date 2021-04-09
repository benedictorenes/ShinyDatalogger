# ShinyDatalogger


## Description

This project contains 3 main files:
  2. DHT11_sensor.ino : arduino due programming file
  3. serial_com_test.r : script for serial communication between r and arduino
  1. app.R : Shiny application

Whithin the *www* directory, it also contains a *.css* file to define the style of the app (feel free to make it look nicer!)

## How to use

It requires that you connect your arduino Due board through the programming port and upload the **DHT11_sensor.ino** file. This file was originally found at:.... and it has been modified to print out to the serial port the data in appropriate format. 

Open the R project. Open the file **serial_com_test.r**. You need to specify the port over which communication is happening. This can be checked from the R console using the function **listPorts()** to identify the name of the port which is used by your board. If you use the *Arduino Create Web Editor*, and Windows OS, this will be displayed in the web editor. 
The default logging time is set to 1 day of measurements every 5 secons. Once you run it, it will create/modify the **serial_data2.txt** file used for communication with the app. Run this file. It will start to print out the datetime, temperature, and humidity in the console. 

Within a different R session, launch the **app.R**. This will automatically look for modifications in **serial_data2.txt** file and append this data to an internally stored data frame. Also, the plot will update automatically, displaying the last 10 values of the log. The "Save Log" button automatically writes a csv file with the logged data to the **log** directory. 


  