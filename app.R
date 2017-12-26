#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Dashboard"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        checkboxGroupInput("recordType",
                           "Record type",
                           list("Golden records",
                                "Valids",
                                "Invalids")),
        dateRangeInput("dateRange", 
                       "Date range",
                       start = "2017-01-01",
                       end = "2017-12-31",
                       min = "2017-01-01",
                       max = "2017-12-31"),
        actionButton("updateAction",
                     "Update")
      ),
      
      # Show a plot of the generated distribution
      mainPanel(

      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
}

# Run the application 
shinyApp(ui = ui, server = server)

