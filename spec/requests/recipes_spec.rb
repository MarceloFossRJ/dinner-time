require "rails_helper"

RSpec.describe "Recipes", type: :request do
  let!(:recipe) do
    r = create(:recipe, category: "Dinner", total_time: 30, ratings: 4.5)
    create(:recipe_ingredient, recipe: r, name: "2 cloves garlic")
    create(:recipe_ingredient, recipe: r, name: "1 lb chicken breast")
    create(:recipe_ingredient, recipe: r, name: "1 lemon, juiced")
    r
  end

  describe "GET /recipes" do
    context "with fewer than 3 ingredients" do
      it "renders the page with a flash alert" do
        get recipes_path, params: { ingredients: %w[garlic chicken] }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("at least 3 ingredients")
      end
    end

    context "with 3 or more ingredients" do
      it "returns 200 and shows results" do
        get recipes_path, params: { ingredients: %w[chicken garlic lemon] }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(recipe.title)
      end
    end

    context "with no ingredients submitted" do
      it "renders the search form without error" do
        get recipes_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /recipes/:id" do
    it "returns 200 and renders the recipe detail" do
      get recipe_path(recipe)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(recipe.title)
    end
  end
end
