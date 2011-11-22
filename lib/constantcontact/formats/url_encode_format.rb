module ActiveResource
  module Formats
    module UrlEncodeFormat
      extend self

      def extension
        ""
      end

      def mime_type
        "application/x-www-form-urlencoded"
      end

      def encode(hash, options = nil)
        # none
      end
      
      def decode(xml)
        {}
      end

    end
  end
end