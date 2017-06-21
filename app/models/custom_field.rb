# == Schema Information
#
# Table name: custom_fields
#
#  id             :integer          not null, primary key
#  type           :string(255)
#  sort_priority  :integer
#  search_filter  :boolean          default(TRUE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  community_id   :integer
#  required       :boolean          default(TRUE)
#  min            :float(24)
#  max            :float(24)
#  allow_decimals :boolean          default(FALSE)
#
# Indexes
#
#  index_custom_fields_on_community_id   (community_id)
#  index_custom_fields_on_search_filter  (search_filter)
#

class CustomField < ApplicationRecord
  include SortableByPriority # use `sort_priority()` for sorting

  has_many :names, class_name: "CustomFieldName", dependent: :destroy

  has_many :category_custom_fields, dependent: :destroy
  has_many :categories, through: :category_custom_fields

  has_many :answers, class_name: "CustomFieldValue", dependent: :destroy

  has_many :options, class_name: "CustomFieldOption"

  belongs_to :community

  VALID_TYPES = ["TextField", "NumericField", "DropdownField", "CheckboxField","DateField"]

  validates_length_of :names, minimum: 1
  validates_length_of :category_custom_fields, minimum: 1
  validates_presence_of :community

  def name_attributes=(attributes)
    build_attrs = attributes.map { |locale, value| {locale: locale, value: value } }
    build_attrs.each do |name|
      if existing_name = names.find_by_locale(name[:locale])
        existing_name.update_attribute(:value, name[:value])
      else
        names.build(name)
      end
    end
  end

  def category_attributes=(attributes)
    category_custom_fields.clear
    attributes.each { |category| category_custom_fields.build(category) }
  end

  def name(locale="en")
    TranslationCache.new(self, :names).translate(locale, :value)
  end

  def with(expected_type, &block)
    with_type do |own_type|
      if own_type == expected_type
        block.call
      end
    end
  end

  def with_type(&block)
    throw "Implement this in the subclass"
  end
end
