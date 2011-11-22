require 'spec_helper'

describe ConstantContact::Base do
	it { subject.should be_a_kind_of ActiveResource::Base }

	describe do
		subject { ConstantContact::Base }
		it { should respond_to :api_key }
		it { should respond_to :user }
		it { should respond_to :password }

		context ".api_key" do
			before { subject.api_key = "api_key" }
			it { subject.api_key.should eq("api_key") }
		end

		context ".user" do
			before { subject.user = "user" }
			it { subject.user.should eq("user") }
		end

		context ".password" do
			before { subject.password = "password" }
			it { subject.password.should eq("password") }
		end

		context "when all credentials are set correctly" do
			before do
				subject.api_key = "api_key" 
				subject.user = "user" 
				subject.password = "password" 
			end

			it "should construct the connection string correctly" do
				subject.connection.user.should eq("api_key%user")
			end
		end

	end

	describe "dynamic finder methods" do
		before do
			@one   = ConstantContact::Base.new(:id => 1, :name => "A deal")
			@two   = ConstantContact::Base.new(:id => 2, :name => "A deal")
			@three = ConstantContact::Base.new(:id => 3, :name => "Another deal")
			ConstantContact::Base.should_receive(:find).with(:all).and_return([@one, @two, @three])
		end
		it ".find_by_(attribute) finds one" do
			ConstantContact::Base.find_by_name("A deal").should == @one
		end
		it ".find_all_by_(attribute) finds all" do
			ConstantContact::Base.find_all_by_name("A deal").should == [@one, @two]
		end
	end	

end