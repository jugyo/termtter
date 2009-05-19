# -*- coding: utf-8 -*

require 'tempfile'
require 'rubygems'
require 'giic'

module Termtter::Client
  editor = ENV['EDITOR'] or
           config.editor or
           config.plugins.update_editor.editor
  config.plugins.github_issues.set_default('editor', editor)

  config.plugins.github_issues.set_default('user', 'jugyo')
  config.plugins.github_issues.set_default('repo', 'termtter')

  register_command('ilist', :alias => 'il', :help => ['ilist, il', 'list all issues']) do |state|
    state = state.empty? ? 'open' : state
    list = gi_project.list(state)['issues']
    no_length = list.map {|i| i.number.to_s.size }.max
    list = list.map {|i| "##{i.number.to_s.ljust(no_length)} #{i.title}" }
    puts list.join("\n")
  end

  register_command('ishow', :alias => 'is', :help => ['ishow,is NO', 'show specific issue']) do |no|
    if no.empty?
      warn 'need issue number'
      next
    end
    issue = gi_project.show(no.to_i)['issue']
    label_length = issue.keys.map(&:size).max
    issue.each do |key, value|
      puts "#{key.rjust(label_length)}: #{value}"
    end
  end

  register_command('iopen', :alias => 'io', :help => ['iopen,io TITLE', 'open new issue']) do |title|
    if title.empty?
      warn 'need issue title'
      next
    end
    login
    body = input_editor
    res = login.open(title, body)
    if res.has_key?('error')
      warn 'failed'
      next
    end
    res = res['issue']
    label_length = res.keys.map(&:size).max
    puts 'success:'
    puts
    res.each do |key, value|
      puts "#{key.rjust(label_length)}: #{value}"
    end
  end

  register_command('iedit', :alias => 'ie', :help => ['iedit,ie NO', 'edit issue']) do |no|
    if no.empty?
      warn 'need issue no'
      next
    end
    no = no.to_i
    target = gi_project.show(no)
    if target.has_key?('error')
      warn 'no such issue'
      next
    end
    issue_body = target['issue']['body']
    login
    body = input_editor(issue_body)
    res = login.edit(no, body)
    if res.has_key?('error')
      warn 'failed'
      next
    end
    res = res['issue']
    label_length = res.keys.map(&:size).max
    puts 'success:'
    puts
    res.each do |key, value|
      puts "#{key.rjust(label_length)}: #{value}"
    end
  end

  register_command('ilabel', :alias => 'ilb', :help => ['ilabel,ilb (add | remove) LABEL NO', 'add or remove label to issue']) do |args|
    op, label, no = args.split(/\s/)
    unless [op, label, no].all?
      warn 'need op, label, no'
      next
    end
    case op
    when 'add'
      res = login.add_label(label, no)
      if res.has_key?('error')
        warn 'failed'
        next
      end
      puts 'success'
    when 'remove'
      res = login.remove_label(label, no)
      if res.has_key?('error')
        warn 'failed'
        next
      end
      puts 'success'
    else
      warn 'no such operate'
    end
  end

  register_command('iclose', :alias => 'ic', :help => ['iclose,ic NO', 'close issue']) do |no|
    if no.empty?
      warn 'need issue title'
      next
    end
    res = login.close(no.to_i)
    res.has_key?('error') ? warn('failed') : puts('success')
  end

  register_command('ireopen', :alias => 'iro', :help => ['ireopen,ire NO', 'reopen closed issue']) do |no|
    if no.empty?
      warn 'need issue title'
      next
    end
    res = login.reopen(no.to_i)
    res.has_key?('error') ? warn('failed') : puts('success')
  end

  register_command('irepo', :alias => 'ir', :help => ['irepo, ir USER REPO', 'change user and repo']) do |user_repo|
    user, repo = user_repo.split(/\s/)
    unless [user, repo].all?
      puts "now: user => #{gi_config.user}, repo => #{gi_config.repo}"
      next
    end
    gi_config.user = user
    gi_config.repo = repo
    puts "changed: user => #{user}, repo => #{repo}"
  end

  private

  def self.gi_config; config.plugins.github_issues end
  def self.gi_project; Giic.new(gi_config.user, gi_config.repo) end

  def self.login
    if config.plugins.github_issues.login.empty?
      print 'login > '; $stdout.flush
      config.plugins.github_issues.login = gets.chomp
    end
    if config.plugins.github_issues.token.empty?
      print 'token > '; $stdout.flush
      config.plugins.github_issues.token = gets.chomp
    end
    gi_project.login(gi_config.login, gi_config.token)
  end

  def self.input_editor(body = nil)
    file = Tempfile.new('termtter')
    editor = config.plugins.github_issues.editor
    file.write body if body
    file.close
    system("#{editor} #{file.path}")
    result = file.open.read
    file.flush
    file.close(false)
    result
  end
end

