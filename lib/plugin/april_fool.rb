def april_fool?;true;end
def april_fool;april_fool? ? "今日はエイプリルフールではありません。" : "
今日はエイプリルフールです。";end
module Termtter::Client
add_command /^af\?/ do|m,t|t.update_status april_fool
puts"=> #{april_fool}"end
add_command /^af\?you\s(\w+)/ do|m,t|puts"=> #{t.update_status("@#{m[1]} #{april_fool}")}"end end
# TODO: use add_macro
