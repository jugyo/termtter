# -*- coding: utf-8 -*-
#
# This plugin resolve inputed domain name or IP address, like this following:
# 
#   > whois www.google.com
#   => 66.249.89.147
#   > whois 65.74.177.129
#   => github.com
#
# Just same dig command:p

require 'resolv'

module Termtter::Client
  register_command(
    :name => :whois,
    :exec_proc => lambda {|name|
      revaled = whois? name
      Termtter::API.twitter.update(revaled)
    }
  )  
end

def whois?(arg)
  if addr? arg 
    begin
      Resolv.getname(arg)
    rescue => e
      e.message
    end
  else
    begin
      Resolv.getaddress(arg)
    rescue => e
      e.message
    end
  end
end

def addr?(arg)
  Resolv::AddressRegex =~ arg
end

# vim: textwidth=78
