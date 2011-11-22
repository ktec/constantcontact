require 'spec_helper'

describe ContactEvents::SentEvent do
  it { should be_a_kind_of ContactEvents::Base }
  describe do
	  subject { ContactEvents::ClickEvent }
	  its(:collection_name) { should == "clicks" }
	end
end