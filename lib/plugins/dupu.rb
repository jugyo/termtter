# Maintainer: Sora Harakami

Termtter::Client.register_command(:name => :dupu, :exec => lambda do |arg|
  Termtter::Client.execute("update #{arg.chars.inject([]){|r,v|r << v*10}.join}")
end)
