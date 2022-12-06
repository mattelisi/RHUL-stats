#!/usr/bin/env Rscript

rm(list=ls())
setwd("/mnt/sda2/matteoHDD/git_local_HDD/RHUL-stats/RHUL-stats-notebook")

# bookdown::serve_book(dir="/mnt/sda2/matteoHDD/git_local_HDD/RHUL-stats/RHUL-stats-notebook",
#                      output_dir = "../docs")
# servr::daemon_stop(1)

bookdown::render_book("index.Rmd", "bookdown::bs4_book",
                      output_dir = "../docs",
                      new_session = TRUE)

# bookdown::render_book("index.Rmd", "bookdown::pdf_book",
#                       output_dir = "../",
#                       new_session = TRUE)

options(bookdown.clean_book = TRUE)
bookdown::clean_book()

setwd("/mnt/sda2/matteoHDD/git_local_HDD/RHUL-stats/")
system("rm *.md")
system("rm *.tex")

system("git add -A")
system('git commit -m "gave up on share again ¯_(ツ)_/¯"')
system("git push origin main")
