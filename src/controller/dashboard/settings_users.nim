# A simple publishing platform powered by Supranim,
# a modern web framework for Nim.
#
# (c) 2026 George Lemon | AGPLv3 License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/sunday

import std/[os, json, strutils]

import pkg/[bag, ozark, jsony]
import pkg/supranim/[core/paths, controller]
import ../../service/provider/[db, session, tim]

ctrl getDashboardSettings:
  ## Renders the users settings dashboard screen.
  withDBPool do:
    let settings = Models.table(Settings).selectAll().where("tab", "general").getAll()
    if likely(settings.isEmpty == false):
      let data = settings.first()
      render("dashboard.settings.general",
          layout="dashboard", local = &*{
            "isAuth": isAuth,
            "settings": {
              "tab": data.getTab(),
              "description": data.getDescription(),
              "data": fromJson(data.getData())
            }
          })
    else:
      render("errors.5xx")
      

ctrl getDashboardSettingsUsers:
  ## Renders the users settings dashboard screen.
  render("dashboard.settings.users",
        layout="dashboard", local = &*{"isAuth": isAuth})