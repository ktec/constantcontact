module ConstantContact
  class Contact < Base
    include Searchable
  	include HasManyLists

    alias_attribute :email, :email_address

    def initialize(attributes = {}, persisted = false)
      attributes = attributes[0] if attributes.kind_of? Array
      @contact_lists = attributes.delete(:list_ids) if attributes.has_key? :list_ids 
      super
    end

    #attr_accessor :opt_in_source
    def opt_in_source
      @opt_in_source ||= "ACTION_BY_CUSTOMER"
    end
    
    # see http://developer.constantcontact.com/doc/manageContacts#create_contact for more info about the two values.
    def opt_in_source=(val)
      @opt_in_source = val if ['ACTION_BY_CONTACT','ACTION_BY_CUSTOMER'].include?(val)
    end

    def to_xml
      xml = Builder::XmlMarkup.new
      xml.tag!("Contact", :xmlns => "http://ws.constantcontact.com/ns/1.0/") do
        self.attributes.reject {|k,v| k == 'ContactLists'}.each{|k, v| xml.tag!( k.to_s.camelize, v )}
        xml.tag!("OptInSource", self.opt_in_source)
        xml.tag!("ContactLists") do
          #@contact_lists = [1] if @contact_lists.nil? && self.new?
          self.contact_lists.each do |list|
            xml.tag!("ContactList", :id=> list.url)
          end
        end
      end
    end

  end
end