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
        hash ||= {}

        if xml.class != Nokogiri::XML::NodeSet && xml.name == 'PropertyDetails'
          hash = set_attributes(hash, xml)

          xml.children.each do |child|
            if child.children.length == 1 && child.children[0].type == Nokogiri::XML::Reader::TYPE_TEXT
              hash[child.name] = set_attributes({}, child)
              hash[child.name] = child.children[0].text
            else
              if child.name == 'Photo'
                hash["#{child.name}s"] = set_attributes({}, child)
                hash["#{child.name}s"] = get_photos(child) if child.name == "Photo"
              else
                hash[child.name] = set_attributes({}, child)
                hash[child.name] = self.xml_to_hash(child.children, hash[child.name])
              end
            end
          end
        elsif xml.class == Nokogiri::XML::NodeSet
          xml.each do |node|
            if node.children.length == 1 && node.children[0].type == Nokogiri::XML::Reader::TYPE_TEXT
              hash[node.name] = set_attributes({}, node)
              hash[node.name] = node.children[0].text
            else
              if node.name == 'Phones'
                hash[node.name] = []

                node.children.each do |child|
                  hash[node.name] << get_phone(child) if node.name == "Phones"
                end
              else
                hash[node.name] = set_attributes({}, node)
                hash[node.name] = self.xml_to_hash(node.children, hash[node.name])
              end
            end
          end
        end

        hash
      end

      def self.set_attributes(hash, xml)
        if xml.attributes.length > 0
          xml.attributes.each do |attribute|
            hash[attribute[1].name] = attribute[1].value
          end

          hash
        end
      end

      def self.get_phone(phone)
        hash = {}
        hash[phone.attributes["PhoneType"].value] = phone.text
        hash
      end

      def self.get_photos(child)
        photos = []
        child.children.each do |photo|
          hash = {}
          photo.children.each do |attribute|
            hash[attribute.name] = attribute.text
          end
          photos << hash
        end

        photos
      end
    end
  end
end
