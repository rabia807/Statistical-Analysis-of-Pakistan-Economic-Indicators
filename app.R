library(shiny)
library(dplyr)
library(ggplot2)
library(DT)
library(scales)

source("R/data.R")

current_year <- as.integer(format(Sys.Date(), "%Y"))

ui <- fluidPage(
  titlePanel("Statistical Analysis of Pakistan Economic Indicators"),
  p("Explore long-run trends, relationships and simple statistical models using World Bank data."),
  sidebarLayout(
    sidebarPanel(
      h4("Dashboard filters"),
      sliderInput(
        "years", "Select year range",
        min = 2000, max = current_year,
        value = c(2000, current_year), sep = ""
      ),
      selectInput(
        "indicator", "Main indicator",
        choices = names(indicator_codes),
        selected = names(indicator_codes)[1]
      ),
      tags$hr(),
      helpText("Country: Pakistan | Source: World Bank World Development Indicators"),
      helpText("The latest year available can differ by indicator.")
    ),
    mainPanel(
      h3(textOutput("selected_title")),
      fluidRow(
        column(4, wellPanel(h5("Latest available value"), h3(textOutput("latest_value")))),
        column(4, wellPanel(h5("Selected-period average"), h3(textOutput("average_value")))),
        column(4, wellPanel(h5("Observations"), h3(textOutput("observation_count"))))
      ),
      tabsetPanel(
        tabPanel("Trend", br(), plotOutput("trend_plot", height = "400px"),
                 br(), tableOutput("summary_table")),
        tabPanel("Correlation", br(),
                 selectInput("cor_x", "First indicator", choices = names(indicator_codes),
                             selected = names(indicator_codes)[1]),
                 selectInput("cor_y", "Second indicator", choices = names(indicator_codes),
                             selected = names(indicator_codes)[2]),
                 plotOutput("cor_plot", height = "380px"),
                 verbatimTextOutput("cor_result")),
        tabPanel("Regression", br(),
                 selectInput("reg_y", "Outcome (dependent variable)",
                             choices = names(indicator_codes),
                             selected = names(indicator_codes)[1]),
                 selectInput("reg_x", "Predictor (independent variable)",
                             choices = names(indicator_codes),
                             selected = names(indicator_codes)[2]),
                 plotOutput("reg_plot", height = "380px"),
                 verbatimTextOutput("reg_result")),
        tabPanel("Trend test", br(),
                 p("Tests whether the selected indicator has a statistically significant linear trend over the selected years."),
                 verbatimTextOutput("trend_test")),
        tabPanel("Data", br(), downloadButton("download_csv", "Download filtered data"),
                 br(), br(), DTOutput("data_table")),
        tabPanel("Project notes", br(),
                 h4("Interpretation guidance"),
                 p("Correlation measures association, not causation. Regression is a simple exploratory linear model and does not control for all economic factors."),
                 p("The trend test evaluates a linear time trend. A small p-value is evidence of a non-zero linear trend under the model assumptions; it does not establish a cause."),
                 p("World Bank observations may be revised. Missing observations are not imputed."),
                 h4("Data source"),
                 p("World Bank World Development Indicators (WDI), accessed through the R package WDI."))
      )
    )
  )
)

server <- function(input, output, session) {
  economic_data <- reactive({
    tryCatch(
      fetch_pakistan_indicators(2000, current_year),
      error = function(e) {
        showNotification(
          paste("Could not load World Bank data:", conditionMessage(e)),
          type = "error", duration = NULL
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
      filter(is.finite(value))
  })

  output$selected_title <- renderText(input$indicator)

  format_indicator_value <- function(value, indicator) {
    if (indicator == "Population, total") comma(round(value)) else paste0(round(value, 2), "%")
  }

  output$latest_value <- renderText({
    values <- selected_values()
    validate(need(nrow(values) > 0, "No data"))
    latest <- values |> arrange(desc(year)) |> slice(1)
    format_indicator_value(latest$value, input$indicator)
  })

  output$average_value <- renderText({
    values <- selected_values()
    validate(need(nrow(values) > 0, "No data"))
    format_indicator_value(mean(values$value), input$indicator)
  })

  output$observation_count <- renderText(nrow(selected_values()))

  output$trend_plot <- renderPlot({
    values <- selected_values()
    validate(need(nrow(values) > 1, "At least two observations are needed to draw a trend."))
    ggplot(values, aes(x = year, y = value)) +
      geom_line(linewidth = 1, colour = "#176B87") +
      geom_point(size = 2, colour = "#64CCC5") +
      scale_x_continuous(breaks = pretty_breaks()) +
      scale_y_continuous(labels = label_number(big.mark = ",")) +
      labs(title = input$indicator, x = "Year",
           y = if (input$indicator == "Population, total") "People" else "Percent") +
      theme_minimal(base_size = 13)
  })

  output$summary_table <- renderTable({
    values <- selected_values()
    validate(need(nrow(values) > 0, "No observations for this selection."))
    summarise_indicator(filtered_data(), input$indicator) |>
      mutate(across(where(is.numeric), ~ round(.x, 3)))
  }, striped = TRUE, bordered = TRUE, spacing = "s")

  correlation_data <- reactive({
    req(filtered_data())
    filtered_data() |>
      transmute(x = .data[[input$cor_x]], y = .data[[input$cor_y]], year) |>
      filter(is.finite(x), is.finite(y))
  })

  output$cor_plot <- renderPlot({
    dat <- correlation_data()
    validate(need(nrow(dat) >= 3, "At least three paired observations are required."))
    ggplot(dat, aes(x = x, y = y)) +
      geom_point(colour = "#176B87", size = 2.5) +
      geom_smooth(method = "lm", se = TRUE, colour = "#D95F02") +
      labs(x = input$cor_x, y = input$cor_y) +
      theme_minimal(base_size = 12)
  })

  output$cor_result <- renderPrint({
    dat <- correlation_data()
    validate(need(nrow(dat) >= 3, "At least three paired observations are required."))
    validate(need(sd(dat$x) > 0 && sd(dat$y) > 0,
                  "Correlation cannot be calculated when an indicator has zero variance."))
    test <- cor.test(dat$x, dat$y, method = "pearson")
    cat("Paired observations:", nrow(dat), "\n")
    cat("Pearson correlation:", round(unname(test$estimate), 4), "\n")
    cat("95% confidence interval:", paste(round(test$conf.int, 4), collapse = " to "), "\n")
    cat("p-value:", format.pval(test$p.value, digits = 4), "\n")
    cat("Interpretation: association does not imply causation.")
  })

  regression_data <- reactive({
    req(filtered_data())
    filtered_data() |>
      transmute(year, outcome = .data[[input$reg_y]], predictor = .data[[input$reg_x]]) |>
      filter(is.finite(outcome), is.finite(predictor))
  })

  regression_model <- reactive({
    dat <- regression_data()
    validate(need(nrow(dat) >= 3, "At least three complete observations are required."))
    validate(need(sd(dat$predictor) > 0, "The predictor has no variation."))
    lm(outcome ~ predictor, data = dat)
  })

  output$reg_plot <- renderPlot({
    dat <- regression_data()
    validate(need(nrow(dat) >= 3, "At least three complete observations are required."))
    ggplot(dat, aes(x = predictor, y = outcome)) +
      geom_point(colour = "#176B87", size = 2.5) +
      geom_smooth(method = "lm", se = TRUE, colour = "#D95F02") +
      labs(x = input$reg_x, y = input$reg_y) +
      theme_minimal(base_size = 12)
  })

  output$reg_result <- renderPrint({
    model <- regression_model()
    print(summary(model))
    cat("\nNote: This is an exploratory bivariate linear regression, not a causal estimate.")
  })

  output$trend_test <- renderPrint({
    dat <- selected_values()
    validate(need(nrow(dat) >= 3, "At least three observations are required for a trend test."))
    validate(need(sd(dat$year) > 0, "The selected data do not span multiple years."))
    model <- lm(value ~ year, data = dat)
    result <- summary(model)$coefficients
    slope <- result["year", ]
    cat("Observations:", nrow(dat), "\n")
    cat("Estimated annual change:", round(slope["Estimate"], 5), "\n")
    cat("t statistic:", round(slope["t value"], 4), "\n")
    cat("p-value:", format.pval(slope["Pr(>|t|)"], digits = 4), "\n")
    cat("R-squared:", round(summary(model)$r.squared, 4), "\n")
    cat("\nThis ordinary least squares trend test does not account for serial correlation or structural breaks.")
  })

  output$data_table <- renderDT({
    datatable(filtered_data(), rownames = FALSE,
              options = list(pageLength = 10, scrollX = TRUE))
  })

  output$download_csv <- downloadHandler(
    filename = function() paste0("pakistan-economic-indicators-",
                                 input$years[1], "-", input$years[2], ".csv"),
    content = function(file) write.csv(filtered_data(), file, row.names = FALSE)
  )
}

shinyApp(ui = ui, server = server)
