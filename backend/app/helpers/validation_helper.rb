module ValidationHelper
  def self.format_errors(raw_errors)
    errors = {}
    raw_errors.each do |name, error_list|
      errors[name] = error_list.map { |e| "#{name.to_s.titleize} #{e}"}
    end
    return errors
  end
end
