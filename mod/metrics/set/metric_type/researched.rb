def score_cards
  # we don't check the metric type
  # we assume that a metric with left is a metric again is always a score
  Card.search type_id: MetricID,
              left_id: id
end

format :html do
  def default_content_formgroup_args _args
    super _args
    voo.edit_structure += [
      [:value_type,      "Value Type"],
      [:research_policy, "Research Policy"],
      [:report_type,     "Report Type"]
    ]
  end

  def tab_list
    super.merge source_tab: "#{fa_icon :globe} Sources",
                scores_tab: "Scores"
  end

  view :details_tab do |args|
    tab_wrap do
      wrap_with :div, class: "metric-details-content" do
        [
          _render_metric_properties(args),
          wrap_with(:hr, ""),
          nest(card.about_card, view: :titled, title: "About"),
          nest(card.methodology_card, view: :titled, title: "Methodology"),
          _render_import_button(args),
          _render_add_value_buttons
        ]
      end
    end
  end

  view :contributing do |args|
    heading = wrap_with(:div, "Contributing", class: "heading-content")
    value_type =
      wrap_with(:div, _render_value_type_detail(args))
    content = wrap_with :div, class: "contributing-details" do
      [
        value_type,
        nest(card.report_type_card, view: :titled,
                                    title: "Report type",
                                    items: { view: :name }),
        nest(card.research_policy_card, view: :titled,
                                        title: "Research Policy",
                                        items: { view: :name }),
        nest(card.project_card, view: :titled,
                                title: "Projects",
                                items: { view: "content",
                                         structure: "list item" }),
        _render_import_button(args)
      ]
    end
    heading + content
  end

  view :value_type_detail do
    # wrap do
    #   <<-HTML
    #     <div class="padding-bottom-10">
    #       <div class='row nopadding'>
    #         <div class="heading-content pull-left">Value Type</div>
    #         <div class="margin-8 pull-left">
    #           #{_render_value_type_edit_modal_link}
    #         </div>
    #       </div>
    #         #{_render_short_view}
    #     </div>
    #   HTML
    # end
   wrap_with :div do
     [
       _render_value_type_edit_modal_link,
       _render_short_view
     ]
   end
  end

  view :source_tab do
    tab_wrap do
      # TODO: get rid of process content
      process_content <<-HTML
      <div class="row">
        <div class="row-icon">
          <i class="fa fa-globe"></i>
        </div>
        <div class="row-data">
            {{+source|titled;title:Sources;|content;listing}}
        </div>
      </div>
      HTML
    end
  end

  view :scores_tab do |args|
    tab_wrap do
      wrap_with :div, class: "list-group" do
        card.score_cards.map do |item|
          subformat(item)._render_score_thumbnail(args)
        end
      end
    end
  end

  def add_value_path
    "/new/metric_value?metric=" + _render_cgi_escape_name
  end

  view :add_value_buttons do
    policy = card.fetch(trait: :research_policy, new: {}).item_cards.first.name
    is_admin = Card::Auth.always_ok?
    is_owner = Auth.current.id == card.creator.id
    is_designer_assessed = policy.casecmp("designer assessed").zero?
    # TODO: add metric designer respresentative logic here
    return if is_designer_assessed && !(is_admin || is_owner)
    <<-HTML
    <div class="row margin-no-left-15">
      <a class="btn btn-primary"  href='#{add_value_path}'>
        #{fa_icon 'plus'} Add new value
      </a>
    </div>
    HTML
  end

  view :import_button do
    <<-HTML
      <h5>Bulk Import</h5>
        <div class="btn-group" role="group" aria-label="...">
          <a class="btn btn-default btn-sm" href='/new/source?layout=wikirate%20layout'>
            <span class="fa fa-arrow-circle-o-down"></span>
            Import
          </a>
          <a class="btn btn-default btn-sm slotter"
             href='/import_metric_values?layout=modal'
             data-toggle='modal' data-target='#modal-main-slot'>
            Help <small>(how to)</small>
          </a>
        </div>
    HTML
  end
end