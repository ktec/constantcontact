require 'spec_helper'

describe Searchable do
  class TestClass < Base; include Searchable; end
  subject { TestClass.new }
  
  it_should_behave_like "a searchable class"
end
