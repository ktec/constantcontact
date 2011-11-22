require 'spec_helper'

describe ConstantContact::Pageable do
  class TestClass < ConstantContact::Base; include ConstantContact::Pageable; end
  subject { TestClass.new }
  
  it_should_behave_like "a pageable class"
end
