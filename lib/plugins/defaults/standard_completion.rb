# -*- coding: utf-8 -*-

require 'set'

module Termtter::Client

  #
  # completion for status ids
  # (I want to delete)
  #

  public_storage[:status_ids] ||= Set.new

  register_hook(:collect_status_ids, :point => :pre_filter) do |statuses, event|
    statuses.each do |s|
      public_storage[:status_ids].add(s.id)
      public_storage[:status_ids].add(s.in_reply_to_status_id) if s.in_reply_to_status_id
    end
  end

  #
  # completion for user names
  #

  public_storage[:users] ||= Set.new

  register_hook(:collect_user_names, :point => :pre_filter) do |statuses, event|
    statuses.each do |s|
      public_storage[:users].add(s.user.screen_name)
      public_storage[:users] += s.text.scan(/@([a-zA-Z_0-9]*)/i).flatten
    end
  end

  register_hook(:user_names_completion, :point => :completion) do |input|
    if /(.*)@([^\s]*)$/ =~ input
      command_str = $1
      part_of_user_name = $2

      users = 
        if part_of_user_name.nil? || part_of_user_name.empty?
          public_storage[:users].to_a
        else
          public_storage[:users].grep(/^#{Regexp.quote(part_of_user_name)}/i)
        end

      users.map {|u| "#{command_str}@%s" % u }
    end
  end

  #
  # completion for hashtags
  #

  public_storage[:hashtag] ||= Set.new

  register_hook(:collect_hashtags, :point => :pre_filter) do |statuses, event|
    statuses.each do |s|
      public_storage[:hashtag] += s.text.scan(/#([^\s]+)/).flatten
    end
  end

  register_hook(:hashtags_completion, :point => :completion) do |input|
    if /(.*)#([^\s]*)$/ =~ input
      command_str = $1
      part_of_hashtag = $2
      public_storage[:hashtag].grep(/^#{Regexp.quote(part_of_hashtag)}/i).map { |i| "#{command_str}##{i}" }
    end
  end
end
