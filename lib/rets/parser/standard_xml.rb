# coding: utf-8
require 'cgi'

module Rets
  module Parser
    class StandardXML
      def self.parse_document(xml)
        properties = []

        Nokogiri::XML::Reader(xml).each do |node|
          if node.name == 'PropertyDetails'
            if node.inner_xml.size > 0
              properties << xml_to_hash(Nokogiri::XML(node.outer_xml).root)
            end
          end
        end
        properties
      end

      def self.xml_to_hash(xml, hash={})
        if xml.class == Nokogiri::XML::Element
          hash = set_attributes(xml, hash)
          return get_collection xml if collections.include? xml.name
        end

        xml.children.each do |child|
          if child.children.length == 1 && child.children[0].type == Nokogiri::XML::Reader::TYPE_TEXT
            hash[child.name] = child.children.first.text
          else
            if child.class == Nokogiri::XML::Element
              hash[child.name] = set_attributes(child, {})
              hash[child.name] = self.xml_to_hash(child, hash[child.name])
            else
              child.children.each do |node|
                hash[node.name] = set_attributes(node, {})
                hash[node.name] = self.xml_to_hash(node, {})
              end
            end
          end
        end
        hash
      end

      def self.set_attributes(xml, hash)
        if xml.attribute_nodes.length > 0
          xml.attribute_nodes.each do |attribute|
            hash[attribute.name] = attribute.value
          end
        end
        hash
      end

      def self.collections
        [
          "Phones",
          "Rooms",
          "UtilitiesAvailable",
          "Websites",
          "OpenHouse",
          "ParkingSpaces",
          "Photo",
          "Specialties",
          "Designations",
          "Languages"
        ]
      end

      def self.get_collection(xml)
        collection = []
        xml.children.each do |node|
          hash = set_attributes node, {}
          node.children.each do |item|
            hash[item.name] = item.text
          end
          collection << hash
        end
        collection
      end
    end
  end
end
