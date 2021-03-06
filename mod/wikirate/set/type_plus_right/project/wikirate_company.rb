include_set Abstract::Table

def project_name
  cardname.left
end

def company_project_card company_card
  Card.fetch company_card.name, project_name, new: {}
end

def all_company_project_cards
  item_cards.map do |company|
    next unless company.type_id == WikirateCompanyID
    company_project_card company
  end.compact
end

format :html do
  view :core do
    wrap_with :div, class: "progress-bar-table" do
      wikirate_table(
        :company, card.all_company_project_cards,
        [:company_thumbnail, :research_progress_bar, :research_button],
        header: ["Company", "Metrics Researched", "Research Company"],
        table: { class: "company-research" },
        td: { classes: ["metric", "progress-column", "button-column"] }
      )
    end
  end
end
