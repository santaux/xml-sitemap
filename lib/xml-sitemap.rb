module XmlSitemap
  PERIODS = [:none, :always, :hourly, :daily, :weekly, :monthly, :yearly, :never]

  class Item
    attr_reader :path
    attr_reader :updated
    attr_reader :priority
    attr_reader :changefreq
    
    def initialize(opts={})
      @path = opts[:url] if opts.key?(:url)
      @updated = opts[:updated] || Time.now
      @priority = opts[:priority] || 1.0
      @changefreq = opts[:period] || :weekly
    end
  end

  class Map
    attr_reader :domain, :items
    attr_reader :buffer
    
    # Creates new Map class for specified domain
    def initialize(domain)
      @domain = domain
      @items = []
      yield self if block_given?
    end
    
    # Yields Map class for easier access
    def generate
      raise ArgumentError, 'Block required' unless block_given?
      yield self
    end
    
    # Add new item to sitemap list
    def add(opts)
      @items << XmlSitemap::Item.new(opts)
    end
    
    # Render XML
    def render
      return '' if @items.size == 0
      output = []
      output << '<?xml version="1.0" encoding="UTF-8"?>'
      output << '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
      @items.each do |item|
        output << '<url>'
          output << "<loc>http://#{@domain}#{item.path.to_s}</loc>"
          output << "<lastmod>#{item.updated.utc.strftime("%Y-%m-%dT%H:%M:%S-0000")}</lastmod>"
          output << "<changefreq>#{item.changefreq.to_s}</changefreq>"
          output << "<priority>#{item.priority.to_s}</priority>"
        output << '</url>'
      end
      output << '</urlset>'
      return output.join("\n")
    end
  end
end