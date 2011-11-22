require 'spec_helper'

describe ActiveResource::Formats::UrlEncodeFormat do

  describe do

    before { 
      class AtomFormatter
        include ActiveResource::Formats::UrlEncodeFormat
      end
    }
    subject { AtomFormatter.new }

    its(:extension) { should eq ("")}
    its(:mime_type) { should eq ("application/x-www-form-urlencoded")}

  end

end