# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{termtter}
  s.version = "1.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["jugyo", "ujihisa"]
  s.date = %q{2009-08-10}
  s.description = %q{Termtter is a terminal based Twitter client.}
  s.email = %q{jugyo.org@gmail.com}
  s.executables = ["kill_termtter", "termtter"]
  s.extra_rdoc_files = ["README.rdoc", "ChangeLog"]
  s.files = ["Rakefile", "README.rdoc", "ChangeLog", "lib/plugins", "lib/plugins/addspace.rb", "lib/plugins/april_fool.rb", "lib/plugins/bomb.rb", "lib/plugins/clear.rb", "lib/plugins/command_plus.rb", "lib/plugins/confirm.rb", "lib/plugins/cool.rb", "lib/plugins/countter.rb", "lib/plugins/curry.rb", "lib/plugins/db.rb", "lib/plugins/defaults", "lib/plugins/defaults/auto_reload.rb", "lib/plugins/defaults/command_line.rb", "lib/plugins/defaults/exec.rb", "lib/plugins/defaults/fib.rb", "lib/plugins/defaults/retweet.rb", "lib/plugins/defaults/standard_commands.rb", "lib/plugins/defaults/standard_completion.rb", "lib/plugins/defaults/stdout.rb", "lib/plugins/defaults.rb", "lib/plugins/devel.rb", "lib/plugins/en2ja.rb", "lib/plugins/english.rb", "lib/plugins/erb.rb", "lib/plugins/exec_and_update.rb", "lib/plugins/expand-tinyurl.rb", "lib/plugins/fib_filter.rb", "lib/plugins/filter.rb", "lib/plugins/github-issues.rb", "lib/plugins/graduatter.rb", "lib/plugins/grass.rb", "lib/plugins/group.rb", "lib/plugins/growl.rb", "lib/plugins/growl2.rb", "lib/plugins/hatebu.rb", "lib/plugins/hatebu_and_update.rb", "lib/plugins/history.rb", "lib/plugins/http_server", "lib/plugins/http_server/favicon.ico", "lib/plugins/http_server/index.html", "lib/plugins/http_server.rb", "lib/plugins/hugeurl.rb", "lib/plugins/ignore.rb", "lib/plugins/irb.rb", "lib/plugins/irc_gw.rb", "lib/plugins/keyword.rb", "lib/plugins/l2.rb", "lib/plugins/list_with_opts.rb", "lib/plugins/log.rb", "lib/plugins/mark.rb", "lib/plugins/me.rb", "lib/plugins/modify_arg_hook_sample.rb", "lib/plugins/msagent.rb", "lib/plugins/multi_post.rb", "lib/plugins/multi_reply.rb", "lib/plugins/notify-send.rb", "lib/plugins/notify-send2.rb", "lib/plugins/notify-send3.rb", "lib/plugins/open_url.rb", "lib/plugins/otsune.rb", "lib/plugins/outputz.rb", "lib/plugins/pause.rb", "lib/plugins/pool.rb", "lib/plugins/post_exec_hook_sample.rb", "lib/plugins/pre_exec_hook_sample.rb", "lib/plugins/primes.rb", "lib/plugins/protected_filter.rb", "lib/plugins/quicklook.rb", "lib/plugins/random.rb", "lib/plugins/reblog.rb", "lib/plugins/reload.rb", "lib/plugins/reply.rb", "lib/plugins/reverse.rb", "lib/plugins/say.rb", "lib/plugins/saykanji.rb", "lib/plugins/scrape.rb", "lib/plugins/screen-notify.rb", "lib/plugins/screen.rb", "lib/plugins/search_url.rb", "lib/plugins/shell.rb", "lib/plugins/sl.rb", "lib/plugins/spam.rb", "lib/plugins/storage", "lib/plugins/storage/DB.rb", "lib/plugins/storage/status.rb", "lib/plugins/storage/status_mook.rb", "lib/plugins/storage.rb", "lib/plugins/switch_user.rb", "lib/plugins/system_status.rb", "lib/plugins/timer.rb", "lib/plugins/tinyurl.rb", "lib/plugins/translation.rb", "lib/plugins/trends.rb", "lib/plugins/twitpic.rb", "lib/plugins/typable_id.rb", "lib/plugins/update_editor.rb", "lib/plugins/uri-open.rb", "lib/plugins/wassr.rb", "lib/plugins/wassr_post.rb", "lib/plugins/whois.rb", "lib/plugins/yhara.rb", "lib/plugins/yhara_filter.rb", "lib/plugins/yonda.rb", "lib/termtter", "lib/termtter/api.rb", "lib/termtter/client.rb", "lib/termtter/command.rb", "lib/termtter/config.rb", "lib/termtter/config_setup.rb", "lib/termtter/config_template.erb", "lib/termtter/connection.rb", "lib/termtter/hook.rb", "lib/termtter/optparse.rb", "lib/termtter/system_extensions.rb", "lib/termtter/task.rb", "lib/termtter/task_manager.rb", "lib/termtter/version.rb", "lib/termtter.rb", "spec/plugins", "spec/plugins/cool_spec.rb", "spec/plugins/curry_spec.rb", "spec/plugins/db_spec.rb", "spec/plugins/english_spec.rb", "spec/plugins/fib_spec.rb", "spec/plugins/filter_spec.rb", "spec/plugins/pause_spec.rb", "spec/plugins/primes_spec.rb", "spec/plugins/shell_spec.rb", "spec/plugins/sl_spec.rb", "spec/plugins/spam_spec.rb", "spec/plugins/standard_commands_spec.rb", "spec/plugins/storage", "spec/plugins/storage/DB_spec.rb", "spec/plugins/storage/status_spec.rb", "spec/plugins/whois_spec.rb", "spec/spec_helper.rb", "spec/termtter", "spec/termtter/client_spec.rb", "spec/termtter/command_spec.rb", "spec/termtter/config_spec.rb", "spec/termtter/hook_spec.rb", "spec/termtter/optparse_spec.rb", "spec/termtter/task_manager_spec.rb", "spec/termtter/task_spec.rb", "spec/termtter_spec.rb", "test/friends_timeline.json", "test/search.json", "bin/kill_termtter", "bin/termtter"]
  s.homepage = %q{http://wiki.github.com/jugyo/termtter}
  s.rdoc_options = ["--main", "README.rdoc", "--exclude", "spec"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{termtter}
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Terminal based Twitter client.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json_pure>, [">= 1.1.3"])
      s.add_runtime_dependency(%q<highline>, [">= 1.5.0"])
      s.add_runtime_dependency(%q<termcolor>, [">= 0.3.1"])
      s.add_runtime_dependency(%q<rubytter>, [">= 0.6.4"])
    else
      s.add_dependency(%q<json_pure>, [">= 1.1.3"])
      s.add_dependency(%q<highline>, [">= 1.5.0"])
      s.add_dependency(%q<termcolor>, [">= 0.3.1"])
      s.add_dependency(%q<rubytter>, [">= 0.6.4"])
    end
  else
    s.add_dependency(%q<json_pure>, [">= 1.1.3"])
    s.add_dependency(%q<highline>, [">= 1.5.0"])
    s.add_dependency(%q<termcolor>, [">= 0.3.1"])
    s.add_dependency(%q<rubytter>, [">= 0.6.4"])
  end
end
