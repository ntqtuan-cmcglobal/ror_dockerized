module PaymentResult
  PENDING  = 'pending'.freeze
  SUCCESS  = 'success'.freeze
  ERROR    = 'error'.freeze
  DISABLED = 'disabled'.freeze

  def self.color_for(result)
    case result.to_s.downcase
    when SUCCESS
      'green'
    when ERROR
      'red'
    when PENDING
      'orange'
    when DISABLED
      'gray'
    else
      'black'
    end
  end
end
