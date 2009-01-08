if RUBY_VERSION < "1.8.7"
  class Array
    def choice
      at(rand(size))
    end
  end
end

# based on new-harizon.rb
module Yharian

  VOICES = 
    %w(Agnes Albert Bad\ News Bahh Bells Boing Bruce Bubbles Cellos Deranged Fred Hysterical Junior Kathy Pipe\ Organ Princess Ralph Trinoids Vicki Victoria Whisper Zarvox)
  

  class Speaker
    attr_reader :name
    def initialize(name)
      @name = name
    end
    
    def talk(context)
      n = 7
      words = (0..rand(n)).map { %w[y hara].choice }.
        inject {|r, e| r + (rand < 0.97 ? ' ' : ', ') + e }
      eos = %w(? ? . . . . . . . . !).choice
      [Remark.new(self,words, eos)]
    end

    def voice(context = nil)
      @name
    end

  end


  class Alex < Speaker
    def initialize
      super 'Alex'
    end
  end

  class Vicki < Speaker
    def initialize
      super 'Vicki'
    end
  end
  
  class Yhara < Speaker
    def initialize
      super 'yhara'
    end

    def voice(context = nil)
      VOICES.choise
    end
  end

  class Jenifer < Speaker
    ARABIAN = %w[ايران نيست]

    def initialize
      super 'jenifer'
    end
    
    def talk(context)
      words = (0..rand(3)). map { ARABIAN.choice }.join(' ')
      [Remark.new(self,words, '')]
    end

    def voice(context = nil)
      'Princess'
    end
  end
  
  class Remark
    attr_reader :speaker, :words, :eos, :pronounciation
    
    def initialize(speaker, words, eos, options = {})
      @speaker = speaker
      @words = words
      @eos = eos # end of text : "?" or "." or "!"
      @pronounciation = options[:pronounciation] || text
    end
    
    def text
      @words + @eos
    end
    
    def interrogative?
      @eos == '?'
    end
    
    def display
      puts "#{@speaker.name}: #{text}"
    end
    
    def say(context = nil)
      Kernel.say pronounciation, :voice => @speaker.voice(context)
    end
    
    def correct?(s)
      s.gsub(/[^yhar]/,'') == @words.gsub(/[^yhar]/,'')
    end
  end

  @@context = []
  @@speakers = [Alex.new, Vicki.new]

  def self.text
    if ( @@context.last && Yhara === @@context.last.speaker && rand < 0.25 ) || rand < 0.01
      speaker = Jenifer.new
    elsif @@context.last && @@context.last.words =~ /y hara/ and @@context.last.interrogative? and rand < 0.25
      speaker = Yhara.new
    else
      speaker = @@speakers[rand(2)]
    end

    remark = speaker.talk(@@context).first
    @@context.push remark
    remark.text
  end
end

module Termtter::Client

  add_help 'yhara', 'Post a new Yharian sentence'
  
  add_command /^(yhara|y)\s*/ do |m, t|
    text = Yharian::text
    unless text.empty?
      t.update_status(text)
      puts "=> #{text}"
    end
  end
end

# yhara.rb
#   post a new yharian sentence
# example:
#   > yhara
#   => hara y y hara.
