module ConstantContact
	module CampaignEvents
		class Base < ConstantContact::Base
			self.site += "/campaigns/:campaign_id/events"            
		end
	end
end
