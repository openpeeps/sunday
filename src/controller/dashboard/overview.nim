# A simple publishing platform powered by Supranim,
# a modern web framework for Nim.
#
# (c) 2026 George Lemon | AGPLv3 License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/sunday

import std/[os, json]

import pkg/[bag, ozark]
import pkg/supranim/[core/paths, controller]
import ../../service/provider/[db, session, tim]

ctrl getDashboard:
  ## Renders the posts overview dashboard screen.
  withDBPool do:
    let countPosts = Models.table(Posts).select("id").getAll().len
    let countComments = Models.table(Comments).select("id").getAll().len
    render("dashboard.overview", layout="dashboard", local = &*{
      "isAuth": isAuth,
      "countPosts": countPosts,
      "countComments": countComments
    })
    