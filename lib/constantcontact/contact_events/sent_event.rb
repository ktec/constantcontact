module ConstantContact
	module ContactEvents
		class SentEvent < ContactEvents::Base
			def self.collection_name
				'sends'
			end
		end
	end
end
