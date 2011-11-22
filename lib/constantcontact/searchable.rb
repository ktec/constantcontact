module ConstantContact
  module Searchable
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # List By Search Criteria
      # Ex: ConstantContact::Contact.search(:email => "john.doe@example.com", :country => "CA")
      # Available criteria are: city, state, country, zip, phone, email
      def search(options = {})
        search_params = options.inject({}) { |h, (k, v)| h[k] = v; h }
        # This might have to be changed in the future if other non-pagable resources become searchable
        if self.respond_to?(:find_all_across_pages)
          self.find_all_across_pages(:from => "#{self.collection_path}", :params => search_params)
        else
          self.find(:all, {:from => "#{self.collection_path}", :params => search_params})
        end
      end
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

      # Builds the query string for the request.
      def query_string(options)
        #if options[:email].kind_of? Array
        #  query = options.collect do |k,v|
        #    if v.kind_of?(Array)
        #      v.collect {|v| v.to_query(k) }
        #    else
        #      v.to_query
        #    end
        #  end.sort * "&"
        #  query = "?#{query}"
       # else
          "?#{options.to_query}" unless options.nil? || options.empty?
        #end
      end
=end
    end
  end
end

class Array
  # Converts an array into a string suitable for use as a URL query string,
  # using the given +key+ as the param name.
  #
  # ['Rails', 'coding'].to_query('hobbies') # => "hobbies%5B%5D=Rails&hobbies%5B%5D=coding"
  def to_query(key)
    prefix = "#{key}"
    collect { |value| value.to_query(prefix) }.join '&'
  end
end

=begin


#Object
  def to_query(key)
    require 'cgi' unless defined?(CGI) && defined?(CGI::escape)
    "#{CGI.escape(key.to_param)}=#{CGI.escape(to_param.to_s)}"
  end
#Array
  def to_query(key)
    prefix = "#{key}[]"
    collect { |value| value.to_query(prefix) }.join '&'
  end
#Hash
  def to_param(namespace = nil)
    collect do |key, value|
      value.to_query(namespace ? "#{namespace}[#{key}]" : key)
    end.sort * '&'
  end

=end