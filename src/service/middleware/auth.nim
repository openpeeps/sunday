# A simple publishing platform powered by Supranim,
# a modern web framework for Nim.
#
# (c) 2026 George Lemon | AGPLv3 License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/sunday

import pkg/supranim/middleware
import ../provider/session

newMiddleware authenticate:
  ## Checks if the user is authenticated. If not, redirects to the login page.
  withSession do:
    let userData = req.getClientData()
    if userSession.isAuthenticated():
      next() # continue to the next middleware
  abort("/auth/login") # redirects to `GET /auth/login` page

newMiddleware membership:
  ## Checks if the user is authenticated and has an active
  ## membership. If not, redirects to the login page.
  withSession do:
    let userData = req.getClientData()
    if userSession.isAuthenticated():
      next() # continue to the next middleware
  abort("/auth/login") # redirects to `GET /auth/login` page