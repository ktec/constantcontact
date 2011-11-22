require 'spec_helper'

describe CampaignEvents::SentEvent do
  it { should be_a_kind_of CampaignEvents::Base }
  describe do
	  subject { CampaignEvents::SentEvent }
	  its(:collection_name) { should == "sends" }
	end
end