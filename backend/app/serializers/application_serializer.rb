class ApplicationSerializer
  ATTRS = [
    :id,
    :created_at,
    :updated_at
  ]

  def self.make_hash(raw_array)
    data = {}
    self::ATTRS.each.with_index do |attr_name, i|
      data[attr_name] = raw_array[i]
    end
    return data
  end

  def self.serialize(application_record_instance_or_hash)
    raw_array = []
    self::ATTRS.each do |attr_name|
      raw_array << application_record_instance_or_hash[attr_name]
    end
    return self.make_hash(raw_array)
  end
end