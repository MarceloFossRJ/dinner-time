<<<<<<< HEAD

# dinner-time

=======

# It's Dinner Time

Dinner-Time is a Rails recipe-finder prototype that helps you decide what to cook tonight based on ingredients you already have at home.

Enter at least three ingredients, optionally filter by meal category and total cooking time, and get a ranked list of matching recipes pulled from a dataset scraped from allrecipes.com recipes.

---

## User Stories

**User Story 1 — Ingredient search**

> As a cook I want to input at least 3 ingredients I have at home and see a ranked list of recipes that use those ingredients, so I can have options to choose what can I cook for my meal.

**User Story 2 — Filter results**

> As a cook, I want to filter the recipe list by meal category and total cooking time, so I can find something that fits what I'm in the mood for and how much time I have.

**User Story 3 — Recipe detail**

> As a cook, I want to tap a recipe from the list and see its full details (ingredients, times, rating, …), so I know exactly what I need and how to prepare it.

---

## Setup

### Prerequisites

- Ruby 4.0.1 (via RVM or rbenv)
- PostgreSQL 14+
- Node.js + Yarn

### Install dependencies

```bash
bundle install
yarn install
```

### Environment variables

Copy `.env.example` to `.env` and fill in your values:

### Database setup

```bash
bin/rails db:create db:migrate
```

### Seed the database

In order to import the allrecipes.com in the database, execute the following command (which loads recipes from the `data/recipes-en.json` dataset).

```bash
bin/rails db:seed
```

### Build CSS

```bash
yarn build:css
```

### Start the server

```bash
bin/rails server
```

Visit [http://localhost:3000](http://localhost:3000).

---

## Tech Stack

| Layer      | Technology                                  |
| ---------- | ------------------------------------------- |
| Framework  | Rails 8.1                                   |
| Database   | PostgreSQL (via `pg` gem)                   |
| CSS        | Bootstrap 5 (via `cssbundling-rails` + npm) |
| JavaScript | Stimulus (Hotwire)                          |
| Testing    | RSpec, FactoryBot, Faker, shoulda-matchers  |
| Linting    | RuboCop (rubocop-rails-omakase)             |

---

## Dataset & Ingredient Matching

The recipe dataset (`data/recipes-en.json`) contains 10,013 recipes scraped from allrecipes.com. Each recipe includes a title, category, prep/cook times, author, image URL, rating, and a list of raw ingredient strings (e.g. `"2 cloves garlic, minced"`). Even though the image URL address in the dataset has values, the image address is broken, due to that images are being skipped until it is fixed.

Ingredients are stored as raw quantity strings rather than normalized names, as a result, matching is done with PostgreSQL `ILIKE '%term%'` substring search against the `recipe_ingredients.name` column. This intentionally avoids over-engineering a normalization pipeline while still catching natural-language ingredient mentions.

Relevance ranking uses a single `GROUP BY` SQL query that counts how many of the user's ingredient terms match at least one ingredient row for each recipe. Recipes are ordered by match count descending, then by rating descending.

The `cuisine` field is empty on all records in this dataset; `category` (983 distinct values) is used as the meal-type filter facet instead.
