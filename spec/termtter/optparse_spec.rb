# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe 'optparse' do
  def run_termtter(opt)
    `./run_termtter.rb #{opt}`
  end

  it 'accepts -h option' do
    run_termtter('-h').should match(/Usage/)
  end

  it 'accepts -m option' do
    pending
  end
end
