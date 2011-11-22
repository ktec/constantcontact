module ConstantContact
  module HasManyLists
    def self.included(base)
      base.send :include, (InstanceMethods)
    end

    module InstanceMethods

      # Also, shouldn't this return an array of ContactLists
      # rather than id - maybe contact_list_ids should return
      # the ids - and that can simply map the ids
      def contact_lists
        return @contact_lists if defined?(@contact_lists)
        # otherwise, attempt to assign it
        @contact_lists = if self.attributes.keys.include?('ContactLists')
          lists = self.ContactLists
          if lists
            if lists.ContactList.is_a?(Array)
              lists #.collect { |list| ::Base.parse_id(list.id) }
            else
              #[ ::Base.parse_id(lists.ContactList.id) ]
              [ lists.ContactList ]
            end
          else
            [ ContactList.new( :id=>"http://api.constantcontact.com/ws/customers/joesflowers/lists/1" ) ] # => Contact is not a member of any lists (legitimatly empty!)
          end
        else
          [ ContactList.new( :id=>"http://api.constantcontact.com/ws/customers/joesflowers/lists/1" ) ]
        end
      end

      def contact_lists=(val)
        @contact_lists = val.kind_of?(Array) ? val : [val]
      end

    end
  end
end
