library(shiny)
library(tidyverse)
library(ggplot2)
library(serial)
library(scales)

##########################################################################
##########################################################################


# Application

# file name to store serial print data
fname = "test/serial_data2.txt"
N = 20 # number of data points to show in the plot

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

        # Output plot
        mainPanel(
           plotOutput(outputId = "LogPlot"),
           plotOutput(outputId = "LogPlot2"),
           width = 7
        )
    )
)

# Define server logic
server <- function(input, output) {
    
    ########### Create and manipulate input data
    
    # create a log data frame inside a reactive wrapper
    myvals = reactiveValues(log22 = data.frame(Time = NULL,Temperature = NULL,Humidity = NULL))
    
    #handy: reactive values ymin and ymax for updating plot limits. They will be wrapped
    #   around reactives() lower_ylim, higher_ylim
    handy = reactiveValues(ymin = 10, ymax = 30)
    lower_ylim = reactive({handy$ymin = min(tail(myvals$log22$Temperature,N),na.rm = T)-5})
    higher_ylim = reactive({handy$ymax = max(tail(myvals$log22$Temperature,N),na.rm = T)+5})
    
    
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
    
    
    ########## Output reactions that call inpput data
    
    # Table output with the last 6 values in the data frame
    output$dataTable <- renderTable({
        tail(myvals$log22,6)
    })
    
    
    # Plot showing the last 10 values of the temperature in the log22 data frame
    output$LogPlot <- renderPlot({
        # draw the plot
        ggplot(data = tail(myvals$log22,N), aes(x=as.POSIXct(strptime(Time,format = "%Y-%m-%d %H:%M:%S")), y=Temperature)) +
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
    
    ## second plot for the Humidity
    output$LogPlot2 <- renderPlot({
        # draw the plot
        ggplot(data = tail(myvals$log22,N), aes(x=as.POSIXct(strptime(Time,format = "%Y-%m-%d %H:%M:%S")), y=Humidity)) +
            geom_point(col = 2, pch = 18, size = 3) + 
            geom_path()+
            theme_minimal() + 
            theme(plot.title = element_text(size=10)) + 
            ggtitle("Lab Humidity") +
            ylab("Rel. Humidity (%)") +
            xlab("Time stamp") +
            scale_x_datetime(labels = date_format("%Y-%m-%d %H:%M:%S")) +
            ylim(15,80)
    })
    
    
    # when clicking on the save Log button, write a file with the logged data
    observeEvent(input$saveButton,{
        write.csv(myvals$log22,file = paste0("log/sensor_log_",as.character(Sys.Date()),".csv"))
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
