class TightenSchema < ActiveRecord::Migration[8.1]
  def change
    drop_table :taggings
    drop_table :tags
    drop_table :exports

    change_column_default :essays, :status, from: nil, to: "draft"
    change_column_null :essays, :title, false
    change_column_null :essays, :slug, false
    change_column_null :essays, :status, false, "draft"
    add_index :essays, [ :status, :published_at ]

    change_column_default :builds, :status, from: nil, to: "active"
    change_column_default :builds, :kind, from: nil, to: "other"
    change_column_null :builds, :title, false
    change_column_null :builds, :slug, false
    change_column_null :builds, :status, false, "active"
    change_column_null :builds, :kind, false, "other"
    change_column_null :builds, :position, false, 0

    change_column_default :books, :status, from: nil, to: "reading"
    change_column_null :books, :title, false
    change_column_null :books, :author, false
    change_column_null :books, :status, false, "reading"

    change_column_default :field_series, :kind, from: nil, to: "photo"
    change_column_null :field_series, :title, false
    change_column_null :field_series, :slug, false
    change_column_null :field_series, :kind, false, "photo"

    change_column_default :field_items, :kind, from: nil, to: "photo"
    change_column_null :field_items, :kind, false, "photo"
    change_column_null :field_items, :position, false, 1
    add_index :field_items, [ :field_series_id, :position ]

    remove_column :page_views, :updated_at, :datetime, null: false
    add_index :page_views, :created_at
  end
end
