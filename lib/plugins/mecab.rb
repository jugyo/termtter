# coding: utf-8
$KCODE = 'u' unless defined?(Encoding)
# mecab('これはテストです') #=>
#   [["これ", "名詞", "代名詞", "一般", "*", "*", "*", "これ", "コレ", "コレ"],
#    ["は", "助詞", "係助詞", "*", "*", "*", "*", "は", "ハ", "ワ"],
#    ["テスト", "名詞", "サ変接続", "*", "*", "*", "*", "テスト", "テスト", "テスト"],
#    ["です", "助動詞", "*", "*", "*", "特殊・デス", "基本形", "です", "デス", "デス"]]
def mecab(str)
  IO.popen('mecab', 'r+') {|io|
    io.puts str
    io.close_write
    io.read.split(/\n/).map {|i| i.split(/\t|,/) }[0..-2]
  }
end

Termtter::Client.register_command(
  :name => 'mecab',
  :help => 'post a Japanese message with syntaxtic explanations. Requirements: mecab command',
  :exec => lambda {|arg|
    text = mecab(arg).map {|i| "#{i[0]}(#{i[1]}: #{i[2]})" }.join
    update(text)
    puts "=> #{test}"
  })
