# -*- coding: utf-8 -*-
require 'uri'
require 'open-uri'
require 'nokogiri'
require 'timeout'
require 'digest/sha1'

module Termtter::Client
  config.plugins.appendtitle.set_default(:timeout, 30)
  config.plugins.appendtitle.set_default(:cache_expire, 3600 * 24 * 7)

  def self.fetch_title_data(uri) # returns {:title, :uri} | {:uri} | nil
    return unless uri
    key = %w{ plugins appendtitle title-data}.push(Digest::SHA1.hexdigest(uri)).join('-')
    if v = memory_cache.get(key)
      logger.debug "appendtitle: cache hit for #{uri}"
      return v
    end

    memory_cache.set(key, {}, config.plugins.appendtitle.cache_expire) # to avoid duplicate fetch
    logger.debug "appendtitle: fetching title for #{uri}"
    data = {}
    uri_fetch = uri
    begin
      io = URI.parse(uri_fetch).read
      base_uri = io.base_uri.to_s
      base_uri = uri_fetch if base_uri.length > 1000
      data[:uri] = base_uri
      begin # title
        source = Nokogiri(io)
        title = source.at('title').text rescue nil
        title ||= source.at('h1').text rescue nil
        title ||= source.at('h2').text rescue nil
        title.gsub(/\n/, '').gsub(/\s+/, ' ') if title
        data[:title] = title if title
      rescue
      end
      memory_cache.set(key, data, config.plugins.appendtitle.cache_expire)
      data
    rescue RuntimeError => error
      # example: redirection forbidden: http://bit.ly/gSarwN -> https://github.com/jugyo/termtter/commit/6e5fa4455a5117fb6c10bdf82bae52cfcf57a91f
      if error.message =~ /^redirection forbidden/
        logger.debug "appendtitle: #{error.message}"
        uri_fetch = error.message.split(/\s+/).last
        retry
      end
    rescue Timeout::Error, StandardError => error
      logger.debug "appendtitle: error #{uri}, #{error.class.to_s}: #{error.message}"
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
            status.text.gsub!(URI.regexp(['http', 'https'])) {|uri_before|
            data  = fetch_title_data(uri_before) || {}
            title = data[:title]
            body_for_compare = status.text.gsub(/\n/, '').gsub(/\s+/, ' ')
            uri_after = data[:uri] || uri_before
            if title and not (
                body_for_compare.include? title or
                body_for_compare.include? title[0..(title.length/2)] or
                body_for_compare.include? title[(title.length/2)..-1]) # XXX: heuristic!!!
              "#{uri_after} (#{title})"
            else
              uri_after
            end
            }
          rescue => error
            logger.debug "appendtitle: [ERROR] #{error.class.to_s}: #{error.message}"
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
# append title for uri and expand short uri.
