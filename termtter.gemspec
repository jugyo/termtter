Gem::Specification.new do |s|
  s.name = 'termtter'
  s.version = '1.1.2'
  s.summary = "Terminal based Twitter client"
  s.description = "Termtter is a terminal based Twitter client"
  s.files = %w( lib/plugins/addspace.rb lib/plugins/april_fool.rb lib/plugins/auto_reload.rb lib/plugins/bomb.rb lib/plugins/clear.rb lib/plugins/command_plus.rb lib/plugins/confirm.rb lib/plugins/cool.rb lib/plugins/countter.rb lib/plugins/devel.rb lib/plugins/direct_messages.rb lib/plugins/en2ja.rb lib/plugins/english.rb lib/plugins/erb.rb lib/plugins/exec.rb lib/plugins/exec_and_update.rb lib/plugins/expand-tinyurl.rb lib/plugins/fib.rb lib/plugins/fib_filter.rb lib/plugins/filter.rb lib/plugins/graduatter.rb lib/plugins/grass.rb lib/plugins/group.rb lib/plugins/growl.rb lib/plugins/growl2.rb lib/plugins/hatebu.rb lib/plugins/hatebu_and_update.rb lib/plugins/history.rb lib/plugins/ignore.rb lib/plugins/irc_gw.rb lib/plugins/keyword.rb lib/plugins/l2.rb lib/plugins/list_with_opts.rb lib/plugins/log.rb lib/plugins/me.rb lib/plugins/modify_arg_hook_sample.rb lib/plugins/msagent.rb lib/plugins/multi_post.rb lib/plugins/multi_reply.rb lib/plugins/notify-send.rb lib/plugins/notify-send2.rb lib/plugins/notify-send3.rb lib/plugins/open_url.rb lib/plugins/otsune.rb lib/plugins/outputz.rb lib/plugins/pause.rb lib/plugins/post_exec_hook_sample.rb lib/plugins/pre_exec_hook_sample.rb lib/plugins/primes.rb lib/plugins/quicklook.rb lib/plugins/random.rb lib/plugins/reblog.rb lib/plugins/reload.rb lib/plugins/reply.rb lib/plugins/retweet.rb lib/plugins/reverse.rb lib/plugins/say.rb lib/plugins/scrape.rb lib/plugins/screen-notify.rb lib/plugins/screen.rb lib/plugins/search_url.rb lib/plugins/shell.rb lib/plugins/sl.rb lib/plugins/spam.rb lib/plugins/standard_commands.rb lib/plugins/stdout.rb lib/plugins/storage/DB.rb lib/plugins/storage/status.rb lib/plugins/storage/status_mook.rb lib/plugins/storage.rb lib/plugins/switch_user.rb lib/plugins/system_status.rb lib/plugins/timer.rb lib/plugins/tinyurl.rb lib/plugins/translation.rb lib/plugins/typable_id.rb lib/plugins/update_editor.rb lib/plugins/uri-open.rb lib/plugins/wassr.rb lib/plugins/wassr_post.rb lib/plugins/yhara.rb lib/plugins/yhara_filter.rb lib/plugins/yonda.rb lib/termtter/api.rb lib/termtter/client.rb lib/termtter/command.rb lib/termtter/config.rb lib/termtter/config_setup.rb lib/termtter/connection.rb lib/termtter/hook.rb lib/termtter/optparse.rb lib/termtter/system_extensions.rb lib/termtter/task.rb lib/termtter/task_manager.rb lib/termtter/version.rb lib/termtter.rb lib/termtter/config_template.erb
                spec/plugins/cool_spec.rb spec/plugins/english_spec.rb spec/plugins/fib_spec.rb spec/plugins/filter_spec.rb spec/plugins/pause_spec.rb spec/plugins/primes_spec.rb spec/plugins/shell_spec.rb spec/plugins/sl_spec.rb spec/plugins/spam_spec.rb spec/plugins/standard_plugins_spec.rb spec/plugins/storage/DB_spec.rb spec/plugins/storage/status_spec.rb spec/spec_helper.rb spec/termtter/client_spec.rb spec/termtter/command_spec.rb spec/termtter/config_spec.rb spec/termtter/hook_spec.rb spec/termtter/task_manager_spec.rb spec/termtter/task_spec.rb spec/termtter_spec.rb
                test/friends_timeline.json test/search.json
                README.rdoc
                History.txt
                Rakefile )
  s.executables = ["kill_termtter", "termtter"]
  s.add_dependency("json_pure", ">= 1.1.3")
  s.add_dependency("highline", ">= 1.5.0")
  s.add_dependency("termcolor", ">= 0.3.1")
  s.add_dependency("rubytter", ">= 0.6.4")
  s.authors = %w(jugyo ujihisa)
  s.email = 'jugyo.org@gmail.com'
  s.homepage = 'http://wiki.github.com/jugyo/termtter'
  s.rubyforge_project = 'termtter'
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.rdoc", "--exclude", "spec"]
  s.extra_rdoc_files = ["README.rdoc", "History.txt"]
end
