#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(shiny)
library(dplyr)
library(data.table)
library(ggplot2)
library(serial)

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
fname = "test/test_data.txt"


# ui: 
#   - Output plot 
#   - Input browse panel to choose the file to look at
#   - Input update button
#   - Maybe some interacting functionality for the plot such as zoom in or so


ui <- fluidPage(
    tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "mystyle.css")
    ),
    tags$h1("Data Logger for Arduino"),
    tags$hr(),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            # actionButton(inputId = "updateButton", label = "Update plot"),
            tableOutput(outputId = "dataTable")
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput(outputId = "LogPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    fileData <- reactiveFileReader(1000,  session = NULL,
                                   filePath =  fname, 
                                   readFunc = read.table,header = TRUE,sep = "")
    
    output$dataTable <- renderTable({
        tail(fileData(),10)
    })
    
    output$LogPlot <- renderPlot({
        # draw the plot
        ggplot(data = fileData(), aes(x=Time, y=Temperature)) +
            geom_point(col = 2, pch = 18, size = 3) + 
            geom_smooth(col = 3) + 
            theme_minimal() + 
            theme(plot.title = element_text(size=10)) + 
            ggtitle("Lab temperature") +
            ylab("Temperature (celsius)") +
            ylim(0,30)
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
