# -*- coding: utf-8 -*-

Termtter::API.module_eval %Q{
  class << self
    attr_reader :wassr

    def setup_wassr(user_name, password)
      @wassr = create_wassr(user_name, password)
    end

    def create_wassr(user_name, password)
      Rubytter.new(
        user_name,
        password,
        {
          :app_name => config.app_name.empty? ? Termtter::APP_NAME : config.app_name,
          :host => 'api.wassr.jp',
          :header => {
            'User-Agent' => 'Termtter http://github.com/jugyo/termtter',
            'X-Wassr-Client' => 'Termtter',
            'X-Wassr-Client-URL' => 'http://github.com/jugyo/termtter',
            'X-Wassr-Client-Version' => Termtter::VERSION
          },
          :enable_ssl => config.enable_ssl,
          :proxy_host => config.proxy.host,
          :proxy_port => config.proxy.port,
          :proxy_user_name => config.proxy.user_name,
          :proxy_password => config.proxy.password
        }
        )
    end
  end
}

module Termtter::Client
  register_command(
    :name => :wassr, :aliases => [:wsr],
    :exec_proc => lambda {|arg|
      Termtter::API.setup_wassr(config.plugins.wassr.username, config.plugins.wassr.password)
      statuses = Termtter::API.wassr.friends_timeline
      add_member = [:created_at, :in_reply_to_status_id]
      event = :wassr_friends_timeline
      print_statuses(statuses, event)
    },
    :completion_proc => lambda {|cmd, arg|
      find_user_candidates arg, "#{cmd} %s"
    },
    :help => ["wassr, wsr", "List the wassr timeline."]
  )
end

def print_statuses(statuses, sort = true, time_format = nil)
  return unless statuses and statuses.first
  unless time_format
    t0 = Time.now
    t1 = Time.at(statuses.first[:epoch])
    t2 = Time.at(statuses.last[:epoch])
    time_format =
      if [t0.year, t0.month, t0.day] == [t1.year, t1.month, t1.day] \
        and [t1.year, t1.month, t1.day] == [t2.year, t2.month, t2.day]
        '%H:%M:%S'
      else
        '%y/%m/%d %H:%M'
      end
  end

  output_text = ''

  user_login_ids = []
  statuses.sort{|a, b| a.epoch <=> b.epoch}.each do |s|
    text = s.text
    user_login_ids << s.user_login_id unless user_login_ids.include?(s.user_login_id)
    status_color = config.plugins.stdout.colors[user_login_ids.index(s.user_login_id) % config.plugins.stdout.colors.size]
    status = "#{s.user.screen_name}: #{TermColor.escape(text)}"

    time = "[wassr] [#{Time.at(s.epoch).strftime(time_format)}]"
    id = s.id
    source =
      case s.source
      when />(.*?)</ then $1
      when 'web' then 'web'
      end

    erbed_text = ERB.new('<90><%=time%></90> <<%=status_color%>><%=status%></<%=status_color%>>').result(binding)
    output_text << TermColor.parse(erbed_text) + "\n"
  end

  if config.plugins.stdout.enable_pager && ENV['LINES'] && statuses.size > ENV['LINES'].to_i
    file = Tempfile.new('termtter')
    file.print output_text
    file.close
    system "#{config.plugins.stdout.pager} #{file.path}"
    file.close(true)
  else
    print output_text
  end
end
