class String
  def char_at(n)
    self[n] and self[n].chr
  end
end

module SketchUpJSON
  SyntaxError = Class.new(StandardError)

  class Parser
    ESCAPEE = {
      '"' => '"',
      '\\' => '\\',
      '/' => '/',
      'b' => "\b",
      'f' => "\f",
      'n' => "\n",
      't' => "\t",
      'r' => "\r",
    }.freeze

    def initialize(json_string)
      @at, @ch = 0, nil
      @openned_brackets = 0
      @openned_square_brackets = 0
      @openned_quotes = 0
      @text = json_string
    end

    def parse
      value
    end

   private

    def value
      white
      case @ch
        when '{'
          return object
        when '['
          return array
        when '"'
          return string
        when '-', '+', /\d/
          return number
        else
          return word
      end
      raise SyntaxError.new "Invalid syntax. Index #{@at}"
    end

    def object
      obj = {}

      if @ch == '{'
        update_delimiter_counter! @ch
        next_char '{'
        white

        if @ch == '}'
          update_delimiter_counter! @ch
          next_char '}'
          return obj
        end

        while @ch
          key = string
          white
          next_char ':'
          obj[key] = value
          white
          
          if @ch == '}'
            update_delimiter_counter! @ch
            next_char '}'
            return obj
          end

          next_char ','
          white
        end
      end

      raise SyntaxError.new "Bad object"      
    end

    def array
      arr = []

      if @ch == '['
        next_char '['
        white

        if @ch == ']'
          next_char ']'
          return arr
        end
        
        while @ch
          arr.push(value)
          white

          if @ch == ']'
            next_char ']'
            return arr
          end

          next_char ','
          white
        end
      end

      raise SyntaxError.new "Bad array"
    end
    
    def string
      str = ''
      
      if @ch == '"'
        while next_char
          if @ch == '"'
            next_char
            return str

          elsif @ch == '\\'
            next_char
            
            if @ch == 'u'
              uffff = 0
              4.times do
                hex = next_char.to_i(16)
                break unless hex.is_a? Numeric
                uffff = uffff * 16 + hex
              end
              
              str += uffff.chr
            elsif ESCAPEE[@ch]
              str += ESCAPEE[@ch]
            else
              break
            end
          else
            str += @ch
          end
        end
      end

      raise SyntaxError.new "Bad string"
    end

    def number
      string = ''

      if @ch == '-'
        string = '-'
        next_char '-'
      end
      
      while decimal?(@ch)
        string += @ch
        next_char
      end

      if @ch == '.'
        string += '.'

        while next_char && decimal?(@ch)
          string += @ch
        end
      end

      if @ch == 'e' || @ch == 'E'
        string += @ch
        next_char

        if @ch == '-' || @ch == '+'
          string += @ch
          next_char
        end
        
        while decimal?(@ch)
          string += @ch
          next_char
        end
      end

      raise SyntaxError.new "Bad number" unless number?(string)
      string.send convertion_method(string)
    end 

    def word
      proc = Proc.new { |l| next_char l }
      case @ch
        when 't'
          %w(t r u e).map &proc
          return true
        when 'f'
          %w(f a l s e).map &proc
          return false
        when 'n'
          %w(n u l l).map &proc
          return nil
      end
      raise SyntaxError.new "Unexpected #{@ch}"
    end

    def next_char(c = nil)
      ensure_ended_chars!
      if c && c != @ch
        raise SyntaxError.new "Expected #{c} instead of #{@ch}"
      else
        @ch = @text.char_at(@at)
        @at += 1
        @ch
      end
    end

    def convertion_method(str)
      str.index('.') || str.index('e') || str.index('E') ? :to_f : :to_i
    end

    def number?(str)
      str.match /[-]?([1-9]|(0\.))[0-9]*[eE]?[+-]?[0-9]*/ 
    end

    def decimal?(n)
      n && n.match(/\d/)
    end

    def white
      next_char while @ch.nil? || @ch.strip.empty?
    end

    def ensure_ended_chars!
      if @at == @text.size
        counters = [@openned_brackets, @openned_square_brackets, @openned_quotes]
        counters.map do |counter|
          raise SyntaxError unless counter.zero?
        end
      end
    end

    def update_delimiter_counter!(char)
      case char
        when '{'
          @openned_brackets += 1
        when '}'
          @openned_brackets -= 1
        when '['
          @openned_square_brackets +=1
        when ']'
          @openned_square_brackets -=1
      end
    end
  end
end
