module OrderStatus
  UNPAID     = 'unpaid'.freeze
  PAID       = 'paid'.freeze # Seller can now see the "Delivering" button
  PENDING    = 'pending'.freeze # Seller clicked on "Delivering" button
  CANCELLED  = 'cancelled'.freeze # Seller/Admin/Buyer can cancel the order
  COMPLETED  = 'completed'.freeze # Admin/Buyer can mark the order as completed
end
