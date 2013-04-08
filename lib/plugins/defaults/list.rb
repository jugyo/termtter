module Termtter::Client
  public_storage[:lists] = []

  register_hook(:fetch_my_lists, :point => :launched) do
    begin
      public_storage[:lists] +=
        Termtter::API.twitter.lists(:screen_name => config.user_name).map(&:full_name)
    rescue TimeoutError
      # do nothing
    rescue Exception => e
      Termtter::Client.handle_error(e)
    end
  end

  register_command(
    :name => :list, :aliases => [:l],
    :exec_proc => lambda {|arg|
      a = {}
      if /\-([\d]+)/ =~ arg
        options = {:count => $1}
        arg = arg.gsub(/\-([\d]+)/, '')
      else
        options = {}
      end

      options[:include_rts] = 1
      options[:include_entities] = 1

      last_error = nil
      if arg.empty?
        event = :list_friends_timeline
        statuses = Termtter::API.twitter.home_timeline(options)
        a[:type] = :home_timeline
      else
        event = :list_user_timeline
        statuses = []
        Array(arg.split).each do |user|
          if user =~ /\/\w+/
            user_name, slug = *user.split('/')
            a[:type] = :list
            user_name = config.user_name if user_name.empty?
            user_name = normalize_as_user_name(user_name)
            a[:list_user] = user_name
            a[:list_slug] = slug
            options[:per_page] = options[:count]
            options.delete(:count)
            statuses += Termtter::API.twitter.list_statuses({:owner_screen_name => user_name, :slug => slug}.merge(options))
          else
            begin
              if user =~ /^\d+$/
                profile = Termtter::API.twitter.user(nil, :screen_name => user) rescue nil
                unless profile
                  status  = Termtter::API.twitter.show(user) rescue nil
                  user    = status.user.screen_name if status
                end
              end
              user_name = normalize_as_user_name(user.sub(/\/$/, ''))
              a[:type] = :user
              a[:user_name] = user_name
              statuses += Termtter::API.twitter.user_timeline({:screen_name => user_name}.merge(options))
            rescue Rubytter::APIError => e
              last_error = e
            end
          end
        end
      end
      a[:type] = :multiple if arg.split.length > 1
      output(statuses, Termtter::Event.new(event, a))
      raise last_error if last_error
    },
    :help => ["list,l [USERNAME]/[SLUG] [-COUNT]", "List the posts"]
  )

  register_command(
    :name => 'list list',
    :exec => lambda {|arg|
      unless arg.empty?
        user_name = normalize_as_user_name(arg)
      else
        user_name = config.user_name
      end
      # TODO: show more information of lists
      lists = Termtter::API.twitter.lists(user_name).lists
      public_storage[:lists] += lists.map(&:full_name)
      puts lists.map{|i| i.full_name}.join("\n")
    },
    :help => ["list list [USERNAME]", "Show Lists"]
  )

  register_command(
    :name => %s{list follow},
    :alias => %s{list add},
    :exec => lambda { |arg|
      list_name, *users = arg.split(' ')
      slug = list_name_to_slug(list_name)
      users.each{ |screen_name|
        begin
          user = Termtter::API.twitter.cached_user(screen_name) || Termtter::API.twitter.user(screen_name)
          Termtter::API.twitter.add_member_to_list(:owner_screen_name => config.user_name, :slug => slug, :user_id => user.id)
          puts "#{slug} + #{screen_name}"
        rescue => e
          handle_error(e)
        end
      }
    },
    :help => ["list follow|add LISTNAME USERNAME", "Follow users to the list"]
    )

  register_command(
    :name => %s{list remove},
    :exec => lambda { |arg|
      list_name, *users = arg.split(' ')
      slug = list_name_to_slug(list_name)
      users.each{ |screen_name|
        begin
          user = Termtter::API.twitter.cached_user(screen_name) || Termtter::API.twitter.user(screen_name)
          Termtter::API.twitter.remove_member_from_list(:owner_screen_name => config.user_name, :slug => slug, :user_id => user.id)
          puts "#{slug} - #{screen_name}"
        rescue => e
          handle_error(e)
        end
      }
    },
    :help => ["list remove LISTNAME USERNAME", "Remove user(s) from the list"]
    )

  register_command(
    :name => %s{list create},
    :exec => lambda { |arg|
      slug, *options = arg.split(' ')
      param = { }

      OptionParser.new {|opt|
        opt.on('--description VALUE') {|v| param[:description] = v }
        opt.on('--private') {|v| param[:mode] = 'private' }
        opt.parse(options)
      }
      list = Termtter::API.twitter.create_list({:name => slug}.merge(param))
      public_storage[:lists] << list.full_name
      p [list.full_name, param]
    },
    :help => ["list create SLUG [--description VALUE] [--private]", "Create list"]
    )

  register_command(
    :name => %s{list delete},
    :exec => lambda { |arg|
      return unless confirm("Are you sure?")
      arg.split(' ').each{ |list_name|
        begin
          slug = list_name_to_slug(list_name)
          list = Termtter::API.twitter.delete_list(:owner_screen_name => config.user_name, :slug => slug)
          public_storage[:lists].delete(list.full_name)
          puts "#{list.full_name} deleted"
        rescue => e
          handle_error(e)
        end
      }
    },
    :help => ["list delete LISTNAME", "Delete list"]
  )

  register_command(
    :name => %s{list show},
    :exec => lambda { |arg|
      raise ArgumentError unless /([^\s]*\/[^\s]+)/ =~ arg
      user_name, slug = *arg.split('/')
      user_name = config.user_name if user_name.empty?
      user_name = normalize_as_user_name(user_name)
      list = Termtter::API.twitter.list(:owner_screen_name => user_name, :slug => slug)
      attrs = %w[ full_name slug description mode id member_count subscriber_count]
      label_width = attrs.map(&:size).max
      attrs.each do |attr|
        value = list.__send__(attr.to_sym)
        puts "#{attr.gsub('_', ' ').rjust(label_width)}: #{value}"
      end
    },
    :help => ["list show LISTNAME", "Show the detail of list"]
  )

  def self.list_name_to_slug(list_name)
    list_name[/([^\/]*)$/]
  end
end
