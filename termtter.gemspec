# -*- encoding: utf-8; mode: ruby -*-
$:.push File.expand_path("../lib", __FILE__)
require 'termtter/version'

Gem::Specification.new do |s|
  s.name = "termtter"
  s.version = Termtter::VERSION

  s.authors = ["jugyo", "ujihisa", "koichiroo"]
  s.default_executable = %q{termtter}
  s.description = %q{Termtter is a terminal based Twitter client.}
  s.email = %q{jugyo.org@gmail.com}
  s.executables = ["termtter"]
  s.extra_rdoc_files = [
    "ChangeLog",
    "README.rdoc"
  ]

  s.homepage = %q{http://termtter.github.com/}
  s.rdoc_options = ["--main", "README.rdoc", "--exclude", "spec"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{termtter}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Terminal based Twitter client.}

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 1.1.3"])
      s.add_runtime_dependency(%q<highline>, [">= 1.5.0"])
      s.add_runtime_dependency(%q<termcolor>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<rubytter>, [">= 1.4.0"])
      s.add_runtime_dependency(%q<notify>, [">= 0.2.1"])
    else
      s.add_dependency(%q<json>, [">= 1.1.3"])
      s.add_dependency(%q<highline>, [">= 1.5.0"])
      s.add_dependency(%q<termcolor>, [">= 1.0.0"])
      s.add_dependency(%q<rubytter>, [">= 1.4.0"])
      s.add_dependency(%q<notify>, [">= 0.2.1"])
    end
  else
    s.add_dependency(%q<json>, [">= 1.1.3"])
    s.add_dependency(%q<highline>, [">= 1.5.0"])
    s.add_dependency(%q<termcolor>, [">= 1.0.0"])
    s.add_dependency(%q<rubytter>, [">= 1.4.0"])
    s.add_dependency(%q<notify>, [">= 0.2.1"])
  end
end
