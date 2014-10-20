# -*- encoding : utf-8 -*-
require 'link_thumbnailer'

describe Card::Set::Self::Webpage do
  describe "get meta data of url" do
    
    it "should handle invalid url" do
      
      url = 'abcdefg'
      page_card = Card["Page"]
      Card::Env.params[:url] = url
      result = page_card.format( :format=>:json)._render(:metadata) 

      result_hash = JSON.parse(result)
      result_hash["title"].should == ""
      result_hash["description"].should == ""
      result_hash["error"].should == 'invalid url'
     
    end
    it "should handle empty url" do
      url = ''
      page_card = Card["Page"]
      Card::Env.params[:url] = url
      result = page_card.format( :format=>:json)._render(:metadata) 

      result_hash = JSON.parse(result)
      result_hash["title"].should == ""
      result_hash["description"].should == ""
      result_hash["error"].should == 'empty url'
    end

    it "should handle normal existing url " do
      url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
      Card::Env.params[:sourcebox] = 'true'
      sourcepage = Card.create! :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {:content=> url} }
      
      page_card = Card["Page"]
      Card::Env.params[:url] = url
      result = page_card.format( :format=>:json)._render(:metadata) 

      result_hash = JSON.parse(result)
      Card.fetch("#{ sourcepage.name }+title").content.should == result_hash["title"]
      Card.fetch("#{ sourcepage.name }+description").content.should == result_hash["description"]
      result_hash["error"].empty?.should == true
    end

    it "should handle normal non existing url " do
      url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
      
      page_card = Card["Page"]
      Card::Env.params[:url] = url
      result = page_card.format( :format=>:json)._render(:metadata) 

      result_hash = JSON.parse(result)
      preview = LinkThumbnailer.generate(url)

      result_hash["title"].should == preview.title
      result_hash["description"].should == preview.description
      result_hash["error"].empty?.should == true
      
    end
  end
end