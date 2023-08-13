class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.find_hash_by(hash)
    raw_data = self.where(hash).pluck(*self.column_names).first
    if raw_data.present?
      data = {}
      self.column_names.each.with_index do |column_name, index|
        data[column_name.to_sym] = raw_data[index]
      end
      return data
    end
    return nil
  end

  def self.serialize(klass)
    self.where({}).serialize(klass)
  end

  def self.indexed_serialize(klass)
    self.where({}).indexed_serialize(klass)
  end

  def serialize(klass)
    klass.serialize(self)
  end
end