class RecipesController < ApplicationController
  def index
    @ingredients = Array(params[:ingredients]).reject(&:blank?)
    @category = params[:category].presence
    @max_time = params[:max_time].presence&.to_i
    @categories = Recipe.distinct.pluck(:category).compact.sort

    if @ingredients.length >= 3
      @recipes = RecipeSearchService.new(
        ingredients: @ingredients,
        category: @category,
        max_time: @max_time
      ).call
    elsif @ingredients.any?
      flash.now[:alert] = "Please enter at least 3 ingredients."
    end
  end

  def show
    @recipe = Recipe.find(params[:id])
  end
end
