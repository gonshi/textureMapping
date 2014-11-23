$ = require "jquery"

effect = {}
output = {}

#  GRAY SCALE
effect.grayScale = ( img, width, height )->
  if output.grayScale?
    return output.grayScale.toDataURL()

  output.grayScale = makeCanvas( width, height )
  context = output.grayScale.getContext "2d"
  context.drawImage( img, 0, 0, width, height )

  imgData = context.getImageData 0, 0, width, height
  pixelData = imgData.data
  for y in [ 0..height - 1 ]
    for x in [ 0..width - 1 ]
      i = ( y * 4 * width ) + x * 4
      red = pixelData[ i ]
      green = pixelData[ i + 1 ]
      blue = pixelData[ i + 2 ]
      output_pixel = red * 0.3 + green * 0.59 + blue * 0.11
      pixelData[ i ] = output_pixel
      pixelData[ i + 1 ] = output_pixel
      pixelData[ i + 2 ] = output_pixel
  context.putImageData imgData, 0, 0
  output.grayScale.toDataURL()

# MOSAIC
effect.mosaic = ( img, width, height )->
  if output.mosaic?
    return output.mosaic.toDataURL()

  output.mosaic = makeCanvas( width, height )
  context = output.mosaic.getContext "2d"
  context.drawImage( img, 0, 0, width, height )

  whole_imgData = context.getImageData 0, 0, width, height
  whole_pixelData = whole_imgData.data

  mosaic_block_num = 25
  mosaic_width = width / mosaic_block_num
  mosaic_height = height / mosaic_block_num
  for block_y in [ 0..mosaic_block_num - 1 ]
    for block_x in [ 0..mosaic_block_num - 1 ]
      imgData = context.getImageData block_x * mosaic_width,
                                     block_y * mosaic_height,
                                     mosaic_width, mosaic_height
      pixelData = imgData.data
      red = green = blue = alpha = 0
      # input
      for y in [ 0..mosaic_height - 1 ]
        for x in [ 0..mosaic_width - 1 ]
          i = ( y * 4 * mosaic_width ) + x * 4
          red += pixelData[ i ]
          green += pixelData[ i + 1 ]
          blue += pixelData[ i + 2 ]
          alpha += pixelData[ i + 3 ]

      pixel_num = mosaic_width * mosaic_height
      average_red = red / pixel_num
      average_green = green / pixel_num
      average_blue = blue / pixel_num
      average_alpha = alpha / pixel_num

      # output
      offset = block_y * mosaic_height * width * 4 +
               block_x * mosaic_width * 4
      for y in [ 0..mosaic_height ]
        for x in [ 0..mosaic_width ]
          i = ( y * 4 * width ) + x * 4
          whole_pixelData[ offset + i ] = average_red
          whole_pixelData[ offset + i + 1 ] = average_green
          whole_pixelData[ offset + i + 2 ] = average_blue
          whole_pixelData[ offset + i + 3 ] = average_alpha

  context.putImageData whole_imgData, 0, 0
  output.mosaic.toDataURL()

# BLUR
effect.blur = ( img, width, height )->
  if output.blur?
    return output.blur.toDataURL()

  output.blur = makeCanvas( width, height )
  context = output.blur.getContext "2d"
  context.drawImage( img, 0, 0, width, height )

  imgData = context.getImageData 0, 0, width, height
  pixelData = imgData.data

  rgba = [ "red", "green", "blue", "alpha" ]
  rgba_length = rgba.length

  conv_r = 4 # amount of convolution pixel around the target
  conv_total = Math.pow( conv_r * 2 + 1, 2 )

  for y in [ 0..height - 1 ]
    for x in [ 0..width - 1 ]

      pixel = ( y * 4 * width ) + x * 4

      for param in [ 0..rgba_length - 1 ]
        conv_sum = 0

        for conv_y in [ -conv_r..conv_r ]
          for conv_x in [ -conv_r..conv_r ]
            if pixelData[ pixel + ( conv_y * 4 * width ) + conv_x * 4 ]?
              conv_sum += pixelData[ pixel +
                                     ( conv_y * 4 * width ) +
                                     conv_x * 4 + param ]
        pixelData[ pixel + param ] = conv_sum / conv_total

  context.putImageData imgData, 0, 0
  output.blur.toDataURL()

makeCanvas = ( width, height )->
  canvas = $( "<canvas>" ).get( 0 )
  canvas.width = width
  canvas.height = height
  canvas

module.exports = effect
