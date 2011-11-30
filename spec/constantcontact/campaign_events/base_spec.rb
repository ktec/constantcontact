require 'spec_helper'

describe CampaignEvents::Base do
  it { should be_a_kind_of ConstantContact::Base }
  it { should be_a_kind_of Base }
  before { set_default_credentials }
  describe do
	  subject { CampaignEvents::Base }
    specify { subject.site.to_s.should eq("https://api.constantcontact.com/") }
    specify { subject.collection_path(:campaign_id => 2).to_s.should eq("/ws/customers/joesflowers/campaigns/2/events") }
    specify { subject.element_path(1,:campaign_id => 2).to_s.should eq("/ws/customers/joesflowers/campaigns/2/events/1") }        
	end
end