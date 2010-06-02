# -*- coding: utf-8 -*-
require 'nkf'
require 'MeCab'
require 'open-uri'

module HatenaKeywordHaiku
  class Word
    @@mecab = MeCab::Tagger.new("-Oyomi")

    def initialize(word, yomi = nil)
      raise 'word is nil' unless word and not word.empty?
      @word = word
      @yomi = yomi
    end

    def word
      @word
    end

    def yomi
      @yomi ||= @@mecab.parse(word)
    end

    def length
      @length ||= self.yomi.gsub(/\n|ぁ|ぃ|ぅ|ぇ|ぉ|ァ|ィ|ゥ|ェ|ォ|ゃ|ゅ|ょ|ャ|ュ|ョ/, '').split(//).length
    end
  end

  @@words = nil

  def self.generate(*args)
    args  = [5,7,5] if args.empty?

    args.map{ |len|
      words[len.to_i].choice rescue raise "No word which length is #{len}"
    }.map{ |w| w.word }.join(' ')
  end

  # http://d.hatena.ne.jp/hatenadiary/20060922/1158908401
  def self.setup(csv_path = '/tmp/keywordlist_furigana.csv', csv_url = 'http://d.hatena.ne.jp/images/keyword/keywordlist_furigana.csv')
    return if @@words
    @@words = { }
    csv_path = File.expand_path(csv_path)
    unless File.exists? csv_path
      puts "haiku: downloading CSV"
      open(csv_path, 'w'){ |f|
        f.write(open(csv_url).read)
      }
    end


    puts "haiku: parsing CSV"
    open(csv_path).each_line{ |line|
      yomi, word = *NKF.nkf('-w', line.chomp).split(/\t/)
      w = Word.new(word, yomi)
      @@words[w.length] = [] unless @@words.has_key? w.length
      @@words[w.length].push w
    }
    puts "haiku: setup done"
    @@words
  end

  def self.words
    setup unless @@words
    @@words
  end
end

Thread.new{
  HatenaKeywordHaiku.setup('~/.termtter/keywordlist_furigana.csv')
}
Termtter::Client.register_command(
  :name => :hatena_keyword_haiku,
  :aliases => [:haiku],
  :author => 'hitode909',
  :exec_proc => lambda {|arg|
    args = arg.split(/\s+/)

    name = ''
    if args.first and not args.first =~ /^\d+$/
      name = Termtter::Client.normalize_as_user_name(args.shift)
      command = "u @#{name} #{HatenaKeywordHaiku.generate(*args)}"
    else
      command = "u #{HatenaKeywordHaiku.generate(*args)}"
    end

    Termtter::Client.execute command
  },
  :help => ['haiku [(Optinal) USER] [(Optional) 5 7 5 7 7]', 'Post a Haiku']
)
