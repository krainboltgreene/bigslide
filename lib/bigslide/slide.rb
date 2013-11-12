module Bigslide
  class Slide
    attr_reader :name
    attr_reader :link
    attr_reader :images

    def self.[](links)
      links.map.with_index { |link, index| new(link, index) }
    end

    def initialize(uri, position)
      data = Nokogiri::HTML(open(uri))
      @name = data.css(".headDiv2 h2 a, .headDiv h3 a").inner_text
      @link = data.css(".headDiv2 h2 a, .headDiv h3 a").first["src"]
      @images = data.css(".bpImageTop,.bpMore .bpBoth").map.with_index do |data, index|
        Image.new(data, index)
      end
      @position = position
    end

    def to_hash
      {
        name: name,
        link: link,
        images: images.map(&:to_hash),
        meta: {
          back: @position - 1,
          forward: @position + 1
        }
      }
    end
  end
end
