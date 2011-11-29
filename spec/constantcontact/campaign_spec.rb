require 'spec_helper'

shared_examples_for "a default campaign" do
  # defaults
  its(:view_as_webpage) { should_not be_empty }
  its(:from_name) { should_not be_empty }
  its(:from_email) { should_not be_empty }
  its(:permission_reminder) { should_not be_empty }
  its(:permission_reminder_text) { should_not be_empty }
  its(:greeting_salutation) { should_not be_empty }
  its(:greeting_name) { should_not be_empty }
  its(:greeting_string) { should_not be_empty }
  its(:status) { should_not be_empty }
  its(:include_forward_email) { should_not be_empty }
  its(:include_subscribe_link) { should_not be_empty }
  its(:organization_name) { should_not be_empty }
end

describe Campaign do
  
  it { should be_a_kind_of Base }
  it_should_behave_like "a searchable class"

  before {
    set_default_credentials
    stub_get('/settings/emailaddresses','settings/email_addresses.xml')
    stub_get('/lists/1','/lists/1.xml')
  }

  context "class" do

    subject { 
      Campaign.new(:name => "Test Email",
        :subject => "Test Email",
        :email_content_format => "HTML",
        :email_text_content => "Test Email",
        :email_content => "<h1>Test Email</h1>")
    }

    it { should respond_to :encode }

    context '.to_xml' do
      its(:to_xml) { should match /<Campaign xmlns=\"http:\/\/ws.constantcontact.com\/ns\/1.0\/\"/ }
      its(:to_xml) { should match /<Name>/ }
    end

  end

#####################
# Listing Campaigns #
#####################

  # You can get a list of campaigns avaialble in your account 
  # by using the GET method on the campaigns collection:
  describe ".all" do

    before do
      stub_get('/campaigns', 'campaigns.xml')
    end

    subject { Campaign.all }
    it { should have(3).items }

    context "first item" do
      subject { Campaign.all.first }
      it { should be_a_kind_of Campaign }
      its(:name) { should == "Nationwide 221111" }
      its(:id) { should == "http://api.constantcontact.com/ws/customers/joesflowers/campaigns/1108737216651" }
      its(:status) { should == "Sent" }
      its(:date) { should == "2011-11-22T15:26:32.156Z" }

      it_should_behave_like "a default campaign"
    end
  end

  # search
  # campaigns?status=SENT
  # Below are the choices of status for query:
  # Status  Description
  # SENT  All campaigns that have been sent and not currently scheduled for resend
  # SCHEDULED   All campaigns that are currently scheduled to be sent some time in the future
  # DRAFT   All campaigns that have not yet been scheduled for delivery
  # RUNNING   All campaigns that are currently being processed and delivered
  describe "search" do
    before do
      stub_get('/campaigns?status=SENT', '/campaigns/sent.xml')
    end
    subject { Campaign.search(:status => 'SENT') }
    it { should have(3).items }

    context "first item" do
      subject { Campaign.search(:status => 'SENT').first }
      it_should_behave_like "a default campaign"
    end
  end

##################################
# Obtaining Campaign Information #
##################################

  # To get more details for a particular campaign, you need to  
  # use the <link> provided inside <entry> to construct a new URI 
  # and query the campaign itself, and the resulting URI would look like the following:
  context "get more details of a particular campaign" do
    before do
      stub_get('/campaigns/1100545398420', '/campaigns/1100545398420.xml')
    end
    subject { Campaign.find(1100545398420) }
    it { should be_a_kind_of Campaign }
    its(:name) { should == "joesflowers custom campaign HTML" }
    its(:id) { should == "http://api.constantcontact.com/ws/customers/joesflowers/campaigns/1100545398420" }
    its(:status) { should == "Draft" }
    its(:date) { should == "2009-10-01T18:42:56.939Z" }
    its(:contact_lists) { should have(1).item }
    its(:from_email) { should be_a_kind_of EmailAddress }
    its(:reply_to_email) { should be_a_kind_of EmailAddress }

    context "ContactList" do
      subject { Campaign.find(1100545398420).contact_lists.first }
      # TODO - refactor contact_lists method to return an array of ContactLists
      #it { should be_a_kind_of ContactList }
    end
  end

#######################
# Creating a Campaign #
#######################

  describe ".new" do

    context "without parameters" do
      subject { Campaign.new }
      it { Base.user.should == "joesflowers" }
      its(:from_name) { should == "joesflowers" }
      its(:view_as_webpage) { should == "NO" }
      its(:to_atom) { should match /<Campaign/ }
      its(:to_atom) { should match /http:\/\/api.constantcontact.com\/ws\/customers\/joesflowers\/lists\/1/ }
      it { should be_valid } # is this right? surely it should require some default values first?

      it_should_behave_like "a default campaign"

      context ".save" do
        before do
          stub_post('/campaigns', 'nocontent.xml')
          subject.save
        end
        it { should be_valid }
      end

    end

    context "with parameters" do
      subject { Campaign.new(:name => "Test Email",
        :subject => "Test Email",
        :from_name => "Joe",
        :email_content_format => "HTML",
        :email_text_content => "Test Email",
        :email_content => "<h1>Test Email</h1>", 
        :list_ids => [7,8]) }
      its(:from_name) { should == "Joe" }
      its(:contact_lists) { should == [7,8] }
    end

    context "with attributes hash" do
      subject do
        Campaign.new(
          {
            "id"=>"http://api.constantcontact.com/ws/customers/joesflowers/campaigns/1108737216651", 
            "xmlns"=>"http://ws.constantcontact.com/ns/1.0/", 
            "name"=>"Nationwide 221111", 
            "status"=>"Sent", 
            "date"=>"2011-11-22T15:26:32.156Z", 
            "from_name"=>"joesflowers", 
            "permission_reminder"=>"YES", 
            "permission_reminder_text"=>"You are receiving this email because of your relationship with us. Please <ConfirmOptin><a style=\"color:#0000ff;\">confirm</a></ConfirmOptin> your continued interest in receiving email from us.", 
            "greeting_salutation"=>"Dear", 
            "greeting_name"=>"FirstName", 
            "greeting_string"=>"Greetings!", 
            "include_forward_email"=>"NO", 
            "include_subscribe_link"=>"NO", 
            "organization_name"=>"joesflowers", 
            "organization_address1"=>"123 Main", 
            "organization_city"=>"Kansas City", 
            "organization_state"=>"KS", 
            "organization_international_state"=>"", 
            "organization_country"=>"US", 
            "organization_postal_code"=>"64108"}

        )
      end
      it { should be_valid }
      it_should_behave_like "a default campaign"
    end

    context "with attributes array" do
      subject { Contact.new([{"id"=>"http://api.constantcontact.com/ws/customers/joesflowers/contacts/2", "xmlns"=>"http://ws.constantcontact.com/ns/1.0/", "Status"=>"Active", "EmailAddress"=>"jon@example.com", "EmailType"=>"HTML", "Name"=>"jon smith", "FirstName"=>"jon", "MiddleName"=>nil, "LastName"=>"smith", "JobTitle"=>nil, "CompanyName"=>nil, "HomePhone"=>nil, "WorkPhone"=>nil, "Addr1"=>nil, "Addr2"=>nil, "Addr3"=>nil, "City"=>nil, "StateCode"=>nil, "StateName"=>nil, "CountryCode"=>nil, "CountryName"=>nil, "PostalCode"=>nil, "SubPostalCode"=>nil, "Note"=>nil, "CustomField1"=>nil, "CustomField2"=>nil, "CustomField3"=>nil, "CustomField4"=>nil, "CustomField5"=>nil, "CustomField6"=>nil, "CustomField7"=>nil, "CustomField8"=>nil, "CustomField9"=>nil, "CustomField10"=>nil, "CustomField11"=>nil, "CustomField12"=>nil, "CustomField13"=>nil, "CustomField14"=>nil, "CustomField15"=>nil, "ContactLists"=>{"ContactList"=>{"id"=>"http://api.constantcontact.com/ws/customers/joesflowers/lists/1", "link"=>{"href"=>"/ws/customers/joesflowers/lists/1", "rel"=>"self", "xmlns"=>"http://www.w3.org/2005/Atom"}, "OptInSource"=>"ACTION_BY_CUSTOMER", "OptInTime"=>"2010-04-21T18:35:34.175Z"}}, "Confirmed"=>"false", "InsertTime"=>"2010-04-21T18:35:34.066Z", "LastUpdateTime"=>"2010-04-21T18:35:34.279Z"}]) }
      it { should be_valid }
      its(:name) { should == "jon smith" }
      its(:contact_lists) { should == [ContactList.find(1)] }
      its(:status) { should == "Active" }
    end
  end

#######################
# Updating a Campaign #
#######################

  # To update a campaign, the easiest way is to get details 
  # of a campaign, as described in Obtaining a Campaign's Information, 
  # and modify only the elements you would like to change, and use the 
  # resulting XML through a PUT operation on the campaign URI.

  # When updating a campaign, you can change values of elements 
  # that are marked as editable in the Campaign Collection Reference.
  # http://community.constantcontact.com/t5/Documentation/Campaigns-Collection/ba-p/25111
  context "updating a campaign" do

    before do
      stub_get('/campaigns/1100545398420', '/campaigns/1100545398420.xml')
    end

    subject { Campaign.find(1100545398420) }

    context "with editable fields" do # ensure we can only update editable fields
      Campaign::EDITABLE.each do |attribute|
        it ".#{attribute.to_s} should update" do
          case attribute
          when :from_email
          when :reply_to_email
            # test with EmailAddress
          when :contact_lists
            # test with ContactList
          when :greeting_name
          when :email_content_format
            # use restricted values
          else
            subject.send("#{attribute}=","Updated")
            subject.send(attribute).should == "Updated"
          end
        end
      end
    end

    context "with non editable fields" do
      Campaign::NON_EDITABLE.each do |attribute|
        it ".#{attribute.to_s} should not update" do
          case attribute
          when :from_email
          when :reply_to_email
            # test with EmailAddress
          when :contact_lists
            # test with ContactList
          else
            subject.send("#{attribute}=","Updated")
            subject.send(attribute).should_not == "Updated"
            # it { should have_error_on :email } # rather than update an invalidate the object, lets just make sure its a read only
          end
        end
      end
    end

    context "with invalid values" do
      it ".greeting_name should not update" do
        begin
          subject.greeting_name = "Updated"
        rescue
        end
        subject.greeting_name.should_not == "Updated"
      end
    end
  end

#####################################
# Scheduling and Sending a Campaign #
#####################################


end