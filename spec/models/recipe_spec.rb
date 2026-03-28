require "rails_helper"

RSpec.describe Recipe, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:recipe_ingredients).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
  end
end
