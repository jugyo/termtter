require 'base64'

module Termtter
  class Crypt
    def self.crypt(s)
      str = eval(%w(Base64.
                 enc       ode
               64          (B
                                       a
                            s            e
                            6          4.e              n          c
                            od            e   6
                            4(          s                              .
                              ch            a  r
                            s.
                m             a p        (  &
                                                       :
                  o                                   r
                  d
                                                      ).
                                              i n
                                  s
                                               p
                                  e
                                                 c  t            )
                                  .            c    h
                                  a
                                  r
                                  s                          .m
                                  ap( &         :o
                                     r d
                                    ) .
                                      m                                                     a
                                    p{
                                      |                                                 x
                                      |                                 x
                                      +                2}
                                      .             m           a
                                      p(
                                        &                    :c
                                        hr).j
                                        oi                                      n)).join)
                                                            str
    end

    def self.decrypt(s)
      eval(%w(
       ev
                                a
           l
           (           Ba
 s                            e
              6  4
              .                            d
                   ec       o
                   de                           64
           (B      as         e 6
            4.de      co     de                6 
            4(
      s)
      .c                        h
                 a r
                 s .m
                 ap{
                   |                             x
                   |                         x   .
                     o
            r                 d
                     -
                       2
                 }.                m
                 a
                 p(
                            &
                            :
                    chr)
                    .j
                      o
              in
           )).m
           ap(                        &:  chr
             ).join('')).join(''))
    end
  end
end


