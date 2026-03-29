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
# Categories
# ----------------------------------------------------------
puts "Creating Categories & Images..."

cat_images = {
  'Clothing'      => 'https://images.unsplash.com/photo-1445205170230-053b830c6050?w=800',
  'Electronics'   => 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=800',
  'Footwear'      => 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=800',
  'Accessories'   => 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
  'Home & Living' => 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=800'
}

categories = {}
cat_images.each do |name, url|
  cat = Category.find_or_create_by!(name: name)
  attach_image(cat, url, "#{name.parameterize}.jpg")
  categories[name] = cat
end

# Sub-categories
tshirts_cat  = Category.find_or_create_by!(name: 'T-Shirts',  parent: categories['Clothing'])
hoodies_cat  = Category.find_or_create_by!(name: 'Hoodies',   parent: categories['Clothing'])
phones_cat   = Category.find_or_create_by!(name: 'Phones',    parent: categories['Electronics'])
laptops_cat  = Category.find_or_create_by!(name: 'Laptops',   parent: categories['Electronics'])
sneakers_cat = Category.find_or_create_by!(name: 'Sneakers',  parent: categories['Footwear'])
bags_cat     = Category.find_or_create_by!(name: 'Bags',      parent: categories['Accessories'])
candles_cat  = Category.find_or_create_by!(name: 'Candles',   parent: categories['Home & Living'])

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
  p.category         = categories['Electronics']
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
  p.category         = categories['Accessories']
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

# 6. Urban Pullover Hoodie
hoodie = Product.find_or_create_by!(slug: 'urban-pullover-hoodie') do |p|
  p.name             = 'Urban Pullover Hoodie'
  p.description      = 'A heavyweight 380gsm fleece hoodie with a kangaroo pocket.'
  p.base_price       = 54.99
  p.category         = hoodies_cat
  p.product_type     = 'variant'
  p.featured         = true
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
# Done
# ----------------------------------------------------------
puts ""
puts "✅ Seed complete with images!"
puts "  Categories : #{Category.count}"
puts "  Products   : #{Product.count}"
puts "  Variants   : #{Variant.count}"
