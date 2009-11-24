# -*- coding: utf-8 -*-

require 'rubygems'
require 'nokogiri'
require 'open-uri'

module Termtter::Client

  class << self
    def output_favorites(target)
      url = "http://favotter.matope.com/user.php?user=#{target}"
      parse(url).reverse.each do |text, amount, users|
        puts TermColor.parse("#{fav_color(amount.rjust(10))} <YELLOW>#{users.join(', ')}</YELLOW>:「#{text}」")
      end
    end

    private
    def parse(url)
      doc = Nokogiri(open(url).read)
      doc.css('div.entry').map do |entry|
        text   = entry.css('span.status_text').first.content
        amount = entry.css('div.info span.favotters').first.content
        users  = entry.css('div.info span.favotters img').map {|u| u['title'] }
        [text, amount, users]
      end
    end

    def fav_color(amount)
      num = amount.match(/(\d)/)[1].to_i
      return amount if num == 1
      color = case num
        when 2 then 'GREEN'
        when 3 then 'BLUE'
        when 4 then 'BLUE'
        else        'RED'
      end
      "<#{color}>#{amount}</#{color}>"
    end
  end

  help = ['favotter [USERNAME]', 'Show info from favotter']
  register_command('favotter', :help => help) do |args|
    target = args.empty? ? config.user_name : args
    if /@(.*)/ =~ target
      target = $1
    end
    output_favorites target
  end
end
