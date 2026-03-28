class Api::ProductsController < Api::ApplicationController
  def index
    products = Product.with_attached_images.includes(:category, :variants)
                      .where(active: true)

    # Filters
    if params[:category_id].present?
      category = Category.find_by(id: params[:category_id])
      products = products.where(category_id: category.subtree_ids) if category
    end
    products = products.featured if params[:featured] == 'true'

    # Sorting
    case params[:sort_by]
    when 'newest'
      products = products.order(created_at: :desc)
    when 'price_asc'
      products = products.order(base_price: :asc)
    when 'price_desc'
      products = products.order(base_price: :desc)
    when 'popular'
      products = products.order(featured: :desc, created_at: :desc)
    else
      products = products.order(created_at: :desc)
    end

    # Pagination
    page  = [params[:page].to_i, 1].max
    per   = (params[:per_page] || 20).to_i
    total = products.count
    products = products.offset((page - 1) * per).limit(per)

    render json: {
      products: products.map { |p| serialize_product_card(p) },
      meta: { total: total, page: page, per_page: per, total_pages: (total.to_f / per).ceil }
    }
  end

  def show
    product = Product.with_attached_images.includes(
      :category, :product_specifications,
      product_option_types: :option_type,
      variants: [:option_values]
    ).find_by!(slug: params[:slug])

    # Build option type → values map for variant pickers
    used_option_value_ids = product.variants.flat_map(&:option_value_ids).uniq
    option_types = product.product_option_types.map do |pot|
      ot = pot.option_type
      {
        id: ot.id,
        name: ot.name,
        presentation: ot.presentation,
        is_visual: pot.is_visual,
        values: ot.option_values.where(id: used_option_value_ids).map { |ov| { id: ov.id, value: ov.value, presentation: ov.presentation } }
      }
    end

    variants = product.variants.where(is_master: false).map do |v|
      {
        id: v.id,
        sku: v.sku,
        price: v.price.to_f,
        stock: v.stock_quantity,
        is_master: v.is_master,
        option_value_ids: v.option_value_ids,
        images: image_urls(v.images)
      }
    end

    render json: {
      id: product.id,
      name: product.name,
      slug: product.slug,
      description: product.description,
      brand: product.brand,
      base_price: product.base_price.to_f,
      compare_at_price: product.compare_at_price&.to_f,
      discount: product.calculated_discount,
      on_sale: product.on_sale?,
      featured: product.featured,
      free_shipping: product.free_shipping,
      tags: product.tags,
      category: { id: product.category&.id, name: product.category&.name },
      images: image_urls(product.images),
      option_types: option_types,
      variants: variants,
      specifications: product.product_specifications.map { |s| { name: s.name, value: s.value } }
    }
  end

  private

  def image_urls(images)
    super(images)
  end
end
