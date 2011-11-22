module ConstantContact
  class Contact < Base
    include Pageable
  	include Searchable
  
    alias_attribute :email, :email_address

    def initialize(attributes = {}, persisted = false)
      attributes = attributes[0] if attributes.kind_of? Array
      super
      @contact_lists = attributes.delete(:list_ids) if attributes.has_key? :list_ids 
    end

    #attr_accessor :opt_in_source
    def opt_in_source
      @opt_in_source ||= "ACTION_BY_CUSTOMER"
    end
    
    # see http://developer.constantcontact.com/doc/manageContacts#create_contact for more info about the two values.
    def opt_in_source=(val)
      @opt_in_source = val if ['ACTION_BY_CONTACT','ACTION_BY_CUSTOMER'].include?(val)
    end

    def contact_lists
      return @contact_lists if defined?(@contact_lists)
      # otherwise, attempt to assign it
      @contact_lists = if self.attributes.keys.include?('ContactLists')
        if self.ContactLists
          if self.ContactLists.ContactList.is_a?(Array)
            self.ContactLists.ContactList.collect { |list|
              ConstantContact::Base.parse_id(list.id)
            }
          else
            [ ConstantContact::Base.parse_id(self.ContactLists.ContactList.id) ]
          end
        else
          [] # => Contact is not a member of any lists (legitimatly empty!)
        end
      else
        nil
      end
    end

    def contact_lists=(val)
      @contact_lists = val.kind_of?(Array) ? val : [val]
    end

    def list_url(id=nil)
      id ||= defined?(self.list_id) ? self.list_id : 1
      "#{ConstantContact::Base.site}#{ConstantContact::Base.user}/lists/#{id}"
    end

    def to_xml
      xml = Builder::XmlMarkup.new
      xml.tag!("Contact", :xmlns => "http://ws.constantcontact.com/ns/1.0/") do
        self.attributes.reject {|k,v| k == 'ContactLists'}.each{|k, v| xml.tag!( k.to_s.camelize, v )}
        xml.tag!("OptInSource", self.opt_in_source)
        xml.tag!("ContactLists") do
          @contact_lists = [1] if @contact_lists.nil? && self.new?
          self.contact_lists.sort.each do |list_id|
            xml.tag!("ContactList", :id=> self.list_url(list_id))
          end
        end
      end
    end

  end
end