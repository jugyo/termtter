# -*- coding: utf-8 -*-
require 'set'

module Termtter::Client
  public_storage[:hashtags] ||= Set.new
  public_storage[:orig_prompt] = config.prompt

  register_hook(:add_hashtags, :point => :modify_arg_for_update) do |cmd, arg|
    "#{arg} #{public_storage[:hashtags].to_a.join(' ')}"
  end

  register_command(:raw_update) do |args|
    temp = public_storage[:hashtags].dup
    public_storage[:hashtags].clear
    execute "update #{args}"
    public_storage[:hashtags] = temp
  end

  register_command('hashtag add') do |args|
    args.split(/\s+/).each do |arg|
      hashtag = /^#/ =~ arg ? arg : "##{arg}"
      public_storage[:hashtags] << hashtag
      config.prompt = "#{public_storage[:hashtags].to_a.join(', ')} #{public_storage[:orig_prompt]}"
    end
  end

  register_command('hashtag clear') do |args|
    public_storage[:hashtags].clear
    config.prompt = public_storage[:orig_prompt]
  end

  register_command('hashtag list') do |args|
    puts public_storage[:hashtags].to_a
  end
end
