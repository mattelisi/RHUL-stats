
rm(list=ls())
setwd("/mnt/sda2/matteoHDD/git_local_HDD/RHUL-stats")

library(tidyverse)

d <- read_csv('./data/survey_march22/stats-survey-rhul_edit.csv')

# -----------------------------------------------------------
# 1
d %>%
  filter(Finished==TRUE) %>%
  select(starts_with('models_') & !contains('TEXT')) %>%
  mutate(id = 1:nrow(.)) %>%
  pivot_longer(starts_with('models_'),names_to = 'what') %>%
  filter(!is.na(value)) %>%
  filter(value!="Other (please specify)") %>%
  mutate(value_short = str_extract(value, pattern='^[^:\\.)]*')) %>% 
  # simplify labels (regex whiz may do it more elegantly)
  mutate(value_short = ifelse(str_detect(value_short,"\\((?=e)"),
                              str_sub(value_short,1,-1 -2),
                              value_short)) %>%
  mutate(value_short = ifelse(str_detect(value_short,"\\("),
                              str_c(value_short,")"),
                              value_short)) %>%
  group_by(value_short) %>%
  summarise(N = length(id)) %>%
  arrange(N) %>%
  mutate(value_short=as_factor(value_short)) %>%
  ggplot(aes(y=value_short, x=N))+
  theme_gray(12) +
  geom_col() +
  labs(y="")

d %>%
  filter(Finished==TRUE) %>%
  select(starts_with('models_') & contains('TEXT')) %>%
  filter(!is.na(models_17_TEXT)) %>%
  pull(models_17_TEXT)

# -----------------------------------------------------------
# 2
d %>%
  filter(Finished==TRUE) %>%
  select(open_topics) %>%
  filter(!is.na(open_topics)) %>%
  pull(open_topics)

# -----------------------------------------------------------
# 3
d %>%
  filter(Finished==TRUE) %>%
  select(starts_with('extra_') & !contains('TEXT')) %>%
  mutate(id = 1:nrow(.)) %>%
  pivot_longer(starts_with('extra_'),names_to = 'what') %>%
  filter(!is.na(value)) %>%
  filter(value!="Other (please specify)") %>%
  group_by(value) %>%
  summarise(N = length(value)) %>%
  arrange(N) %>%
  mutate(value=as_factor(value)) %>%
  ggplot(aes(y=value, x=N))+
  theme_gray(12) +
  geom_col() +
  labs(y="")

d %>%
  filter(Finished==TRUE) %>%
  select(starts_with('extra_') & contains('TEXT')) %>%
  filter(!is.na(extra_5_TEXT)) %>%
  pull(extra_5_TEXT)

# -----------------------------------------------------------
# 4 format
d %>%
  filter(Finished==TRUE) %>%
  select(starts_with('format_')) %>%
  mutate(id = 1:nrow(.)) %>%
  pivot_longer(starts_with('format_'),names_to = 'what') %>%
  mutate(value=factor(value, ordered=T, levels=c("Very unlikely",
                                                 "Unlikely",
                                                 "Unsure",
                                                 "Likely",
                                                 "Very likely"))) %>%
  filter(!is.na(value)) %>%
  mutate(what=case_when(
    str_detect(what,"1") ~ "Short workshop",
    str_detect(what,"2") ~ "Longer workshop",
    str_detect(what,"3") ~ "one-on-one meeting",
    str_detect(what,"4") ~ "shared resource",
    str_detect(what,"5") ~ "collaboration"
  ) ) %>%
  group_by(what, value) %>%
  summarise(N = length(id)) %>%
  ggplot(aes(x=value, y=N)) +
  geom_col()+
  facet_wrap(.~what, ncol=2) +
  labs(x="")


d %>%
  filter(Finished==TRUE) %>%
  filter(!is.na(open_format)) %>%
  pull(open_format)

# -----------------------------------------------------------
# role
d %>%
  filter(Finished==TRUE) %>%
  filter(!is.na(role)) %>%
  ggplot(aes(x=role))+
  geom_histogram(stat='count')



