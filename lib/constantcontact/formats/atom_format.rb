#require 'atom'
require 'rexml/document'

module ActiveResource
  module Formats
    module AtomFormat
      extend self

      def extension
        "atom"
      end

      def mime_type
        "application/atom+xml"
      end

      def encode(hash, options = nil)
        hash.to_xml(options)
      end

      # returns {} or {:next_page=>"/page=2",:records=>[]}
      def decode(xml)
        xml.gsub!( /\<(\/?)atom\:/, '<\1' ) # the "events" feeds have "atom:" in front of tags, for some reason
        doc = REXML::Document.new(xml)
        data = REXML::XPath.match(doc, '//content')
        result = Hash.from_xml(from_content(data))
        case data.size
        when 0
          return {}
        when 1
          result['records'].first
        else
          # TODO - Not ideal, but the consumer needs to know this stuff!!
          next_link = REXML::XPath.first(doc, "/feed/link[@rel='next']")
          result[:next_page] = next_link.attribute('href').value if next_link
          result
        end
      end

      private

      def from_content(data)
        str = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><records type=\"array\">"
        data.each do |e|
          content = e.children[1]
          str << content.to_s
        end
        str << "</records>"
        str
      end
      
    end
  end
end