# Sunday - A simple publishing platform written in Nim
#
# (c) 2025 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/sunday

import std/[os, json, strutils]

import pkg/[bag, ozark]
import pkg/supranim/[core/paths, controller]
import ../../service/provider/[db, session, tim]

ctrl getDashboardComments:
  ## Renders the comments overview dashboard screen.
  withDBPool do:
    let comments = Models.table(Comments)
                         .select(["id", "author_name", "author_email"])
                         .where("approved", "false")
                        #  .orderDescBy(["created_at"])
                         .getAll()
    render("dashboard.comments.list", layout="dashboard", local = &*{
      "isAuth": isAuth,
      "comments": comments.toJson().fromJson()["entries"],
    })

ctrl postDashboardCommentsIdApprove:
  ## Handles comment approval.
  let commentId = req.params["id"].parseInt()
  # withDBPool do:
  #   let comment = Models.table("comments").select.where("id", commentId).get()
  #   if comment.isNil:
  #     resp.status = Http404
  #     return
  #   comment["approved"] = true
  #   comment.update()
  go getDashboardComments


ctrl postDashboardCommentsIdDelete:
  ## Handles comment deletion.
  let commentId = req.params["id"].parseInt()
  # withDBPool do:
  #   let comment = Models.table("comments").select.where("id", commentId).get()
  #   if comment.isNil:
  #     resp.status = Http404
  #     return
  #   comment.delete()
  # go getDashboardComments