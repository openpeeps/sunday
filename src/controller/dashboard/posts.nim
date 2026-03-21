# A simple publishing platform powered by Supranim,
# a modern web framework for Nim.
#
# (c) 2026 George Lemon | AGPLv3 License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/sunday

import std/[os, json, strutils, options, times]

import pkg/[bag, ozark, jsony, tiptap]
import pkg/supranim/[core/paths, controller]
import pkg/supranim/support/slug

import ../../service/provider/[db, session, tim]

ctrl getDashboardPosts:
  ## Renders the posts overview dashboard screen.
  withDBPool do:
    let posts = Models.rawSQL("""
SELECT 
  posts.*,
  (SELECT COUNT(*) FROM comments WHERE comments.post_id = posts.id) AS comments_count
FROM posts
ORDER BY posts.created_at DESC LIMIT 20 OFFSET 0;""").getWith(Posts)
    render("dashboard.posts.list", layout="dashboard", local = &*{
      "isAuth": isAuth,
      "posts": posts,
    })

ctrl getDashboardPostsCreate:
  ## GET handler for rendering `dashboard.posts.create` template
  ## which contains the form for creating a new post.
  withDBPool do:
    let categories = Models.table(Categories).select(["id", "name"]).getAll()
    render("dashboard.posts.create", layout="dashboard", local = &*{
      "isAuth": isAuth,
      "categories": categories,
    })

ctrl postDashboardPostsCreate:
  ## POST handler for creating a new post
  let someData = req.getBodyData(JsonNode)
  
  if someData.isNone:
    # if the request body is empty or not valid JSON, return an error response 
    json("No data provided")

  let data = someData.get()
  var isEditing: bool # flag to determine if we're editing an existing post or creating a new one
  let postId: JsonNode =
    if data.hasKey("id") and data["id"].kind != JNull:
      isEditing = true; data["id"]
    else:
      nil
  try:
    let tiptapEditor = initTipTap(content = data["content"].toJson())
    if tiptapEditor.content.validate():
      # if the content is valid, we can proceed to
      # save the post to the database
      withUserSession do:
        let userData = req.getClientData()
        var postTitle = data["title"].getStr()

        if postTitle.len == 0:
          # default title if none provided
          postTitle = "Untitled Post"

        withDBPool do:
          var occurs = 0
          let
            slugBase = slug.slugify(postTitle)
            postContent = tiptapEditor.content.toJson()
            postAuthorId = userSession.getAuthUserId()
            postStatus: int = 0 # default to draft
          
          assert postAuthorId.isSome, "User must be authenticated to create a post"
          
          # ensure the slug is unique. if a post with the same
          # slug exists, append a number to make it unique
          var postSlug = slugBase
          block composeSlug:
            while true:
              # TODO maybe instead of doing a loop here, we can do a single query
              # that checks for existing slugs that start with the slugBase?
              let checkSlugQuery = Models.table(Posts).selectAll()
                                         .where("slug", postSlug)
                                         .extractSQL()
              var existing: Collection[Posts]
              if isEditing:
                # if we're editing an existing post, we need to exclude the current
                # post from the slug uniqueness check, otherwise it will always
                # find itself and think the slug is not unique
                existing = checkSlugQuery.fromSQL()
                                         .whereNot("id", $(postId.getInt))
                                         .getAll()
              else:
                # if we're creating a new post, we can just check
                # for any existing post with the same slug
                existing = checkSlugQuery.fromSQL().getAll()
              if existing.isEmpty:
                break # slug is unique, we can use it
              occurs += 1
              postSlug = slugBase & "-" & $occurs
          
          if not isEditing:
            # creating a new post will insert a new record into the database
            let postId =
              Models.table(Posts).insert({
                "title": postTitle,
                "slug": postSlug,
                "content": postContent,
                "author_id": postAuthorId.get(),
                "created_at": $(now()),
              }).execGet()
            # once created, will prepare the notification
            # message that will be used in the edit screen
            # after redirecting there.
            userSession.notify("Post created successfully!", some("/dashboard/posts/" & $postId))
            json(%*{"post_id": postId}, HttpCode(201))
          else:
            # while editing an existing post requires
            # updating the existing record in the database
            let postId = postId.getInt
            Models.table(Posts)
                  .update({
                    "title": postTitle,
                    "slug": postSlug,
                    "content": postContent,
                    "updated_at": $(now()),
                  })
                  .where("id", $postId)
                  .exec()
            userSession.notify("Post updated successfully!", some("/dashboard/posts/" & $postId))
            json(%*{"post_id": postId}, HttpCode(200))
  except jsony.JsonError as e:
    # Catch JSON parsing errors
    json(%*{"error": "Invalid content: " & e.msg}, HttpCode(400))
  json(%*{"error": "Could not create post"}, HttpCode(400))
  
ctrl getDashboardPostsId:
  ## GET handler for rendering the edit screen for a specific post
  let id = req.params["id"].parseInt()
  withSession do:
    withDBPool do:
      let currentPost =
        Models.table(Posts)
              .selectAll()
              .where("id", $id)
              .getAll()
      if not currentPost.isEmpty:
        let categories = Models.table(Categories).select(["id", "name"]).getAll()
        render("dashboard.posts.edit", layout="dashboard", local = &*{
          "isAuth": isAuth,
          "notifications": userSession.getNotifications(req.getUriPath).get(@[]),
          "post": currentPost.first(),
          "categories": categories,
        })
      render("errors.4xx")