module ConstantContact
	module ContactEvents
		class BounceEvent < ContactEvents::Base
			def self.collection_name
				'bounces'
			end
		end
	end
end
