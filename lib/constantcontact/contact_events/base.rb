module ConstantContact
	module ContactEvents
		class Base < ConstantContact::Base
			self.prefix = "/contacts/:contact_id/"            
	    self.collection_name = "events"
		end
	end
end
