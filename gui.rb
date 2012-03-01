require './game_object'

class GUIObject < GameObject
  include KeyListener
  include MouseListener
  
  def initialize(game, x, y, width = 0, height = 0)
    super(game)
    @x = x
    @y = y
    @width = width
    @height = height
  end
  
  def mouse_within?
    x = mouse_x
    y = mouse_y
    x >= @x && x <= @x + @width && y >= @y && y <= @y + @height
  end
end

class TextLabel < GUIObject
  include TextDrawable
  
  attr_accessor :fgcolor, :text
  attr_reader :font
  
  def initialize(game, x, y, text, params={})
    super(game, x, y)
    @text = text
    @font = params[:font] || "default"
    @fgcolor = params[:fgcolor] || Gosu::Color::BLACK
    @width = @game.fonts[@font].text_width(@text)
    @height = @game.fonts[@font].height
  end
  
  def update
    @width = @game.fonts[@font].text_width(@text)
  end
end

class TextField < GUIObject
  include TextEditable
  
  attr_accessor :text, :font, :fgcolor, :bgcolor
   
  def initialize(game, x, y, width, params={})
    super(game, x, y, width)
    @text = params[:text] || ""
    @font = params[:font] || "default"
    @fgcolor = params[:fgcolor] || Gosu::Color::BLACK
    @bgcolor = params[:bgcolor] || Gosu::Color::WHITE
    @height = @game.fonts[@font].height
    @caret_pos = @text.length
    @caret = Gosu::Image.new(game, "images/caret.#{ImageExt}")
  end
  
  def draw
    @game.draw_quad(@x, @y, @bgcolor, 
                    @x+@width, @y, @bgcolor,
                    @x, @y+@height, @bgcolor,
                    @x+@width, @y+@height, @bgcolor)
    super
  end
end

class TextArea < GUIObject
end

class Button < GUIObject
end

class ImageButton < Button
end

class TextButton < Button
end
