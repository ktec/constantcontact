module ConstantContact
	module ContactEvents
		class ForwardEvent < ContactEvents::Base
			def self.collection_name
				'forwards'
			end
		end
	end
end
