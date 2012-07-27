require 'test_helper'

class CategoryTest < ActiveSupport::TestCase

  test "category name must not be empty" do
    category = Category.new
    assert category.invalid?
    assert category.errors[:name].any?
  end

  test "category is not valid without a unique title" do
    category = Category.new(name: categories(:one).name)
    assert !category.save
    assert_equal I18n.translate('activerecord.errors.messages.taken'),
    category.errors[:name].join('; ')
  end

end
