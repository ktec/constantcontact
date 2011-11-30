require 'spec_helper'

describe ContactListMember do
  #it { should be_a_kind_of Base }

  # TODO - find out how to pass arguments to shared spec groups
  #        to deal with the prefix_option
  #it_should_behave_like "a searchable class"

  describe do

    before { set_default_credentials }
    subject { ContactListMember.new(:id => 1, :Name => "First ContactList Member", :params => {:contact_list_id => 2}) }

    context ".find" do
      
      # TODO - rename this
      it "when creating new items" do
        list = ContactListMember.new(:id => 2, :Name => "Another ContactList Member", :contact_list_id => 2)
        ContactListMember.should_receive(:find).with(:all).and_return([list, subject])
        ContactListMember.find_by_name("First ContactList Member", :contact_list_id => 2).should == subject
      end

###################################
# Contact List Members Collection #
###################################

      context "CLASS" do
        subject { ContactListMember }
        specify { subject.site.to_s.should eq("https://api.constantcontact.com/") }
        specify { subject.collection_path(:contact_list_id => 2).to_s.should eq("/ws/customers/joesflowers/lists/2/members") }
        specify { subject.element_path(1,:contact_list_id => 2).to_s.should eq("/ws/customers/joesflowers/lists/2/members/1") }        
      end

      context ".find :all" do
        before {
          stub_get('/lists/2/members', 'lists/2/members.xml') 
        }
        subject { ContactListMember.find(:all, :params => {:contact_list_id => 2} ) }
        it { subject.count.should == 3 }
      end

    end

  end

end