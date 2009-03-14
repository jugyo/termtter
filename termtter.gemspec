Gem::Specification.new do |s|
  s.name = 'termtter'
  s.version = '0.8.14'
  s.summary = "Terminal based Twitter client"
  s.description = "Termtter is a terminal based Twitter client"
  s.files = %w( lib/filter/en2ja.rb lib/filter/english.rb lib/filter/expand-tinyurl.rb lib/filter/fib.rb lib/filter/ignore.rb lib/filter/reply.rb lib/filter/reverse.rb lib/filter/url_addspace.rb lib/filter/yhara.rb lib/plugin/april_fool.rb lib/plugin/bomb.rb lib/plugin/clear.rb lib/plugin/confirm.rb lib/plugin/cool.rb lib/plugin/devel.rb lib/plugin/english.rb lib/plugin/erb.rb lib/plugin/favorite.rb lib/plugin/fib.rb lib/plugin/filter.rb lib/plugin/follow.rb lib/plugin/graduatter.rb lib/plugin/grass.rb lib/plugin/group.rb lib/plugin/growl.rb lib/plugin/hatebu.rb lib/plugin/history.rb lib/plugin/keyword.rb lib/plugin/log.rb lib/plugin/me.rb lib/plugin/modify_arg_hook_sample.rb lib/plugin/msagent.rb lib/plugin/multi_reply.rb lib/plugin/notify-send.rb lib/plugin/otsune.rb lib/plugin/outputz.rb lib/plugin/pause.rb lib/plugin/plugin.rb lib/plugin/post_exec_hook_sample.rb lib/plugin/pre_exec_hook_sample.rb lib/plugin/primes.rb lib/plugin/quicklook.rb lib/plugin/random.rb lib/plugin/reblog.rb lib/plugin/reload.rb lib/plugin/say.rb lib/plugin/scrape.rb lib/plugin/screen.rb lib/plugin/shell.rb lib/plugin/sl.rb lib/plugin/spam.rb lib/plugin/standard_plugins.rb lib/plugin/stdout.rb lib/plugin/system_status.rb lib/plugin/translation.rb lib/plugin/update_editor.rb lib/plugin/uri-open.rb lib/plugin/wassr_post.rb lib/plugin/yhara.rb lib/plugin/yonda.rb lib/termtter/api.rb lib/termtter/client.rb lib/termtter/command.rb lib/termtter/connection.rb lib/termtter/hook.rb lib/termtter/status.rb lib/termtter/system_extensions.rb lib/termtter/task.rb lib/termtter/task_manager.rb lib/termtter/twitter.rb lib/termtter/user.rb lib/termtter/version.rb lib/termtter.rb
                spec/plugin/cool_spec.rb spec/plugin/fib_spec.rb spec/plugin/filter_spec.rb spec/plugin/plugin_spec.rb spec/plugin/shell_spec.rb spec/plugin/spam_spec.rb spec/plugin/standard_plugins_spec.rb spec/spec_helper.rb spec/termtter/client_spec.rb spec/termtter/command_spec.rb spec/termtter/task_manager_spec.rb spec/termtter/task_spec.rb spec/termtter/user_spec.rb spec/termtter_spec.rb
                test/test_termtter.rb test/friends_timeline.json test/search.json
                README.rdoc
                History.txt
                Rakefile )
  s.executables = ["kill_termtter", "termtter"]
  s.add_dependency("json_pure", ">= 1.1.3")
  s.add_dependency("configatron", ">= 2.2.2")
  s.add_dependency("highline", ">= 1.5.0")
  s.add_dependency("termcolor", ">= 0.3.1")
  s.authors = %w(jugyo ujihisa)
  s.email = 'jugyo.org@gmail.com'
  s.homepage = 'http://wiki.github.com/jugyo/termtter'
  s.rubyforge_project = 'termtter'
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.rdoc", "--exclude", "spec"]
  s.extra_rdoc_files = ["README.rdoc", "History.txt"]
end
