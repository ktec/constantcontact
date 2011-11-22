module ConstantContact
	module ContactEvents
		class ReportsSummary < ContactEvents::Base
			def self.collection_name
				'summary'
			end
		end
	end
end
