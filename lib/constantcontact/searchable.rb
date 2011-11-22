module ConstantContact
  module Searchable
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Available criteria are: city, state, country, zip, phone, email
      def search(options = {})
        search_params = options.inject({}) { |h, (k, v)| h[k] = v; h }
        self.find(:all, {:from => "#{self.collection_path}", :params => search_params})
      end

      def query_string(options)
        begin
          super(options).gsub('%5B%5D','')
        rescue
        end
      end

    end
  end
end
