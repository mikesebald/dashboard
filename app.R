library(shinydashboard)
library(mongolite)

# db.record_history.createIndex({"_id.s": 1})
# db.record_history.createIndex({"api": 1})

mdbname <- "bi"
colname <- "record_history"
mdb <- mongo(collection = colname, db = mdbname)
mongo_revision <- mongo("revision", "cdh")

ui <- dashboardPage(
  skin = "red",
  dashboardHeader(title = "Dashboard"),
  dashboardSidebar(sidebarMenu(
    menuItem("Dashboard", tabName = "dashboard"),
    menuItem("Validation errors", tabName = "validationErrors")
  )),
  
  dashboardBody(tabItems(
    tabItem(
      "dashboard",
      fluidRow(
        box(
          "Record selection",
          background = "maroon",
          checkboxGroupInput(
            "recordType",
            "Record type",
            list(
              "Golden records" = "goldens",
              "Valid source records" = "valids",
              "Invalid source records" = "invalids"
            )
          )
        ),
        box(
          "Date range selection",
          background = "teal",
          dateInput(
            "fromDate",
            "From",
            value = "2017-01-01",
            min = "2017-01-01",
            max = "2017-12-31"
          ),
          dateInput(
            "toDate",
            "To",
            value = "2017-12-31",
            min = "2017-01-01",
            max = "2017-12-31"
          )
        )
      ),
      fluidRow(
        valueBoxOutput("goldens"),
        valueBoxOutput("valids"),
        valueBoxOutput("invalids")
      )
    ),
    tabItem("validationErrors",
            fluidRow())
  ))
)

server <- function(input, output) {
  output$goldens <- renderValueBox({
    fromDate <- as.character(input$fromDate)
    toDate <- as.character(input$toDate)
    cat("from: ", fromDate, "\n")
    cat("to: ", toDate, "\n")
    
    mongo_revision$find(query = '{"date": {"$gte": {"$date": "2017-01-04T00:00:00Z"}}}', 
                        fields = '{"_id": 1}', 
                        sort = '{"date": 1}', 
                        limit = 1)


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
      recordCount <-
        mdb$count(query = '{"_id.s": {"$ne": "system"}, "api": "merged"}')
    else
      recordCount <- 0
    
    valueBox(
      value = as.character(recordCount),
      subtitle = "Valid source records",
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
      subtitle = "Invalid source records",
      icon = icon("thumbs-down")
    )
  })
}

# Run the application
shinyApp(ui = ui, server = server)
