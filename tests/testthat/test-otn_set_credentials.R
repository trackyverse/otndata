test_that("otn_set_credentials stores credentials temporarily in otn_global", {
  local_mocked_bindings(
    askpass = function(prompt) {
      if (grepl("Username", prompt)) "temp_user" else "temp_pass"
    },
    .package = "askpass"
  )

  otn_set_credentials("testthat", temporary = TRUE)

  otn_glob <- asNamespace("otndata")$otn_global
  expect_equal(otn_glob$testthat$username, "temp_user")
  expect_equal(otn_glob$testthat$password, "temp_pass")
})

test_that("otn_set_credentials errors if credentials already exist and overwrite is FALSE", {
  old_home <- Sys.getenv("HOME", unset = NA)

  tmp_dir <- tempfile()
  dir.create(tmp_dir)
  renv_file <- file.path(tmp_dir, ".Renviron")

  # Populate .Renviron with existing credentials for this network
  writeLines("OTN_USER.testthat='existing_user'", renv_file)

  on.exit(
    {
      if (is.na(old_home)) {
        Sys.unsetenv("HOME")
      } else {
        Sys.setenv(HOME = old_home)
      }
      unlink(tmp_dir, recursive = TRUE)
    },
    add = TRUE
  )

  Sys.setenv(HOME = tmp_dir)

  local_mocked_bindings(
    askpass = function(prompt) "dummy",
    .package = "askpass"
  )

  expect_error(
    otn_set_credentials("testthat", temporary = FALSE, overwrite = FALSE),
    regexp = "Some credentials for that server already exist"
  )
})

test_that("otn_set_credentials appends to .Renviron when overwrite is TRUE", {
  old_home <- Sys.getenv("HOME", unset = NA)

  tmp_dir <- tempfile()
  dir.create(tmp_dir)
  renv_file <- file.path(tmp_dir, ".Renviron")
  file.create(renv_file)

  on.exit(
    {
      if (is.na(old_home)) {
        Sys.unsetenv("HOME")
      } else {
        Sys.setenv(HOME = old_home)
      }
      unlink(tmp_dir, recursive = TRUE)
    },
    add = TRUE
  )

  Sys.setenv(HOME = tmp_dir)

  local_mocked_bindings(
    askpass = function(prompt) {
      if (grepl("Username", prompt)) "new_user" else "new_pass"
    },
    .package = "askpass"
  )

  otn_set_credentials("testthat", temporary = FALSE, overwrite = TRUE) |>
    expect_message("Your OTN")

  lines <- readLines(renv_file)
  expect_true(any(grepl("OTN_USER.testthat='new_user'", lines)))
  expect_true(any(grepl("OTN_PASS.testthat='new_pass'", lines)))
})
