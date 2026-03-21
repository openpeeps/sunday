# A simple publishing platform powered by Supranim,
# a modern web framework for Nim.
#
# (c) 2026 George Lemon | AGPLv3 License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/sunday

import std/[strutils, tables, json, macros, os]
import pkg/ozark
import pkg/kapsis/interactive/prompts

import pkg/supranim/core/services
import pkg/supranim/core/[paths, config]
import pkg/supranim/support/auth

import ./events

initService DB[Global]:
  backend do:
    macro loadModels =
      # auto discover /database/models/*.nim
      # nim files prefixed with `!` will be ignored
      result = newStmtList()
      for fModel in walkDirRec(modelPath):
        let f = fModel.splitFile
        if f.ext == ".nim" and f.name.startsWith("!") == false:
          add result, nnkImportStmt.newTree(newLit(fModel))
          add result, nnkExportStmt.newTree(ident(f.name))
    loadModels() # autoload available models

  client do:
    proc init*() =
      loadEnvStatic()
      ozark.initOzarkDatabase(
        address = getEnv("database.address"),
        name = getEnv("database.name"),
        user = getEnv("database.user"),
        password = getEnv("database.password")
      )
      initOzarkPool(10)
      try:
        withDBPool do:
          # create database tables if not exists
          Models.table(Settings).prepareTable().exec()
          Models.table(MediaLibrary).prepareTable().exec()

          # categories and tags
          Models.table(Categories).prepareTable().exec()
          Models.table(Tags).prepareTable().exec()

          # posts and their associations
          Models.table(Posts).prepareTable().exec()
          Models.table(PostCategories).prepareTable().exec()
          Models.table(PostTags).prepareTable().exec()
          Models.table(MediaPost).prepareTable().exec()

          # Pages and media associations
          Models.table(Pages).prepareTable().exec()
          Models.table(MediaPage).prepareTable().exec()

          # user related tables
          Models.table(Users).prepareTable().exec()
          Models.table(UserSessions).prepareTable().exec()
          Models.table(UserAccountConfirmations).prepareTable().exec()
          Models.table(UserAccountEmailConfirmations).prepareTable().exec()
          Models.table(UserAccountPasswordResets).prepareTable().exec()

          when not defined release:
            # the following code is used to create a test user account.
            # this code should be removed in production
            # and should be moved to a seeder or a migration file.
            let userRes = Models.table(Users)
                                .selectAll().where("id", "1").getAll()
            if userRes.isEmpty:
              event().emit("account.register", some(@["test@example.com", "strong password here"]))

            let hasSettings = Models.table(Settings).selectAll().getAll().isEmpty == false
            if not hasSettings:
              Models.table(Settings).insert({
                "tab": "general",
                "description": "General application settings",
                "data": toJson(%*{
                  "site_name": "Awesome Sunday Blog",
                  "site_description": "Just another blog powered by Sunday",
                  "site_keywords": "blog, sunday, cms, nim, supranim",
                })
              }).exec()

      except DbError:
        displayError("Database connection failed. Please check your database settings.")