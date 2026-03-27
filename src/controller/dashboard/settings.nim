# A simple publishing platform powered by Supranim,
# a modern web framework for Nim.
#
# (c) 2026 George Lemon | AGPLv3 License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/sunday

import std/[os, envvars, osproc, json, strutils, times]

import pkg/[bag, ozark, jsony]

import pkg/supranim/[controller, application]
import pkg/supranim/core/[paths, utils, fileserver]

import ../../service/provider/[db, session, tim]

ctrl getDashboardSettings:
  ## Renders the users settings dashboard screen.
  withDBPool do:
    let tabs = %*[
      {
        "name": "general",
        "label": "General"
      },
      {
        "name": "users",
        "label": "Users"
      },
      {
        "name": "plugins",
        "label": "Plugins"
      },
      {
        "name": "system",
        "label": "System"
      }
    ]
    if req.getQuery.isSome:
      let query = req.getQuery.get()
      if query.hasKey("tab") and query["tab"] != "general":
        if query["tab"] == "system":
          render("dashboard.settings.system", layout="dashboard", local = &*{
            "tabs": tabs
          })
        elif query["tab"] == "users":
          render("dashboard.settings.users", layout="dashboard", local = &*{
            "tabs": tabs
          })
        elif query["tab"] == "plugins":
          render("dashboard.settings.plugins", layout="dashboard", local = &*{
            "tabs": tabs
          })
        else:
          render("errors.4xx", layout="dashboard")

    # the `general` settings tab is the default view
    # for the settings dashboard
    let settings = Models.table(Settings).selectAll().where("tab", "general").getAll()
    if likely(settings.isEmpty == false):
      let data = settings.first()
      render("dashboard.settings.general",
          layout="dashboard", local = &*{
            "tabs": tabs,
            "settings": {
              "tab": data.getTab(),
              "description": data.getDescription(),
              "data": fromJson(data.getData())
            }
          })
    else:
      render("errors.5xx")

ctrl postDashboardSettingsFreeMemory:
  ## POST handler for triggering the release of unused memory back to the OS
  ## This can help reduce the memory footprint of the application, especially after
  ## performing memory-intensive operations. It uses the `releaseUnusedMemory` proc
  ## defined in `core/utils.nim`, which is a cross-platform shim for `malloc_trim` on Linux and `malloc_zone_pressure_relief` on macOS.
  if releaseUnusedMemory():
    json(%*{"msg": "Unused memory released back to the OS successfully."})
  else:
    json(%*{"msg": "Failed to release unused memory. This may not be supported on the current platform."})

ctrl getDashboardSettingsStats:
  ## GET handler for rendering the system stats screen in the dashboard settings

  # Get CPU cores
  let cpuCores = countProcessors()

  # Get total RAM (macOS: use sysctl)
  let ramOutput = execProcess("sysctl -n hw.memsize")
  let totalRamBytes = parseInt(ramOutput.strip())

  # Get current process memory usage (resident set size)
  let pid = getCurrentProcessId()
  let output = execProcess("ps -p " & $pid & " -o %cpu,rss,comm")
  let lines = output.splitLines()
  var cpuUsage = 0.0
  var memoryUsageBytes = 0
  if lines.len > 1:
    let cols = lines[1].strip().splitWhitespace()
    if cols.len >= 2:
      cpuUsage = parseFloat(cols[0])
      memoryUsageBytes = parseInt(cols[1]) * 1024 # rss is in KB

  json(%*{
    "total_cores": cpuCores,
    "total_ram_bytes": totalRamBytes, # in bytes
    "cpu_usage_percent": cpuUsage, # as a percentage
    "memory_usage_bytes": memoryUsageBytes # in bytes
  })

ctrl postDashboardSettingsBackup:
  ## Endpoint to download a zipped SQL backup of the entire database.
  let
    timeNow = getTime()
    dateStr = timeNow.format("dd-MM-yyyy-HHmmss").replace("-", "_")
    backupName = "sunday_backup_" & dateStr
    tempSql = getTempDir() / backupName & ".sql" 
    tempZip = getTempDir() / backupName & ".zip"

  # Adjust these as needed for your environment
  # Dump the database to a temp SQL file
  let dumpCmd = "pg_dump -U " & getEnv("database.user") & " " & getEnv("database.name") & " > " & tempSql
  let dumpResult = execShellCmd(dumpCmd)
  if dumpResult != 0:
    json(%*{"msg": "Failed to create database backup."})

  # Zip the SQL file
  let zipCmd = "zip -j " & tempZip & " " & tempSql
  let zipResult = execShellCmd(zipCmd)
  if zipResult != 0:
    json(%*{"msg": "Failed to create backup zip file."})
  
  req.sendDownloadable(tempZip, res.headers)

ctrl postDashboardSettingsUpdate:
  ## POST handler for 

ctrl getDashboardSettingsUsers:
  ## Renders the users settings dashboard screen.
  render("dashboard.settings.users",
        layout="dashboard", local = &*{})