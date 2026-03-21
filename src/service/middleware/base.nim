# A simple publishing platform powered by Supranim,
# a modern web framework for Nim.
#
# (c) 2026 George Lemon | AGPLv3 License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/sunday

import std/[strutils, times, options]
import pkg/supranim/middleware
import ../provider/session

# import pkg/limiter

# var globalLimiter = Limiter(
#   maximumHits: 300,
#   timeLimit: initDuration(seconds = 60),
#   timeToWait: initDuration(seconds = 60)
# )

# newBaseMiddleware limitChecker:
#   ## Checks if the request is coming from an IP
#   ## address that is currently limited by the server
#   when defined release:
#     if not globalLimiter.hit(req.getIp):
#       req.resp(code = HttpCode(429), "", res.getHeaders())
#   else: discard

newBaseMiddleware uriChecker:
  ## Fix the trailing slash in the URI
  let path = req.getUriPath
  if path != "/" and path[^1] == '/':
    res.addHeader("Location", path[0..^2])
    req.resp(code = HttpCode(301), "", res.getHeaders())