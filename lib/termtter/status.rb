# -*- coding: utf-8 -*-

module Termtter

  class Status

    %w(

      id text created_at truncated

      in_reply_to_status_id in_reply_to_user_id in_reply_to_screen_name

      user_id user_name user_screen_name user_url user_profile_image_url

    ).each do |attr|

      attr_accessor attr.to_sym

    end



    def eql?(other); self.id == other.id end

    def hash; self.id end



    def english?

      self.class.english?(self.text)

    end



    # english? :: String -> Boolean

    def self.english?(message)

      /[一-龠]+|[ぁ-ん]+|[ァ-ヴー]+|[ａ-ｚＡ-Ｚ０-９]+/ !~ message

    end

  end

end


