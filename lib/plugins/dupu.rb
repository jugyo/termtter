# Maintainer: Sora Harakami
# http://gist.github.com/453709

Termtter::Client.register_command(:name => :dupu, :exec => lambda do |body|
  #Termtter::Client.execute("update #{arg.chars.inject([]){|r,v|r << v*(5+rand(3)}.join}")
  body.chomp!
  max = 140
  len = body.split(//).length
  mod = max % len
  ext = (0...len).to_a.sort_by{ rand }.take(mod)
  res = body.split(//).each_with_index.map{ |c, i| c * (max / len + (ext.include?(i) ? 1 : 0)) }.join('')
  Termtter::Client.execute("update #{res}")
end)
