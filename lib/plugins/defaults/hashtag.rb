# -*- coding: utf-8 -*-
require 'set'

module Termtter::Client
  public_storage[:hashtags] ||= Set.new

  register_hook(:erb, :point => :modify_arg_for_update) do |cmd, arg|
    "#{arg} #{public_storage[:hashtags].to_a.join(' ')}"
  end

  register_command('hashtag add') do |args|
    args.split(/\s+/).each do |arg|
      hashtag = /^#/ =~ arg ? arg : "##{arg}"
      public_storage[:hashtags] << hashtag
    end
  end

  register_command('hashtag clear') do |args|
    public_storage[:hashtags].clear
  end
end
