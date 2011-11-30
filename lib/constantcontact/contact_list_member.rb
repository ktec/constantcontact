module ConstantContact
  class ContactListMember < Base
  	self.prefix = "/lists/:contact_list_id/"
    self.collection_name = "members"
  	include Searchable
  end
end