# -*- coding: utf-8 -*-

require 'rubygems'
require 'atomutil'

module Termtter::Client
  register_command(
    :name => :hatebu, :aliases => [],
    :exec_proc => lambda {|arg|
      if arg =~ /^(\d+)(.*)$/
        id = $1.strip
        comment = $2.strip
        statuses = public_storage[:log].select { |s| s.id == id }
        unless statuses.empty?
          status = statuses.first
        else
          status = t.show(id).first
        end
        auth = auth = Atompub::Auth::Wsse.new({
            :username => config.plugins.hatebu.username,
            :password => config.plugins.hatebu.password,
        })
        link = Atom::Link.new({
           :href => "http://twitter.com/#{status.user.screen_name}/status/#{status.id}",
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
        Net::HTTP.start('b.hatena.ne.jp', 80) do |http|
          res = http.request(req)
        end
      end
    },
    :completion_proc => lambda {|cmd, args|
      if args =~ /^(\d*)$/
        find_status_id_candidates $1, "#{cmd} %s"
      end
    },
	:help => ['hatebu ID', 'Hatena bookmark a status']
  )
end

# hatebu.rb
# hatena bookmark it!
#
# config.plugins.hatebu.username = 'your-username-on-hatena'
# config.plugins.hatebu.password = 'your-password-on-hatena'
#
#   hatebu 1114860346 [termtter][<82>±<82>ê<82>Í<82>·<82>²<82>¢]mattn++
