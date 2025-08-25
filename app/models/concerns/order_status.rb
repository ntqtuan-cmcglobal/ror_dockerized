module OrderStatus
  UNPAID     = 'unpaid'.freeze
  PAID       = 'paid'.freeze
  CANCELLED  = 'cancelled'.freeze
  COMPLETED  = 'completed'.freeze

  def self.keys
    constants.map { |const| const_get(const) }
  end
end
