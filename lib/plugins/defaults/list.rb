module Termtter::Client
  public_storage[:lists] = []

  register_hook(:fetch_my_lists, :point => :launched) do
    begin
      public_storage[:lists] +=
        Termtter::API.twitter.lists(config.user_name).lists.map(&:full_name)
    rescue TimeoutError
      # do nothing
    rescue Exception => e
      Termtter::Client.handle_error(e)
    end
  end

  register_command(
    :name => :list, :aliases => [:l],
    :exec_proc => lambda {|arg|
      if arg =~ /\-([\d]+)/
        options = {:count => $1}
        arg = arg.gsub(/\-([\d]+)/, '')
      else
        options = {}
      end

      if arg.empty?
        event = :list_friends_timeline
        statuses = Termtter::API.twitter.home_timeline(options)
      else
        event = :list_user_timeline
        statuses = []
        Array(arg.split).each do |user|
          if user =~ /\/\w+/
            user_name, slug = *user.split('/')
            user_name = config.user_name if user_name.empty?
            user_name = normalize_as_user_name(user_name)
            statuses += Termtter::API.twitter.list_statuses(user_name, slug, options)
          else
            user_name = normalize_as_user_name(user.sub(/\/$/, ''))
            statuses += Termtter::API.twitter.user_timeline(user_name, options)
          end
        end
      end
      output(statuses, event)
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
    :help => ["lists [USERNAME]", "Show Lists"]
  )

  register_command(
    :name => %s{list follow},
    :exec => lambda { |arg|
      slug, *users = arg.split(' ')
      users.each{ |screen_name|
        begin
          user = Termtter::API.twitter.cached_user(screen_name) || Termtter::API.twitter.user(screen_name)
          Termtter::API.twitter.add_member_to_list(slug, user.id)
          puts "#{slug} + #{screen_name}"
        rescue => e
          handle_error(e)
        end
      }
    },
    :help => ["list follow SLUG USERNAME", "Follow users to the list"]
    )

  register_command(
    :name => %s{list remove},
    :exec => lambda { |arg|
      slug, *users = arg.split(' ')
      users.each{ |screen_name|
        begin
          user = Termtter::API.twitter.cached_user(screen_name) || Termtter::API.twitter.user(screen_name)
          Termtter::API.twitter.remove_member_from_list(slug, user.id)
          puts "#{slug} - #{screen_name}"
        rescue => e
          handle_error(e)
        end
      }
    },
    :help => ["list remove SLUG USERNAME", "Remove user(s) from the list"]
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
      list = Termtter::API.twitter.create_list(slug, param)
      p [list.full_name, param]
    },
    :help => ["list create SLUG [--description VALUE] [--private]", "Create list"]
    )

  register_command(
    :name => %s{list delete},
    :exec => lambda { |arg|
      arg.split(' ').each{ |slug|
        begin
          list = Termtter::API.twitter.delete_list(slug)
          puts "#{list.full_name} deleted"
        rescue => e
          handle_error(e)
        end
      }
    },
    :help => ["list delete SLUG", "Delete list"]
    )
end
