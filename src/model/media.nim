# A simple publishing platform powered by Supranim,
# a modern web framework for Nim.
#
# (c) 2026 George Lemon | AGPLv3 License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/sunday

import pkg/supranim/model

import ./users, ./posts, ./pages

newModel MediaLibrary:
  # This model represents media items (images, videos, documents, etc.)
  # that are uploaded to the application. It stores metadata about
  # each media item, including its filename, filepath, uploader, and upload time
  id {.pk.}: Serial
  filename {.notnull.}: Varchar(255)
  filepath {.notnull.}: Varchar(255)
  uploaded_by {.notnull.}: Users.id
  uploaded_at {.notnull.}: TimestampTz

newModel MediaPost:
  # This model represents the association between
  # media items and posts in the application.
  id {.pk.}: Serial
  media_id {.notnull.}: MediaLibrary.id
  post_id {.notnull.}: Posts.id

newModel MediaPage:
  # This model represents the association between
  # media items and pages in the application.
  id {.pk.}: Serial
  media_id {.notnull.}: MediaLibrary.id
  page_id {.notnull.}: Pages.id