###!
main function
###
$ = require "jquery"
Ticker = require "./util/ticker"
ClickHandler = require "./controller/clickHandler"
ResizeHandler = require "./controller/resizeHandler"
CanvasManager = require "./view/canvasManager"
TextureManager = require "./view/textureManager"
effect = require "./view/effect"

# main
$ ->
  ticker        = Ticker()
  clickHandler  = ClickHandler()
  resizeHandler = ResizeHandler()
  canvasManager = CanvasManager()
  ua_lower = window.navigator.userAgent.toLowerCase()
  texture = []
  canvas_img= new Image()
  canvas_img.src = "http://jsrun.it/assets/w/s/V/H/wsVHu.png"

  $plotContainer = $( "#plot_container" )
  plotContainer_width = $plotContainer.width()
  plotContainer_height = $plotContainer.height()
  plot_width_size = parseInt( $( "#setting .setPlot .width" ).val() )
  plot_height_size = parseInt( $( "#setting .setPlot .height" ).val() )

  width_interval = 0
  height_interval = 0
  wrapper_width = 0
  wrapper_height = 0
  def_translate = 0

  numExp = /.*?num(.*?)$/

  if !window._DEBUG?
    window._DEBUG = state: false
  if Object.freeze?
    window.DEBUG = Object.freeze window._DEBUG
  else
    window.DEBUG = window._DEBUG

  if ua_lower.match( /iphone|ipod|ipad|android/ )
    $( "body" ).addClass "sp"

  # EVENT LISTENER
  resizeHandler.listen "RESIZED", ->
    canvasManager.resetContext ( wrapper_width = $( "#wrapper").width() ),
                               ( wrapper_height = $( "#wrapper" ).height() )
    _setTexture()
    # set texture offset
    texture_max = texture.length - 1
    plotContainer_offset_x = $plotContainer.offset().left
    plotContainer_offset_y = $plotContainer.offset().top
    for i in [ 0..texture_max ]
      _plot_num = parseInt( i / ( plot_width_size - 1 ) ) *
                  plot_width_size + i % ( plot_width_size - 1 )
      plot_num = ( "00" + _plot_num ).slice -2
      texture[ i ].setOffset
        x: plotContainer_offset_x +
            parseFloat( $plotContainer.find( ".num#{ plot_num }" ).
            css( "left" ) )
        y: plotContainer_offset_y +
            parseFloat( $plotContainer.find( ".num#{ plot_num }" ).
            css( "top" ) )
        width_interval: width_interval
        height_interval: height_interval
        origin_x: $plotContainer.offset().left
        origin_y: $plotContainer.offset().top
    clickHandler.setPlotOffset()

  ticker.listen ()->
    _draw()

  clickHandler.listen "MOVE_PLOT", ( diff_x, diff_y )->
    _class_num = parseInt $( @ ).attr( "class" ).match( numExp )[ 1 ]
    texture_num = parseInt( _class_num / plot_width_size ) *
                  ( plot_width_size - 1 ) +
                  ( _class_num % plot_width_size )

    is_left = is_right = is_bottom = is_bottom = false

    $( @ ).css
      transform: "translate(#{ diff_x + def_translate }px," +
                 "#{ diff_y + def_translate }px )"

    if parseInt( _class_num ) % plot_width_size != 0
      is_right = true
    if ( parseInt( _class_num ) + 1 ) % plot_width_size != 0
      is_left = true
    if _class_num < plot_width_size * ( plot_height_size - 1 )
      is_top = true
    if _class_num >= plot_width_size
      is_bottom = true

    if is_left && is_top
      texture[ texture_num ].setCurrent 0,
        x: diff_x
        y: diff_y
    if is_left && is_bottom
      texture[ texture_num - ( plot_width_size - 1 ) ].setCurrent 3,
        x: diff_x
        y: diff_y
    if is_right && is_top
      texture[ texture_num - 1 ].setCurrent 1,
        x: diff_x
        y: diff_y
    if is_right && is_bottom
      texture[ texture_num - plot_width_size ].setCurrent 2,
        x: diff_x
        y: diff_y

  clickHandler.listen "RESET_PLOT", ( width, height )->
    if width * height >= 11 * 10
      alert "値が大きすぎます."
      return undefined
    plot_width_size = parseInt( width )
    plot_height_size = parseInt( height )
    _init()
    clickHandler.setPlotOffset()

  clickHandler.listen "SET_EFFECT", ( effect_type )->
    if effect_type == "grayScale"
      canvas_img.src = effect.grayScale canvas_img,
                                        plotContainer_width,
                                        plotContainer_height
    else if effect_type == "mosaic"
      canvas_img.src = effect.mosaic canvas_img,
                                     plotContainer_width,
                                     plotContainer_height

    texture_max = texture.length - 1
    for i in [ 0..texture_max ]
      texture[ i ].setImg canvas_img

  # PRIVATE
  _draw = ()->
    texture_num = 0
    canvasManager.clear wrapper_width, wrapper_height
    length = plot_width_size * ( plot_height_size - 1 ) - 1
    for i in [ 0..length ]
      if ( i + 1 ) % plot_width_size != 0 # not the rightest plot
        texture[ texture_num ].drawImage()
        texture_num += 1

  _putPlot = ()->
    $( "#plot_container .plot" ).remove()
    width_interval = plotContainer_width / ( plot_width_size - 1 )
    height_interval = plotContainer_height / ( plot_height_size - 1 )
    for i in [ 0..( plot_height_size - 1 ) ]
      for j in [ 0..( plot_width_size - 1 ) ]
        plot_num = ( "0" + ( i * plot_width_size + j ) ).slice( -2 )
        $( "<p>" ).addClass( "plot num#{ plot_num }" )
          .css
            top: parseInt( plot_num / plot_width_size ) * height_interval
            left: plot_num % plot_width_size * width_interval
          .appendTo "#plot_container"

  _setTexture = ()->
    texture = []
    plot_max = plot_width_size * ( plot_height_size - 1 ) - 1
    for i in [ 0..plot_max ]
      if ( i + 1 ) % plot_width_size != 0 # not the rightest plot
        texture.push new TextureManager
          x_0: $( ".plot" ).eq( i ).offset().left - def_translate
          x_1: $( ".plot" ).eq( i + 1 ).offset().left - def_translate
          x_2: $( ".plot" ).eq( i + plot_width_size + 1 ).
               offset().left - def_translate
          x_3: $( ".plot" ).eq( i + plot_width_size ).
               offset().left - def_translate
          y_0: $( ".plot" ).eq( i ).offset().top - def_translate
          y_1: $( ".plot" ).eq( i + 1 ).offset().top - def_translate
          y_2: $( ".plot" ).eq( i + plot_width_size + 1 ).
               offset().top - def_translate
          y_3: $( ".plot" ).eq( i + plot_width_size ).
               offset().top - def_translate
          origin_x: $plotContainer.offset().left
          origin_y: $plotContainer.offset().top
          context: canvasManager.getContext()
          img: canvas_img
          size_x: $plotContainer.width()
          size_y: $plotContainer.height()

  _init = ()->
    _putPlot()
    def_translate = parseInt( $( "#plot_container .plot" ).css( "transform" ).
                    split( "," )[ 5 ] )
    _setTexture()

  # INIT
  if window.DEBUG.state
    canvas_img.src = "img/common/jsdoit.png"

  canvasManager.resetContext wrapper_width = $( "#wrapper").width(),
                             wrapper_height = $( "#wrapper" ).height()
  _init()
  clickHandler.plot()
  clickHandler.resetPlot()
  clickHandler.setEffect()
  resizeHandler.exec()
