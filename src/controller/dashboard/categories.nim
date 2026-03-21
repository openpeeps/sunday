import std/[os, tables, json, strutils, times]

import pkg/[bag, ozark, jsony]
import pkg/supranim/[core/paths, controller]
import pkg/supranim/support/slug
import ../../service/provider/[db, session, tim]

ctrl getDashboardCategories:
  ## Renders the categories overview dashboard screen.
  withDBPool do:
    let categories = Models.table(Categories).selectAll().getAll()
    let counters = Models.table(PostCategories).selectAll().getAll()
    # var countCategories = CountTable[string]()
    # for count in counters:
    #   countCategories.inc(parseInt(count.getCategoryId()))
    render("dashboard.categories.list", layout="dashboard", local = &*{
      "isAuth": isAuth,
      "categories": categories
    })

ctrl getDashboardCategoriesCreate:
  ## Renders the new category creation screen.
  render("dashboard.categories.create", layout="dashboard", local = &*{
    "isAuth": isAuth
  })

ctrl postDashboardCategoriesCreate:
  ## Handles the new category creation form submission.
  let someData = req.getBodyData(JsonNode)
  if someData.isNone:
    json("No data provided")
  let data = someData.get()
  
  # todo use `pkg/valido` to validate the incoming data and return errors if validation fails
  let categoryName = data["category_name"].getStr()
  if categoryName.len == 0:
    json("Category name cannot be empty")

  let catSlug = slug.slugify(categoryName)
  withDBPool do:
    # Ensure the slug is unique by appending a number if necessary
    let existingSlug = Models.rawSQL("SELECT id FROM categories where slug = $1", catSlug)
                           .getWith(Categories)
    
    let suffix =
      if existingSlug.isEmpty: ""
      else: "-" & $(existingSlug.len + 1)

    let catId = Models.table(Categories).insert({
                  "name": categoryName,
                  "slug": catSlug & suffix,
                  "description": toJson(newJObject()),
                  "created_at": $(now())
                }).execGet()
    json(%*{"success": true, "category_id": catId}) 

ctrl getDashboardCategoriesId:
  ## Renders the category editing screen.
  let categoryId = req.params["id"].parseInt()
  render("dashboard.categories.edit", layout="dashboard",
    local = &*{
      "isAuth": isAuth,
      "categoryId": categoryId
    }
  )

ctrl deleteDashboardCategoriesId:
  ## Handles the category deletion.
  let categoryId = req.params["id"].parseInt()
  # withDBPool do:
    # Models.table(Categories).delete(categoryId).exec()
  go getDashboardCategories