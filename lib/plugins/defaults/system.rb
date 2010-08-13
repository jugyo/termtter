module Termtter::Client
  register_command('hook list') do
    name_max_size = hooks.keys.map{|i|i.size}.max
    points_max_size = hooks.values.map{|i|i.points.join(', ').size}.max
    hooks.each do |name, hook|
      points = "[#{hook.points.join(', ')}]"
      puts "#{name.to_s.ljust(name_max_size)} " +
              "<90>=&gt;</90>".termcolor + " #{points.ljust(points_max_size)} " +
              "<90>=&gt;</90>".termcolor + " #{hook.exec_proc}"
    end
  end

  register_command('hook remove') do |name|
    puts remove_hook(name) ? "removed => #{name}" : '<red>hook not found!</red>'.termcolor
  end

  register_command('command list') do
    name_max_size = commands.keys.map{|i|i.size}.max
    commands.each do |name, command|
      puts "#{name.to_s.ljust(name_max_size)} " + "<90>=&gt;</90>".termcolor + " #{command.exec_proc}"
    end
  end

  register_command('command remove') do |name|
    puts remove_command(name) ? "removed => #{name}" : '<red>command not found!</red>'.termcolor
  end
end
