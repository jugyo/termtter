# coding: utf-8

module Termtter::Client
  register_command(:toppo) do |arg|
    text = "#{arg}。その点トッポってすげぇよな、最後までチョコたっぷりだもん。"
    Termtter::API.twitter.update(text)
    puts "=> " << text
  end
end
