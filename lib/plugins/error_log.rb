config.plugins.error_log.set_default(:file, File.expand_path("~/.termtter/error.log.txt"))

Termtter::Client.register_hook(
  :name => :error_log,
  :point => :on_error,
  :exec => lambda do |e|
    open(config.plugins.error_log.file,"a") do |f|
      f.puts "#{Time.now} ---------------------"
      f.puts "  #{e.class.to_s}: #{e.message}"
      e.backtrace.each do |s|
        f.puts "    #{s}"
      end
    end
  end
)
