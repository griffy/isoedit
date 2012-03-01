require './game_object'
require './components'

class MapObject < GameObject
  include TileDrawable
  include Collidable

  def initialize(game, x, y, name, version = 0)
    super(game)
    @name = name
    @version = version
    @x = x
    @y = y
  end
end

class Map
  attr_reader :width, :height
  
  def initialize(game, width, height)
    @width = width
    @height = height
    @objects = Array.new(width) { Array.new(height) }
    0.upto(width-1) do |i|
      (height-1).downto(0) do |j|
        @objects[i][j] = MapObject.new(game, i, j, "dirt")
      end
    end
  end
  
  def draw
    0.upto(@width-1) do |i|
      (@height-1).downto(0) do |j|
        @objects[i][j].draw
      end
    end
  end
end
