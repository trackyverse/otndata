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

test_that("otn_set_credentials creates .Renviron file if it does not exist", {
  # 1. Create an isolated home directory
  tmp_home <- tempfile(pattern = "mock_home_")
  dir.create(tmp_home)

  # 2. Preserve original environment state
  old_home <- Sys.getenv("HOME", unset = NA)
  old_user <- Sys.getenv("OTN_USER.testthat", unset = NA)
  old_pass <- Sys.getenv("OTN_PASS.testthat", unset = NA)

  # Restore environment on exit
  on.exit(
    {
      unlink(tmp_home, recursive = TRUE)
      if (is.na(old_home)) {
        Sys.unsetenv("HOME")
      } else {
        Sys.setenv(HOME = old_home)
      }
      if (is.na(old_user)) {
        Sys.unsetenv("OTN_USER.testthat")
      } else {
        Sys.setenv(OTN_USER.testthat = old_user)
      }
      if (is.na(old_pass)) {
        Sys.unsetenv("OTN_PASS.testthat")
      } else {
        Sys.setenv(OTN_PASS.testthat = old_pass)
      }
    },
    add = TRUE
  )

  # 3. Point HOME to the temp directory and clear OTN variables
  Sys.setenv(HOME = tmp_home)
  Sys.unsetenv("OTN_USER.testthat")
  Sys.unsetenv("OTN_PASS.testthat")

  # 4. Mock interactive credential prompts
  local_mocked_bindings(
    askpass = function(prompt) "mock_value",
    .package = "askpass"
  )

  renv_file <- file.path(tmp_home, ".Renviron")
  expect_false(file.exists(renv_file))

  # 5. Execute
  otn_set_credentials("testthat", temporary = FALSE, overwrite = TRUE)

  expect_true(file.exists(renv_file))
  expect_true(any(grepl("OTN_USER\\.testthat", readLines(renv_file))))
})
