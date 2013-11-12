module Bigslide
  class Image
    attr_reader :source
    attr_reader :caption
    attr_reader :position

    def initialize(data, position)
      @position = position
      @source = data.css(".bpImage").first["src"]
      @caption = data.css(".bpCaption").first.inner_text
      @active = data.css("a[name=photo1]").any?
    end

    def active
      "active" if @active
    end

    def to_hash
      {
        source: source,
        position: position,
        caption: caption,
        active: active
      }
    end
  end
end
