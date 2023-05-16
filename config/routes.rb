# routes.rb
Rails.application.routes.draw do
  root "analyzer#index"

  post "analyzer/filter_data", to: "analyzer#filter_data", as: :analyzer_filter_data
end
