format :html do
  view :progress_bar do
    value = card.raw_content
    if card.number? value
      progress_bar value: value
    else
      "Only card with numeric content can be shown as progress bar."
    end
  end

  def progress_bar *sections
    wrap_with :div, class: "progress" do
      Array.wrap(sections).map do |section_args|
        progress_bar_section section_args
      end.join
    end
  end

  def progress_bar_section args
    add_class args, "progress-bar"
    value = args.delete :value
    wrap_value = wrap_with :span, "#{value}%", class: "progress-value"
    body = args.delete(:body) || wrap_value
    wrap_with :div, body, args.reverse_merge(
      role: "progressbar", style: "width: #{value}%",
      "aria-valuenow" => value, "aria-valuemin" => 0, "aria-valuemax" => 100
    )
  end
end
