require 'spec_helper'

describe ContactEvents::Base do
  it { should be_a_kind_of ConstantContact::Base }
  it { should be_a_kind_of Base }
  describe do
	  subject { ContactEvents::Base.site.to_s }
	  it { should match "/contacts/:contact_id/events" }
	end
end