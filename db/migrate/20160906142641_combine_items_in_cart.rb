class CombineItemsInCart < ActiveRecord::Migration[5.0]
  # def change
  # end
  def self.up
  	# replace multiple items for a single product in a cart with a single item
  	Cart.all.each do |cart|
  		# count the number of each product in the cart
  		sums = cart.line_items.group(:product_id).sum(:quantity)

  		sums.each do |product_id, quantity|
  			if quantity > 1
  				# remove individual itemss
  				cart.line_items.where(product_id: product_id).delete_all

  				# replace with a single item
  				cart.line_items.create(product_id: product_id, quantity: quantity)
  			end
  		end
  	end
  end


  def self.down
  	# split items with quantity>1 into multiple items
  	LineItem.where("quantity>1").each do |line_items|
  		# add individual items
  		line_items.quantity.times do
  			LineItem.create cart_id: line_items.cart_id, product_id: line_items.product_id, quantity: 1
  		end

  		# remove original item
  		line_items.destroy
  	end
  end

end
