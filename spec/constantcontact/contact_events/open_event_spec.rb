require 'spec_helper'

describe ContactEvents::OpenEvent do
  it { should be_a_kind_of ContactEvents::Base }
  describe do
	  subject { ContactEvents::OpenEvent }
	  its(:collection_name) { should == "opens" }
	end
end