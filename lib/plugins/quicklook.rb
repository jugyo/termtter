# -*- coding: utf-8 -*-

require 'uri'
require 'open-uri'
require 'pathname'
require 'tmpdir'

config.plugins.quicklook.set_default(:quicklook_tmpdir, "#{Dir.tmpdir}/termtter-quicklook-tmpdir")
tmpdir = Pathname.new(config.plugins.quicklook.quicklook_tmpdir)
tmpdir.mkdir unless tmpdir.exist?

def quicklook(url)
  tmpdir = Pathname.new(config.plugins.quicklook.quicklook_tmpdir)
  path   = tmpdir + Pathname.new(url).basename

  Thread.new do
    open(path, 'w') do |f|
      f.write(open(url).read)
    end
    system("qlmanage -p #{path} > /dev/null 2>&1")
  end
end

module Termtter::Client
  register_command(
    :name => :quicklook, :aliases => [:ql],
    :exec_proc => proc{|arg|
      status = Termtter::API.twitter.show(arg)
      if (status)
        uris = URI.regexp.match(status.text).to_a
        quicklook(uris.first) unless uris.empty?
      end
    }
  )
end

# quicklook.rb
# REQUIREMENTS:
#   t.plug 'expand_url'
# TODO:
#   Close quicklook window automatically.
