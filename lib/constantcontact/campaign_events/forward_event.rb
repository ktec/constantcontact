module ConstantContact
	module CampaignEvents
		class ForwardEvent < CampaignEvents::Base
			def self.collection_name
				'forwards'
			end
		end
	end
end
