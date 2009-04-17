# -*- coding: utf-8 -*-

require 'rubygems'
require 'atomutil'
require 'nokogiri'

module Termtter::Client
  register_command(
    :name => :hatebu_and_update, :aliases => [:hau],
    :exec_proc => lambda {|arg|
      url, comment = arg.split(/\s/)
      if url =~ URI.regexp
        auth = auth = Atompub::Auth::Wsse.new({
            :username => config.plugins.hatebu.username,
            :password => config.plugins.hatebu.password,
        })
        link = Atom::Link.new({
            :href => url,
            :rel => 'related',
            :type => 'text/html',
        })
        entry = Atom::Entry.new({
            :link => link,
            :title => 'dummy',
            :summary => comment,
        })
        req = Net::HTTP::Post.new 'http://b.hatena.ne.jp/atom/post'
        req['User-Agent'] = 'Mozilla/5.0'
        req['Content-Type'] = 'application/atom+xml'
        req['Slug'] = 'termtter'
        req.body = entry.to_s
        auth.authorize(req)
        title = nil
        tinyurl = nil
        Termtter::API.connection.start('b.hatena.ne.jp', 80) do |http|
          res = http.request(req)
          title = Nokogiri::XML(res.body).search('link[title]').first['title'] rescue nil
        end
        if title
          Termtter::API.connection.start('tinyurl.com', 80) do |http|
            tinyurl = http.get('/api-create.php?url=' + URI.escape(url)).body
          end

          Termtter::API.twitter.update("[はてぶ] #{title} #{tinyurl}")
        end
      end
    },
    :help => ['hatebu2 URL', 'Hatena bookmark a URL, and update']
    )
end

# hatebu.rb
# hatena bookmark it, and post
#
# config.plugins.hatebu.username = 'your-username-on-hatena'
# config.plugins.hatebu.password = 'your-password-on-hatena'
#
#   hatebu_and_update http://www.yahoo.co.jp/ [yahoo]
