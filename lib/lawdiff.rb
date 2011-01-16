require 'nokogiri'

module Lawdiff
  class Patch
    def initialize(xml)
      @xml = xml
    end

    def document_name
      @xml["document"]
    end

    def apply(store)
      document = store[:example]

      @xml.elements.each do |elem|
        add(document, elem)
      end

      return store
    end


    def add(doc, elem)
      where = elem["pos"]
      xpath = "//" + elem["at"].split("/").map { |id| "*[@ref='#{id}']" }.join("/")
      node = doc.to_xml.xpath(xpath)[0]

      case where
        when "after"
          node.add_next_sibling(elem.children)
        when "before"
          node.add_previous_sibling(elem.children)
        when "append"
          node.children.after(elem.children)
        when "prepend"
          node.children.before(elem.children)
        else
          raise "ERROR!"
      end
    end
  end


  class Document
    def initialize(xml)
      @xml = xml
    end

    def patches
      @xml.xpath("//patch[not(ancestor::patch)]").map { |xml| Patch.new(xml) }
    end

    def self.from_file(fname)
      xml = File.open(fname) do |f| Nokogiri::XML(f) end
      new(xml)
    end

    def to_xml
      @xml
    end

  end
end

