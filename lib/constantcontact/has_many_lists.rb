module ConstantContact
  module HasManyLists
    def self.included(base)
      base.send :include, (InstanceMethods)
    end

    module InstanceMethods

      def contact_lists
        return @contact_lists if defined?(@contact_lists)
        if attributes.has_key? "ContactLists" and attributes["ContactLists"].respond_to?:attributes and !attributes["ContactLists"].attributes.empty?
          self.contact_lists = attributes["ContactLists"]
        else
          self.contact_lists = 1
        end
        @contact_lists = [@contact_lists] unless @contact_lists.kind_of? Array 
        @contact_lists
      end

      def contact_lists=(collection)
        @contact_lists = if collection.kind_of?(Array)
            collection.collect { |list| instantiate_contact_list(list)}
          elsif collection.respond_to?:attributes
            collection.attributes["ContactList"]
          else
            instantiate_contact_list(collection)
          end
      end

      def instantiate_contact_list(list)
        return list if list.is_a? ContactList
        ContactList.find(list)
      end

    end
  end
end
