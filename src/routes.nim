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

routes do:
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

      # Media routes
      get "/media"
      (get, post) -> "/media/upload"
      (get, delete) -> "/media/{id:id}"

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

  #
  # Front-end routes
  #
  get "/" {.middleware: [membership].}
    # GET route links to `getHomepage` controller
  
  get "/feed.xml"
    # GET route links to `getFeed` controller
  
  get "/sitemap.xml"
    # GET route links to `getSitemap` controller

  get "/{slug:slug}" {.middleware: [membership].}
    # GET route links to `getSlug` controller, which handles
    # rendering posts and pages based on the slug
  
  get "/category/{slug:slug}" {.middleware: [membership].}
    # GET route links to `getCategorySlug` controller, which renders
    # a list of posts in the specified category

  get "/tag/{slug:slug}"  {.middleware: [membership].}
    # GET route links to `getTagSlug` controller, which renders
    # a list of posts with the specified tag