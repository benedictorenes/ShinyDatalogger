#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(shiny)
library(tidyverse)
library(dplyr)
library(data.table)
library(ggplot2)
library(serial)
library(scales)

##########################################################################
##########################################################################

# The application will read a txt file and display a plot of the variables
# The code will consist on two sections:
#   - Serial communication for read and save the incoming data to a txt
#   - Application: --> read txt --> plot output

##########################################################################
##########################################################################

# Serial communication and writing log file



##########################################################################
##########################################################################

# Application
fname = "test/serial_data2.txt"

datiles = read.table(fname,header = F,sep = "\t",col.names = c("Time","Temperature","Humidity"),as.is = T)
# ui: 
#   - Output plot 
#   - Output table with the last values updating
#   - Input browse panel to choose the file to look at
#   - Input Save button to save the data frame to a file
#   - Maybe some interacting functionality for the plot such as zoom in or so


ui <- fluidPage(
    tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "mystyle.css")
    ),
    tags$h1("Data Logger for Arduino"),
    tags$hr(),

    # Sidebar: contains output table for the last incoming data and the save button
    sidebarLayout(
        sidebarPanel(
            actionButton(inputId = "saveButton", label = "Save Log to file"),
            tags$hr(),
            tableOutput(outputId = "dataTable"),
            width = 5
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput(outputId = "LogPlot"),
           width = 7
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    # create a log data frame inside a reactive wrapper
    myvals = reactiveValues(log22 = data.frame(Time = NULL,Temperature = NULL,Humidity = NULL))
    
    #handy: reactive values for updating plot limits: lower_ylim, higher_ylim
    handy = reactiveValues(ymin = 10, ymax = 30)
    lower_ylim = reactive({handy$ymin = min(tail(myvals$log22$Temperature,10),na.rm = T)-5})
    higher_ylim = reactive({handy$ymax = max(tail(myvals$log22$Temperature,10),na.rm = T)+5})
    
    # fileData() will update every time the log file has been modified
    fileData <- reactiveFileReader(1000,  session = NULL,
                                   filePath =  fname, 
                                   readFunc = read.table,
                                   header = F,sep = "\t",col.names = c("Time","Temperature","Humidity"),as.is = T)
    
    # in order to store the data into the log22 dataframe, we need to isolate its call
    # newData gets the data from fileData()
    # a recursive call (inside the isolate) to log22 (insige the reactive myvals) appends the new data to the existing data frame
    # without triggering a new call to myvals, which would "refresh" the data set.
    observe({
        newData = fileData()
        # Check that the file has bee modified recently, then read it. Otherwise, ignore it
        # This is to avoid "first old element"
        if(Sys.time() - 4 < newData$Time){
            #newData$Time = strptime(newData$Time,format = "%Y-%m-%d %H:%M:%S")
            isolate( myvals$log22 <- bind_rows(myvals$log22, newData) )
        }
        else{}
    })
    
    # Table output with the last 6 values in the data frame
    output$dataTable <- renderTable({
        tail(myvals$log22,6)
    })
    
    
    # Plot showing the last 10 values of the temperature in the log22 data frame
    output$LogPlot <- renderPlot({
        # draw the plot
        ggplot(data = tail(myvals$log22,10), aes(x=as.POSIXct(strptime(Time,format = "%Y-%m-%d %H:%M:%S")), y=Temperature)) +
            geom_point(col = 2, pch = 18, size = 3) + 
            geom_path()+
            theme_minimal() + 
            theme(plot.title = element_text(size=10)) + 
            ggtitle("Lab temperature") +
            ylab("Temperature (celsius)") +
            xlab("Time stamp") +
            scale_x_datetime(labels = date_format("%Y-%m-%d %H:%M:%S")) +
            ylim(lower_ylim(),higher_ylim())
    })
    
    # when clicking on the save Log button, write a file with the logged data
    observeEvent(input$saveButton,{
        write.csv(myvals$log22,file = "log/sensor_log.csv")
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
