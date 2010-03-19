# coding: utf-8

def generate_story
  you = config.user_name
  friends = config.plugins.stdout.sweets.dup
  the_man = friends.delete(friends.sample)
  a = friends.delete(friends.sample)
  b = friends.delete(friends.sample)
  c = friends.delete(friends.sample)

  story = <<-"EOS"

  --- アタシの名前は#{you}。心に傷を負った女子高生。
      モテカワスリムで恋愛体質の愛されガール♪
 アタシがつるんでる友達は援助交際をやってる#{a}、
  学校にナイショでキャバクラで働いてる#{b}。
  訳あって不良グループの一員になってる#{c}。
 友達がいてもやっぱり学校はタイクツ。
  今日もミキとちょっとしたことで口喧嘩になった。
  女のコ同士だとこんなこともあるからストレスが溜まるよね☆
  そんな時アタシは一人でTwitterを使うことにしている。
 がんばった自分へのご褒美ってやつ？自分らしさの演出とも言うかな！
  ｢あームカツク｣・・。そんなことをつぶやきながらしつこいrepliesを軽くあしらう。
  ｢カノジョー、ちょっと話聞いてくれない？｣
  どいつもこいつも同じようなツイートしか投稿しない。
 Twitterの男はカッコイイけどなんか薄っぺらくてキライだ。
  もっと等身大のアタシを見て欲しい。
　｢すいません・・。｣・・・またか、とセレブなアタシは思った。
  シカトするつもりだったけど、チラっとTwitterの男の顔を見た。
「・・！！」
　・・・チガウ・・・今までの男とはなにかが決定的に違う。スピリチュアルな感覚がアタシのカラダを
駆け巡った・・。「・・（カッコイイ・・！！・・これってtermtter・・？）」
男は#{the_man}だった。連れていかれてfibでやすらぎされた。
「キャーやめて！」gをキメた。
「ガッシ！ボカッ！」アタシはコミッタになった。コミット（笑）
  EOS
end

Termtter::Client.register_command(
  :name => 'story',
  :help => 'Show a dramatic story in Japanese.',
  :exec => lambda {|arg|
    puts generate_story
  })
