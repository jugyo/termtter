# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{termtter}
  s.version = "0.8.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["bubblegum", "hakobe", "hitode909", "jugyo", "koichiro", "mattn", "motemen", "Sixeight", "ujihisa", "yanbe"]
  s.date = %q{2009-02-09}
  s.description = %q{Termtter is a terminal based Twitter client}
  s.email = ["jugyo.org@gmail.com"]
  s.executables = ["kill_termtter", "termtter"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "bin/kill_termtter", "bin/termtter", "lib/filter/en2ja.rb", "lib/filter/english.rb", "lib/filter/expand-tinyurl.rb", "lib/filter/fib.rb", "lib/filter/ignore.rb", "lib/filter/reply.rb", "lib/filter/reverse.rb", "lib/filter/url_addspace.rb", "lib/filter/yhara.rb", "lib/plugin/april_fool.rb", "lib/plugin/bomb.rb", "lib/plugin/confirm.rb", "lib/plugin/cool.rb", "lib/plugin/devel.rb", "lib/plugin/english.rb", "lib/plugin/erb.rb", "lib/plugin/favorite.rb", "lib/plugin/fib.rb", "lib/plugin/filter.rb", "lib/plugin/follow.rb", "lib/plugin/graduatter.rb", "lib/plugin/grass.rb", "lib/plugin/group.rb", "lib/plugin/growl.rb", "lib/plugin/hatebu.rb", "lib/plugin/history.rb", "lib/plugin/keyword.rb", "lib/plugin/log.rb", "lib/plugin/modify_arg_hook_sample.rb", "lib/plugin/msagent.rb", "lib/plugin/multi_reply.rb", "lib/plugin/notify-send.rb", "lib/plugin/otsune.rb", "lib/plugin/outputz.rb", "lib/plugin/pause.rb", "lib/plugin/plugin.rb", "lib/plugin/post_exec_hook_sample.rb", "lib/plugin/pre_exec_hook_sample.rb", "lib/plugin/primes.rb", "lib/plugin/quicklook.rb", "lib/plugin/reblog.rb", "lib/plugin/reload.rb", "lib/plugin/say.rb", "lib/plugin/scrape.rb", "lib/plugin/screen.rb", "lib/plugin/shell.rb", "lib/plugin/sl.rb", "lib/plugin/spam.rb", "lib/plugin/standard_plugins.rb", "lib/plugin/stdout.rb", "lib/plugin/system_status.rb", "lib/plugin/translation.rb", "lib/plugin/update_editor.rb", "lib/plugin/uri-open.rb", "lib/plugin/wassr_post.rb", "lib/plugin/yhara.rb", "lib/plugin/yonda.rb", "lib/termtter.rb", "lib/termtter/api.rb", "lib/termtter/client.rb", "lib/termtter/command.rb", "lib/termtter/connection.rb", "lib/termtter/hook.rb", "lib/termtter/status.rb", "lib/termtter/task.rb", "lib/termtter/task_manager.rb", "lib/termtter/twitter.rb", "lib/termtter/user.rb", "lib/termtter/version.rb", "run_termtter.rb", "test/friends_timeline.json", "test/search.json", "test/test_termtter.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/jugyo/termtter}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{termtter}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Termtter is a terminal based Twitter client}
  s.test_files = ["test/test_termtter.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json_pure>, [">= 0"])
      s.add_runtime_dependency(%q<configatron>, [">= 0"])
      s.add_runtime_dependency(%q<highline>, [">= 0"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<json_pure>, [">= 0"])
      s.add_dependency(%q<configatron>, [">= 0"])
      s.add_dependency(%q<highline>, [">= 0"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<json_pure>, [">= 0"])
    s.add_dependency(%q<configatron>, [">= 0"])
    s.add_dependency(%q<highline>, [">= 0"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
