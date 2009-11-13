# -*- coding: utf-8 -*-

module Termtter::Client
  plug 'translation'

  register_hook(:en2ja, :point => :filter_for_output) do |statuses, event|
    statuses.each do |s|
      if english?(s.text)
        s.text = translate(s.text, 'en|ja')
      end
    end
  end

  def self.english?(text)
    /[一-龠]+|[ぁ-ん]+|[ァ-ヴー]+|[ａ-ｚＡ-Ｚ０-９]+/ !~ text
  end
end
