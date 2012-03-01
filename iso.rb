require 'gosu'
require './game_object'
require './tile'
require './map'
require './gui'

ImageExt = "png"
TileExt = "png"

ScreenWidth = 640
ScreenHeight = 480

MapWidth = 12
MapHeight = 12
MapTileWidth = 32
MapTileHeight = 16
MapTileFullHeight = MapTileHeight + (MapTileHeight / 2)

# OffsetX = (ScreenWidth / 2) - MapWidth * (MapTileWidth / 2)
# OffsetY = (ScreenHeight / 2) - 8

class FPS
  def initialize(game, x, y)
    @game = game
    @label = TextLabel.new(game, x, y, "FPS", 
                           :fgcolor => Gosu::Color::WHITE)
    @counter = 0
    @fps = 0
    @last_time = 0
  end
  
  def update
    @counter += 1
    if @game.time >= @last_time + 1000
      @fps = @counter
      @label.text = "FPS: #{@fps}"
      @counter = 0
      @last_time = @game.time
    end
  end
  
  def draw
    @label.draw
  end
end

class Game < Gosu::Window
  attr_reader :map, :tiles, :time, :fonts, :keys_down, :key_down_times

  def initialize
    super(ScreenWidth, ScreenHeight, false, 1)
    self.caption = "Iso"
    load_fonts "fonts"
    load_tiles("tiles/terrain", MapTileWidth, MapTileFullHeight)
    @map = Map.new(self, MapWidth, MapHeight)
    @time = 0
    @keys_down = []
    @key_down_times = Hash.new(0)
    @cursor = Gosu::Image.new(self, "images/cursor.#{ImageExt}")
    @fps = FPS.new(self, 10, 10)
    @fields = [TextField.new(self, 50, 50, 100),
               TextField.new(self, 50, 80, 100),
               TextField.new(self, 50, 200, 200),
               TextField.new(self, 220, 120, 78)]
  end

  def load_fonts(dir)
    # TODO: load ttf fonts from font directory
    @fonts = Hash.new
    @fonts["default"] = Gosu::Font.new(self, Gosu::default_font_name, 20)
  end
  
  def load_tiles(dir, tile_width, tile_height)
    @tiles = Hash.new
    files = Dir.new(dir).entries
    files.sort!
    files.delete(".")
    files.delete("..")
    files.each do |file|
      name = File.basename(file, ".#{TileExt}")
      @tiles[name.hash] = Tile.new(self, File.join(dir, file), 
                                   tile_width, tile_height)
    end
  end

  def update
    @time = Gosu::milliseconds
    @keys_down.each { |key| @key_down_times[key] += 1 }
    @fps.update
    @fields.each { |field| field.update }
  end

  def draw
    @map.draw
    @fields.each { |field| field.draw }
    @fps.draw
    @cursor.draw mouse_x, mouse_y, 0
  end

  def button_down(id)
    @key_down_times[id] = 0
    @keys_down.push id
  end

  def button_up(id)
    @key_down_times[id] = 0
    @keys_down.delete id
  end
end


game = Game.new
game.show
