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
      textOutput("fromDate"),
      textOutput("toDate"),
      textOutput("recordType"),
      textOutput("buttonPushed"),
      textOutput("recordCount")
    ),
    fluidRow(
      valueBoxOutput("count")
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
  
  output$count <- renderValueBox({
    recordTypes <- paste0(input$recordType)
    queryString <- c()
    # build query string for record types
    if (!is.na(match("goldens", recordTypes)))
      queryString <- c(queryString, '"_id.s": "system"')
    if (!is.na(match("valids", recordTypes)))
      queryString <- c(queryString, '"api": "merged", "_id.s": {"$ne": "system"}')
    if (!is.na(match("invalids", recordTypes)))
      queryString <- c(queryString, '"api": "validated"')

    # build query string for date
    
    # execute query
    if (is.null(queryString)) {
      recordCount <- 0
      cat("Record Count:", recordCount)
    }
    else {
      queryString <- paste0('{"$or": [{', paste0(queryString, collapse = '}, {'), '}]}')
      cat("\nQuery String:", queryString, "\n")
      recordCount <- mdb$count(query = queryString)
    }
    
    valueBox(
      value = as.character(recordCount),
      subtitle = "Total records",
      icon = icon("address-card")
    )
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

