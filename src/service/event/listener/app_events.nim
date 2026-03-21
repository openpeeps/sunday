# A simple publishing platform powered by Supranim,
# a modern web framework for Nim.
#
# (c) 2026 George Lemon | AGPLv3 License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/sunday

import std/options
import supranim/service/events

listener "app.startup":
  # This event is triggered when
  # the application starts up.
  discard