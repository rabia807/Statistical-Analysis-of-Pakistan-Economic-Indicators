testthat::test_that("indicator metadata contains six documented series", {
  source(testthat::test_path("../../R/data.R"))
  testthat::expect_length(indicator_codes, 6)
  testthat::expect_true(all(nzchar(unname(indicator_codes))))
  testthat::expect_setequal(names(indicator_codes), names(indicator_units))
})

testthat::test_that("descriptive statistics are calculated correctly", {
  source(testthat::test_path("../../R/data.R"))
  sample <- data.frame("GDP growth (annual %)" = c(1, 2, 3, NA))
  result <- summarise_indicator(sample, "GDP growth (annual %)")
  testthat::expect_equal(result$observations, 3)
  testthat::expect_equal(result$mean, 2)
  testthat::expect_equal(result$median, 2)
  testthat::expect_equal(result$minimum, 1)
  testthat::expect_equal(result$maximum, 3)
})

testthat::test_that("empty data return missing summary values", {
  source(testthat::test_path("../../R/data.R"))
  sample <- data.frame("GDP growth (annual %)" = c(NA_real_, NA_real_))
  result <- summarise_indicator(sample, "GDP growth (annual %)")
  testthat::expect_equal(result$observations, 0)
  testthat::expect_true(is.na(result$mean))
})

testthat::test_that("unknown indicator names produce an informative error", {
  source(testthat::test_path("../../R/data.R"))
  sample <- data.frame(x = 1:3)
  testthat::expect_error(summarise_indicator(sample, "not-an-indicator"),
                         "Unknown indicator")
})
