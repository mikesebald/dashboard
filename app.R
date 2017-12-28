library(shinydashboard)
library(mongolite)

mdbname <- "cdh"
colname <- "record_history"
mdb <- mongo(collection = colname, db = mdbname)

ui <- dashboardPage(
  skin = "red",
  dashboardHeader(title = "Dashboard"),
  dashboardSidebar(
    fluidPage(
      checkboxGroupInput("recordType",
                         "Record type",
                         list("Golden records" = "goldens",
                              "Valid records" = "valids",
                              "Invalid records" = "invalids")),
      dateRangeInput("dateRange", 
                       "Date range",
                       start = "2017-01-01",
                       end = "2017-12-31",
                       min = "2017-01-01",
                       max = "2017-12-31")
    )
  ),

  dashboardBody(
    fluidRow(
      valueBoxOutput("goldens"),
      valueBoxOutput("valids"),
      valueBoxOutput("invalids")
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
  
  output$goldens <- renderValueBox({
    if (!is.na(match("goldens", input$recordType)))
      recordCount <- mdb$count(query = '{"_id.s": "system"}')
    else
      recordCount <- 0

    valueBox(
      value = as.character(recordCount),
      subtitle = "Golden records",
      icon = icon("diamond")
    )
  })
  
  output$valids <- renderValueBox({
    if (!is.na(match("valids", input$recordType)))
      recordCount <- mdb$count(query = '{"api": "merged", "_id.s": {"$ne": "system"}}')
    else
      recordCount <- 0

    valueBox(
      value = as.character(recordCount),
      subtitle = "Valid records",
      icon = icon("thumbs-up")
    )
  })
  
  output$invalids <- renderValueBox({
    if (!is.na(match("invalids", input$recordType)))
      recordCount <- mdb$count(query = '{"api": "validated"}')
    else
      recordCount <- 0

    valueBox(
      value = as.character(recordCount),
      subtitle = "Invalid records",
      icon = icon("thumbs-down")
    )
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

