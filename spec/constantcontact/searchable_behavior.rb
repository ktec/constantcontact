shared_examples_for "a searchable class" do
  it { subject.class.included_modules.should include(Searchable) }

  it ".search" do
    find_args = {:from => "#{subject.class.collection_path}", :params => {:email => "john.doe@example.com", :zip => "90210"}}
    subject.class.should_receive(:find).with(:all, find_args)
    subject.class.search(:email => "john.doe@example.com", :zip => "90210")
  end
end
