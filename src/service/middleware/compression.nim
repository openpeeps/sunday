# A simple publishing platform powered by Supranim,
# a modern web framework for Nim.
#
# (c) 2026 George Lemon | AGPLv3 License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/sunday

# import std/[strutils, options, httpcore]

# import pkg/zippy
# import pkg/supranim/afterware

# newAfterware gzipped:
#   ## Afterware handle for gzip compression.
#   ## 
#   ## This middleware will compress the response body
#   ## using gzip if the client supports it.
#   if req.headers.isSome():
#     var reqHeaders = req.headers.get()
#     if reqHeaders.hasKey("Accept-Encoding"):
#       if contains($(reqHeaders["Accept-Encoding"]), "gzip"):
#         res.addHeader("Content-Encoding", "gzip")
#         res.body = zippy.compress(res.body)
#   next()
