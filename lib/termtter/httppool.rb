# -*- coding: utf-8 -*-
require 'net/http'

module Termtter
  module HTTPpool
    @@connections = {}

    def self.start(host, port = 80)
      begin
        yield(connection(host, port))
      rescue EOFError
        finish(host, port)
        retry
      end
    end

    def self.connection(host, port = 80)
      key = connection_key(host, port)
      @@connections[key] ||= http_class.start(host, port)
    end

    def self.finish(host, port = 80)
      key = connection_key(host, port)
      @@connections[key] && @@connections[key].do_finish rescue nil
      @@connections.delete(key)
    end

    def self.connection_key(host, port)
      port == 80 ? host : [host, port.to_s].join(':')
    end

    def self.http_class
      if config.proxy.host.nil? or config.proxy.host.empty?
        Net::HTTP
      else
        Net::HTTP::Proxy(config.proxy.host,
                         config.proxy.port,
                         config.proxy.user_name,
                         config.proxy.password)
      end
    end

  end
end
