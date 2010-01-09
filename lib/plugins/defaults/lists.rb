# XXX: db plugin is required.
Termtter::Client.plug 'db'

module Termtter::Client
  register_command(
    :name => :lists,
    :exec => lambda {|arg|
      unless arg.empty?
        user_name = normalize_as_user_name(arg)
      else
        user_name = config.user_name
      end
      # TODO: show more information of lists
      puts Termtter::API.twitter.lists(user_name).lists.map{|i| i.full_name}
    }
    )

  register_command(
    :name => :follow_to_list,
    :exec => lambda { |arg|
      slug, *users = arg.split(' ')
      users.each{ |screen_name|
        begin
          Termtter::API.twitter.add_member_to_list(slug, User.find_or_fetch(:screen_name => screen_name).id)
          puts "#{slug} + #{screen_name}"
        rescue => e
          handle_error(e)
        end
      }
    },
    :help => ["follow_to_list SLUG USERNAME", "Follow users to the list"]
    )

  register_command(
    :name => :remove_from_list,
    :exec => lambda { |arg|
      slug, *users = arg.split(' ')
      users.each{ |screen_name|
        begin
          Termtter::API.twitter.remove_member_from_list(slug, User.find_or_fetch(:screen_name => screen_name).id)
          puts "#{slug} - #{screen_name}"
        rescue => e
          handle_error(e)
        end
      }
    },
    :help => ["remove_from_list SLUG USERNAME", "Remove user(s) from the list"]
    )

  register_command(
    :name => :create_list,
    :exec => lambda { |arg|
      slug, *options = arg.split(' ')
      param = { }

      OptionParser.new {|opt|
        opt.on('--description VALUE') {|v| param[:description] = v }
        opt.on('--private') {|v| param[:mode] = 'private' }
        opt.parse(options)
      }
      list = Termtter::API.twitter.create_list(slug, param).full_name
      p [list.full_name, param]
    },
    :help => ["create_list SLUG [--description VALUE] [--private]", "Create list"]
    )
end
