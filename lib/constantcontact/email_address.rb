# http://developer.constantcontact.com/doc/settingsemails
module ConstantContact
  class EmailAddress < Base
    self.element_name = 'settings/emailaddresses'
    def to_s
    	"#{self.email_address}"
    end
  end
end