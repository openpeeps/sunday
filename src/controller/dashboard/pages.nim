# A simple publishing platform powered by Supranim,
# a modern web framework for Nim.
#
# (c) 2026 George Lemon | AGPLv3 License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/sunday

import std/[os, json, strutils]

import pkg/[bag, ozark]
import pkg/supranim/[core/paths, controller]
import ../../service/provider/[db, session, tim]

ctrl getDashboardPages:
  ## Renders the posts overview dashboard screen.
  withDBPool do:
    let pages = Models.table(Pages)
                      .selectAll()
                      # .orderDescBy(["created_at"])
                      # .limit(20)
                      .getAll()
    render("dashboard.pages.list", layout="dashboard", local = &*{
      "isAuth": isAuth,
      "pages": pages.toJson().fromJson()["entries"],
    })

ctrl getDashboardPagesCreate:
  ## Renders the new post creation screen.
  render("dashboard.pages.create",
        layout="dashboard", local = &*{"isAuth": isAuth})

ctrl postDashboardPagesCreate:
  ## Handles the new post creation form submission.
  go getDashboardPages

ctrl getDashboardPagesId:
  ## Renders the post editing screen.
  let postId = req.params["id"].parseInt()
  render("dashboard.pages.edit", layout="dashboard",
    local = &*{
      "isAuth": isAuth,
      "postId": postId
    }
  )