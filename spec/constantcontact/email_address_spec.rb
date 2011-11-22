require 'spec_helper'

describe EmailAddress do
  it { should be_a_kind_of Base }

  describe do

    before { set_default_credentials }
    subject { EmailAddress.new(:id => 1, :EmailAddress => "joesflowers@example.com") }

    context ".find" do
      
      # TODO - rename this
      it "by EmailAddress" do
        list = EmailAddress.new(:id => 2, :EmailAddress => "joesflowers2@example.com")
        EmailAddress.should_receive(:find).with(:all).and_return([list, subject])
        EmailAddress.find_by_EmailAddress("joesflowers@example.com").should == subject
      end

      context "with stubbed content" do
        before { stub_get('/settings/emailaddresses','settings/email_addresses.xml') }
        subject { EmailAddress.find_by_EmailAddress("joesflowers@example.com") }
        its(:EmailAddress) { should == 'joesflowers@example.com' }
      end

    end

  end

end