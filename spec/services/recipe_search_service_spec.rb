require "rails_helper"

RSpec.describe RecipeSearchService do
  let!(:pasta_recipe) do
    recipe = create(:recipe, category: "Pasta", total_time: 25, ratings: 4.8)
    create(:recipe_ingredient, recipe: recipe, name: "2 cloves garlic")
    create(:recipe_ingredient, recipe: recipe, name: "1 cup chicken broth")
    create(:recipe_ingredient, recipe: recipe, name: "1 lemon, juiced")
    recipe
  end

  let!(:soup_recipe) do
    recipe = create(:recipe, category: "Soup", total_time: 45, ratings: 4.2)
    create(:recipe_ingredient, recipe: recipe, name: "3 cloves garlic, minced")
    create(:recipe_ingredient, recipe: recipe, name: "2 cups chicken stock")
    create(:recipe_ingredient, recipe: recipe, name: "1 onion, diced")
    recipe
  end

  let!(:dessert_recipe) do
    recipe = create(:recipe, category: "Dessert", total_time: 60, ratings: 4.9)
    create(:recipe_ingredient, recipe: recipe, name: "2 cups flour")
    create(:recipe_ingredient, recipe: recipe, name: "1 cup sugar")
    create(:recipe_ingredient, recipe: recipe, name: "3 eggs")
    recipe
  end

  describe "#call" do
    context "with 3 matching ingredients" do
      it "returns recipes containing those ingredients" do
        results = described_class.new(ingredients: %w[chicken garlic lemon]).call
        titles = results.map(&:title)
        expect(titles).to include(pasta_recipe.title)
      end
    end

    context "ordered by match_count DESC then ratings DESC" do
      it "ranks recipes with more matches first" do
        results = described_class.new(ingredients: %w[chicken garlic lemon]).call
        match_counts = results.map(&:match_count)
        expect(match_counts).to eq(match_counts.sort.reverse)
      end

      it "attaches match_count virtual attribute" do
        results = described_class.new(ingredients: %w[chicken garlic lemon]).call
        expect(results.first).to respond_to(:match_count)
      end
    end

    context "when fewer than 3 ingredients are provided" do
      it "raises ArgumentError" do
        expect do
          described_class.new(ingredients: %w[chicken garlic])
        end.to raise_error(ArgumentError, /At least 3 ingredients/)
      end
    end

    context "with category filter" do
      it "returns only recipes in that category" do
        results = described_class.new(ingredients: %w[chicken garlic lemon], category: "Soup").call
        categories = results.map(&:category).uniq
        expect(categories).to eq([ "Soup" ])
      end
    end

    context "with max_time filter" do
      it "excludes recipes over the time limit" do
        results = described_class.new(ingredients: %w[chicken garlic lemon], max_time: 30).call
        expect(results.map(&:total_time)).to all(be <= 30)
      end
    end

    context "when no ingredients match any recipe" do
      it "returns an empty result" do
        results = described_class.new(ingredients: %w[xylophone quasar nebula]).call
        expect(results).to be_empty
      end
    end
  end
end
