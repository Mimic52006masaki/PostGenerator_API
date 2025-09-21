class CreateDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :details do |t|
      t.references :post, null: false, foreign_key: true
      t.string :date
      t.text :content

      t.timestamps
    end
  end
end
