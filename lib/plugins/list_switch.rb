module Termtter
  module Client
    register_command('list switch',
      :help => ["list switch LISTNAME", "Switch to the list"]
    ) do |arg|
      ListSwitch.list_switch(arg)
    end

    # TODO: コマンド名が微妙
    register_command('list restore',
      :help => ["list restore LISTNAME", "Restore to switch list "]
    ) do |arg|
      ListSwitch.restore
    end

    module ListSwitch
      extend self

      attr_reader :active

      def list_switch(full_name)
        @active = true
        list_name, list_user_name = split_list_name(full_name)
        # TODO: list 用に　Termtter::API.twitter　のメソッドを置き換える（RubytterProxy#call_rubytter をフックすればいけそう）
        #   :home_timeline => :list_statuses
        #   :follow => :add_member_to_list
        #   :leave => :remove_member_from_list
        # TODO: プロンプトを変更する
      end

      def restore
        @active = false
        # TODO: list 用に置き換えたメソッドをもとに戻す
        # TODO: プロンプトをもとに戻す
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
