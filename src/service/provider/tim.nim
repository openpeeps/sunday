# A simple publishing platform powered by Supranim,
# a modern web framework for Nim.
#
# (c) 2026 George Lemon | AGPLv3 License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/sunday

import std/[macros, json, strutils, os,
        httpcore, times, options]

import pkg/supranim/controller
import pkg/supranim/support/slug
import pkg/supranim/core/[services, paths]
import pkg/voodoo/language/value

import pkg/[tim, iconim]
import pkg/kapsis/interactive/prompts

export HttpCode, render, `&*`
export times.now, times.format

initService Tim[Global]:
  # A singleton service that wraps the Tim Engine
  # and provides a simple interface to render HTML pages
  backend do:
    var timInstance*: TimEngine
    
    Icon.init(
      source = storagePath / "icons",
      default = "outline",
      stripAttrs = %*["class"]
    )

    proc init*(src, output, basePath: string; global = newJObject()) =
      ## Initialize Tim Engine as a singleton service
      timInstance = newTim(
        src = src,
        output = output,
        basePath = basePath,
        globalData = global
      )

      # predefine foreign functions
      timInstance.userScript.addProc("slugify", @[paramDef("s", ttyString)], ttyString,
        proc (args: StackView, argc: int): value.Value =
          ## Convert a string to a URL-friendly slug
          return initValue(slugify(args[0].stringVal[]))
        )

      timInstance.userScript.addProc("dashboard", @[paramDef("x", ttyString)], ttyString,
        proc (args: StackView, argc: int): value.Value =
          # prefix a link with `/dashboard/`
          return initValue("/dashboard/" & args[0].stringVal[])
        )

      timInstance.userScript.addProc("icon", @[paramDef("name", ttyString)], ttyString,
        proc (args: StackView, argc: int): value.Value =
          # Return an HTML string for an icon
          return initValue($icon(args[0].stringVal[]).size(18))
        )
      tim.initCommonStorage:
        {
          "path": req.getUrl(),
          "currentYear": now().format("yyyy"),
        }
      timInstance.precompile()

    proc getTimInstance*: TimEngine =
      # Returns the singleton instance of the Tim Engine
      if timInstance == nil:
        raise newException(ValueError, "Tim Engine not initialized")
      return timInstance

  client do:
    proc isSPARequest(req: var Request): bool =
      # A simple heuristic to determine if the request is an AJAX request
      # You can customize this based on your frontend framework's conventions
      req.getHeaders().isSome and req.getHeaders().get().hasKey("X-Requested-With")

    template render*(view: string, layout: string = "base",
                      httpCode = Http200, local: JsonNode = nil): untyped =
      ## Renders a Tim template and sends it as an HTTP response.
      ## It must be used within a route handler (controller).
      try:
        let output = render(timInstance, view, layout, local)
        respond(httpCode, output)
      except TimEngineError as e:
        displayError("<services.tim> " & e.msg)
        respond(Http500, render(timInstance, "errors.5xx", layout, local))
      except Exception as e:
        displayError("<services.tim> " & e.msg)
        respond(Http500, render(timInstance, "errors.5xx", layout, local))
      return # blocks further execution in the route handler after rendering the view

    template renderView*(view: string, httpCode = Http200, local: JsonNode = nil): untyped =
      ## Renders a Tim view without a layout and sends it as an HTTP response.
      ## This can be used for rendering partials or standalone views.
      try:
        let output = renderView(timInstance, view, local)
        respond(httpCode, output)
      except TimEngineError as e:
        displayError("<services.tim> " & e.msg)
        respond(Http500, renderView(timInstance, "errors.5xx", local))
      except Exception as e:
        displayError("<services.tim> " & e.msg)
        respond(Http500, renderView(timInstance, "errors.5xx", local))
      return # blocks further execution in the route handler after rendering the view