require 'spec_helper'

describe ContactList do
  it { should be_a_kind_of Base }
  it_should_behave_like "a searchable class"

  describe do

    before { set_default_credentials }
    subject { ContactList.new(:id => 1, :Name => "First ContactList") }

    context ".find" do
      
      # TODO - rename this
      it "when creating new items" do
        list = ContactList.new(:id => 2, :Name => "Another ContactList")
        ContactList.should_receive(:find).with(:all).and_return([list, subject])
        ContactList.find_by_name("First ContactList").should == subject
      end

      context "with stubbed content" do
        before { 
          stub_get('/lists', 'lists.xml') 
        }
        subject { ContactList.find_by_name("Clients") }
        its(:Name) { should == 'Clients' }
      end

    end

  end


###################################
# Contact List Members Collection #
###################################

# "/lists/1/members", "lists/1/members.xml"

#########################
# Contact List Resource #
#########################

# You can now obtain the number of contacts in a list.  Please 
# look for <ContactCount> tag in both the ContactList collection 
# and resource. The system contact lists, such as Removed, Active 
# or Do-Not-Mail, do not return the number of contacts at the moment.

#######################
# Creating a New List #
#######################

# A new Contact list is created by making an HTTP POST to the collection URI.

########################################
# Retrieving a Contact List Collection #
########################################

# To retrieve the collection of contact lists for the UserName joesflowers, 
# you perform an HTTP GET on the collection URI, 
# https://api.constantcontact.com/ws/customers/joesflowers/lists in this example,
# which returns the following XML document:

#################################
# Retrieving an Individual List #
#################################

# "/lists/1", "lists/1.xml"

###################
# Updating a List #
###################

# A Contact List is updated by issuing an HTTP PUT to the entry's URI. 

end