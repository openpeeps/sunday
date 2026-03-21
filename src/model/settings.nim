# A simple publishing platform powered by Supranim,
# a modern web framework for Nim.
#
# (c) 2026 George Lemon | AGPLv3 License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/sunday

import pkg/supranim/model

newModel Settings:
  tab {.unique.}: Varchar(255)
  description {.nullable.}: Varchar(255)
  data {.notnull.}: Json