module ConstantContact
	module CampaignEvents
		class OpenEvent < CampaignEvents::Base
			def self.collection_name
				'opens'
			end
		end
	end
end
