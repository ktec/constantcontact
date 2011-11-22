module ConstantContact
	module CampaignEvents
		class ClickEvent < CampaignEvents::Base
			def self.collection_name
				'clicks'
			end
		end
	end
end
