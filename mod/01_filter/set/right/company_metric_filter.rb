def virtual?
  true
end

format :html do
  include Set::Abstract::Filter::HtmlFormat
  def filter_categories
    %w(metric wikirate_topic research_policy metric_type)
  end

  def filter_active?
    Env.params.keys.any? { |key| filter_categories.include? key }
  end

  def default_button_formgroup_args args
    args[:buttons] = [
      card_link(card.cardname.left, path_opts: { view: :content_left_col },
                                    text: "Reset",
                                    class: "slotter btn btn-default margin-8",
                                    remote: true),
      button_tag("Filter", situation: "primary", disable_with: "Filtering")
    ].join
  end

  view :core do |args|
    action = card.cardname.left_name.url_key
    filter_active = filter_active? ? "block" : "none"
    <<-HTML
    <div class="filter-container">
        <div class="filter-header">
          <span class="glyphicon glyphicon-filter"></span>
          Filter &amp; Sort
          <span class="filter-toggle">
            <span class="glyphicon glyphicon-triangle-right"></span>
          </span>
        </div>
        <div class="filter-details" style="display: #{filter_active};">
          <form action="/#{action}?view=content_left_col" method="GET" data-remote="true" class="slotter">
            <h4>Metric</h4>
            <div class="margin-12 sub-content"> #{metric_filter_fields(args).join} </div>
            <h4>Answer</h4>
            <div class="margin-12"> #{other_filter_fields(args).join} </div>
            <div class="filter-buttons">
              #{_optional_render :button_formgroup, args}
            </div>
          </form>
        </div>
    </div>
    HTML
  end

  def metric_filter_fields args
    [
      _optional_render(:name_formgroup, args),
      _optional_render(:wikirate_topic_formgroup, args),
      _optional_render(:research_policy_formgroup, args),
      _optional_render(:importance_formgroup, args),
      _optional_render(:metric_type_formgroup, args)
    ]
  end

  def other_filter_fields args
    [
      _optional_render(:metric_value_formgroup, args),
      _optional_render(:year_formgroup, args),
      content_tag(:hr),
      _optional_render(:sort_formgroup, args)
    ]
  end

  def default_sort_formgroup_args args
    args[:sort_options] = {
      "Importance to Community (up-voted by community)" => "upvoted",
      "Metric Designer (Alphabetical)" => "metric_designer",
      "Metric Title (Alphabetical)" => "metric_title",
      "Recently Updated" => "recent",
      "Most Values" => "value"
    }
    args[:sort_option_default] = "upvoted"
  end
end