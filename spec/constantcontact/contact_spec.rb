require 'spec_helper'

describe Contact do
  it { should be_a_kind_of Base }
  it_should_behave_like "a searchable class"

  describe do

    before do
      set_default_credentials
      stub_get('/lists/1', '/lists/1.xml')
      stub_get('/lists/7', '/lists/1.xml')
      stub_get('/lists/8', '/lists/2.xml')
    end

    subject { Contact.new(:id => 1, :name => "First Contact") }

    it { should respond_to :encode }

    #context "encode should call to_xml" do
    #  before { subject.encode }
    #  it { should_receive(:to_atom) }
    #end

    it ".find_by_name" do
      contact = Contact.new(:id => 2, :name => "Another Contact")
      Contact.should_receive(:find).with(:all).and_return([contact, subject])
      Contact.find_by_name("First Contact").should == subject
    end

    context "when saved" do

      context '.id' do
        pending "id returned should be an integer not the full uri that CC uses"
      end

    end

    describe ".new" do

      context "without parameters" do
        subject { Contact.new }
        it { Base.user.should == "joesflowers" }
        its(:opt_in_source) { should == "ACTION_BY_CUSTOMER" }
        its(:contact_lists) { should have(1).item } # Shouldn't this be should_not be nil?
        its(:to_atom) { should match /<ContactList id="/ }
        its(:to_atom) { should match /http:\/\/api.constantcontact.com\/ws\/customers\/joesflowers\/lists\/1/ }
      end

      context "with parameters" do
        subject { Contact.new(:name => "First Contact", :list_ids => [7,8]) }
        its(:name) { should == "First Contact" }
        its(:opt_in_source) { should == "ACTION_BY_CUSTOMER" }
        its(:contact_lists) { should have(2).items }
        context ".save" do
          before do
            stub_post('/contacts', 'nocontent.xml')
            subject.save
          end
          it { should be_valid }
        end
      end

      context "with attributes hash" do
        subject {
          Contact.new(
            {
              "id"=>"http://api.constantcontact.com/ws/customers/joesflowers/contacts/2", 
              "xmlns"=>"http://ws.constantcontact.com/ns/1.0/", 
              "Status"=>"Active", 
              "EmailAddress"=>"jon@example.com", 
              "EmailType"=>"HTML", 
              "Name"=>"jon smith", 
              "FirstName"=>"jon", 
              "LastName"=>"smith", 
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
        it { should be_valid }
        its(:Name) { should == "jon smith" }
        its(:EmailAddress) { should == "jon@example.com" }
        its(:contact_lists) { should have(1).item }
        its(:Status) { should == "Active" }
      end

      context "with attributes array" do
        subject { Contact.new([{"id"=>"http://api.constantcontact.com/ws/customers/joesflowers/contacts/2", "xmlns"=>"http://ws.constantcontact.com/ns/1.0/", "Status"=>"Active", "EmailAddress"=>"jon@example.com", "EmailType"=>"HTML", "Name"=>"jon smith", "FirstName"=>"jon", "MiddleName"=>nil, "LastName"=>"smith", "JobTitle"=>nil, "CompanyName"=>nil, "HomePhone"=>nil, "WorkPhone"=>nil, "Addr1"=>nil, "Addr2"=>nil, "Addr3"=>nil, "City"=>nil, "StateCode"=>nil, "StateName"=>nil, "CountryCode"=>nil, "CountryName"=>nil, "PostalCode"=>nil, "SubPostalCode"=>nil, "Note"=>nil, "CustomField1"=>nil, "CustomField2"=>nil, "CustomField3"=>nil, "CustomField4"=>nil, "CustomField5"=>nil, "CustomField6"=>nil, "CustomField7"=>nil, "CustomField8"=>nil, "CustomField9"=>nil, "CustomField10"=>nil, "CustomField11"=>nil, "CustomField12"=>nil, "CustomField13"=>nil, "CustomField14"=>nil, "CustomField15"=>nil, "ContactLists"=>{"ContactList"=>{"id"=>"http://api.constantcontact.com/ws/customers/joesflowers/lists/1", "link"=>{"href"=>"/ws/customers/joesflowers/lists/1", "rel"=>"self", "xmlns"=>"http://www.w3.org/2005/Atom"}, "OptInSource"=>"ACTION_BY_CUSTOMER", "OptInTime"=>"2010-04-21T18:35:34.175Z"}}, "Confirmed"=>"false", "InsertTime"=>"2010-04-21T18:35:34.066Z", "LastUpdateTime"=>"2010-04-21T18:35:34.279Z"}]) }
        it { should be_valid }
        its(:Name) { should == "jon smith" }
        its(:EmailAddress) { should == "jon@example.com" }
        its(:contact_lists) { should have(1).item }
        its(:Status) { should == "Active" }
      end
    end

    # encoding
    describe ".to_atom" do

      before do
        stub_get('/lists/1', 'lists/1.xml')
        stub_get('/lists/2', 'lists/2.xml')
      end

      subject { Contact.new(:email_address => "test_100@example.com" ) }
      
      its(:to_atom) { should match /Atom/ }
      its(:to_atom) { should match /ws.constantcontact.com/ }
      its(:to_atom) { should match /\<\/Contact\>/ }
      its(:to_atom) { should match /\<\/ContactLists\>/ }

      context "with multiple lists subscriptions" do
        before { subject.contact_lists = [ContactList.find(1),ContactList.find(2)] }
        specify { subject.to_atom.scan(/<ContactList /).length.should == 2 }
        # TODO -need to test the output more thoroughly
        specify { subject.to_atom.should match /<ContactList id=/ }
        specify { subject.to_atom.should match /<ContactList id=/ }
      end
    end

    describe ".search" do
      before {
        stub_get('/contacts?email=fred%40example.com', 'nocontent.xml')
        stub_get('/contacts?email=jon%40example.com', 'contacts/search1.xml')
        stub_get('/contacts?email=jon%40example.com&email=my%40example.com', 'contacts/search2.xml')
      }

      context "with no result" do
        subject { Contact.search(:email => "fred@example.com") }
        it { should have(0).item }
      end

      context "with one email address" do
        subject { Contact.search(:email => "jon@example.com") }
        it { should have(1).item }
        it { subject[0].Name == 'jon smith' }
      end

      context "with multiple addresses" do
        subject { Contact.search(:email => ["jon@example.com", "my@example.com"]) }
        it { should have(2).items }
        it { subject[0].Name == 'jon smith' }
      end
    end

    describe ".find" do

      context "single contact by id" do
        before { stub_get('/contacts/2', 'contacts/2.xml') }
        subject { Contact.find(2) }
        it { should be_valid }
        it { should be_a_kind_of Base }
        its(:Name) { should == 'jon smith' }
        its(:contact_lists) { should have(1).item }

        context "with no contact lists" do
          before { stub_get('/contacts/3', 'contacts/3.xml') }
          subject { Contact.find(3) }
          its(:Name) { should == 'jon smith' }
          its(:contact_lists) { should have(1).item }
        end

      end

      context "all active contacts" do
        stub_get('/contacts?status=Active','contacts/active.xml')
        subject { Contact.find(:all, :params => {:status => 'Active'}) }
        it { should have(2).items }
        specify { subject[0].id.should == "http://api.constantcontact.com/ws/customers/joesflowers/contacts/2" }
      end

      context "with multiple page results" do
        before {
          stub_get('/contacts', 'contacts.xml')
          stub_get('/contacts?page=2', 'contacts2.xml')
        }

        context "with one email address" do
          subject { Contact.all }
          it { should have(4).items }
          it { subject[0].Name.should == 'smith, jon' }
          it { subject.last.Name.should == 'Doe, Marvin2'}
        end

      end

    end

  end

######################
# Creating a Contact #
######################

# POST https://api.constantcontact.com/ws/customers/{username}/contacts

########################
# Listing All Contacts #
########################

# GET https://api.constantcontact.com/ws/customers/{username}/contacts

#####################################
# Obtaining a Contact's Information #
#####################################

# GET https://api.constantcontact.com/ws/customers/{username}/contacts/{contact-id}

#######################
# Opting-in a Contact #
#######################

# https://api.constantcontact.com/ws/customers/{username}/contacts/{contact-id}

# <OptInSource> must be ACTION_BY_CONTACT, which can only be used when the API 
# call is the direct result of an action performed by the contact (e.g. clicking 
# a Subscribe button in an application). It is a serious violation of the Constant 
# Contact Terms of Service to use the Opt-in features of the API in any other way 
# (i.e. opting in a contact without his or her action and consent).


########################
# Opting-out a Contact #
########################

# DELETE https://api.constantcontact.com/ws/customers/{username}/contacts/{contact-id}

##########################################
# Removing a Contact from a Contact List #
##########################################

# PUT https://api.constantcontact.com/ws/customers/{username}/contacts/{contact-id}

# simply remove all of the <ContactList> elements from the <ContactLists> element

############################################
# Searching for a Contact by Email Address #
############################################

# GET https://api.constantcontact.com/ws/customers/{username}/contacts?email={email-address}

########################################################################
# Searching for Contacts by Last Updated Date (Synchronizing Contacts) #
########################################################################

# GET https://api.constantcontact.com/ws/customers/{username}/contacts?updatedsince={date}&listid={numeric-list-id}

######################################
# Adding a Contact to a Contact List #
######################################

# PUT https://api.constantcontact.com/ws/customers/{username}/contacts/{contact-id} 

# simply remove all of the <ContactList> elements from the <ContactLists> element

################################
# Updating Contact Information #
################################

# PUT https://api.constantcontact.com/ws/customers/{username}/contacts/{contact-id} 

####################################
# Contacts Collection and Resource #
####################################

# GET https://api.constantcontact.com/ws/customers/{user-name}/contacts

# GET https://api.constantcontact.com/ws/customers/{user-name}/contacts/{contact-id}
# PUT https://api.constantcontact.com/ws/customers/{user-name}/contacts/{contact-id}

end