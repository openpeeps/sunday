# A simple publishing platform powered by Supranim,
# a modern web framework for Nim.
#
# (c) 2026 George Lemon | AGPLv3 License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/sunday

import pkg/supranim/model

newModel Categories:
  id {.pk.}: Serial
  name {.notnull.}: Varchar(255)
  slug {.unique, notnull.}: Varchar(255)
  description: Json
  created_at {.notnull.}: TimestampTz
  updated_at: TimestampTz

newModel Tags:
  id {.pk.}: Serial
  name {.notnull.}: Varchar(50)
  slug {.unique, notnull.}: Varchar(50)
  created_at {.notnull.}: TimestampTz
  updated_at: TimestampTz
