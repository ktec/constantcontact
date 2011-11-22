module ConstantContact
	module ContactEvents
		class OpenEvent < ContactEvents::Base
			def self.collection_name
				'opens'
			end
		end
	end
end
