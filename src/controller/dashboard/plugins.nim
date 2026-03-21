# A simple publishing platform powered by Supranim,
# a modern web framework for Nim.
#
# (c) 2026 George Lemon | AGPLv3 License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/sunday

import std/[os, json, strutils]

import pkg/[bag, ozark, jsony, pluginkit]
import pkg/supranim/controller
import pkg/supranim/support/slug

import ../../service/provider/[db, session, tim, pluggable]

ctrl getDashboardPlugins:
  ## GET handler for rendering the plugins overview screen in the dashboard
  var availablePlugins: seq[JsonNode]
  for plugin in pluginManager().plugins():
    availablePlugins.add(%*{
      "id": plugin.getId(),
      "name": plugin.getName(),
      "author": plugin.getAuthor(),
      "version": plugin.getVersion(),
      "status": plugin.getStatus()
    })
  render("dashboard.plugins.list", layout="dashboard", local = &*{
    "isAuth": isAuth,
    "plugins": availablePlugins
  })

