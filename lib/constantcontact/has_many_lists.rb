module ConstantContact
  module HasManyLists
    def self.included(base)
      base.send :include, (InstanceMethods)
    end

    module InstanceMethods

      def contact_lists
        return @contact_lists if defined?(@contact_lists)
        self.contact_lists = 1
        @contact_lists
      end

      def contact_lists=(val)
        @contact_lists = if val.kind_of?(Array)
            val.collect { |list| instantiate_contact_list(list)}
          else
            [instantiate_contact_list(val)]
          end
      end

      def instantiate_contact_list(list)
        return list if list.is_a? ContactList
        ContactList.find(list)
      end

    end
  end
end
