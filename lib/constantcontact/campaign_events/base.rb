module ConstantContact
	module CampaignEvents
		class Base < ConstantContact::Base
			self.prefix = "/campaigns/:campaign_id/"            
	    self.collection_name = "events"
		end
	end
end
