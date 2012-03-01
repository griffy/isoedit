module TileDrawable
  def draw
    @tile ||= @game.tiles[@name.hash]
    @tile_frame = @game.time / 300 % @tile.frames
    offset_x = (@game.width / 2) - (@game.map.width * (@tile.width / 2))
    offset_y = (@game.height / 2) - ((@tile.height-8) / 2)
    screen_x = (@y * @tile.width / 2) + (@x * @tile.width / 2) + offset_x
    screen_y = (@x * (@tile.height-8) / 2) - (@y * (@tile.height-8) / 2) + offset_y
    @tile.draw(screen_x, screen_y, @version, @tile_frame)
  end
end

module TextDrawable
  def draw
    @game.fonts[@font].draw(@text, @x, @y, 1)
  end
end

# TODO: rather than limit characters by width of box,
#       limit based on a max-characters attribute and
#       only draw what can be drawn
#
#       rate limit!
module TextEditable
  KEY_DELAY = 10 # frames a key can be held down before counting as two

  def text_width(text)
    @game.fonts[@font].text_width(text)
  end

  def update
    @key_delay ||= KEY_DELAY
    @height = @game.fonts[@font].height
    
    if left_mouse_down?
      if mouse_within?
        @focused = true
        
        rel_x = (mouse_x - @x).to_i
        @caret_pos = 0
        if @text.length > 1
          while text_width(@text[0..@caret_pos]) < rel_x
            if @caret_pos > @text.length
              @caret_pos = @text.length
              break
            end
            @caret_pos += 1 
          end
        end
      else
        @focused = false
      end
    end
    
    if key_down? && @focused
      key = key_down
      char = @game.button_id_to_char(key)
      if char.nil?
        case key
        when Gosu::KbBackspace
          if @caret_pos > 0
            @text.slice! @caret_pos-1
            @caret_pos -= 1
          end
        when Gosu::KbLeft
          if @caret_pos > 0
            @caret_pos -= 1
          end
        when Gosu::KbRight
          if @caret_pos < @text.length
            @caret_pos += 1
          end
        end
      else
        if text_width(@text) + text_width(char) <= @width
          @text.insert(@caret_pos, char)
          @caret_pos += 1
        end
      end
    end
  end
  
  def draw
    @game.fonts[@font].draw(@text, @x, @y, 1, 1, 1, @fgcolor)
    caret_x = @x + text_width(@text[0,@caret_pos])
    if @focused && @game.time % 1000 < 500
      @caret.draw(caret_x, @y, 1)
    end
  end
end

module Collidable
end

module MouseListener
  def mouse_x
    @game.mouse_x
  end
  
  def mouse_y
    @game.mouse_y
  end
  
  def left_mouse_down?
    @game.button_down? Gosu::MsLeft
  end
  
  def left_mouse_up?
  end
  
  def right_mouse_down?
    @game.button_down? Gosu::MsRight
  end
  
  def right_mouse_up?
  end
end

# TODO: key combos (ctrl-c, shift-1)
module KeyListener
  def key_down
    @game.keys_down[0] 
  end
  
  def key_up
    @game.key_up 
  end
  
  def key_down?
    key = key_down
    if !key.nil?
      down_time = @game.key_down_times[key]
      if down_time % @key_delay <= 1 || down_time <= 1
        return true
      end
    end
    false
  end
  
  def key_up?
    !@game.key_up.nil?
  end
end
