# -*- coding: utf-8 -*-
require 'uri'
require 'open-uri'
require 'nokogiri'
require 'timeout'
require 'digest/sha1'

module Termtter::Client
  config.plugins.appendtitle.set_default(:timeout, 30)
  config.plugins.appendtitle.set_default(:cache_expire, 3600 * 24 * 7)

  def self.fetch_title(uri)
    return unless uri
    key = %w{ plugins appendtitle title}.push(Digest::SHA1.hexdigest(uri)).join('-')
    if v = memory_cache.get(key)
      logger.debug "appendtitle: cache hit for #{uri}"
      return v
    end

    memory_cache.set(key, '', config.plugins.appendtitle.cache_expire) # to avoid duplicate fetch
    begin
      logger.debug "appendtitle: fetching title for #{uri}"
      source = Nokogiri(open(uri).read)
      if source and source.at('title')
        title = source.at('title').text
        memory_cache.set(key, title, config.plugins.appendtitle.cache_expire)
        return title
      end
      nil
     rescue Timeout::Error, StandardError
      nil
    end
  end

  register_hook(
    :name => :appendtitle,
    :point => :filter_for_output,
    :exec_proc => lambda do |statuses, event|
      threads = statuses.map do |status|
        Thread.new{
          begin
          status.text.gsub!(URI.regexp(['http', 'https'])) {|uri|
            title = fetch_title(uri)
            title = title.gsub(/\n/, '').gsub(/\s+/, ' ') if title
            body_for_compare = status.text.gsub(/\n/, '').gsub(/\s+/, ' ')
            if title and not (
                body_for_compare.include? title or
                body_for_compare.include? title[0..(title.length/2)] or
                body_for_compare.include? title[(title.length/2)..-1]) # XXX: heuristic!!!
              "#{uri} (#{title})"
            else
              uri
            end
            }
          rescue
          end
        }
      end
      begin
        # wait for join or timeout
        timeout(config.plugins.appendtitle.timeout) {
          threads.each{ |t| t.join }
        }
      rescue Timeout::Error
        logger.error 'appendtitle: timeout'
      end

      statuses
    end
    )
end

# appendtitle.rb:
# append title for uri.
