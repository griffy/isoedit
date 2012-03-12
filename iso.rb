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
    @fields = [TextField.new(self, 150, 50, 100, 
                             :fgcolor => Gosu::Color::GREEN,
                             :bgcolor => Gosu::Color::WHITE),
               TextField.new(self, 150, 100, 100,
                             :fgcolor => Gosu::Color::RED,
                             :bgcolor => Gosu::Color::WHITE),
               TextField.new(self, 150, 150, 200,
                             :fgcolor => Gosu::Color::BLACK,
                             :bgcolor => Gosu::Color::GREEN),
               TextField.new(self, 150, 200, 78)]
    @buttons = [Button.new(self, 10, 50, 50, 20),
                TextButton.new(self, 10, 100, "Click Me"),
                ImageButton.new(self, 10, 150, "images/buttons/button1up.png",
                                :hover => "images/buttons/button1hover.png",
                                :click => "images/buttons/button1down.png")]
    @gui_objects = []
    @gui_objects.concat @buttons
    @gui_objects.concat @fields
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
    @gui_objects.each { |obj| obj.update }
    if @gui_objects[0].clicked
      if @gui_objects[3].text.empty?
        @gui_objects[3].text = "Clicked!"
      else
        @gui_objects[3].text = ""
      end
    end
    @fps.update
  end

  def draw
    @map.draw
    @gui_objects.each { |obj| obj.draw }
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
