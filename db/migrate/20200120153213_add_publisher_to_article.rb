class AddPublisherToArticle < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :publisher_id, :integer, foreign_key: true
  end
end
