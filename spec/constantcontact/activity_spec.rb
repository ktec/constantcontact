require 'spec_helper'

describe Activity do
  it { should be_a_kind_of Base }

  describe do

    before { set_default_credentials }

    subject { Activity.new }

    it { should respond_to :encode }

    # protected method - test results not internal behaviour
    #its(:format) { should be_a_kind_of ActiveResource::Formats::HtmlEncodedFormat }

    describe ".encode" do

      # The following example shows the parameters used to upload
      # the Email Address, First Name and Last Name of three contacts 
      # (Fred Test, Joan Test and Ann Test) to two Contact Lists in 
      # the joesflowers account. Note that the three contacts are 
      # submitted in a single invocation of the Activities resource.

      context "with SV_ADD activity type" do

        before do
          @expected_result = "activityType=SV_ADD&data=Email+Address%2CFirst+Name%2CLast+Name%0Awstest3%40example.com%2C+Fred%2C+Test%0Awstest4%40example.com%2C+Joan%2C+Test%0Awstest5%40example.com%2C+Ann%2C+Test&lists=http%3A%2F%2Fapi.constantcontact.com%2Fws%2Fcustomers%2Fjoesflowers%2Flists%2F1&lists=http%3A%2F%2Fapi.constantcontact.com%2Fws%2Fcustomers%2Fjoesflowers%2Flists%2F2"
          stub_get('/lists/1', 'lists/1.xml')
          stub_get('/lists/2', 'lists/2.xml')
        end

        context "using the raw data method" do
          subject {
            Activity.new( 
              :activity_type => "SV_ADD", 
              :data => "Email Address,First Name,Last Name\nwstest3@example.com, Fred, Test\nwstest4@example.com, Joan, Test\nwstest5@example.com, Ann, Test",
              :lists => [1,2]#[ContactList.find(1),ContactList.find(2)] # TODO - shouldn't this accept << @list
            )
          }

          its(:encode) { should == @expected_result }
        end

        context "using Contact instances" do
          subject {
            fred = Contact.new(:first_name => "Fred", :last_name => "Test", :email_address => "wstest3@example.com")
            joan = Contact.new(:first_name => "Joan", :last_name => "Test", :email_address => "wstest4@example.com")
            ann = Contact.new(:first_name => "Ann", :last_name => "Test", :email_address => "wstest5@example.com")

            Activity.new( 
              :activity_type => "SV_ADD", 
              :contacts => [fred,joan,ann],
              :lists => [1,2]#[ContactList.find(1),ContactList.find(2)] # TODO - shouldn't this accept << @list
            )
          }

          its(:encode) { should == @expected_result }
        end

      end

      # The following example shows the parameters used to export 
      # the Email Address, First Name and Last Name of three contacts 
      # (Fred Test, Joan Test and Ann Test) from a list in the joesflowers account.
      context "with EXPORT_CONTACTS activity type" do

        before do
          @expected_result = "activityType=EXPORT_CONTACTS&fileType=CSV&exportOptDate=true&exportOptSource=true&exportListName=true&sortBy=DATE_DESC&columns=EMAIL%20ADDRESS&columns=FIRST%20NAME&columns=LAST%20NAME&listId=http%3A%2F%2Fapi.constantcontact.com%2Fws%2Fcustomers%2Fjoesflowers%2Flists%2F2"
          stub_get('/lists/2', 'lists/2.xml')
        end

        subject {
          Activity.new( 
            :activityType => "EXPORT_CONTACTS",
            :fileType => "CSV",
            :exportOptDate => true,
            :exportOptSource => true,
            :exportListName => true,
            :sortBy => "DATE_DESC",
            :columns => ["EMAIL ADDRESS","FIRST NAME", "LAST NAME"],
            :lists => [ContactList.find(2)]
          )
        }

        pending do
          its(:encode) { 
            should == @expected_result 
          }
        end

      end

      # The following example shows the parameters used to clear two 
      # contact lists, identified by ID's 1 and 2. Note that two contact
      # lists are submitted in a single invocation of the Activities resource.
      context "with CLEAR_CONTACTS_FROM_LISTS activity type" do

        before do
          @expected_result = "activityType=CLEAR_CONTACTS_FROM_LISTS&lists=http%3A%2F%2Fapi.constantcontact.com%2Fws%2Fcustomers%2Fjoesflowers%2Flists%2F1&lists=http%3A%2F%2Fapi.constantcontact.com%2Fws%2Fcustomers%2Fjoesflowers%2Flists%2F2"
          stub_get('/lists/2', 'lists/2.xml')
        end

        subject {
          Activity.new( 
            :activityType => "CLEAR_CONTACTS_FROM_LISTS",
            :lists => [ContactList.find(1),ContactList.find(2)]
          )
        }

        pending do
          its(:encode) { should == @expected_result }
        end

      end

    end

  end

end