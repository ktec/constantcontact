module ConstantContact
  class Activity < Base
  	self.format = ActiveResource::Formats::UrlEncodeFormat

    #attr_accessor :contacts, :lists, :activity_type, :raw_data # Data is a reserved word in Rails
    #attr_accessor :data, :contacts
#    schema do
#      attribute 'lists', :string
#      attribute 'contacts', :string
#      attribute 'data', :string
#    end

    attr_writer :data, :contacts

    def data
      @attributes[:data.to_s]
    end
    def contacts
      @attributes[:contacts.to_s]
    end

    def encode
      post_data = "activityType=#{self.activity_type}"
      case self.activity_type.to_sym
      when :SV_ADD
        post_data += self.encoded_data
        post_data += self.encoded_lists
      when :EXPORT_CONTACTS
        #do something
      when :CLEAR_CONTACTS_FROM_LISTS
        #do something
      end
      return post_data
    end

    def self.element_path(id, prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      id_val = Base.parse_id(id)
      id_val = id_val.blank? ? nil : "/#{id_val}"
      "#{collection_path}#{id_val}#{query_string(query_options)}"
    end

    protected
    def encoded_data
      result = "&data="
      if self.data.nil?
        result += CGI.escape("Email+Address,First+Name,Last+Name\n")
        contact_strings = []
        self.contacts.each do |contact|
          contact_strings << "#{contact.email_address}, #{contact.first_name}, #{contact.last_name}"
        end      
        result += CGI.escape(contact_strings.join("\n"))
      else
        result += CGI.escape(self.data)
      end
      result.gsub(/%2B/, "+")
    end

    def encoded_lists
      result = ""
    	return result unless self.lists
      self.lists.each do |list|
        if list.is_a?(Fixnum)
          list = ContactList.find(list) 
        end
        result += "&lists="
        result += CGI.escape(list.id)
      end
      return result
    end

  end
end