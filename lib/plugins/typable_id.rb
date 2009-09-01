# -*- coding: utf-8 -*-

config.plugins.typable_id.set_default(:typable_keys, %w[ a  i  u  e  o
                                                        ka ki ku ke ko
                                                        ga gi gu ge go
                                                        sa si su se so
                                                        za zi zu ze zo
                                                        ta ti tu te to
                                                        da di du de do
                                                        na ni nu ne no
                                                        ha hi hu he ho
                                                        ba bi bu be bo
                                                        pa pi pu pe po
                                                        ma mi mu me mo
                                                        ya    yu    yo
                                                        ra ri ru re ro
                                                        wa          wo
                                                        nn ])

module Termtter::Client
  public_storage[:typable_id] = []
  config.plugins.typable_id.typable_keys.each {|key|
    public_storage[:typable_id].push([key, '', ''])
  }

  register_hook(
    :name => :typable_id,
    :points => [:post_filter],
    :exec_proc => lambda {|filtered, event|
      filtered.each do |s|
        current_id = public_storage[:typable_id].shift
        current_id[1] = s.id.to_s
        current_id[2] = s
        public_storage[:typable_id].push(current_id)
      end
    }
  )

  def self.typable_id_convert(id)
    if current_id = public_storage[:typable_id].assoc(id.to_s)
      return current_id[1]
    elsif current_id = public_storage[:typable_id].rassoc(id.to_s)
      return current_id[0]
    else
      return nil
    end
  end

  def self.typable_id_status(id)
    if current_id = (public_storage[:typable_id].assoc(id.to_s)||\
                     public_storage[:typable_id].rassoc(id.to_s))
      return current_id[2]
    else
      return nil
    end
  end

  def self.typable_id?(id)
    if public_storage[:typable_id].assoc(id.to_s)
      return true
    else
      return false
    end
  end
end

#Setting
#  ex)
#    config.plugins.stdout.timeline_format = '<90><%=time%></90> <<%=status_color%>><%=status%></<%=status_color%>> <90><%=id%>>[<%=Termtter::Client.typable_id_convert(id)%>]</90>
#Optional Settng
#  ex) Like hepburn system
#    config.plugins.typable_id.typable_keys = %w[ a   i   u  e  o
#                                                ka  ki  ku ke ko ga gi gu ge go
#                                                sa shi  su se so za ji zu ze zo
#                                                ta chi tsu te to da di du de do
#                                                na  ni  nu ne no
#                                                ha  hi  fu he ho ba bi bu be bo pa pi pu pe po
#                                                ma  mi  mu me mo
#                                                ya      yu    yo
#                                                ra  ri  ru re ro
#                                                wa            wo
#                                                nn ]
#  ex) Hiragana
#    config.plugins.typable_id.typable_keys = %w[あ い う え お
#                                                か き く け こ が ぎ ぐ げ ご
#                                                さ し す せ そ ざ じ ず ぜ ぞ
#                                                た ち つ て と だ ぢ づ で ど
#                                                な に ぬ ね の
#                                                は ひ ふ へ ほ ば び ぶ べ ぼ ぱ ぴ ぷ ぺ ぽ
#                                                ま み む め も
#                                                や    ゆ    よ
#                                                ら り る れ ろ
#                                                わ          を
#                                                ん ]
