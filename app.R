#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(mongolite)

mdbname <- "cdh"
colname <- "record_history"
mdb <- mongo(collection = colname, db = mdbname)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Dashboard"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        checkboxGroupInput("recordType",
                           "Record type",
                           list("Golden records" = "goldens",
                                "Valid records" = "valids",
                                "Invalid records" = "invalids")
                           ),
        dateRangeInput("dateRange", 
                       "Date range",
                       start = "2017-01-01",
                       end = "2017-12-31",
                       min = "2017-01-01",
                       max = "2017-12-31"
                       ),
        actionButton("updateAction",
                     "Update"
                     )
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
        textOutput("fromDate"),
        textOutput("toDate"),
        textOutput("recordType"),
        textOutput("buttonPushed"),
        textOutput("recordCount")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  output$fromDate <- renderText({
    paste0("From: ", unlist(strsplit(as.character(input$dateRange), " to "))[1])
  })
  
  output$toDate <- renderText({
    paste0("To: ", unlist(strsplit(as.character(input$dateRange), " to "))[2])
  })
  
  output$recordType <- renderText({
    paste("Selected record types: ", paste0(input$recordType, collapse = ", "))
  })
  
  output$buttonPushed <- renderText({
    # input$updateAction
    # paste(input$updateAction)
    
    # querystring <- '{ "merged.type": "person" }'
    
    # build query string for record types
    
    
    # build query string for date
    if ()
    querystring <- '{}'
    recordCount <- mdb$count(query = querystring)
    as.character(recordCount)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

