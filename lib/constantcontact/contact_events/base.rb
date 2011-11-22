module ConstantContact
	module ContactEvents
		class Base < ConstantContact::Base
			self.site += "/contacts/:contact_id/events"            
		end
	end
end
