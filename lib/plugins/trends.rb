# -*- coding: utf-8 -*-

require 'net/http'
require 'json'
require 'cgi'

Net::HTTP.version_1_2

module Termtter::Client
  SEARCH_URI = 'search.twitter.com'
  public_storage[:trends] = []

  register_command :trend do |arg|
    command, first, second = arg.split(/\s/)
    query = []
    if first
      if /\A\d{4}-\d{2}-\d{2}\z/ =~ first
        query << "date=#{first}"
        query << "exclude=#{second}" if second
      else
        query << "exclude=#{first}"
      end
    end
    case command
    when 'list', nil
      Net::HTTP.start(SEARCH_URI) do |http|
        res = http.get('/trends.json')
        show_trends JSON.parse(res.body)['trends']
      end
    when 'current'
      Net::HTTP.start(SEARCH_URI) do |http|
        query = "?#{query.join('&')}" unless query.size.zero?
        res = http.get("/trends/current.json#{query}")
        trends = JSON.parse(res.body)['trends']
        date = trends.keys.first
        puts "Trends: #{date}"
        show_trends trends[date]
      end
    when 'daily'
      Net::HTTP.start(SEARCH_URI) do |http|
        query = "?#{query.join('&')}" unless query.size.zero?
        res = http.get("/trends/daily.json#{query}")
        trends = JSON.parse(res.body)['trends']
        date = trends.keys.first
        puts "Trends: #{date}"
        show_trends trends[date]
      end
    when 'weekly'
      Net::HTTP.start(SEARCH_URI) do |http|
        query = "?#{query.join('&')}" unless query.size.zero?
        res = http.get("/trends/weekly.json#{query}")
        trends = JSON.parse(res.body)['trends']
        date = trends.keys.first
        puts "Trends: #{date}"
        show_trends trends[date]
      end
    when 'show'
      raise 'need number or word' if first.nil?
      word = public_storage[:trends][first.to_i] || first
      call_commands "search #{word}"
    when /^\d$/
      word = public_storage[:trends][command.to_i]
      raise 'no such trend' unless word
      call_commands "search #{word}"
    when 'open'
      raise 'nees number or word' if first.nil?
      word = public_storage[:trends][first.to_i] || first
      `open http://search.twitter.com/search?q=#{CGI.escape(word)}`
    else
      raise 'no such command'
    end
  end

  private
  def self.show_trends(trends)
    public_storage[:trends].clear
    max = trends.size.to_s.size
    trends.each_with_index do |trend, idx|
      public_storage[:trends] << trend['name']
      puts "#{idx.to_s.rjust(max)}: #{trend['name']}"
    end
  end
end

