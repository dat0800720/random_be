# frozen_string_literal: true

class BaseSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attr_reader :column_tables

  class << self
    def build_response(object, options = {})
      return object.as_response if object.is_a?(ActiveModel::Serializer)

      return new(object, options).as_response unless object.respond_to?(:map)

      object.map do |item|
        if item.is_a? ActiveModel::Serializer
          item.as_response
        else
          new(item, options).as_response
        end
      end
    end
  end

  def initialize(object, options = {})
    super
    @column_tables = begin
      object.class.columns_hash
    rescue StandardError
      []
    end
  end

  def attributes(requested_attrs = nil, reload = nil)
    @attributes = nil if reload
    @attributes ||= self.class._attributes_data.each_with_object({}) do |(key, attr), hash|
      next if attr.excluded?(self)
      next unless requested_attrs.nil? || requested_attrs.include?(key)

      hash[key] = format_data(attr.value(self), attr.name)
    end
  end

  def as_response
    json_data = as_json
    json_data.keys.to_h { |k| [k.to_s, format_data(json_data[k], k)] }
  end

  private

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/MethodLength
  def format_data(data, key)
    return data.nil? ? data.to_h : data if get_nested_model(key)

    enum_columns = object.class.defined_enums
    case column_tables[key.to_s]&.type
    when :date
      data.is_a?(String) ? data : data&.strftime(Settings.datetime.short_date).to_s
    when :integer
      if enum_columns[key.to_s]
        enum_columns[key.to_s][object.send(key)].to_s
      else
        object.send("#{key}_before_type_cast").to_s
      end
    when :decimal
      object.send("#{key}_before_type_cast").to_s
    when :string
      data.is_a?(Array) ? data : data.to_s
    else
      data.nil? ? data.to_s : data
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/MethodLength

  def get_nested_model(key)
    Object.const_get(key.to_s.sub('_attributes', '').classify)
  rescue StandardError
    nil
  end

  def json_for_file(file)
    if file.blank?
      { id: '', filename: '', url: '' }
    else
      { id: file.signed_id, filename: file.filename.to_s,
        url: rails_blob_url(file, host: Settings.blob_host) }
    end
  end
end
