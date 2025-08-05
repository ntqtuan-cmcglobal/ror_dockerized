json.data do
  json.id @order.id
  json.total_price @order.total_price
  json.status @order.status
  json.buyer do
    json.id @order.user.id
    json.full_name @order.user.full_name
    json.email @order.user.email
  end
  json.created_at @order.created_at
  json.updated_at @order.updated_at
  json.order_items @order.order_items do |item|
    json.id item.id
    json.product_id item.product_id
    json.price item.price
  end
end
