---
paths: "app/models/**/*.rb"
dependencies: [money-rails]
---

# Money Rails - Monetize Pattern

Money handling with money-rails gem.

---

## Basic Setup

Use `monetize` macro for currency fields:

```ruby
class Product < ApplicationRecord
  monetize :price_cents
end
```

**What this does:**

- Creates `price` accessor returning Money object
- Stores cents as integer in `price_cents` column
- Handles currency conversion automatically

---

## Database Requirements

**Migration:**

```ruby
class AddPriceToProducts < ActiveRecord::Migration[8.0]
  def change
    add_monetize :products, :price
    # Creates: price_cents (integer), price_currency (string)
  end
end
```

**Manual columns:**

```ruby
add_column :products, :price_cents, :integer, default: 0, null: false
add_column :products, :price_currency, :string, default: "USD", null: false
```

---

## Usage

```ruby
# Setting price
album.price = Money.new(1000, "USD")  # $10.00
album.price_cents = 1000               # Also works

# Reading price
album.price_cents       # => 1000
album.price.format      # => "$10.00"
album.price.currency    # => "USD"
album.price.cents       # => 1000
```

---

## Default Currency

**Global default:**

```ruby
# config/initializers/money.rb
Money.default_currency = Money::Currency.new("USD")
```

**Per-field default:**

```ruby
class Product < ApplicationRecord
  monetize :price_cents, with_currency: :usd
end
```

---

## Calculations

```ruby
# Math operations
total = album.price + track.price
discounted = album.price * 0.9

# Comparisons
album.price > Money.new(500, "USD")  # => true
```

---

## Validations

```ruby
class Product < ApplicationRecord
  monetize :price_cents

  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
end
```

---

## Discovery

**Find monetized models:**

```
Grep "monetize" app/models/**/*.rb
```

**Find money configuration:**

```
Grep "Money" config/initializers/**/*.rb
```
