require 'spec_helper'

describe ConstantContact::Contact do
  it { should be_a_kind_of ConstantContact::Base }
  it_should_behave_like "a pageable class"
  it_should_behave_like "a searchable class"


  describe do

    before {
      ConstantContact::Base.api_key = 'api_key'
      ConstantContact::Base.user = 'joesflowers'
      ConstantContact::Base.password = 'password'
    }
    subject { ConstantContact::Contact.new(:id => 1, :name => "First Contact") }

    it ".find_by_name" do
      contact = ConstantContact::Contact.new(:id => 2, :name => "Another Contact")
      ConstantContact::Contact.should_receive(:find).with(:all).and_return([contact, subject])
      ConstantContact::Contact.find_by_name("First Contact").should == subject
    end

    describe ".new" do

      context "without parameters" do
        subject { ConstantContact::Contact.new( :name => "First Contact" ) }
        it { ConstantContact::Base.user == "joesflowers" }
        it { subject.opt_in_source.should == "ACTION_BY_CUSTOMER" }
        it { subject.contact_lists.should == nil } # Shouldn't this be should_not be nil?
        it { subject.to_atom.should match /<ContactList id="/ }
        it { subject.to_atom.should match /https:\/\/api.constantcontact.com\/ws\/customers\/joesflowers\/lists\/1/ }
      end

      context "with parameters" do
        subject { ConstantContact::Contact.new(:name => "First Contact", :list_ids => [7,8]) }
        it { subject.contact_lists.should == [7,8] }
      end

      context "with attributes from server" do
        subject {
          ConstantContact::Contact.new(
            {
              "id"=>"http://api.constantcontact.com/ws/customers/joesflowers/contacts/2", 
              "xmlns"=>"http://ws.constantcontact.com/ns/1.0/", 
              "Status"=>"Active", 
              "EmailAddress"=>"jon@example.com", 
              "EmailType"=>"HTML", 
              "Name"=>"jon smith", 
              "FirstName"=>"jon", 
              "MiddleName"=>nil, 
              "LastName"=>"smith", 
              "JobTitle"=>nil, 
              "CompanyName"=>nil, 
              "HomePhone"=>nil, 
              "WorkPhone"=>nil, 
              "Addr1"=>nil,
              "Addr2"=>nil,
              "Addr3"=>nil,
              "City"=>nil,
              "StateCode"=>nil,
              "StateName"=>nil,
              "CountryCode"=>nil,
              "CountryName"=>nil,
              "PostalCode"=>nil,
              "SubPostalCode"=>nil,
              "Note"=>nil,
              "ContactLists"=>{
                "ContactList"=>{
                  "id"=>"http://api.constantcontact.com/ws/customers/joesflowers/lists/1",
                  "link"=>{
                    "href"=>"/ws/customers/joesflowers/lists/1",
                    "rel"=>"self",
                    "xmlns"=>"http://www.w3.org/2005/Atom"},
                  "OptInSource"=>"ACTION_BY_CUSTOMER",
                  "OptInTime"=>"2010-04-21T18:35:34.175Z"
                }
              },
              "Confirmed"=>"false",
              "InsertTime"=>"2010-04-21T18:35:34.066Z",
              "LastUpdateTime"=>"2010-04-21T18:35:34.279Z"
            }
          )
        }
        it { subject.Name.should == "jon smith" }
        it { subject.EmailAddress.should == "jon@example.com" }
        it { subject.contact_lists.should == [1] }
        it { subject.Status.should == "Active" }
      end

      context "with parameters as array" do
        subject { ConstantContact::Contact.new([{"id"=>"http://api.constantcontact.com/ws/customers/joesflowers/contacts/2", "xmlns"=>"http://ws.constantcontact.com/ns/1.0/", "Status"=>"Active", "EmailAddress"=>"jon@example.com", "EmailType"=>"HTML", "Name"=>"jon smith", "FirstName"=>"jon", "MiddleName"=>nil, "LastName"=>"smith", "JobTitle"=>nil, "CompanyName"=>nil, "HomePhone"=>nil, "WorkPhone"=>nil, "Addr1"=>nil, "Addr2"=>nil, "Addr3"=>nil, "City"=>nil, "StateCode"=>nil, "StateName"=>nil, "CountryCode"=>nil, "CountryName"=>nil, "PostalCode"=>nil, "SubPostalCode"=>nil, "Note"=>nil, "CustomField1"=>nil, "CustomField2"=>nil, "CustomField3"=>nil, "CustomField4"=>nil, "CustomField5"=>nil, "CustomField6"=>nil, "CustomField7"=>nil, "CustomField8"=>nil, "CustomField9"=>nil, "CustomField10"=>nil, "CustomField11"=>nil, "CustomField12"=>nil, "CustomField13"=>nil, "CustomField14"=>nil, "CustomField15"=>nil, "ContactLists"=>{"ContactList"=>{"id"=>"http://api.constantcontact.com/ws/customers/joesflowers/lists/1", "link"=>{"href"=>"/ws/customers/joesflowers/lists/1", "rel"=>"self", "xmlns"=>"http://www.w3.org/2005/Atom"}, "OptInSource"=>"ACTION_BY_CUSTOMER", "OptInTime"=>"2010-04-21T18:35:34.175Z"}}, "Confirmed"=>"false", "InsertTime"=>"2010-04-21T18:35:34.066Z", "LastUpdateTime"=>"2010-04-21T18:35:34.279Z"}]) }
      end

      # Person.find(:all, :params => { :title => "CEO" })
      # # => GET /people.json?title=CEO
      context "find all active contacts" do
        stub_get('/contacts?Status=Active','multiple_contacts_by_emails.xml')
        subject { ConstantContact::Contact.find(:all, :params => {:Status => 'Active'}) }
        it { subject.count.should == 2 }
        it { subject[0].id.should == "http://api.constantcontact.com/ws/customers/joesflowers/contacts/2" }
      end

    end

    # encoding
    describe ".to_atom" do

      subject { ConstantContact::Contact.new(:email_address => "test_100@example.com") }
      
      it { subject.to_atom.should match /http:\/\/www.w3.org\/2005\/Atom/ }
      it { subject.to_atom.should match /<Contact xmlns=\"http:\/\/ws.constantcontact.com\/ns\/1.0\/\"/ }
      it { subject.to_atom.should match /\<\/Contact\>/ }
      it { subject.to_atom.should match /\<\/ContactLists\>/ }

      context "with multiple lists subscriptions" do
        before { subject.contact_lists = [1,2] }
        it { subject.to_atom.scan(/<ContactList /).length.should == 2 }
        it { subject.to_atom.should match /<ContactList id="#{Regexp.escape(subject.list_url(1))}"/ }
        it { subject.to_atom.should match /<ContactList id="#{Regexp.escape(subject.list_url(2))}"/ }
      end

    end

    describe ".search" do
      before {
        stub_get('/contacts', 'all_contacts.xml')
        stub_get('/contacts?email=jon%40example.com&n=0', 'single_contact_by_email.xml')
        stub_get('/contacts?email=jon%40example.com&n=1', 'nocontent.xml')
        stub_get('/contacts?email=jon%40example.com&email=my%40example.com&n=0', 'multiple_contacts_by_emails.xml')
        stub_get('/contacts?email=jon%40example.com&email=my%40example.com&n=1', 'nocontent.xml')
        stub_get('/contacts?email=jon%40example.com&email=my%40example.com&n=2', 'nocontent.xml')
      }

      context "for one email address" do
        subject { ConstantContact::Contact.search(:email => "jon@example.com") }
        it { subject.count.should == 1 }
        it { subject[0].Name == 'jon smith' }
      end

      context "for multiple address" do
        subject { ConstantContact::Contact.search(:email => ["jon@example.com", "my@example.com"]) }
        it { subject.count.should == 2 }
        it { subject[0].Name == 'jon smith' }
      end

    end

    describe ".find" do

      context "single contact by found by id" do
        before { stub_get('/contacts/2', 'single_contact_by_id.xml') }
        subject { ConstantContact::Contact.find(2) }
        it { subject.Name = 'jon smith' }
        it { subject.contact_lists == [1] }
      end

      context "single contact by found by id with no contact lists" do
        before { stub_get('/contacts/3', 'single_contact_by_id_with_no_contactlists.xml') }
        subject { ConstantContact::Contact.find(3) }
        it { subject.Name = 'jon smith' }
        it { subject.contact_lists == [] }
      end

    end

  end

end