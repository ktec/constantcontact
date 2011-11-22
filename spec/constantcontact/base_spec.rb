require 'spec_helper'

describe Base do
  it { should be_a_kind_of ActiveResource::Base }


  describe do
    subject { Base }

    it { should respond_to :api_key }
    it { should respond_to :user }
    it { should respond_to :password }

    context "with credentials" do

      before {
        subject.api_key   = "api_key" 
        subject.user      = "user" 
        subject.password  = "password" 
      }

      its(:api_key) { should eq("api_key") }
      its(:user) { should eq("user") }
      its(:password) { should eq("password") }

      specify { subject.connection.user.should eq("api_key%user") }
      specify { subject.site.to_s.should eq("https://api.constantcontact.com/") }
      specify { subject.collection_path.to_s.should eq("/ws/customers/user/bases") }
      specify { subject.element_path(1).to_s.should eq("/ws/customers/user/bases/1") }
    end

    context "with updated credentials" do
      before {
        subject.api_key   = "api_key" 
        subject.user      = "user2" 
        subject.password  = "password" 
      }

      its(:api_key) { should eq("api_key") }
      its(:user) { should eq("user2") }
      its(:password) { should eq("password") }

      specify { subject.connection.user.should eq("api_key%user2") }
      specify { subject.site.to_s.should eq("https://api.constantcontact.com/") }
      specify { subject.collection_path.to_s.should eq("/ws/customers/user2/bases") }
      specify { subject.element_path(1).to_s.should eq("/ws/customers/user2/bases/1") }
    end
  end

  describe "dynamic finder methods" do
    before do
      @one   = Base.new(:id => 1, :name => "A deal")
      @two   = Base.new(:id => 2, :name => "A deal")
      @three = Base.new(:id => 3, :name => "Another deal")
      Base.should_receive(:find).with(:all).and_return([@one, @two, @three])
    end
    it ".find_by_(attribute) finds one" do
      Base.find_by_name("A deal").should == @one
    end
    it ".find_all_by_(attribute) finds all" do
      Base.find_all_by_name("A deal").should == [@one, @two]
    end
  end

  describe "support underscore method calls set" do

    context "with CamelCase" do
      subject { Base.new( :ViewAsWebpage => "Yes" ) }
      its(:view_as_webpage) { should == "Yes" }
      its(:ViewAsWebpage) { should == "Yes" }
    end

    context "with _underscore_ " do
      subject { Base.new( :view_as_webpage => "Yes" ) }
      its(:view_as_webpage) { should == "Yes" }
      its(:ViewAsWebpage) { should == "Yes" }
    end

    context "with both CamelCase and _underscore_ in the object invocation" do
      subject { Base.new( :view_as_webpage => "Yes", :ViewAsWebpage => "No" ) }
      its(:view_as_webpage) { should == "Yes" }
      its(:ViewAsWebpage) { should == "Yes" }
    end

  end 


end