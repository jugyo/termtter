# -*- coding: utf-8 -*-
require 'g'

module Termtter::Client
  public_storage[:hashtags] = []

  register_hook(:erb, :point => :modify_arg_for_update) do |cmd, arg|
    "#{arg} #{public_storage[:hashtags].join(' ')}"
  end

  register_command('hashtag add') do |args|
    args.split(/\s+/).each do |arg|
      hashtag = /^#/ =~ arg ? arg : "##{arg}"
      public_storage[:hashtags] << hashtag
    end
  end
end
