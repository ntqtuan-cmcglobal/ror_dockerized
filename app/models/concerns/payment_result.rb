module PaymentResult
  PENDING = 'pending'.freeze
  SUCCESS = 'success'.freeze
  ERROR   = 'error'.freeze

  def self.color_for(result)
    case result.to_s.downcase
    when SUCCESS
      'green'
    when ERROR
      'red'
    when PENDING
      'orange'
    else
      'black'
    end
  end
end
