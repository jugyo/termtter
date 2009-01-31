# -*- coding: utf-8 -*-

require 'uri'

require 'open-uri'

require 'pathname'

require 'tmpdir'



configatron.plugins.quicklook.set_default(:quicklook_tmpdir, "#{Dir.tmpdir}/termtter-quicklook-tmpdir")

tmpdir = Pathname.new(configatron.plugins.quicklook.quicklook_tmpdir)

tmpdir.mkdir unless tmpdir.exist?



def quicklook(url)

  tmpdir = Pathname.new(configatron.plugins.quicklook.quicklook_tmpdir)

  path   = tmpdir + Pathname.new(url).basename



  Thread.new do

    open(path, 'w') do |f|

      f.write(open(url).read)

    end

    system("qlmanage -p #{path} > /dev/null 2>&1")

  end

end



module Termtter::Client

  add_command %r'^(?:quicklook|ql)\s+(\w+)$' do |m,t|

    id = m[1]

    status = t.show(id).first



    if (status)

      uris = URI.regexp.match(status.text).to_a

      quicklook(uris.first) unless uris.empty?

    end

  end

end



# quicklook.rb

# TODO:

#   Close quicklook window automatically.
