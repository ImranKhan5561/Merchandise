require 'open-uri'

# ============================================================
#  SEEDS — Optimized for Render Deployment
# ============================================================

# NOTE: Most seeds are commented out to save memory/time on Render Free Tier.
# Run 'rails db:seed' to only populate Banners in production.

=begin
# ----------------------------------------------------------
# Helper: Attach image from URL
# ----------------------------------------------------------
def attach_image(record, url, filename)
  attachment_rel = record.respond_to?(:images) ? record.images : record.image
  
  if attachment_rel.attached?
    blob = attachment_rel.respond_to?(:first) ? attachment_rel.first.blob : attachment_rel.blob
    return if blob && blob.service_name.to_s.downcase == 'cloudinary'
    attachment_rel.purge
  end
  
  begin
    file = URI.open(url)
    if record.respond_to?(:images)
      record.images.attach(io: file, filename: filename)
    else
      record.image.attach(io: file, filename: filename)
    end
    puts "  📸 Attached #{filename} to #{record.class} (ID: #{record.id})"
  rescue => e
    puts "  ⚠️ Failed to attach image from #{url}: #{e.message}"
  end
end

# ----------------------------------------------------------
# Admin user
# ----------------------------------------------------------
puts "Creating Admin User..."
User.find_or_create_by!(email: 'admin@example.com') do |u|
  u.password              = 'password123'
  u.password_confirmation = 'password123'
  u.role                  = :admin
  u.name                  = 'Admin'
  u.is_verified           = true
end

# ... (rest of the products/categories) ...
=end

# ----------------------------------------------------------
# Admin User (Active for Production/Render)
# ----------------------------------------------------------
puts "Seeding Admin User..."
admin_email    = ENV.fetch("ADMIN_EMAIL", "admin@merchandise.com")
admin_password = ENV.fetch("ADMIN_PASSWORD", "Admin@12345")

User.find_or_create_by!(email: admin_email) do |u|
  u.password              = admin_password
  u.password_confirmation = admin_password
  u.role                  = :admin
  u.name                  = "Admin"
  u.is_verified           = true
end
puts "✅ Admin user ready! Email: #{admin_email}"

# ----------------------------------------------------------
# Banners (Active for Production/Render)
# ----------------------------------------------------------
puts "Seeding Banners..."
[
  {
    title: "The Artisan Collection",
    subtitle: "Spring Drop 2024",
    badge_text: "NEW ARRIVAL",
    description: "Experience the synergy of tradition and modern aesthetics. Each piece is hand-crafted with precision.",
    image_url: "https://images.unsplash.com/photo-1490114538077-0a7f8cb49891?q=80&w=2400&auto=format&fit=crop",
    position: 1,
    text_align: "left"
  },
  {
    title: "Ethereal Minimalist",
    subtitle: "Summer Essentials",
    badge_text: "LIMITED EDITION",
    description: "Discover the beauty of simplicity with our new minimalist collection. Lightweight fabrics for the modern soul.",
    image_url: "https://images.unsplash.com/photo-1441986300917-64674bd600d8?q=80&w=2400&auto=format&fit=crop",
    position: 2,
    text_align: "center"
  },
  {
    title: "Tech Meets Style",
    subtitle: "Future Forward",
    badge_text: "TRENDING",
    description: "The latest in high-performance electronics wrapped in a shell of pure elegance. Upgrade your lifestyle today.",
    image_url: "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?q=80&w=2400&auto=format&fit=crop",
    position: 3,
    text_align: "right"
  }
].each do |banner_attrs|
  Banner.find_or_create_by!(title: banner_attrs[:title]) do |b|
    b.assign_attributes(banner_attrs)
  end
end

puts "✅ Banners seeded successfully!"
puts "Seeding Categories..."

clothing_category = Category.find_or_create_by!(name: "Clothing") do |c|
  attach_image(c, "https://images.unsplash.com/photo-1520975916645-a625c83c6299?q=80&w=2400&auto=format&fit=crop", "clothing.jpg")
end

electronics_category = Category.find_or_create_by!(name: "Electronics") do |c|
  attach_image(c, "https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=2400&auto=format&fit=crop", "electronics.jpg")
end

accessories_category = Category.find_or_create_by!(name: "Accessories") do |c|
  attach_image(c, "https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb?q=80&w=2400&auto=format&fit=crop", "accessories.jpg")
end

puts "✅ Categories seeded successfully!"

puts "Seeding Products..."

# Clothing products
shirt = Product.find_or_create_by!(name: "Classic White Shirt") do |p|
  p.category = clothing_category
  p.base_price = 49.99
  p.description = "Elegant white shirt made from premium cotton."
  p.total_stock = 100
  p.slug = "classic-white-shirt"
end
attach_image(shirt, "https://images.unsplash.com/photo-1585110396000-7a0cae707951?q=80&w=2400&auto=format&fit=crop", "shirt_front.jpg")
attach_image(shirt, "https://images.unsplash.com/photo-1576402114348-3511cce3c8fb?q=80&w=2400&auto=format&fit=crop", "shirt_back.jpg")

jeans = Product.find_or_create_by!(name: "Blue Denim Jeans") do |p|
  p.category = clothing_category
  p.base_price = 79.99
  p.description = "Comfortable blue denim jeans with a modern fit."
  p.total_stock = 80
  p.slug = "blue-denim-jeans"
end
attach_image(jeans, "https://images.unsplash.com/photo-1582719476602-264f271dd74a?q=80&w=2400&auto=format&fit=crop", "jeans_front.jpg")
attach_image(jeans, "https://images.unsplash.com/photo-1567945715060-867e1c2f2c38?q=80&w=2400&auto=format&fit=crop", "jeans_back.jpg")

# Electronics products
laptop = Product.find_or_create_by!(name: "UltraSlim Laptop") do |p|
  p.category = electronics_category
  p.base_price = 1299.99
  p.description = "Lightweight laptop with 16GB RAM, 512GB SSD, and stunning retina display."
  p.total_stock = 30
  p.slug = "ultraslim-laptop"
end
attach_image(laptop, "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=2400&auto=format&fit=crop", "laptop.jpg")

smartphone = Product.find_or_create_by!(name: "ProMax Smartphone") do |p|
  p.category = electronics_category
  p.base_price = 999.99
  p.description = "Flagship smartphone with triple camera system and 5G connectivity."
  p.total_stock = 50
  p.slug = "promax-smartphone"
end
attach_image(smartphone, "https://images.unsplash.com/photo-1512499617640-c2f9996178b5?q=80&w=2400&auto=format&fit=crop", "smartphone_front.jpg")
attach_image(smartphone, "https://images.unsplash.com/photo-1509395176047-4a66953fd231?q=80&w=2400&auto=format&fit=crop", "smartphone_back.jpg")

# Accessories products
watch = Product.find_or_create_by!(name: "Classic Leather Watch") do |p|
  p.category = accessories_category
  p.base_price = 199.99
  p.description = "Timeless leather strap watch with minimalist dial."
  p.total_stock = 60
  p.slug = "classic-leather-watch"
end
attach_image(watch, "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=2400&auto=format&fit=crop", "watch.jpg")

puts "✅ Products seeded successfully!"
