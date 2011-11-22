require 'spec_helper'

describe CampaignEvents::Base do
  it { should be_a_kind_of ConstantContact::Base }
  it { should be_a_kind_of Base }
  describe do
	  subject { CampaignEvents::Base.site.to_s }
	  it { should match "/campaigns/:campaign_id/events" }
	end
end