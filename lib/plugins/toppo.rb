# coding: utf-8

module Termtter::Client
  register_command(:toppo) do |msg|
    msg = msg[0..-2] if /。\z/ =~ msg
    text = "#{msg}。その点トッポってすげぇよな、最後までチョコたっぷりだもん。"
    Termtter::API.twitter.update(text)
    puts "=> " << text
  end
end

