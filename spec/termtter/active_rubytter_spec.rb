# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'
require 'termtter/active_rubytter'
require 'pp'

module Termtter
  describe ActiveRubytter do
    before(:each) do
      @data = {
        :hoge => "hogehoge",
        :fuga => "fugafuga",
        :hage => {
          :foo => "foofoo",
          :bar => {
            :nest => "nestnest"
          }
        }
      }
    end

    it "入れ子のHashをクラス化できる" do
      d = ActiveRubytter.new( @data )
      d.class.should == ActiveRubytter

      #array.map{ |elem| ActiveRubytter.new(elem)})}
    end

    it "Hashからクラス化して`.'でアクセスできる" do
      d = ActiveRubytter.new( @data )
      d.hoge.should == "hogehoge"

      #array.map{ |elem| ActiveRubytter.new(elem)})}
    end

    it "Hashからクラス化して`.'で入れ子でもアクセスできる" do
      d = ActiveRubytter.new( @data )
      d.hage.foo.should == "foofoo"

      #array.map{ |elem| ActiveRubytter.new(elem)})}
    end

    it "Hashからクラス化して`.'で入れ子の入れ子でもアクセスできる" do
      d = ActiveRubytter.new( @data )
      d.hage.bar.nest.should == "nestnest"

      #array.map{ |elem| ActiveRubytter.new(elem)})}
    end
  end
end

