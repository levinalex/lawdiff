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
      pos = elem["pos"].to_sym
      xpath = "//" + elem["at"].split("/").map { |id| "*[@ref='#{id}']" }.join("/")
      node = doc.to_xml.xpath(xpath)[0]

      h = { after:   ->(new){ node.add_next_sibling(new) },
            before:  ->(new){ node.add_previous_sibling(new) },
            append:  ->(new){ node.children.after(new) },
            prepend: ->(new){ node.children.before(new) } }

      h[pos].call(elem.children)
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

