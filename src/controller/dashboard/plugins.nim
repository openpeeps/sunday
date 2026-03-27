# A simple publishing platform powered by Supranim,
# a modern web framework for Nim.
#
# (c) 2026 George Lemon | AGPLv3 License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/sunday

import std/[os, json, strutils, times]
import pkg/[bag, ozark, jsony, pluginkit]

import pkg/ozark/runtimequery
import pkg/supranim/controller
import pkg/supranim/support/[slug, nanoid]

import ../../service/provider/[db, session, tim, pluggable]

ctrl getDashboardPlugins:
  ## GET handler for rendering the plugins overview screen in the dashboard
  withSession do:
    withDBPool do:
      var availablePlugins: seq[JsonNode]
      for plugin in pluginManager().manager.plugins():
        let exists = Models.table(Plugins)
                          .select(["id", "status"])
                          .where("id", plugin.getId())
                          .get()
        let pluginStatus =
          # todo get the int status instead of string
          if exists.isEmpty:
            # get the status of the plugin from the plugin manager
            # which can be "loaded" or "invalid" depending on whether
            # the plugin was successfully loaded at startup or not.
            $(plugin.getStatus())
          else:
            "pluginStatusInstalled"
        availablePlugins.add(%*{
          "id": plugin.getId(),
          "status": pluginStatus,
          "name": plugin.getName(),
          "author": plugin.getAuthor(),
          "version": plugin.getVersion(),
          "description": plugin.getDescription(),
          "license": plugin.getLicense(),
          "url": plugin.getUrl(),
        })
      
      let flashNotifications = userSession.getNotifications("/dashboard/plugins").get(@[])
      render("dashboard.plugins.list", layout="dashboard", local = &*{
        "plugins": availablePlugins,
        "notifications": flashNotifications,
        "permission_icons": {
          "filesystem": $icon("device-floppy"),
          "database": $icon("database"),
          "template": $icon("template"),
          "event": $icon("calendar-event"),
          "middleware": $icon("keyframe-align-center"),
          "settings": $icon("settings"),
        }
      })

ctrl postDashboardPluginsManageCsrf:
  ## POST handler for fetching a new CSRF token for plugin management actions
  withSession do:
    let id = req.params["nanoid"]
    if pluginManager().manager.hasPlugin(id):
      let token = userSession.genCSRF("/plugins/" & id & "/manage")
      json(%*{"token": token})
  json(%*{"error": "Plugin not found"}, code = HttpCode(404))

ctrl postDashboardPluginsManage:
  ## POST handler for managing a plugin (installing or uninstalling)
  withSession do:
    withDBPool do:
      if req.getFieldsTable.isNone():
        userSession.notify("Invalid request", some("/dashboard/plugins"))
        go getDashboardPlugins

      # the plugin_id field is required to identify which plugin to manage
      let data = req.getFieldsTable.get()
      if not data.hasKey("plugin_id"): 
        userSession.notify("Plugin ID is required", some("/dashboard/plugins"))
        go getDashboardPlugins

      let id = data["plugin_id"]
      let sundayPlugins = pluginManager()
      let exists = Models.table(Plugins).select(["id"]).where("id", id).get()
      if sundayPlugins.manager.hasPlugin(id):
        if exists.isEmpty:
          if sundayPlugins.onInstall.hasKey(id):
            # if the plugin has an `onInstall` schema collected during the loading process,
            # we can execute the provided schema to create any necessary tables
            let schema = sundayPlugins.onInstall[id]
            for name, tableSchema in schema.schemas:
              # let xid = nanoid.generate(defaultAlphabet[2..^1], size = 10)
              # let tableName = "plugin_" & name & "_" & xid
              # sundayPlugins.onUninstallAliases[tableName] = id
              dbcon.exec(createTable(name, tableSchema))
          Models.table(Plugins).insert({
            "id": id,
            "status": "1", # mark as installed
            "installed_at": $(now())
          }).exec()
          userSession.notify("Plugin installed successfully", some("/dashboard/plugins"))
          go getDashboardPlugins
        else:
          Models.table(Plugins).removeRow().where("id", id).exec()
          userSession.notify("Plugin uninstalled successfully", some("/dashboard/plugins"))
          go getDashboardPlugins
      userSession.notify("Plugin not found", some("/dashboard/plugins"))
      go getDashboardPlugins