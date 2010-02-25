# -*- coding: utf-8 -*-

module Termtter
  module Client
    register_command('list switch',
      :help => ["list switch LISTNAME", "Switch to the list"]
    ) do |arg|
      @since_id = nil
      Termtter::Plugins::ListSwitch.list_switch(arg)
    end

    # TODO: コマンド名が微妙...
    register_command('list switch restore',
      :help => ["list switch restore LISTNAME", "Restore to switch list "]
    ) do |arg|
      Termtter::Plugins::ListSwitch.restore
    end
  end

  class RubytterProxy
    alias_method :call_rubytter_without_list_switch, :call_rubytter
    def call_rubytter_with_list_switch(method, *args, &block)
      Termtter::Plugins::ListSwitch.call_rubytter(self, method, *args, &block)
    end
    alias_method :call_rubytter, :call_rubytter_with_list_switch
  end

  module Plugins
    module ListSwitch
      extend self

      attr_reader :active, :list_name, :list_user_name, :list_user_id

      def call_rubytter(rubytter_proxy, method, *args, &block)
        if active
          case method
          when :home_timeline
            # => list_statuses(user_name, slug, options)
            method, args = :list_statuses, [list_user_name, list_name, *args]
          when :follow
            # => add_member_to_list(slug, user.id)
            method, args = :add_member_to_list, [list_name, *args]
          when :leave
            # => remove_member_from_list(slug, user.id)
            method, args = :remove_member_from_list, [list_name, *args]
          end
        end
        rubytter_proxy.call_rubytter_without_list_switch(method, *args, &block)
      end

      def list_switch(full_name)
        @active = true
        @list_user_name, @list_name = split_list_name(full_name)
        user = Termtter::API.twitter.cached_user(list_user_name) ||
                  Termtter::API.twitter.user(list_user_name)
        @list_user_id = user.id
        # TODO: やっつけなのでちゃんとやる
        config.prompt = full_name + '> '
      end

      def restore
        @active = false
        # TODO: やっつけなのでちゃんとやる
        config.prompt = '> '
      end

      def split_list_name(list_name)
        if /([^\/]+)\/([^\/]+)/ =~ list_name
          [Termtter::Client.normalize_as_user_name($1), $2]
        else
          [config.user_name, $2]
        end
      end
    end
  end
end
