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
