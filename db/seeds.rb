require 'open-uri'

# ============================================================
#  SEEDS — Safe to re-run (find_or_create patterns throughout)
# ============================================================

# Use a specific version of Ruby/Rails if needed (handled in terminal)

# ----------------------------------------------------------
# Helper: Attach image from URL
# ----------------------------------------------------------
def attach_image(record, url, filename)
  attachment_rel = record.respond_to?(:images) ? record.images : record.image
  
  if attachment_rel.attached?
    blob = attachment_rel.respond_to?(:first) ? attachment_rel.first.blob : attachment_rel.blob
    # Skip if it's already on Cloudinary. If it's on local disk from a previous deploy, purge it!
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

# ----------------------------------------------------------
# Clothing Products
# ----------------------------------------------------------
puts "Creating Clothing..."

# Master Product: Classic Tee
tee = Product.find_or_create_by!(slug: 'classic-artisan-tee') do |p|
  p.name        = 'The Artisan Tee'
  p.description = 'A heavyweight, 100% organic cotton tee with a structured silhouette and hand-finished seams.'
  p.base_price  = 45.00
  p.category    = tshirts_cat
  p.brand       = 'Ethereal'
  p.tags        = ['cotton', 'organic', 'basic']
  p.featured    = true
end

# ----------------------------------------------------------
# Global Option Types
# ----------------------------------------------------------
puts "Creating Option Types..."

def find_or_build_option_type(name:, presentation:, values:)
  ot = OptionType.find_or_create_by!(name: name) do |o|
    o.presentation = presentation
  end
  values.each do |v, p|
    ot.option_values.find_or_create_by!(value: v) { |ov| ov.presentation = p }
  end
  ot
end

size_ot  = find_or_build_option_type(name: 'size', presentation: 'Size', values: { 'XS' => 'XS', 'S' => 'S', 'M' => 'M', 'L' => 'L', 'XL' => 'XL', 'XXL' => 'XXL' })
color_ot = find_or_build_option_type(name: 'color', presentation: 'Color', values: { 'black' => 'Black', 'white' => 'White', 'navy' => 'Navy', 'gray' => 'Gray', 'red' => 'Red', 'green' => 'Green', 'beige' => 'Beige', 'brown' => 'Brown', 'pink' => 'Pink' })
storage_ot = find_or_build_option_type(name: 'storage', presentation: 'Storage', values: { '128GB' => '128 GB', '256GB' => '256 GB', '512GB' => '512 GB', '1TB' => '1 TB' })
material_ot = find_or_build_option_type(name: 'material', presentation: 'Material', values: { 'leather' => 'Leather', 'canvas' => 'Canvas', 'nylon' => 'Nylon', 'suede' => 'Suede' })

# ----------------------------------------------------------
# Categories (3-Level Hierarchy)
# ----------------------------------------------------------
puts "Creating Categories (3-Level Hierarchy)..."

cat_data = [
  {
    name: 'Fashion',
    image: 'https://images.unsplash.com/photo-1445205170230-053b830c6050?w=800',
    children: [
      {
        name: 'Men',
        children: ['T-Shirts', 'Shirts', 'Footwear']
      },
      {
        name: 'Women',
        children: ['Dresses', 'Tops', 'Handbags']
      }
    ]
  },
  {
    name: 'Electronics',
    image: 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=800',
    children: [
      {
        name: 'Gadgets',
        children: ['Smartphones', 'Laptops', 'Tablets']
      },
      {
        name: 'Audio',
        children: ['Headphones', 'Speakers']
      }
    ]
  },
  {
    name: 'Home & Decor',
    image: 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=800',
    children: [
      {
        name: 'Furniture',
        children: ['Chairs', 'Tables', 'Sofas']
      },
      {
        name: 'Decor',
        children: ['Candles', 'Vases']
      }
    ]
  },
  {
    name: 'Accessories',
    image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
    children: [
      {
        name: 'Lifestyle',
        children: ['Bags', 'Watches', 'Sunglasses']
      }
    ]
  }
]

# Helper to build tree recursively
def seed_categories(data, parent = nil)
  data.each do |item|
    name = item.is_a?(String) ? item : item[:name]
    cat = Category.find_or_create_by!(name: name, parent: parent)
    
    if item.is_a?(Hash) && item[:image]
      attach_image(cat, item[:image], "#{name.parameterize}.jpg")
    end

    if item.is_a?(Hash) && item[:children]
      seed_categories(item[:children], cat)
    end
  end
end

seed_categories(cat_data)

# Extract leaf categories for easy assignment
tshirts_cat    = Category.find_by!(name: 'T-Shirts')
hoodies_cat    = Category.find_by!(name: 'Shirts') # mapped to shirts for this seed
phones_cat     = Category.find_by!(name: 'Smartphones')
laptops_cat    = Category.find_by!(name: 'Laptops')
sneakers_cat   = Category.find_by!(name: 'Footwear')
bags_cat       = Category.find_by!(name: 'Bags')
candles_cat    = Category.find_by!(name: 'Candles')
lifestyle_cat  = Category.find_by!(name: 'Lifestyle')
dresses_cat    = Category.find_by!(name: 'Dresses')
tops_cat       = Category.find_by!(name: 'Tops')
handbags_cat   = Category.find_by!(name: 'Handbags')
headphones_cat = Category.find_by!(name: 'Headphones')

# ----------------------------------------------------------
# Helper: create master variant
# ----------------------------------------------------------
def create_master_variant(product, price:, sku:, stock: 50)
  Variant.find_or_create_by!(sku: sku) do |v|
    v.product        = product
    v.price          = price
    v.stock_quantity = stock
    v.is_master      = true
  end
end

# ----------------------------------------------------------
# SIMPLE PRODUCTS (no variant options, single master variant)
# ----------------------------------------------------------
puts "Creating simple products & images..."

# 1. Scented Candle Set
candle = Product.find_or_create_by!(slug: 'lavender-dreams-candle-set') do |p|
  p.name               = 'Lavender Dreams Candle Set'
  p.description        = 'A luxury set of three hand-poured soy wax candles in calming lavender, vanilla, and eucalyptus scents.'
  p.base_price         = 29.99
  p.compare_at_price   = 39.99
  p.brand              = 'EtherealWax'
  p.category           = candles_cat
  p.product_type       = 'simple'
  p.featured           = true
  p.total_stock        = 120
  p.tags               = %w[candle home gift]
end
attach_image(candle, 'https://images.unsplash.com/photo-1603006905003-be475563bc59?w=800', 'candle.jpg')
create_master_variant(candle, price: 29.99, sku: 'CNDL-LAV-001', stock: 120)

# 2. Wireless Charging Pad
charger = Product.find_or_create_by!(slug: 'aura-wireless-charging-pad') do |p|
  p.name             = 'Aura Wireless Charging Pad'
  p.description      = '15W fast wireless charging pad compatible with all Qi-enabled devices.'
  p.base_price       = 24.99
  p.compare_at_price = 34.99
  p.brand            = 'AuraTech'
  p.category         = phones_cat
  p.product_type     = 'simple'
  p.total_stock      = 200
end
attach_image(charger, 'https://images.unsplash.com/photo-1622445275463-afa2ab738c34?w=800', 'charger.jpg')
create_master_variant(charger, price: 24.99, sku: 'ELEC-CHRG-001', stock: 200)

# 3. Slim Leather Card Wallet
wallet = Product.find_or_create_by!(slug: 'slim-leather-card-wallet') do |p|
  p.name             = 'Slim Leather Card Wallet'
  p.description      = 'Minimalist genuine leather bifold wallet with 6 card slots.'
  p.base_price       = 34.99
  p.brand            = 'LuxLeather'
  p.category         = lifestyle_cat
  p.product_type     = 'simple'
  p.total_stock      = 80
end
attach_image(wallet, 'https://images.unsplash.com/photo-1627123424574-724758594e93?w=800', 'wallet.jpg')
create_master_variant(wallet, price: 34.99, sku: 'ACC-WALL-001', stock: 80)

# 4. White Sneakers
plain_sneaker = Product.find_or_create_by!(slug: 'cloud-step-classic-white') do |p|
  p.name             = 'CloudStep Classic White Sneakers'
  p.description      = 'Clean, versatile low-top canvas sneakers with cushioned insoles.'
  p.base_price       = 49.99
  p.brand            = 'CloudStep'
  p.category         = sneakers_cat
  p.product_type     = 'simple'
  p.featured         = true
  p.total_stock      = 60
end
attach_image(plain_sneaker, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=800', 'white-sneakers.jpg')
create_master_variant(plain_sneaker, price: 49.99, sku: 'FOOT-SNKR-001', stock: 60)

# ----------------------------------------------------------
# VARIANT PRODUCTS
# ----------------------------------------------------------
puts "Creating variant products & images..."

def ov(ot, val)
  ot.option_values.find_by!(value: val)
end

# 5. Essential Cotton T-Shirt
tshirt = Product.find_or_create_by!(slug: 'essential-cotton-tshirt') do |p|
  p.name               = 'Essential Cotton T-Shirt'
  p.description        = 'Our best-selling 100% organic cotton t-shirt with a relaxed fit.'
  p.base_price         = 19.99
  p.compare_at_price   = 24.99
  p.category           = tshirts_cat
  p.product_type       = 'variant'
  p.featured           = true
end
attach_image(tshirt, 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800', 'tshirt-main.jpg')

# T-Shirt Colors (just a few for brevity)
tshirt_images = {
  'black' => 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=800',
  'white' => 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800',
  'navy'  => 'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=800'
}

ProductOptionType.find_or_create_by!(product: tshirt, option_type: color_ot) { |po| po.is_visual = true; po.position = 0 }
ProductOptionType.find_or_create_by!(product: tshirt, option_type: size_ot)  { |po| po.is_visual = false; po.position = 1 }
tshirt.update!(visual_option_type_id: color_ot.id)

[['black', 'M', tshirt_images['black']], ['white', 'M', tshirt_images['white']], ['navy', 'M', tshirt_images['navy']]].each do |color, size, url|
  v = Variant.find_or_create_by!(sku: "TSHRT-#{color.upcase}-#{size}") do |var|
    var.product = tshirt
    var.price   = 19.99
    var.stock_quantity = 50
  end
  v.option_values |= [ov(color_ot, color), ov(size_ot, size)]
  v.save!
  attach_image(v, url, "tshirt-#{color}.jpg")
end

# Master Product: Minimalist Hoodie
hoodie = Product.find_or_create_by!(slug: 'minimalist-hoodie') do |p|
  p.name        = 'Minimalist Oversized Hoodie'
  p.description = 'Double-layered fleece hoodie with a clean, hardware-free design. Brushed interior for ultimate comfort.'
  p.base_price  = 95.00
  p.category    = hoodies_cat
  p.brand       = 'Ethereal'
  p.tags        = ['fleece', 'oversized', 'minimalist']
  p.featured    = true
end
attach_image(hoodie, 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800', 'hoodie-main.jpg')

hoodie_images = {
  'black' => 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800',
  'gray'  => 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=800'
}

[['black', 'L', hoodie_images['black']], ['gray', 'L', hoodie_images['gray']]].each do |color, size, url|
  v = Variant.find_or_create_by!(sku: "HOOD-#{color.upcase}-#{size}") do |var|
    var.product = hoodie
    var.price   = 54.99
    var.stock_quantity = 40
  end
  v.option_values |= [ov(color_ot, color), ov(size_ot, size)]
  v.save!
  attach_image(v, url, "hoodie-#{color}.jpg")
end

# 7. NovaPro X12 Smartphone
phone = Product.find_or_create_by!(slug: 'novapro-smartphone') do |p|
  p.name             = 'NovaPro X12 Smartphone'
  p.description      = '6.7" AMOLED display, 108MP triple camera, 5G-ready.'
  p.base_price       = 699.99
  p.category         = phones_cat
  p.product_type     = 'variant'
  p.featured         = true
end
attach_image(phone, 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800', 'phone-main.jpg')

[['black', '128GB', 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800'], ['white', '128GB', 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=800']].each do |color, storage, url|
  v = Variant.find_or_create_by!(sku: "PHONE-#{color.upcase}-#{storage}") do |var|
    var.product = phone
    var.price   = 699.99
    var.stock_quantity = 20
  end
  v.option_values |= [ov(color_ot, color), ov(storage_ot, storage)]
  v.save!
  attach_image(v, url, "phone-#{color}.jpg")
end
GC.start # Reclaim memory after variant creation


# 8. Heritage Explorer Backpack
bag = Product.find_or_create_by!(slug: 'heritage-backpack') do |p|
  p.name             = 'Heritage Explorer Backpack'
  p.description      = '28L capacity backpack with a padded 15" laptop compartment.'
  p.base_price       = 89.99
  p.category         = bags_cat
  p.product_type     = 'variant'
  p.featured         = true
end
attach_image(bag, 'https://images.unsplash.com/photo-1547949003-9792a18a2601?w=800', 'backpack-main.jpg')

[['canvas', 'navy', 'https://images.unsplash.com/photo-1547949003-9792a18a2601?w=800'], ['leather', 'brown', 'https://images.unsplash.com/photo-1590874139869-045a133f8fe4?w=800']].each do |material, color, url|
  v = Variant.find_or_create_by!(sku: "BAG-#{material.upcase}-#{color.upcase}") do |var|
    var.product = bag
    var.price   = material == 'leather' ? 109.99 : 89.99
    var.stock_quantity = 15
  end
  v.option_values |= [ov(material_ot, material), ov(color_ot, color)]
  v.save!
  attach_image(v, url, "bag-#{material}-#{color}.jpg")
end

# ----------------------------------------------------------
# 9. iPhone 16 (Premium Variant Seeding)
# ----------------------------------------------------------
puts "Seeding iPhone 16 with variants..."

iphone_16_desc = "The iPhone 16, launched in September 2024, combines sleek design with powerful performance. Featuring a 6.1-inch Super Retina XDR OLED display, the Apple A18 chip, and up to 512GB storage, it delivers lightning-fast speed and stunning visuals. With a 48MP main camera, advanced iOS 18, and durable Ceramic Shield protection, the iPhone 16 is built for both productivity and creativity. Available in Ultramarine, Teal, Pink, White, and Black, it balances elegance with cutting-edge technology."

# ----------------------------------------------------------
# I Phone 16 - Seeding Cleanup & fresh creation
# ----------------------------------------------------------
iphone = Product.find_or_create_by!(slug: 'iphone-16-ultimate-performance-style') do |p|
  p.name               = 'I phone 16'
  p.description        = iphone_16_desc
  p.base_price         = 699.00
  p.compare_at_price   = 799.00
  p.brand              = 'Apple'
  p.category           = phones_cat
  p.product_type       = 'variant'
  p.featured           = true
  p.tags               = %w[iphone new apple smartphone]
end

# CLEANUP: Identify canonical SKUs and safely remove others if possible
canonical_skus = []
colors_list = ['red', 'green', 'blue']
storages_list = ['128GB', '256GB', '512GB']
colors_list.each { |c| storages_list.each { |s| canonical_skus << "IPH16-#{c.upcase}-#{s}" } }

iphone.variants.where.not(sku: canonical_skus).each do |v|
  v.destroy
rescue ActiveRecord::RecordNotDestroyed
  # Keep legacy variants that have orders, but we won't show them in the primary UI if possible
  puts "  ℹ️ Skipping legacy variant #{v.sku} (has orders)"
end

iphone.product_option_types.destroy_all
iphone.product_specifications.destroy_all

# Ensure Option Types & Values are updated
color_ot_iphone = find_or_build_option_type(
  name: 'color', 
  presentation: 'Color', 
  values: { 'red' => 'Red', 'green' => 'Green', 'blue' => 'Blue' }
)
storage_ot_iphone = find_or_build_option_type(
  name: 'storage', 
  presentation: 'Storage', 
  values: { '128GB' => '128 GB', '256GB' => '256 GB', '512GB' => '512 GB' }
)

# Associate Options
# RAM option removed as a selectable variant (it's now in specifications only)

# Associate Options
# (RAM removed from associations to match local UI)
pot_color = ProductOptionType.find_or_initialize_by(product: iphone, option_type: color_ot_iphone)
pot_color.update!(is_visual: true, position: 0)

pot_storage = ProductOptionType.find_or_initialize_by(product: iphone, option_type: storage_ot_iphone)
pot_storage.update!(is_visual: false, position: 1)

iphone.update!(visual_option_type_id: color_ot_iphone.id)

# Specifications
iphone.product_specifications.destroy_all
[
  ['Display',      '6.1-inch Super Retina XDR OLED, 2556×1179 pixels'],
  ['Processor',    'Apple A18 chip with 8GB LPDDR5X RAM'],
  ['Storage Options', '128GB, 256GB, 512GB NVMe'],
  ['Battery',      '3561 mAh, MagSafe and Qi2 wireless charging support'],
  ['Connectivity', '5G enabled with Qualcomm Snapdragon X71 modem']
].each do |name, value|
  iphone.product_specifications.create!(name: name, value: value)
end

# Main Product Image
attach_image(iphone, 'https://images.unsplash.com/photo-1726059635073-631d8ce44e6b?w=1200', 'iphone-16-main.webp')

# Variants Setup
colors = {
  'red'   => ['https://images.unsplash.com/photo-1616348436168-de43ad0db179?w=800', 'https://images.unsplash.com/photo-1592890288564-76628a30a657?w=800'],
  'green' => ['https://images.unsplash.com/photo-1605236453023-294556ef830c?w=800', 'https://images.unsplash.com/photo-1585060544812-6b45742d762f?w=800'],
  'blue'  => ['https://images.unsplash.com/photo-1510557880182-3d4d3cba3f95?w=800', 'https://images.unsplash.com/photo-1509741102003-ca64bfe5f069?w=800']
}

storage_prices = {
  '128GB' => 699,
  '256GB' => 799,
  '512GB' => 899
}

colors.each do |color, urls|
  storage_prices.each do |storage, price|
    sku = "IPH16-#{color.upcase}-#{storage}"
    v = Variant.find_or_initialize_by(sku: sku)
    v.product = iphone
    v.price   = price
    v.stock_quantity = 20
    
    v.option_values.destroy_all
    v.option_values |= [ov(color_ot_iphone, color), ov(storage_ot_iphone, storage)]
    v.save!
    
    urls.each_with_index do |url, idx|
      attach_image(v, url, "iphone-16-#{color}-#{idx + 1}.webp")
    end
  end
end
GC.start # Reclaim memory after iPhone variant creation


# ----------------------------------------------------------
# More Varied Products for Sub-categories
# ----------------------------------------------------------
puts "Creating more variety..."

# Women - Dresses
dress = Product.find_or_create_by!(slug: 'silk-slip-dress') do |p|
  p.name        = 'Champagne Silk Slip Dress'
  p.description = '100% mulberry silk dress with adjustable straps and a midi length. Effortless elegance.'
  p.base_price  = 180.00
  p.category    = dresses_cat
  p.brand       = 'Ethereal'
  p.tags        = ['silk', 'midi', 'evening']
end
attach_image(dress, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800', 'dress.jpg')

# Electronics - Laptops
laptop = Product.find_or_create_by!(slug: 'pro-artisan-laptop') do |p|
  p.name        = 'Pro Artisan Laptop 14"'
  p.description = 'M3 Max chip, 32GB RAM, 1TB SSD. The ultimate machine for creators.'
  p.base_price  = 2499.00
  p.category    = laptops_cat
  p.brand       = 'EtherealTech'
end
attach_image(laptop, 'https://images.unsplash.com/photo-1517336712461-a49a1f1b1bcc?w=800', 'laptop.jpg')

# Women - Handbags
bag = Product.find_or_create_by!(slug: 'sculpted-leather-clutch') do |p|
  p.name        = 'Sculpted Leather Clutch'
  p.description = 'Hand-sculpted Italian leather clutch with a magnetic closure and gold-tone hardware.'
  p.base_price  = 210.00
  p.category    = handbags_cat
  p.brand       = 'Ethereal'
end
attach_image(bag, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=800', 'handbag.jpg')

# Women - Tops
top = Product.find_or_create_by!(slug: 'ribbed-linen-tank') do |p|
  p.name        = 'Ribbed Linen Tank'
  p.description = 'Breathable linen-blend tank with a subtle ribbed texture. A summer essential.'
  p.base_price  = 55.00
  p.category    = tops_cat
  p.brand       = 'Ethereal'
end
attach_image(top, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800', 'tank.jpg')

# Electronics - Audio
headphone = Product.find_or_create_by!(slug: 'ethereal-studio-buds') do |p|
  p.name        = 'Ethereal Studio Buds'
  p.description = 'Crystal clear audio with 30-hour battery life and an ergonomic artisan fit.'
  p.base_price  = 199.00
  p.category    = headphones_cat
  p.brand       = 'EtherealSound'
end
attach_image(headphone, 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=800', 'buds.jpg')

# ----------------------------------------------------------
# Banners
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

# ----------------------------------------------------------
# Done
# ----------------------------------------------------------
puts ""
puts "✅ Seed complete with high-quality images!"
puts "  Categories : #{Category.count}"
puts "  Products   : #{Product.count}"
puts "  Variants   : #{Variant.count}"
puts "  Banners    : #{Banner.count}"
