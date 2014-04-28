view :core do |args|
  if topic = params[:topic]
    if topic_card = Card[topic]
      topic_name = topic_card.name
      topic_image = Card["#{topic_name}+image"]
      topic = topic_card.key
    end
  end
  
  topics = Card.search :type_id=>WikirateTopicID, :sort=>:name, :return=>:name
  topic_options = topics.map { |t| [t,t.to_name.key] }
  topic_select = select_tag "topic", options_for_select(topic_options, topic), :include_blank=>true

  
  all_companies = Card.search :type_id=>WikirateCompanyID, :sort=>:name, :return=>:name
  company_options = all_companies.map { |c| [c,c.to_name.key] }

  company_selects, analyses = [],[]
  %w{ 1 2 }.each do |i|
    if key = params["company#{i}"]
      if ccard = Card[key]
        cname = ccard.name
        ckey = ccard.key
      end
    end
    analyses << ( cname && topic_name ? Card.fetch("#{cname}+#{topic_name}") : nil )
    company_selects << select_tag( "company#{i}", options_for_select(company_options, ckey), :include_blank=>true )
  end
    
  analysis_args = { :view=>:titled, :show=>'title_link', :structure=>'analysis comparison'}
  
  
  %{
    <form>
      <table>
        <tr><th colspan="2">Topic</th></tr>
        <tr>
          <td>#{ topic_select }</td>
          <td>
            #{ 
              if topic.present? 
                link_to_page( raw( nest topic_image, :view=>:content, :size=>:small ), topic) +
                link_to_page( topic_name )
              end
            }
          </td>
        </tr>
        <tr><th colspan="2">Companies</th></tr>
        <tr>
          <td>#{ company_selects[0] }</td>
          <td>#{ company_selects[1] }</td>
        </tr>
      </table>
    </form>
    
    <div class="left-side" >#{ nest analyses[0], analysis_args.clone if analyses[0] } </div>
    <div class="right-side">#{ nest analyses[1], analysis_args       if analyses[1] } </div>
          

  }
end

