require 'gosu'

class Tile
  attr_reader :width, :height, :animated, :frames

  def initialize(game, filename, tile_width, tile_height)
    @width = tile_width
    @height = tile_height
    puts "Loading #{filename}"
    image = Gosu::Image.new(game, filename, false)
    tiles_wide = image.width / tile_width
    tiles_high = image.height / tile_height
    tiles = Gosu::Image.load_tiles(game, filename, 
                                   tile_width, tile_height, false)
    @image = Array.new(tiles_high) { Array.new(tiles_wide) }
    tiles.each_index do |i|
      @image[i / tiles_wide][i % tiles_wide] = tiles[i]
    end
    @frames = tiles_wide
    @animated = (@frames > 1)
  end

  def draw(x, y, version, frame = 0)
    @image[version][frame].draw(x, y, 0)
  end
end
