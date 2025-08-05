json.data do
  json.array! @products do |product|
    json.id product.id
    json.name product.name
    json.description product.description
    json.price product.price
    if product.user
      json.seller do
        json.id product.user.id
        json.full_name product.user.full_name
        json.email product.user.email
      end
    end
    if product.category
      json.category do
        json.id product.category.id
        json.name product.category.name
      end
    end
    json.digital_asset_url product.digital_asset.attached? ? url_for(product.digital_asset) : nil
    json.is_draft product.is_draft
    json.error_message product.error_message
    json.created_at product.created_at
    json.updated_at product.updated_at
  end
end

json.pagination do
  json.current_page @pagination[:current_page]
  json.next_page @pagination[:next_page]
  json.prev_page @pagination[:prev_page]
  json.total_pages @pagination[:total_pages]
  json.total_count @pagination[:total_count]
end
