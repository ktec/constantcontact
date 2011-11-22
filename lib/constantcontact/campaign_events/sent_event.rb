module ConstantContact
	module CampaignEvents
		class SentEvent < CampaignEvents::Base
			def self.collection_name
				'sends'
			end
		end
	end
end
