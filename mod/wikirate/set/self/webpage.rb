
def self.find_duplicates url
  duplicate_wql = { :right=>Card[:wikirate_link].name, :content=>url ,:left=>{:type_id=>Card::WebpageID}}
  duplicates = Card.search duplicate_wql
end

format :json do
  view :metadata do |args|
    metadata = MetaData.new
    url = Card::Env.params[:url]||args[:url] ||""
    if url.empty?
      metadata.error = 'empty url'
      return metadata.to_json
    end
    begin      
      metadata.website = URI(url).host
    rescue    
    end
    if !metadata.website
      metadata.error = 'invalid url' 
      return metadata.to_json
    end
    duplicates = Webpage.find_duplicates url
    if duplicates.any?
      origin_page_card = duplicates.first.left
      title =  Card["#{origin_page_card.name}+title"] ? Card["#{origin_page_card.name}+title"].content : ""
      description =  Card["#{origin_page_card.name}+description"] ? Card["#{origin_page_card.name}+description"].content : ""
      image_url = Card["#{origin_page_card.name}+image_url"] ? Card["#{origin_page_card.name}+image_url"].content : ""
      metadata.set_meta_data title,description,image_url
    else
      begin 
        preview = LinkThumbnailer.generate url
        if preview.images.length > 0
          image_url = preview.images.first.src.to_s
        end
          metadata.set_meta_data preview.title, preview.description, image_url
      rescue
      end
    end
    metadata.to_json
  end
end

class MetaData  
  attr_accessor :title,:description,:image_url,:website,:error
  def initialize()  
    @title = ""
    @description = ""
    @image_url  =""
    @website = ""
    @error = ""
  end  
  def set_meta_data title,desc,image_url
    @title = title
    @description = desc
    @image_url = image_url
  end
end  
