require 'spec_helper'

describe CampaignEvents::ForwardEvent do
  it { should be_a_kind_of CampaignEvents::Base }
  describe do
	  subject { CampaignEvents::ForwardEvent }
	  its(:collection_name) { should == "forwards" }
	end
end