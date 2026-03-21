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
import pkg/supranim/core/[services, application, paths]
import pkg/voodoo/language/value

import pkg/[tim, iconim]
import pkg/kapsis/interactive/prompts

export HttpCode, render, `&*`
export times.now, times.format

initService Tim[Global]:
  # A singleton service that wraps the Tim Engine
  # and provides a simple interface to render HTML pages
  backend do:
    var timEngineBackend*, timEngineFrontend*: TimEngine

    Icon.init(
      source = storagePath / "icons",
      default = "outline",
      stripAttrs = %*["class"]
    )

    proc init*(app: Application, src, output, basePath: string; global = newJObject()) =
      ## Initializes Tim Engine instances for both backend and frontend rendering
      
      # Ensure the themes directory exists at installation path
      let themesPath = "themes"
      let cachedThemesPath = ".cached_themes"
      block initFrontend:
        discard existsOrCreateDir(app.paths().getInstallationPath / themesPath)
        discard existsOrCreateDir(app.paths().getInstallationPath / cachedThemesPath)
        
        timEngineFrontend = newTim(
          enableThemes = true,
          activeThemeName = some("twentysix"),
          src = themesPath,
          output = cachedThemesPath,
          basePath = app.paths().getInstallationPath,
          globalData = newJObject()
        )

        timEngineFrontend.precompile()

      block initBackend:
        # Initialize the backend Tim Engine instance
        timEngineBackend = newTim(
          src = src,
          output = output,
          basePath = basePath,
          globalData = global
        )

        # predefine foreign functions
        timEngineBackend.userScript.addProc("slugify", @[paramDef("s", ttyString)], ttyString,
          proc (args: StackView, argc: int): value.Value =
            ## Convert a string to a URL-friendly slug
            return initValue(slugify(args[0].stringVal[]))
          )

        timEngineBackend.userScript.addProc("dashboard", @[paramDef("x", ttyString)], ttyString,
          proc (args: StackView, argc: int): value.Value =
            # prefix a link with `/dashboard/`
            return initValue("/dashboard/" & args[0].stringVal[])
          )

        timEngineBackend.userScript.addProc("icon", @[paramDef("name", ttyString)], ttyString,
          proc (args: StackView, argc: int): value.Value =
            # Return an HTML string for an icon
            return initValue($icon(args[0].stringVal[]).size(18))
          )
        tim.initCommonStorage:
          {
            "path": req.getUrl(),
            "currentYear": now().format("yyyy"),
          }
        
        timEngineBackend.precompile()

    proc gettimBackendInstance*: TimEngine =
      # Returns the singleton instance of the Tim Engine
      if timEngineBackend == nil:
        raise newException(ValueError, "Tim Engine not initialized")
      return timEngineBackend

  client do:
    proc isSPARequest(req: var Request): bool =
      # A simple heuristic to determine if the request is an AJAX request
      # You can customize this based on your frontend framework's conventions
      req.getHeaders().isSome and req.getHeaders().get().hasKey("X-Requested-With")

    template renderFrontend*(view: string, layout: string = "base",
                             httpCode = Http200, local: JsonNode = nil): untyped =
      ## Renders a Tim template using the frontend engine and sends it as an HTTP response.
      ## It must be used within a route handler (controller).
      try:
        let output = timEngineFrontend.themeRender(view, layout, local)
        respond(httpCode, output)
      except TimEngineError as e:
        displayError("<services.tim> " & e.msg)
        respond(Http500, timEngineFrontend.themeRender("errors.5xx", layout, local))
      except Exception as e:
        displayError("<services.tim> " & e.msg)
        respond(Http500, timEngineFrontend.themeRender("errors.5xx", layout, local))
      return # blocks further execution in the route handler after rendering the view

    template render*(view: string, layout: string = "base",
                      httpCode = Http200, local: JsonNode = nil): untyped =
      ## Renders a Tim template and sends it as an HTTP response.
      ## It must be used within a route handler (controller).
      try:
        let output = render(timEngineBackend, view, layout, local)
        respond(httpCode, output)
      except TimEngineError as e:
        displayError("<services.tim> " & e.msg)
        respond(Http500, render(timEngineBackend, "errors.5xx", layout, local))
      except Exception as e:
        displayError("<services.tim> " & e.msg)
        respond(Http500, render(timEngineBackend, "errors.5xx", layout, local))
      return # blocks further execution in the route handler after rendering the view

    template renderView*(view: string, httpCode = Http200, local: JsonNode = nil): untyped =
      ## Renders a Tim view without a layout and sends it as an HTTP response.
      ## This can be used for rendering partials or standalone views.
      try:
        let output = renderView(timEngineBackend, view, local)
        respond(httpCode, output)
      except TimEngineError as e:
        displayError("<services.tim> " & e.msg)
        respond(Http500, renderView(timEngineBackend, "errors.5xx", local))
      except Exception as e:
        displayError("<services.tim> " & e.msg)
        respond(Http500, renderView(timEngineBackend, "errors.5xx", local))
      return # blocks further execution in the route handler after rendering the view