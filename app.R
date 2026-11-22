library(shiny)
library(dplyr)
library(ggplot2)
library(DT)
library(scales)

source("R/data.R")

ui <- fluidPage(
  titlePanel("Statistical Analysis of Pakistan Economic Indicators"),
  sidebarLayout(
    sidebarPanel(
      h4("Dashboard filters"),
      sliderInput(
        "years",
        "Select year range",
        min = 2000,
        max = 2024,
        value = c(2000, 2024),
        sep = ""
      ),
      selectInput(
        "indicator",
        "Economic indicator",
        choices = names(indicator_codes),
        selected = names(indicator_codes)[1]
      ),
      helpText("Data source: World Bank World Development Indicators.")
    ),
    mainPanel(
      h3(textOutput("selected_title")),
      fluidRow(
        column(4, wellPanel(h5("Latest available value"), h3(textOutput("latest_value")))),
        column(4, wellPanel(h5("Average in selected period"), h3(textOutput("average_value")))),
        column(4, wellPanel(h5("Observations"), h3(textOutput("observation_count"))))
      ),
      tabsetPanel(
        tabPanel("Trend", br(), plotOutput("trend_plot", height = "420px")),
        tabPanel("Descriptive statistics", br(), tableOutput("summary_table")),
        tabPanel("Data", br(), DTOutput("data_table"))
      )
    )
  )
)

server <- function(input, output, session) {
  economic_data <- reactive({
    tryCatch(
      fetch_pakistan_indicators(2000, 2024),
      error = function(e) {
        showNotification(
          paste("Could not load World Bank data:", conditionMessage(e)),
          type = "error",
          duration = NULL
        )
        NULL
      }
    )
  })

  filtered_data <- reactive({
    req(economic_data())
    economic_data() |>
      filter(year >= input$years[1], year <= input$years[2])
  })

  selected_values <- reactive({
    req(filtered_data())
    filtered_data() |>
      transmute(year, value = .data[[input$indicator]]) |>
      filter(!is.na(value))
  })

  output$selected_title <- renderText(input$indicator)

  output$latest_value <- renderText({
    values <- selected_values()
    validate(need(nrow(values) > 0, "No data"))
    latest <- values |> arrange(desc(year)) |> slice(1)
    if (input$indicator == "Population, total") {
      comma(round(latest$value))
    } else {
      paste0(round(latest$value, 2), "%")
    }
  })

  output$average_value <- renderText({
    values <- selected_values()
    validate(need(nrow(values) > 0, "No data"))
    avg <- mean(values$value)
    if (input$indicator == "Population, total") {
      comma(round(avg))
    } else {
      paste0(round(avg, 2), "%")
    }
  })

  output$observation_count <- renderText(nrow(selected_values()))

  output$trend_plot <- renderPlot({
    values <- selected_values()
    validate(need(nrow(values) > 0, "No observations for this selection."))

    ggplot(values, aes(x = year, y = value)) +
      geom_line(linewidth = 1, colour = "#176B87") +
      geom_point(size = 2, colour = "#64CCC5") +
      scale_x_continuous(breaks = pretty_breaks()) +
      scale_y_continuous(labels = label_number(big.mark = ",")) +
      labs(
        title = input$indicator,
        x = "Year",
        y = if (input$indicator == "Population, total") "People" else "Percent"
      ) +
      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold"))
  })

  output$summary_table <- renderTable({
    values <- selected_values()
    validate(need(nrow(values) > 0, "No observations for this selection."))
    stats <- summarise_indicator(
      filtered_data(),
      input$indicator
    )
    stats |>
      mutate(
        mean = round(mean, 3),
        median = round(median, 3),
        minimum = round(minimum, 3),
        maximum = round(maximum, 3)
      )
  }, striped = TRUE, bordered = TRUE, spacing = "s")

  output$data_table <- renderDT({
    datatable(
      filtered_data(),
      rownames = FALSE,
      options = list(pageLength = 10, scrollX = TRUE)
    )
  })
}

shinyApp(ui = ui, server = server)
