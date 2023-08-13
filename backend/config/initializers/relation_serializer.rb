module RelationSerializer
  def serialize(klass)
    records = pluck(*klass::ATTRS)
    records.map { |record| klass.make_hash(record) }
  end

  def indexed_serialize(klass)
    raise "ATTRS must include :id when making indexed serialization" if klass::ATTRS.exclude?(:id)
    records = pluck(*klass::ATTRS)
    data = {}
    records.each do |record|
      hash = klass.make_hash(record)
      data[hash[:id]] = hash
    end
    return data
  end

  def quick_indexed_serialize(attrs, index_by)
    raise "ATTRS must include #{index_by.to_s} when making indexed serialization" if attrs.exclude?(index_by)
    records = pluck(*attrs)
    data = {}
    records.each do |record|
      record_data = {}
      attrs.each.with_index do |attr_name, i|
        record_data[attr_name] = record[i]
      end
      data[record_data[index_by]] = record_data
    end
    return data
  end
end

ActiveRecord::Relation.send(:include, RelationSerializer)