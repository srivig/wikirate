include_set Abstract::MetricChild, generation: 1

event :validate_type_of_existing_values, :validate,
      on: :save, changed: :content do
  case value_type
  when "Number", "Money" then validate_numeric_values
  when "Category" then validate_categorical_values
  end
end

def validate_categorical_values
  invalid_categories = existing_value_keys - valid_category_keys
  add_categorical_error invalid_categories if invalid_categories.present?
end

def existing_value_keys
  values = Answer.where(metric_id: left.id).select(:value).distinct
  values.map { |n| n.value.to_name.key }
end

def valid_category_keys
  keys = value_options.map { |n| n.to_name.key }
  keys << "unknown"
end

def validate_numeric_values
  metric_card.all_answers.find do |answer|
    next if valid_numeric_value? answer.value
    add_numeric_error answer
  end
end

def valid_numeric_value? value
  number?(value) || value.strip.casecmp("unknown").zero?
end

def add_numeric_error answer
  errors.add Card.fetch_name(answer.answer_id),
             "'#{answer.value}' is not a numeric value."
end

def add_categorical_error invalid_options
  errors.add :value, quoted_list(invalid_options) +
                     " is not an option for this metric. " \
                     "Please #{link_to_edit_options} first."
end

def link_to_edit_options
  format.link_to_card value_options_card, "add the values to options card",
                      path: { view: :edit }, target: "_blank"
end

def quoted_list list
  list.map { |o| "\"#{o}\"" }.join ", "
end
