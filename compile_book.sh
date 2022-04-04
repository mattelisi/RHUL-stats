#!/usr/bin/env Rscript

bookdown::render_book("./RHUL-stats-notebook/index.Rmd", "bookdown::bs4_book")
bookdown::render_book("./RHUL-stats-notebook/index.Rmd", "bookdown::pdf_book")
