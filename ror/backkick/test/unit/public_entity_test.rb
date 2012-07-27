require 'test_helper'

class PublicEntityTest < ActiveSupport::TestCase
  
  test "public_entity name must not be empty" do
    public_entity = PublicEntity.new
    assert public_entity.invalid?
    assert public_entity.errors[:name].any?
  end

  test "public_entity is not valid without a unique title" do
    public_entity = PublicEntity.new(name: public_entities(:one).name)
    assert !public_entity.save
    assert_equal I18n.translate('activerecord.errors.messages.taken'),
    	public_entity.errors[:name].join('; ')
  end
    
end
