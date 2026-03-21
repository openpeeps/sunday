# A simple publishing platform powered by Supranim,
# a modern web framework for Nim.
#
# (c) 2026 George Lemon | AGPLv3 License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/sunday

import pkg/supranim/model

newModel Pages:
  id {.pk.}: Serial
  title {.notnull.}: Varchar(255)
  status: Int4 = 0
    # 0 = draft, 1 = published, 2 = trashed
  slug {.unique, notnull.}: Varchar(255)
  content {.notnull.}: Json
  author_id {.notnull.}: Users.id
  created_at {.notnull.}: TimestampTz
  updated_at: TimestampTz
