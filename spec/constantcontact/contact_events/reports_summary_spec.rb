require 'spec_helper'

describe ContactEvents::ReportsSummary do
  #it { should be_a_kind_of ContactEvents::Base }
  it { should be_a_kind_of ConstantContact::Base }
  describe do
	  subject { ContactEvents::ReportsSummary }
	  its(:collection_name) { should == "summary" }
	end
	before do
    set_default_credentials
	end
  describe do
  	before do
	    stub_get('/contacts/53/events/summary/1100552708599','contacts/53/events/summary.xml')
 		end
	  subject { ContactEvents::ReportsSummary.find(1100552708599, :params => {:contact_id => 53} ) }

=begin
	  specify { subject.contact.id.should == "http://api.constantcontact.com/ws/customers/joesflowers/contacts/53" }
	  #it { should == "soemthign" }
	  #its(:title) { should == "Events Summary for Customer: joesflowers, Contact id: http://api.constantcontact.com/ws/customers/joesflowers/contacts/53" }
	  context do
	  	before {
		  	r1 = subject.records[0]
		  	subject = r1
		  }
		  it { should == "somthing" }
	  	its(:email_address) { should == "customer1@example.com" }
	  end
=end
	end
end