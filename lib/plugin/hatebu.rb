require 'rubygems'
require 'atomutil'

module Termtter::Client
  add_help 'hatebu ID', 'Hatena bookmark a status'

  add_command %r'^hatebu\s+(\d+)(.*)$' do |m, t|
    id = m[1]
    comment = m[2].strip
    statuses = public_storage[:log].select { |s| s.id == id }
    unless statuses.empty?
      status = statuses.first
    else
      status = t.show(id).first
    end
    auth = auth = Atompub::Auth::Wsse.new({
        :username => configatron.plugins.hatebu.username,
        :password => configatron.plugins.hatebu.password,
    })
    link = Atom::Link.new({
       :href => "http://twitter.com/#{status.user_screen_name}/status/#{status.id}",
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

  add_completion do |input|
    %w(hatebu).grep(/^#{Regexp.quote input}/)
  end
end

# hatebu.rb
# hatena bookmark it!
#
# configatron.plugins.hatebu.username = 'your-username-on-hatena'
# configatron.plugins.hatebu.password = 'your-password-on-hatena'
#
#   hatebu 1114860346 [termtter][‚±‚ê‚Í‚·‚²‚¢]mattn++
