module ConstantContact
  class ContactList < Base
  	include Searchable
    self.element_name = "list"

    def to_xml
      xml = Builder::XmlMarkup.new
      xml.tag!("ContactList", :xmlns => "http://ws.constantcontact.com/ns/1.0/") do
        self.attributes.each do |k, v| 
          xml.tag!( k.to_s.camelize, v ) unless v.respond_to?(:to_xml)
        end
      end
    end

    def url
      if id =~ /http/
        "#{id}"
      else
        "#{::Base.site}#{::Base.user}/lists/#{id}"
      end
    end

    def self.find_by_name(name)
      lists = self.find :all
      lists.find{|list| list.Name == name}
    end

  end
end