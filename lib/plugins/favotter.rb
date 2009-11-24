# -*- coding: utf-8 -*-

require 'rubygems'
require 'nokogiri'
require 'open-uri'

module Termtter::Client

  public_storage[:favorited_ids] = {}

  class << self
    def output_favorites(target, threshold)
      url = "http://favotter.matope.com/user.php?user=#{target}&threshold=#{threshold}"
      public_storage[:favorited_ids].clear
      alphabet = '$a'
      parse(url).reverse.each do |id, text, amount, users|
        public_storage[:favorited_ids][alphabet] = id
        color = fav_color(amount)
        fav = "fav#{amount == 1 ? '' : 's'}".rjust(4)
        format = "#{alphabet}<GREEN>%s #{fav} by</GREEN> <YELLOW>%s</YELLOW>: <#{color}>%s</#{color}>"
        values = [amount.to_s.rjust(3), users.join(', '), CGI.escape(text)]
        puts CGI.unescape(TermColor.parse(format % values ))
        alphabet.succ!
      end
    end

    private
    def parse(url)
      doc = Nokogiri(open(url).read)
      doc.css('div.entry').map do |entry|
        id     = entry['id'].gsub(/\Astatus_/, '')
        text   = entry.css('span.status_text').first.content
        amount = entry.css('div.info span.favotters').first.content
        amount = amount.match(/(\d+)/)[1].to_i
        users  = entry.css('div.info span.favotters img').map {|u| u['title'] }
        [id, text, amount, users]
      end
    end

    def fav_color(amount)
      case amount
        when 1 then 'WHITE'
        when 2 then 'GREEN'
        when 3 then 'BLUE'
        when 4 then 'BLUE'
        else        'RED'
      end
    end
  end

  help = ['favotter [USERNAME] [THRESHOLD]', 'Show info from favotter']
  register_command('favotter', :help => help) do |arg|
    target = if arg.empty?
       config.user_name
     else
       args = arg.split
       threshold = args.size == 1 ? 1 : args[1]
       args[0]
    end
    if /@(.*)/ =~ target
      target = $1
    end
    output_favorites target, threshold
  end

  help = ['favotter_fav [FavoritedID]', 'Favorite favorited status']
  register_command('favotter_fav', :alias => :ffav, :help => help) do |arg|
    raise 'need favorited_id' if arg.empty?
    if id = public_storage[:favorited_ids][arg]
      call_commands("favorite #{id}")
    end
  end
end

