include_set Abstract::Header
include_set Abstract::Tabs
include_set Abstract::Media

format :html do
  def default_open_content_args args
    args[:left_class] ||= { class: "left-col nopadding" }
    args[:right_class] ||= { class: "right-col" }
    # args[:grid_option] ||= { md: [6, 6] }
  end

  view :open_content do |args|
    bs_layout container: false, fluid: true,
              class: @container_class do
      row 6, 6, class: "panel-margin-fix" do # args[:grid_option] do
        column _render_content_left_col, args[:left_class]
        column _render_content_right_col, args[:right_class]
      end
    end
  end

  view :rich_header do |args|
    bs_layout do
      row 12 do
        col text_with_image title: "", text: header_right, size: :large
      end
    end
  end

  def header_image
    wrap_with :div, class: "image-box large-rect" do
      field_nest(:image, size: :large)
    end
  end

  def header_right
    wrap_with :h2, _render_title, class: "header-right"
  end

  view :content_right_col do
    _render_tabs
  end

  view :content_left_col do
    # had slot before
    output [_render_rich_header, _render_data]
  end

  view :data, cache: :never do
    wrap do
      [_optional_render_filter, _render_table]
    end
  end
end