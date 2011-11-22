module ConstantContact
	module ContactEvents
		class ClickEvent < ContactEvents::Base
			def self.collection_name
				'clicks'
			end
		end
	end
end
