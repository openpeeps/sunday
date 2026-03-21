# A simple publishing platform powered by Supranim,
# a modern web framework for Nim.
#
# (c) 2026 George Lemon | AGPLv3 License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/sunday

import pkg/supranim/model

import posts

newModel Comments:
  id {.pk.}: Serial
  post_id {.notnull.}: Posts.id
  author_name {.notnull.}: Varchar(100)
  author_email {.notnull.}: Varchar(100)
  content {.notnull.}: Json
  created_at {.notnull.}: TimestampTz
  approved {.notnull.}: Boolean = false