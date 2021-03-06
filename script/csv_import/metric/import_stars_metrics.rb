require_relative "../../../config/environment"
require_relative "metrics_csv_row"
require_relative "../../csv_file"

csv_path = File.expand_path "../data/stars_import.csv", __FILE__

Card::Auth.current_id = Card.fetch_id "Laureen van Breen"

CSVFile.new(csv_path, MetricCSVRow).import
