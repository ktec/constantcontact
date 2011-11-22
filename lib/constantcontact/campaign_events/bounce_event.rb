module ConstantContact
	module CampaignEvents
		class BounceEvent < CampaignEvents::Base
			def self.collection_name
				'bounces'
			end
		end
	end
end
