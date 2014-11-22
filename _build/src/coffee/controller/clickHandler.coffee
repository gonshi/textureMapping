$ = require "jquery"
EventDispatcher = require "../util/eventDispatcher"
Throttle = require "../util/throttle"

$plotContainer = $ "#plot_container"
numExp = /.*?num(.*?)$/
def_translate = 0
instance = null

class ClickHandler extends EventDispatcher
  constructor: ->
    super()
    @click_offset = {}

  plot: ->
    throttle = new Throttle 10
    def_translate = parseInt( $( "#plot_container .plot" ).
                    css( "transform" ).
                    split( "," )[ 5 ] )
    @setOffset()

    $ document
      .on "mousedown touchstart", "#plot_container .plot", ( e )=>
        dom = e.target
        classNum = parseInt $( dom ).attr( "class" ).match( numExp )[ 1 ]
        @click_offset.x = _getPos( e ).x - $( dom ).offset().left
        @click_offset.y = _getPos( e ).y - $( dom ).offset().top
        currentDrag = dom

        $ "body"
          .on "mousemove touchmove", ( e )=>
            throttle.exec =>
              @dispatch "MOVE_PLOT", currentDrag,
                         _getPos( e ).x -
                         @click_offset.x - @offset[ classNum ].x,
                         _getPos( e ).y -
                         @click_offset.y - @offset[ classNum ].y

    $ "body"
      .on "mouseup touchend", ->
        currentDrag = null
        $( @ ).off "mousemove touchmove"

    _getPos = ( e )->
      if e.clientX?
        posX = e.clientX
        posY = e.clientY
      else
        posX = e.originalEvent.changedTouches[0].pageX
        posY = e.originalEvent.changedTouches[0].pageX

      x: posX
      y: posY

  submit: ->
    $( "#setPlot .submit" ).on "click", ( e )=>
      e.preventDefault()
      @dispatch "RESET_PLOT", @,
      $( "#setPlot .width" ).val(),
      $( "#setPlot .height" ).val()

  setOffset: ->
    @offset = []
    _length = $plotContainer.find( ".plot" ).size() - 1
    plotContainer_offset_x = $plotContainer.offset().left
    plotContainer_offset_y = $plotContainer.offset().top

    for i in [ 0.._length ]
      num = ( "00" + i ).slice -2
      @offset.push
        x: plotContainer_offset_x +
           parseFloat( $plotContainer.find( ".num#{ num }" ).css( "left" ) ) +
           def_translate
        y: plotContainer_offset_y +
           parseFloat( $plotContainer.find( ".num#{ num }" ).css( "top" ) ) +
           def_translate

getInstance = ->
  if !instance
    instance = new ClickHandler()
  return instance

module.exports = getInstance
