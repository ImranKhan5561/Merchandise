require 'open-uri'

puts "Cleaning Database..."
# This deletes all records clean
Product.destroy_all
Category.destroy_all
OptionType.destroy_all

puts "Creating Admin User..."
User.find_or_create_by!(email: 'admin@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = :admin
end

puts "Creating Categories..."

categories_data = [
  { name: 'Clothing', image: 'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f' },
  { name: 'Accessories', image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30' },
  { name: 'Footwear', image: 'https://images.unsplash.com/photo-1549298916-b41d501d3772' },
  { name: 'Home & Living', image: 'https://images.unsplash.com/photo-1494438639946-1ebd1d20bf85' },
  { name: 'Beauty', image: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9' },
  { name: 'Artisans', image: 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38' }
]

created_categories = {}

categories_data.each do |cat|
  c = Category.create!(name: cat[:name])
  begin
    c.image.attach(
      io: URI.open(cat[:image] + "?q=80&w=800&auto=format&fit=crop"),
      filename: "#{cat[:name].downcase.gsub(' ', '_')}.jpg",
      content_type: 'image/jpeg'
    )
  rescue => e
    puts "  [!] Could not attach image for #{cat[:name]}: #{e.message}"
  end
  created_categories[cat[:name]] = c
end

clothing = created_categories['Clothing']
men = Category.create!(name: 'Men', parent: clothing)
women = Category.create!(name: 'Women', parent: clothing)
# Add some children to others for future use
Category.create!(name: 'Watches', parent: created_categories['Accessories'])
Category.create!(name: 'Jewelry', parent: created_categories['Accessories'])
Category.create!(name: 'Furniture', parent: created_categories['Home & Living'])

puts "Creating Option Types & Values..."
color = OptionType.create!(name: 'Color', presentation: 'Color')
%w[Red Blue].each { |c| color.option_values.create!(value: c.downcase, presentation: c) }

neck = OptionType.create!(name: 'Neck Design', presentation: 'Neck Design')
%w[Round V-Shape].each { |c| neck.option_values.create!(value: c.downcase.gsub('-', ''), presentation: c) }

size = OptionType.create!(name: 'Size', presentation: 'Size')
%w[S M L XL].each { |s| size.option_values.create!(value: s.downcase, presentation: s) }

puts "Creating Simple Product (No Variants)..."
simple_prod = Product.create!(
  name: 'Everyday Running Cap',
  slug: 'everyday-running-cap',
  product_type: 'Simple',
  brand: 'Nike',
  category: men,
  base_price: 15.00,
  compare_at_price: 20.00,
  description: "A lightweight, breathable cap for your everyday runs. Perfect for outdoor activities.",
  active: true,
  featured: true,
  free_shipping: true,
  tags: ["Free Shipping", "Outdoor"],
  total_stock: 100
)

# Simple products ONLY have a master variant
Variant.create!(
  product: simple_prod, 
  is_master: true, 
  sku: 'CAP-NIKE-01', 
  price: 15.00, 
  stock_quantity: 100,
  weight: 0.1
)

puts "Creating Variable Product: T-Shirt..."
tshirt = Product.create!(
  name: "Premium Cotton T-Shirt",
  slug: 'premium-cotton-tshirt',
  product_type: 'Variable',
  brand: 'Hanes',
  category: men,
  base_price: 24.99,
  compare_at_price: 34.99,
  description: "High-quality, breathable cotton t-shirt for all occasions. Available in multiple cuts.",
  active: true,
  featured: true,
  tags: ["Best Seller", "Sustainable"],
  total_stock: 500
)

# Link Option Types to Product and mark Visual Discriminators
tshirt.product_option_types.create!(option_type: color, is_visual: true)
tshirt.product_option_types.create!(option_type: neck, is_visual: true)
tshirt.product_option_types.create!(option_type: size, is_visual: false)

# Master variant for the variable product
Variant.create!(
  product: tshirt, 
  is_master: true, 
  sku: 'TSHIRT-MASTER', 
  price: 24.99, 
  stock_quantity: 500,
  weight: 0.2
)

puts "Generating Variants and Loading Front/Back Images via ActiveStorage..."
['Red', 'Blue'].each do |c_pres|
  ['Round', 'V-Shape'].each do |n_pres|
    c = color.option_values.find_by(presentation: c_pres)
    n = neck.option_values.find_by(presentation: n_pres)
    
    color_hex = c_pres == 'Red' ? 'cc0000' : '0000cc'
    
    puts " -> Fetching placeholder images for #{c_pres} #{n_pres}..."
    front_url = "https://placehold.co/400x500/#{color_hex}/fff.png?text=#{c_pres}+#{n_pres}+Front"
    back_url = "https://placehold.co/400x500/#{color_hex}/fff.png?text=#{c_pres}+#{n_pres}+Back"
    
    begin
      # Upload standard blobs for this exact visual combo
      front_blob = ActiveStorage::Blob.create_and_upload!(
        io: URI.open(front_url),
        filename: "front_#{c_pres}_#{n_pres}.png",
        content_type: "image/png"
      )
      back_blob = ActiveStorage::Blob.create_and_upload!(
        io: URI.open(back_url),
        filename: "back_#{c_pres}_#{n_pres}.png",
        content_type: "image/png"
      )
      
      # Generate the standard sizes
      ['S', 'M', 'L'].each do |s_pres|
        s = size.option_values.find_by(presentation: s_pres)
        
        sku = "TSHIRT-#{c_pres}-#{n_pres}-#{s_pres}".upcase.gsub(/[^A-Z0-9]/, '-')
        v = Variant.create!(
          product: tshirt, 
          sku: sku, 
          price: 24.99, 
          stock_quantity: 20
        )
        v.option_values = [c, n, s]
        
        # Attach both images firmly to each size using signed_ids 
        v.images.attach([front_blob.signed_id, back_blob.signed_id])
      end
    rescue => e
      puts "    [!] Error downloading images: #{e.message}"
    end
  end
end

puts "Creating Oxford Slim Fit Shirt (Multi-variant)..."
oxford = Product.create!(
  name: "Oxford Slim Fit Shirt",
  slug: "oxford-slim-fit-shirt",
  product_type: "Variable",
  brand: "Ethereal",
  category: men,
  base_price: 49.00,
  compare_at_price: 65.00,
  description: "A timeless classic, our Oxford Slim Fit Shirt is crafted from premium organic cotton. Featuring a button-down collar and a tailored fit that works for both formal and casual settings.",
  active: true,
  featured: true,
  free_shipping: true,
  tags: ["New Arrival", "Premium Cotton", "Slim Fit"],
  total_stock: 400
)

# Associate option types
ProductOptionType.create!(product: oxford, option_type: color, is_visual: true, position: 1)
ProductOptionType.create!(product: oxford, option_type: size, position: 2)

# Attaching main product image for homepage
begin
  oxford.images.attach(
    io: URI.open("https://images.unsplash.com/photo-1596755094514-f87e34085b2c?q=80&w=800&auto=format&fit=crop"),
    filename: "oxford-main.jpg",
    content_type: "image/jpeg"
  )
rescue => e
  puts "    [!] Error downloading main image: #{e.message}"
end

color_red = color.option_values.find_by(presentation: "Red")
color_black = color.option_values.find_or_create_by!(value: "black", presentation: "Black")

sizes = size.option_values.where(presentation: ["S", "M", "L", "XL"])

# Image sets for each color
color_images = {
  "Red" => [
    "https://images.unsplash.com/photo-1589310243389-96a5483213a8",
    "https://images.unsplash.com/photo-1596755094514-f87e34085b2c",
    "https://images.unsplash.com/photo-1621072156002-e2fcced0b170",
    "https://images.unsplash.com/photo-1588359348347-9bc6cbb6cf97"
  ],
  "Black" => [
    "https://images.unsplash.com/photo-1583743814966-8933f1b0cd2e",
    "https://images.unsplash.com/photo-1618354691373-d851c5c3a990",
    "https://images.unsplash.com/photo-1503342217505-b0a15ec3261c",
    "https://images.unsplash.com/photo-1521572267360-ee0c2909d518"
  ]
}

[
  { color: color_red, imgs: color_images["Red"] },
  { color: color_black, imgs: color_images["Black"] }
].each do |variant_group|
  c_val = variant_group[:color]
  puts "  -> Generating variants and uploading images for #{c_val.presentation}..."
  
  # Download and create blobs for this color (to reuse across sizes)
  blobs = variant_group[:imgs].map.with_index do |url, idx|
    begin
      ActiveStorage::Blob.create_and_upload!(
        io: URI.open(url + "?q=80&w=800&auto=format&fit=crop"),
        filename: "oxford-#{c_val.presentation.downcase}-#{idx+1}.jpg",
        content_type: 'image/jpeg'
      )
    rescue => e
      puts "    [!] Error downloading image #{idx+1}: #{e.message}"
      nil
    end
  end.compact

  sizes.each do |s_val|
    v = Variant.create!(
      product: oxford,
      sku: "OXF-#{c_val.presentation[0]}#{s_val.presentation}-#{SecureRandom.hex(3).upcase}",
      price: 49.00,
      stock_quantity: 50
    )
    v.option_values = [c_val, s_val]
    v.images.attach(blobs.map(&:signed_id)) if blobs.any?
  end
end

[
  {
    name: "Silk Slip Dress",
    slug: "silk-slip-dress",
    brand: "Lumiere",
    category: women,
    base_price: 120.00,
    compare_at_price: 150.00,
    description: "An elegant, 100% silk slip dress in a soft lavender hue. Perfect for evening wear.",
    featured: true,
    tags: ["New Arrival", "Silk"],
    image: "https://images.unsplash.com/photo-1594633312681-425c7b97ccd1"
  },
  {
    name: "Minimalist Gold Watch",
    slug: "minimalist-gold-watch",
    brand: "Aura",
    category: created_categories['Accessories'],
    base_price: 85.00,
    compare_at_price: 110.00,
    description: "A sleek, minimalist watch with a 24k gold-plated case and a genuine leather strap.",
    featured: true,
    tags: ["Limited Edition", "Premium"],
    image: "https://images.unsplash.com/photo-1524592094714-0f0654e20314"
  },
  {
    name: "Leather Crossbody Bag",
    slug: "leather-crossbody-bag",
    brand: "Vera",
    category: created_categories['Accessories'],
    base_price: 45.00,
    compare_at_price: 60.00,
    description: "Handcrafted Italian leather crossbody bag with adjustable straps and multiple compartments.",
    featured: true,
    free_shipping: true,
    tags: ["On Sale", "Handmade"],
    image: "https://images.unsplash.com/photo-1548036328-c9fa89d128fa"
  },
  {
    name: "Artisan Ceramic Bowl",
    slug: "artisan-ceramic-bowl",
    brand: "Earth",
    category: created_categories['Artisans'],
    base_price: 32.00,
    compare_at_price: 45.00,
    description: "A unique, hand-thrown ceramic bowl with a beautiful reactive glaze finish.",
    featured: true,
    tags: ["Handmade", "Eco-friendly"],
    image: "https://images.unsplash.com/photo-1578749556568-bc2c40e68b61"
  }
].each do |p_data|
  p = Product.create!(
    name: p_data[:name],
    slug: p_data[:slug],
    product_type: 'Simple',
    brand: p_data[:brand],
    category: p_data[:category],
    base_price: p_data[:base_price],
    compare_at_price: p_data[:compare_at_price],
    description: p_data[:description],
    active: true,
    featured: p_data[:featured],
    tags: p_data[:tags],
    total_stock: 50
  )
  
  Variant.create!(
    product: p, 
    is_master: true, 
    sku: "#{p.slug.upcase}-001", 
    price: p.base_price, 
    stock_quantity: 50
  )

  begin
    p.images.attach(
      io: URI.open(p_data[:image] + "?q=80&w=800&auto=format&fit=crop"),
      filename: "#{p.slug}.jpg",
      content_type: 'image/jpeg'
    )
  rescue => e
    puts "  [!] Error downloading image for #{p.name}: #{e.message}"
  end
end

puts "✅ New Seed data cleanly generated!"
