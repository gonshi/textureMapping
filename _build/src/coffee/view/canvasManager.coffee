$ = require "jquery"
$canvas = $( "#canvas" )

class CanvasManager
  constructor: ->
    if !$canvas.get( 0 ).getContext
      alert "This browser doesn\'t supoort HTML5 Canvas."
      return undefined

    @context = $canvas.get( 0 ).getContext( "2d" )

  resetContext: ( width, height )->
    $canvas.get( 0 ).width = width
    $canvas.get( 0 ).height = height

  clear: ( width, height )->
    @context.clearRect 0, 0, width, height

  getContext: ->
    @context

getInstance = ->
  if !instance
    instance = new CanvasManager()
  instance

module.exports = getInstance
