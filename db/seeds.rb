if Rails.env.development?
  puts "Clearing existing data..."
  Recipe.delete_all
end

data_path = Rails.root.join("data", "recipes-en.json")
raw = JSON.parse(File.read(data_path))

valid_records = raw.reject { |r| r["title"].blank? || r["ingredients"].blank? }
puts "Loading #{valid_records.length} recipes..."

valid_records.each_slice(1000).with_index do |batch, idx|
  recipe_rows = batch.map do |r|
    cook = r["cook_time"].to_i
    prep = r["prep_time"].to_i
    {
      title: r["title"],
      category: r["category"].presence,
      cook_time: cook,
      prep_time: prep,
      total_time: cook + prep,
      ratings: r["ratings"],
      author: r["author"],
      image_url: r["image"],
      created_at: Time.current,
      updated_at: Time.current
    }
  end

  Recipe.insert_all(recipe_rows)

  recipe_ids = Recipe.order(:id).offset(idx * 1000).limit(1000).pluck(:id)

  ingredient_rows = []
  batch.each_with_index do |r, i|
    recipe_id = recipe_ids[i]
    next unless recipe_id

    r["ingredients"].each do |ingredient|
      next if ingredient.blank?

      ingredient_rows << {
        recipe_id: recipe_id,
        name: ingredient,
        created_at: Time.current,
        updated_at: Time.current
      }
    end
  end

  RecipeIngredient.insert_all(ingredient_rows) if ingredient_rows.any?

  puts "  Processed #{(idx + 1) * 1000} records..." if (idx + 1) * 1000 <= valid_records.length
end

puts "Done! #{Recipe.count} recipes, #{RecipeIngredient.count} ingredients loaded."
