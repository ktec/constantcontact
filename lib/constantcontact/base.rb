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

    protected

    DATE_FORMAT = "%Y-%m-%dT%H:%M:%SZ"

    # Fix for ActiveResource 3.1+ errors
    self.format = :atom

    self.site = "https://api.constantcontact.com/ws/customers"

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
          @connection.auth_type = auth_type if auth_type
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
        "#{prefix(prefix_options)}#{self.user}/#{collection_name}#{query_string(query_options)}"
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
        "#{collection_path}#{id_val}#{query_string(query_options)}"
      end

      private
=begin
      # Find every resource
      def find_every(options)
        begin
          case from = options[:from]
          when Symbol
            instantiate_collection(get(from, options[:params]))
          when String
            path = "#{from}#{query_string(options[:params])}"
            instantiate_collection(format.decode(connection.get(path, headers).body) || [])
          else
            prefix_options, query_options = split_options(options[:params])
            path = collection_path(prefix_options, query_options)
            instantiate_collection( (format.decode(connection.get(path, headers).body) || []), prefix_options )
          end
        rescue ActiveResource::ResourceNotFound
          # Swallowing ResourceNotFound exceptions and return nil - as per
          # ActiveRecord.
          nil
        end
      end

      def instantiate_record(record, prefix_options = {})
        new(record, true).tap do |resource|
          resource.prefix_options = prefix_options
        end
      end
=end

    end

    # Dynamic finder for attributes
    def self.method_missing(method, *args, &block)
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
end
