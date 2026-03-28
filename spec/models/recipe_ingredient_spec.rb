require "rails_helper"

RSpec.describe RecipeIngredient, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:recipe) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end
end
