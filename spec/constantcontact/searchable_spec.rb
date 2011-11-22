require 'spec_helper'

describe ConstantContact::Searchable do
  class TestClass < ConstantContact::Base; include ConstantContact::Searchable; end
  subject { TestClass.new }
  
  it_should_behave_like "a searchable class"
end
