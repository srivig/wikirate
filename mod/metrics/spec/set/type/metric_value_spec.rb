shared_examples_for "all_value_type" do |value_type, valid_cnt, invalid_cnt|
  before do
    login_as "joe_user"
    @metric = sample_metric value_type.to_sym
    @company = sample_company
    @error_msg =
      if value_type == :category
        "Please <a href='/Jedi+disturbances_in_the_Force+value_options?"\
        "view=edit' target=\"_blank\">add that option</a>"
      else
        "Only numeric content is valid for this metric."
      end
  end

  describe "add a new value" do
    let(:metric_value) do
      subcard =
        subcards_of_metric_value @metric, @company, @content
      Card.create type_id: Card::MetricValueID, subcards: subcard
    end

    context "value not fit the value type" do
      it "blocks adding a new value" do
        @content = invalid_cnt
        expect(metric_value.errors).to have_key(:value)
        expect(metric_value.errors[:value].first).to include(@error_msg)
      end
    end

    context "value fit the value type" do
      it "adds a new value" do
        @content = valid_cnt
        expect(metric_value.errors).to be_empty
      end
    end

    context 'value is "unknown"' do
      it "passes the validation" do
        @content = "unknown"
        expect(metric_value.errors).to be_empty
      end
    end
  end
end

shared_examples_for "numeric type" do |value_type|
  let(:metric) { sample_metric value_type.to_sym }
  let(:company) { sample_company }

  context "unknown value" do
    it "shows unknown instead of 0 in modal_details" do
      subcard =
        subcards_of_metric_value metric, company, "unknown"
      metric_value = Card.create type_id: Card::MetricValueID, subcards: subcard
      html = metric_value.format.render_modal_details
      expect(html).to have_tag("a", text: "unknown")
    end
  end
end

describe Card::Set::Type::MetricValue do
  let(:a_metric_value) do
    subcard =
      subcards_of_metric_value @metric, @company, "content"
    Card.create type_id: @mv_id, subcards: subcard
  end

  before do
    login_as "joe_user"
    @metric = sample_metric
    @company = sample_company
    @mv_id = Card::MetricValueID
  end

  describe "#metric" do
    it "returns metric name" do
      expect(a_metric_value.metric).to eq @metric.name
    end
  end

  context "value type is Number" do
    it_behaves_like "all_value_type", :number, "33", "hello", @numeric_error_msg
    it_behaves_like "numeric type", :number
  end

  context "value type is Money" do
    it_behaves_like "all_value_type", :money, "33", "hello", @numeric_error_msg

    describe "render views" do
      subject do
        metric = sample_metric :money
        subcard = subcards_of_metric_value metric, @company, "33"
        metric_value = Card.create type_id: @mv_id, subcards: subcard
        metric.update_attributes! subcards: { "+currency" => "$" }
        metric_value.format.render_concise
      end

      it "shows currency sign" do
        is_expected.to have_tag "span.metric-unit" do
          with_text " $ "
        end
      end

      it "shows year" do
        is_expected.to have_tag "span.metric-year" do
          with_text "2015 = "
        end
      end

      it "shows value" do
        is_expected.to have_tag "span.metric-value" do
          with_text "33"
        end
      end
    end
  end

  context "value type is category" do
    it_behaves_like "all_value_type", :category, "yes", "hello",
                    @categorical_error_msg
  end

  context "value type is free text" do
    let(:metric) { sample_metric }
    let(:company) { sample_company }
    let(:source) { sample_source }

    before do
      login_as "joe_user"
      @metric = sample_metric
      subcards_args = {
        "+Unit" => { "content" => "Imperial military units",
                     "type_id" => Card::PhraseID },
        "+Report Type" => { "content" => "Conflict Mineral Report",
                            "type_id" => Card::PointerID }
      }
      @metric.update_attributes! subcards: subcards_args
      subcard = subcards_of_metric_value metric, company, "hoi polloi",
                                         "2015", source.name
      @metric_value =
        Card.create! type_id: Card::MetricValueID, subcards: subcard
    end

    describe "getting related cards" do
      it "returns correct year" do
        expect(@metric_value.year).to eq("2015")
      end
      it "returns correct metric name" do
        expect(@metric_value.metric).to eq(metric.name)
      end
      it "returns correct company name" do
        expect(@metric_value.company_name).to eq(company.name)
      end
      it "returns correct company card" do
        expect(@metric_value.company_card.id).to eq(company.id)
      end
      it "returns correct metric card" do
        expect(@metric_value.metric_card.id).to eq(metric.id)
      end
    end

    describe "#autoname" do
      it "sets a correct autoname" do
        name = "#{metric.name}+#{company.name}+2015"
        expect(@metric_value.name).to eq(name)
      end
    end

    it "saving correct value" do
      value_card = Card["#{@metric_value.name}+value"]
      expect(value_card.content).to eq("hoi polloi")
    end

    context "update metric value name" do
      it "succeeds" do
        new_name = "#{metric.name}+#{company.name}+2014"
        @metric_value.name = new_name
        @metric_value.save!
        expect(@metric_value.name).to eq(new_name)
      end
    end

    describe "+source" do
      let(:source_card) { @metric_value.fetch trait: :source }

      it "includes source in +source" do
        expect(source_card.item_names).to include(source.name)
      end

      it "updates source's company and report type" do
        source_company = source.fetch trait: :wikirate_company
        source_report_type = source.fetch trait: :report_type
        expect(source_company.item_cards).to include(company)
        report_name = "Conflict Mineral Report"
        expect(source_report_type.item_names).to include(report_name)
      end

      it "fails with a non-existing source" do
        subcard = {
          "+metric" => { "content" => @metric.name },
          "+company" => {
            "content" => "[[#{@company.name}]]",
            "type_id" => Card::PointerID
          },
          "+value" => {
            "content" => "I'm fine, I'm just not happy.",
            "type_id" => Card::PhraseID
          },
          "+year" => { "content" => "2014", "type_id" => Card::PointerID },
          "+source" => { "content" => "Page-1" }
        }
        fail_mv = Card.new type_id: Card::MetricValueID, subcards: subcard
        expect(fail_mv).not_to be_valid
        expect(fail_mv.errors).to have_key(:source)
      end

      it "fails if source card cannot be created" do
        subcard = {
          "+metric" => { "content" => @metric.name },
          "+company" => { "content" => "[[#{@company.name}]]",
                          :type_id => Card::PointerID },
          "+value" => { "content" => "I'm fine, I'm just not happy.",
                        :type_id => Card::PhraseID },
          "+year" => { "content" => "2015", :type_id => Card::PointerID }
        }
        fail_metric_value = Card.new type_id: Card::MetricValueID,
                                     subcards: subcard
        expect(fail_metric_value).not_to be_valid
        expect(fail_metric_value.errors).to have_key(:source)
      end
    end

    describe "update metric value's value" do
      it "updates metric value's value correctly" do
        quote = "if nobody hates you, you're doing something wrong."
        @metric_value.update_attributes! subcards: {
          "+value" => quote
        }
        metric_values_value_card = Card["#{@metric_value.name}+value"]
        expect(metric_values_value_card.content).to eq(quote)
      end
    end

    describe "views" do
      it "renders timeline data" do
        # url = "/#{@metric_value.cardname.url_key}?layout=modal&"\
        #      'slot%5Boptional_horizontal_menu%5D=hide&slot%5Bshow%5D=menu'
        html = @metric_value.format.render_timeline_data
        expect(html).to have_tag("div", with: { class: "timeline-row" }) do
          with_tag("div", with: { class: "timeline-dot" })
          with_tag("div", with: { class: "td year" }) do
            with_tag("span", text: "2015")
          end
          with_tag("div", with: { class: "td value" }) do
            with_tag("span", with: { class: "metric-value" }) do
              with_tag("a", text: "hoi polloi")
            end
            with_tag("span", with: { class: "metric-unit" },
                             text: /Imperial military units/)
          end
        end
      end

      it "renders modal_details" do
        url = "/#{@metric_value.cardname.url_key}?layout=modal&"\
              "slot%5Boptional_horizontal_menu%5D=hide&slot%5Bshow%5D=menu"
        html = @metric_value.format.render_modal_details
        expect(html).to have_tag("span", with: { class: "metric-value" }) do
          with_tag("a", with: { href: url },
                        text: "hoi polloi")
        end
      end

      it "renders concise" do
        html = @metric_value.format.render_concise

        expect(html).to have_tag("span", with: { class: "metric-year" },
                                         text: /2015 =/)
        expect(html).to have_tag("span", with: { class: "metric-value" })
        expect(html).to have_tag("span", with: { class: "metric-unit" },
                                         text: /Imperial military units/)
      end
    end
  end
end
