Before("@background-jobs, @delayed-jobs, @javascript") do
  Card[:all, :script].update_machine_output
end