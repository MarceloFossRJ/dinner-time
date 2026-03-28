class RecipeSearchService
  MIN_INGREDIENTS = 3

  def initialize(ingredients:, category: nil, max_time: nil)
    raise ArgumentError, "At least #{MIN_INGREDIENTS} ingredients are required" if ingredients.length < MIN_INGREDIENTS

    @ingredients = ingredients
    @category = category
    @max_time = max_time
  end

  def call
    scope = Recipe
      .select(Arel.sql("recipes.*, #{match_count_sql} AS match_count"))
      .joins(:recipe_ingredients)
      .where(Arel.sql(where_clause))
      .group("recipes.id")
      .order(Arel.sql("match_count DESC, recipes.ratings DESC"))

    scope = scope.where(category: @category) if @category.present?
    scope = scope.where("recipes.total_time <= ?", @max_time) if @max_time.present?

    scope
  end

  private

  def match_count_sql
    parts = @ingredients.map do |term|
      quoted = quote_ilike(term)
      "MAX(CASE WHEN recipe_ingredients.name ILIKE #{quoted} THEN 1 ELSE 0 END)::integer"
    end
    "(#{parts.join(' + ')})"
  end

  def where_clause
    @ingredients.map { |term| "recipe_ingredients.name ILIKE #{quote_ilike(term)}" }.join(" OR ")
  end

  def quote_ilike(term)
    sanitized = ActiveRecord::Base.sanitize_sql_like(term)
    ActiveRecord::Base.connection.quote("%#{sanitized}%")
  end
end
