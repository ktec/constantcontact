require 'spec_helper'

describe CampaignEvents::BounceEvent do
  it { should be_a_kind_of CampaignEvents::Base }
  describe do
	  subject { CampaignEvents::BounceEvent }
	  its(:collection_name) { should == "bounces" }
	end
end