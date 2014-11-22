$ = require "jquery"
EventDispatcher = require "../util/eventDispatcher"
Throttle = require "../util/throttle"

class ResizeHandler extends EventDispatcher
  constructor: ->
    super()

  exec: ->
    throttle = new Throttle 250
    $wrapper = $( '#wrapper' )

    $( window )
      .on "load resize", =>
        throttle.exec =>
          @dispatch "RESIZED",
            @,
            $wrapper.width(),
            $wrapper.height()

getInstance = ->
  if !instance
    instance = new ResizeHandler()
  return instance

module.exports = getInstance
