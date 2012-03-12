require './game_object'

class GUIObject < GameObject
  include KeyListener
  include MouseListener
  
  attr_reader :x, :y, :width, :height

  def initialize(game, x, y, width = 0, height = 0)
    super(game)
    @x = x
    @y = y
    @width = width
    @height = height
    @hot = false
    @@active ||= nil
  end
  
  def mouse_within?
    x = mouse_x
    y = mouse_y
    x >= @x && x <= @x + @width && y >= @y && y <= @y + @height
  end

  def update
    if mouse_within?
      @hot = true
      if @@active.nil? && left_mouse_down?
        @@active = self
        puts @@active
      end
    else
      @hot = false
    end
  end
end

class TextLabel < GUIObject
  include TextDrawable
  
  attr_accessor :fgcolor, :text
  attr_reader :font
  
  def initialize(game, x, y, text, params = {})
    super(game, x, y)
    @text = text
    @font = params[:font] || "default"
    @fgcolor = params[:fgcolor] || Gosu::Color::BLACK
    @width = @game.fonts[@font].text_width(@text)
    @height = @game.fonts[@font].height
  end
  
  def update
    super
    @width = @game.fonts[@font].text_width(@text)
  end
end

class TextField < GUIObject
  include TextEditable
  
  attr_accessor :text, :font, :fgcolor, :bgcolor
   
  def initialize(game, x, y, width, params = {})
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
  include Clickable

  attr_accessor :bgcolor
  attr_reader :clicked

  def initialize(game, x, y, width, height, params = {})
    super(game, x, y, width, height)
    @bgcolor = params[:bgcolor] || Gosu::Color::BLUE
  end

  def draw
    @game.draw_quad(@x, @y, @bgcolor, 
                    @x+@width, @y, @bgcolor,
                    @x, @y+@height, @bgcolor,
                    @x+@width, @y+@height, @bgcolor)
  end
end

class ImageButton < Button
  def initialize(game, x, y, image_url, params = {})
    image = Gosu::Image.new(game, image_url, false)
    super(game, x, y, image.width, image.height)
    @image = image
    hover_url = params[:hover] || nil
    @hover_image = nil
    @hover_image = Gosu::Image.new(game, hover_url, false) if hover_url
    click_url = params[:click] || nil
    @click_image = nil
    @click_image = Gosu::Image.new(game, click_url, false) if click_url
  end

  def draw
    if @left_was_down_inside and !@click_image.nil?
      @click_image.draw(@x, @y, 1)
    elsif @hovering and !@hover_image.nil?
      @hover_image.draw(@x, @y, 1)
    else
      @image.draw(@x, @y, 1)
    end
  end
end

class TextButton < Button
  LeftMargin = 5
  TopMargin = 5

  def initialize(game, x, y, text, params = {})
    font = params[:font] || "default"
    width = params[:width] || game.fonts[font].text_width(text) + 2*LeftMargin
    height = params[:height] || game.fonts[font].height + 2*TopMargin
    bgcolor = params[:bgcolor] || Gosu::Color::WHITE
    super(game, x, y, width, height, :bgcolor => bgcolor)
    @font = font
    @text = text
    @fgcolor = params[:fgcolor] || Gosu::Color::BLACK
  end

  def draw
    super
    @game.fonts[@font].draw(@text, @x+LeftMargin, @y+TopMargin, 1, 1, 1, @fgcolor)
  end
end
