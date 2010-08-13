# -*- coding: utf-8 -*-

module AAMaker
  # view-source:http://amachang.sakura.ne.jp/misc/aamaker/
  def self.random(n)
    rand(n).to_i
  end
  def self.randSelect(array)
    return array[random(array.length)]
  end

  def self.make
    rinkaku = randSelect([['(', ')'], ['(', ')'], ['|', '|'], ['｜', '｜']]);
    otete = randSelect([['', '', '', '', ''], ['', '', 'm', '', ''], ['', '', 'ლ', '', ''], ['ლ', '', '', 'ლ', ''], ['', '｢', '', '', '｢'], ['', ' つ', '', '', 'つ'], ['', ' ', '', '', 'o彡ﾟ'], ['', 'n', '', '', 'η'], ['', '∩', '', '∩', ''], ['∩', '', '', '', '∩'], ['ヽ', '', '', '', 'ノ'], ['┐', '', '', '', '┌'], ['╮', '', '', '', '╭'], ['<', '', '', '', '/'], ['╰', '', '', ' ', ''], ['o', '', '', '', 'o'], ['o', '', '', '', 'ツ'], ['', '', '', '', 'ﾉｼ']]);
    omeme = randSelect([['◕', '◕'], ['╹', '╹'], ['＞', '＜'], ['＾', '＾'], ['・', '・'], ['´・', '・`'], ['`・', '・´'], ['´', '`'], ['≧', '≦'], ['ﾟ', 'ﾟ'], ['\'', '\''], ['･ิ', '･ิ'], ['❛', '❛'], ['⊙', '⊙'], ['￣', '￣'], ['◕ˇ', 'ˇ◕']]);
    okuti = randSelect(['ω', '∀', '▽', '△', 'Д' , '□', '～', 'ー', 'ェ', 'ρ', 'o']);
    hoppe = randSelect([['', ''], ['*', ''], ['', '*'], ['', '#'], ['#', ''], ['✿', ''], ['', '✿'], ['', '；'], ['；', ''], ['｡', '｡'], ['｡', ''], ['', '｡'], ['▰', '▰'], ['', '▰'], ['▰', ''], ['๑', '๑'], ['', '๑'], ['๑', '']]);

    text = [
      otete[0],
      rinkaku[0],
      otete[1] || (otete[3] ? '' : hoppe[0]),
      omeme[0],
      otete[2] || okuti,
      omeme[1],
      otete[3] || (otete[1] ? '' : hoppe[1]),
      rinkaku[1],
      otete[4]
    ].join('')

    text
  end
end

Termtter::Client.register_command(
  :name => :aa,
  :author => 'hitode909',
  :exec_proc => lambda {|arg|
    name = Termtter::Client.normalize_as_user_name(arg)
    command = name.length > 0 ? "u @#{name} #{AAMaker.make}" : "u #{AAMaker.make}"
    Termtter::Client.execute command
  },
  :help => ["aa [(Optinal) USER]", "Post a AA"]
)
