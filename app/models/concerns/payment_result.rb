module PaymentResult
  PENDING  = 'pending'
  SUCCESS  = 'success'
  ERROR    = 'error'
  DISABLED = 'disabled'

  COLOR_MAP = {
    SUCCESS => 'green',
    ERROR => 'red',
    PENDING => 'orange',
    DISABLED => 'gray'
  }.freeze

  def self.color_for(result)
    COLOR_MAP[result.to_s.downcase] || 'black'
  end

  def self.options_for_select
    [
      [PENDING.humanize, PENDING],
      [SUCCESS.humanize, SUCCESS],
      [ERROR.humanize, ERROR],
      [DISABLED.humanize, DISABLED]
    ]
  end
end
