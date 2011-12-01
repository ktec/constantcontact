require 'active_resource'

module ConstantContact
  class Base < ActiveResource::Base

    def to_atom(options={})
      "<entry xmlns=\"http://www.w3.org/2005/Atom\">
        <title type=\"text\"> </title>
        <updated>#{Time.now.strftime(DATE_FORMAT)}</updated>
        <author></author>
        <id>#{id.blank? ? 'data:,none' : id}</id>
        <summary type=\"text\">#{self.class.name.split('::').last}</summary>
        <content type=\"application/vnd.ctct+xml\">
        #{self.to_xml}
        </content>
      </entry>"
    end
    alias :encode :to_atom

    protected

    DATE_FORMAT = "%Y-%m-%dT%H:%M:%SZ"

    # Fix for ActiveResource 3.1+ errors
    self.format = :atom

    self.site = "https://api.constantcontact.com/"
    #self.timeout = 5

    class << self

      # Gets the \api_key for REST HTTP authentication.
      def api_key
        # Not using superclass_delegating_reader. See +site+ for explanation
        if defined?(@api_key)
          @api_key
        elsif superclass != Object && superclass.api_key
          superclass.api_key.dup.freeze
        end
      end

      # Sets the \api_key for REST HTTP authentication.
      def api_key=(api_key)
        @connection = nil
        @api_key = api_key
      end

      # An instance of ActiveResource::Connection that is the base \connection to the remote service.
      # The +refresh+ parameter toggles whether or not the \connection is refreshed at every request
      # or not (defaults to <tt>false</tt>).
      def connection(refresh = false)
        if defined?(@connection) || superclass == Object
          @connection = ActiveResource::Connection.new(site, format) if refresh || @connection.nil?
          @connection.proxy = proxy if proxy
          @connection.user = "#{api_key}%#{user}" if user
          @connection.password = password if password
          #@connection.auth_type = auth_type if auth_type
          @connection.timeout = timeout if timeout
          @connection.ssl_options = ssl_options if ssl_options
          @connection
        else
          superclass.connection
        end
      end
      
      def collection_path(prefix_options = {}, query_options = nil)
        check_prefix_options(prefix_options)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        "/ws/customers/#{self.user}#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
      end

      # Returns an integer which can be used in #find calls.
      # Assumes url structure with the id at the end, e.g.:
      #   http://api.constantcontact.com/ws/customers/yourname/contacts/29
      def parse_id(url)
        url.to_s.split('/').last.to_i
      end

      def element_path(id, prefix_options = {}, query_options = nil)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        integer_id = parse_id(id)
        id_val = integer_id.zero? ? nil : "/#{integer_id}"
        #"#{collection_path}#{id_val}#{query_string(query_options)}"
        "/ws/customers/#{self.user}#{prefix(prefix_options)}#{collection_name}/#{URI.unescape id.to_s}#{query_string(query_options)}"
      end
      
      # This is an alias for find(:all). You can pass in all the same
      # arguments to this method as you can to <tt>find(:all)</tt>
      def all(*args)
        find(:all, *args)
      end

      private

      def check_prefix_options(prefix_options)
        p_options = HashWithIndifferentAccess.new(prefix_options)
        prefix_parameters.each do |p|
          raise(MissingPrefixParam, "#{p} prefix_option is missing") if p_options[p].blank?      
        end
      end

      # returns array
      def decode(path)
        records = []
        next_path = path
        loop do
          if next_path
            result = format.decode(connection.get(next_path, headers))
            next_path = result[:next_page]
            records << ( result.has_key?("records") ? result["records"] : result )
          else
            break
          end
        end
        # this might come back to bite
        records.flatten.compact
      end

      # Find every resource
      def find_every(options)
        begin
          case from = options[:from]
          when Symbol
            instantiate_collection( get(from, options[:params]) )
          when String
            path = "#{from}#{query_string(options[:params])}"
            instantiate_collection( decode(path) || [] )
          else
            prefix_options, query_options = split_options(options[:params])
            path = collection_path(prefix_options, query_options)
            instantiate_collection( (decode(path) || []), prefix_options )
          end
        rescue ActiveResource::ResourceNotFound
          # Swallowing ResourceNotFound exceptions and return nil - as per
          # ActiveRecord.
          nil
        end
      end

      # Find a single resource from the default URL
      def find_single(scope, options)
        prefix_options, query_options = split_options(options[:params])
        path = element_path(scope, prefix_options, query_options)
        instantiate_record(format.decode(connection.get(path, headers)), prefix_options)
      end

      # Dynamic finder for attributes Base.find_by_fruit(:name=>'apples')
      def method_missing(method, *args, &block)
        if method.to_s =~ /^find_(all_)?by_([_a-zA-Z]\w*)$/
          raise ArgumentError, "Dynamic finder method must take an argument." if args.empty?
          options = args.extract_options!
          resources = send(:find, :all)
          resources.send($1 == 'all_' ? 'select' : 'detect') { |container| container.send($2) == args.first }
        else
          super
        end
      end
    end

    def initialize(attributes = {}, persisted = false)
      @attributes = {}.with_indifferent_access
      @prefix_options = {}
      @persisted = persisted
      load(attributes)
    end

    # A method to manually load attributes from a \hash. Recursively loads collections of
    # resources. This method is called in +initialize+ and +create+ when a \hash of attributes
    # is provided.
    #
    # ==== Examples
    # my_attrs = {:name => 'J&J Textiles', :industry => 'Cloth and textiles'}
    # my_attrs = {:name => 'Marty', :colors => ["red", "green", "blue"]}
    #
    # the_supplier = Supplier.find(:first)
    # the_supplier.name # => 'J&M Textiles'
    # the_supplier.load(my_attrs)
    # the_supplier.name('J&J Textiles')
    #
    # # These two calls are the same as Supplier.new(my_attrs)
    # my_supplier = Supplier.new
    # my_supplier.load(my_attrs)
    #
    # # These three calls are the same as Supplier.create(my_attrs)
    # your_supplier = Supplier.new
    # your_supplier.load(my_attrs)
    # your_supplier.save
    def load(attributes, remove_root = false)
      raise ArgumentError, "expected an attributes Hash, got #{attributes.inspect}" unless attributes.is_a?(Hash)
      @prefix_options, attributes = split_options(attributes)

      if attributes.keys.size == 1
        remove_root = self.class.element_name == attributes.keys.first.to_s
      end

      attributes = Formats.remove_root(attributes) if remove_root

      attributes.each do |key, value|
        @attributes[key.to_s] =
          case value
            when Array
              resource = nil
              value.map do |attrs|
                if attrs.is_a?(Hash)
                  resource ||= find_or_create_resource_for_collection(key)
                  resource.new(attrs)
                else
                  attrs.duplicable? ? attrs.dup : attrs
                end
              end
            when Hash
              resource = find_or_create_resource_for(key)
              resource.new(value)
            else
              value.duplicable? ? value.dup : value
          end
      end
      self
    end    

    # support underscore accessors to CamelCase the attributes hash
    def method_missing(method_symbol, *arguments, &block) #:nodoc:
      method_name = method_symbol.to_s
      if method_name =~ /(=|\?)$/
        case $1
        when "="
          attributes[search_attributes($`)] = arguments.first
        when "?"
          attributes[search_attributes($`)]
        end
      else
        key = search_attributes(method_name)
        return attributes[key] if attributes.has_key?(key)
        super
      end
    end

    # check the attributes hash for method_name.camelcase and method_name.underscore
    # and return the correct one, otherwise returns the same string
    # TODO - this could actually result in the instance containing TWO variables
    # the underscore takes preference - SOLUTION - ALL CamelCase is resolved in the
    # encode/decode stage (easier said than done), so the _ONLY_ time there is 
    # CamelCase is in ATOM/XML and throughout the ruby library we only use underscore.
    def search_attributes(method_name)
      return method_name.underscore if attributes.has_key?(method_name.underscore)
      # sorry for this next line, CC's consistency in naming conventions is shocking!
      mnc = method_name.camelize.gsub(/(Urls?)/){|s| $1.upcase }
      return mnc if attributes.has_key?(mnc)
      return method_name
    end

  end
end
