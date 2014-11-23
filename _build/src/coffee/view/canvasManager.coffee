$ = require "jquery"
canvas = $( "#canvas" ).get( 0 )
instance = null

class CanvasManager
  constructor: ->
    if !canvas.getContext
      alert "This browser doesn\'t supoort HTML5 Canvas."
      return undefined

    @context = canvas.getContext( "2d" )

  resetContext: ( width, height )->
    canvas.width = width
    canvas.height = height

  clear: ( width, height )->
    @context.clearRect 0, 0, width, height

  createImage: ( width, height )->
    @context.createImageData( width, height )

  getImage: ( x, y, width, height )->
    @context.getImageData( x, y, width, height )

  getContext: ->
    @context

getInstance = ->
  if !instance
    instance = new CanvasManager()
  instance

module.exports = getInstance
