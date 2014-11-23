###
0----1
|    |
|    |
3----2
* origin_x: plotcontainer x
* origin_y: plotcontainer y
###

class TextureManager
  constructor: ( obj )->
    plot_max = 3
    @p_def = []
    @p_cur = []
    @p_offset = {} #compared to the left-top
    for i in [ 0..plot_max ]
      @p_def[ i ] = {}
      @p_cur[ i ] = {}
      @p_def[ i ].x = @p_cur[ i ].x =
        obj[ "x_#{i}" ]
      @p_def[ i ].y = @p_cur[ i ].y =
        obj[ "y_#{i}" ]

    @p_offset.x = obj.x_0 - obj.origin_x
    @p_offset.y = obj.y_0 - obj.origin_y
    @context = obj.context
    @img = obj.img
    @size_x = obj.size_x
    @size_y = obj.size_y

  drawImage: ->
    _draw = ( segment )=>
      drawOffset = 0
      drawOrigin = 0
      if segment == "left"
        plotArr = [ 0, 1, 3 ]
      else if segment == "right"
        plotArr = [ 2, 3, 1 ]
        drawOffset = -1 * ( @p_def[ 3 ].y - @p_def[ 0 ].y )
        drawOrigin = 3
      @context.save()
      @context.beginPath()
      @context.moveTo @p_cur[ plotArr[ 0 ] ].x,
                      @p_cur[ plotArr[ 0 ] ].y
      @context.lineTo @p_cur[ plotArr[ 1 ] ].x,
                      @p_cur[ plotArr[ 1 ] ].y
      @context.lineTo @p_cur[ plotArr[ 2 ] ].x,
                      @p_cur[ plotArr[ 2 ] ].y
      @context.closePath()
      @context.clip()
      @context.setTransform(
        ( @p_cur[ plotArr[ 1 ] ].x - @p_cur[ plotArr[ 0 ] ].x ) /
        ( @p_def[ plotArr[ 1 ] ].x - @p_def[ plotArr[ 0 ] ].x ),
        ( @p_cur[ plotArr[ 1 ] ].y - @p_cur[ plotArr[ 0 ] ].y ) /
        ( @p_def[ plotArr[ 1 ] ].x - @p_def[ plotArr[ 0 ] ].x ),
        ( @p_cur[ plotArr[ 2 ] ].x - @p_cur[ plotArr[ 0 ] ].x ) /
        ( @p_def[ plotArr[ 2 ] ].y - @p_def[ plotArr[ 0 ] ].y ),
        ( @p_cur[ plotArr[ 2 ] ].y - @p_cur[ plotArr[ 0 ] ].y ) /
        ( @p_def[ plotArr[ 2 ] ].y - @p_def[ plotArr[ 0 ] ].y ),
        @p_cur[ drawOrigin ].x, @p_cur[ drawOrigin ].y )
      @context.drawImage @img,
        -1 * @p_offset.x,
        -1 * @p_offset.y + drawOffset,
        @size_x, @size_y
      @context.restore()

    _draw( "left" )
    _draw( "right" )

  setCurrent: ( plot, diff )->
    @p_cur[ plot ].x = @p_def[ plot ].x + diff.x
    @p_cur[ plot ].y = @p_def[ plot ].y + diff.y

  ###
  For resize Handler.
  Because the plot might be already moved since second time.
  the value of x and y would be different from the default value.
  ###
  setOffset: ( obj )->
    @p_def[ 0 ].x = obj.x
    @p_def[ 1 ].x = obj.x + obj.width_interval
    @p_def[ 2 ].x = obj.x + obj.width_interval
    @p_def[ 3 ].x = obj.x
    @p_def[ 0 ].y = obj.y
    @p_def[ 1 ].y = obj.y
    @p_def[ 2 ].y = obj.y + obj.height_interval
    @p_def[ 3 ].y = obj.y + obj.height_interval

    @p_offset.x = obj.x - obj.origin_x
    @p_offset.y = obj.y - obj.origin_y

  setImg: ( img )->
    @img = img

module.exports = TextureManager
