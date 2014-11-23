$ = require "jquery"

effect = {}
output = {}

effect.grayScale = ( img, width, height )->
  if output.grayScale?
    return output.grayScale.toDataURL()

  output.grayScale = $( "<canvas>" ).get( 0 )
  output.grayScale.width = width
  output.grayScale.height = height

  context = output.grayScale.getContext "2d"
  context.drawImage( img, 0, 0, width, height )

  imgData = context.getImageData 0, 0, width, height
  pixelData = imgData.data
  for y in [ 0..height ]
    for x in [ 0..width ]
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

module.exports = effect
