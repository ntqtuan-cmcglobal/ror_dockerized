json.array! @products do |product|
  json.id product.id
  json.name product.name
  json.description product.description
  json.price product.price
  json.seller do
    json.id product.user.id
    json.full_name product.user.full_name
    json.email product.user.email
  end
  json.category do
    json.id product.category.id
    json.name product.category.name
  end
  json.digital_asset_url product.digital_asset.attached? ? url_for(product.digital_asset) : nil
  json.is_draft product.is_draft
  json.error_message product.error_message
  json.created_at product.created_at
  json.updated_at product.updated_at
end
