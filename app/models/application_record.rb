# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include AttrErrorWithNested

  primary_abstract_class
end
