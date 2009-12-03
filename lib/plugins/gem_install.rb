# Plugin gem_install
#   AUTHOR: Tatsuhiro Ujihisa <http://ujihisa.blogspot.com/>
#   SYNOPSIS:
#     Once you use this plugin by `plug gem_install`, your termtter will
#     install arbitrary gem libraries when they appeared on your timeline,
#     replies or anything on your termtter.
#     How useful it is.
#     If you already have `g`, the automatic installation will be announced
#     on your Growl.
Termtter::Client.register_hook(
  :name => :gem_install,
  :points => [:output],
  :exec_proc => lambda {|statuses, _|
    statuses.each do |s|
      /gem install ([a-zA-Z0-9_\-]+)/ =~ s.text
      if gem_name = $1
        (private_methods.map(&:to_sym).include?(:g) ? method(:g) : method(:p)).
          call("Termtter's `gem_install` plugin is now installing #{gem_name}")
        fork do
          system 'gem', 'install', gem_name
        end
      end
    end
  })
