class RubyFormula < Formula
  def get_value year, metrics_with_values, i
    values = metrics.map do |metric|
      if (v = metrics_with_values[metric])
        v.to_f
      else
        nil
      end
    end.compact
    return if values.size != metrics.size
    @executed_lambda.call(values)
  end

  def to_lambda
    rb_formula = @formula.keyified
    metrics.each_with_index do |metric, i|
      rb_formula.gsub!("{{#{ metric }}}", "args[#{ i }]")
    end
    "lambda { |args| #{rb_formula}}"
  end

  def exec_lambda expr
    eval expr if safe_to_exec?(expr)
  end

  # allow only numbers, whitespace, mathematical operations and args references
  def safe_to_exec? expr
    expr.gsub(/args\[\d+\]/,'').match(/^lambda \{ \|args\| (.+)\}$/)
    $1 && $1.match(/^[\s\d+-\/*\.()]*$/)
  end
end