require 'spec_helper'

describe ActiveResource::Formats::AtomFormat do

  describe do

    before { 
      class AtomFormatter
        include ActiveResource::Formats::AtomFormat
      end
    }
    subject { AtomFormatter.new }

    its(:extension) { should eq ("atom")}
    its(:mime_type) { should eq ("application/atom+xml")}

    context "with a collection" do
      before do 
        @xml = fixture_file('lists.xml') 
        @hash = {
          "records" => [
            {"id"=>"http://api.constantcontact.com/ws/customers/joesflowers/lists/active", "xmlns"=>"http://ws.constantcontact.com/ns/1.0/", "Name"=>"Active", "ShortName"=>"Active"}, 
            {"id"=>"http://api.constantcontact.com/ws/customers/joesflowers/lists/do-not-mail", "xmlns"=>"http://ws.constantcontact.com/ns/1.0/", "Name"=>"Do Not Mail", "ShortName"=>"Do Not Mail"}, 
            {"id"=>"http://api.constantcontact.com/ws/customers/joesflowers/lists/removed", "xmlns"=>"http://ws.constantcontact.com/ns/1.0/", "Name"=>"Removed", "ShortName"=>"Removed"}, 
            {"id"=>"http://api.constantcontact.com/ws/customers/joesflowers/lists/1", "xmlns"=>"http://ws.constantcontact.com/ns/1.0/", "OptInDefault"=>"true", "Name"=>"General Interest", "ShortName"=>"General Interest", "DisplayOnSignup"=>"Yes", "SortOrder"=>"1", "Members"=>{"id"=>"http://api.constantcontact.com/ws/customers/joesflowers/lists/1/members"}}, 
            {"id"=>"http://api.constantcontact.com/ws/customers/joesflowers/lists/2", "xmlns"=>"http://ws.constantcontact.com/ns/1.0/", "OptInDefault"=>"false", "Name"=>"Clients", "ShortName"=>"Clients", "DisplayOnSignup"=>"No", "SortOrder"=>"2", "Members"=>{"id"=>"http://api.constantcontact.com/ws/customers/joesflowers/lists/2/members"}}
          ]
        }
      end
      # TODO - REFACTOR!!!
      # this demonstrates exactly why having pagination inside the
      # format.decode class is wrong. A decoding class really should
      # know NOTHING about multiple pages, or connection objects
      specify { subject.decode(@xml).should be_a_kind_of Hash }
      specify { subject.decode(@xml).should == @hash }
      #specify { subject.encode().should be_a_kind_of String }
    end

    context "with a single item" do
      before do
        @xml = fixture_file('lists/2.xml')
        @hash = {"id"=>"http://api.constantcontact.com/ws/customers/joesflowers/lists/2", "xmlns"=>"http://ws.constantcontact.com/ns/1.0/", "OptInDefault"=>"false", "Name"=>"General Interest", "ShortName"=>"General Interest", "SortOrder"=>"1"}
      end
      specify { subject.decode(@xml).should be_a_kind_of Hash }
      specify { subject.decode(@xml).should == @hash }
    end

    context "with no content" do
      before { @xml = fixture_file('nocontent.xml') }
      specify { subject.decode(@xml).should be_a_kind_of Hash }
      specify { subject.decode(@xml).should == {} }
      #specify { subject.encode().should be_a_kind_of Hash }
    end

  end

end