# A simple publishing platform powered by Supranim,
# a modern web framework for Nim.
#
# (c) 2026 George Lemon | AGPLv3 License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/sunday

#
# This file is automatically imported by the Supranim framework.
# It is used to define the routes for the application.
#

routes:
  get "/" # {.afterware: [gzipped].}
    # GET route links to `getHomepage` controller

  group "/dashboard":
    {.middleware: [authenticate].}:
      # Dashboard overview
      get "/"

      # Posts routes
      get "/posts"
      get "/posts/{id:id}"
      (get, post) -> "/posts/create"

      # Pages routes
      get "/pages"
      get "/pages/{id:id}"
      (get, post) -> "/pages/create"

      # Categories routes
      get "/categories"
      get "/categories/{id:id}"
      (get, post) -> "/categories/create"
      delete "/categories/{id:id}"

      # Comments routes
      get "/comments"
      post "/comments/{id:id}/approve"
      post "/comments/{id:id}/delete"

      # Plugins routes
      get "/plugins"
      # get "/plugins/{id:id}"

      # Settings routes
      get "/settings"
      get "/settings/users"

  # Account routes
  get "/account"
  get "/account/verify"

  # Authentication routes
  group "/auth":
    (get, post) -> "/login"
    (get, post) -> "/register"
    (get, post) -> "/forgot-password"
    (get, post) -> "/reset-password"
    get "/logout"