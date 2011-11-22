#require 'atom/feed'
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

      def decode(xml)
        xml.gsub!( /\<(\/?)atom\:/, '<\1' ) # the "events" feeds have "atom:" in front of tags, for some reason
        doc = REXML::Document.new(xml)
        return [] if no_content?(doc)
        result = Hash.from_xml(from_atom_data(doc))

        if is_collection?(doc)
          list = result['records']

          next_link = REXML::XPath.first(doc, "/feed/link[@rel='next']")
          if next_link
            next_path = next_link.attribute('href').value
            next_page = ::ConstantContact::Base.connection.get(next_path)
            next_page = [next_page] if Hash === next_page
            list.concat(next_page)
          end

          list
        else
          [result.values.first]
        end
      end

      private
      
      def from_atom_data(doc)
        if is_collection?(doc)
          content_from_collection(doc)
        else
          content_from_single_record(doc)
        end
      end
      
      def no_content?(doc)
        REXML::XPath.match(doc,'//content').size == 0
      end
      
      def is_collection?(doc)
        REXML::XPath.match(doc,'//content').size > 1
      end

      def content_from_single_record(doc)
        str = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        REXML::XPath.each(doc, '//content') do |e|
          content = e.children[1]
          str << content.to_s
        end
        str
      end
      
      def content_from_collection(doc)
        str = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><records type=\"array\">"
        REXML::XPath.each(doc, '//content') do |e|
          content = e.children[1]
          str << content.to_s
        end
        str << "</records>"
        str
      end
      
      def content_from_member(doc)
        str = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        REXML::XPath.each(doc, '//content') do |e|
         content = e.children[1].children
         str << content.to_s
        end
        str
      end


      
    end
  end
end