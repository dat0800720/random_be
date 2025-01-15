# frozen_string_literal: true

module AttrErrorWithNested
  extend ActiveSupport::Concern

  def attr_error_with_nested(resource = '') # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    pattern = /(?<model>\w+)\[(?<index>\d+)\].(?<attr>\w+)/
    errors.map do |error_obj|
      if error_obj.is_a?(ActiveModel::NestedError)
        error, ancestor = model_attribute_from_error(error_obj, [])
        name_error = error.attribute.to_s.gsub(pattern,
                                               '\k<model>.\k<index>.\k<attr>').split('.')
        index = name_error.find { |n| n.match?(Settings.regex.number) }.to_i
      end

      res = {
        resource: name_error.try(:first)&.singularize || resource,
        field: name_error.try(:last) || error_obj.attribute,
        key: error_obj.type,
        options: error_obj.options.reject { |k, v| k == :value || v.instance_of?(Proc) }
      }
      res[:index] = index if index
      res[:ancestor] = ancestor if ancestor.present?

      res
    end
  end

  def model_attribute_from_error(error_obj, ancestor) # rubocop:disable Metrics/MethodLength
    if begin
      error_obj.inner_error
    rescue StandardError
      nil
    end.is_a? ActiveModel::NestedError
      parent_model = error_obj.attribute.to_s.split('.').first.split('[')
      ancestor << {
        ancestor_resource: parent_model[0].singularize,
        ancestor_index: parent_model[1].to_i
      }
      model_attribute_from_error error_obj.inner_error, ancestor
    else
      [error_obj, ancestor]
    end
  end
end
