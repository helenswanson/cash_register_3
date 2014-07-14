#!/usr/bin/env ruby
require 'csv'
require 'pry'

#force value to have 2 decimals; output is string
def force_2decimals(value)
  '%.2f' % value
end

def ask_how_many()
  puts "How many?\n"
  gets.chomp
end

def gets_amount(amount_type)
  puts "What is the #{amount_type}?"
  gets.chomp
end

#extract csv info into an array of hashes
def extract_csv_info
  menu = []
  CSV.foreach('products.csv', headers: true) do |row|
    #reassigning variables
    row["wholesale_price"] = row["wholesale_price"].to_f
    row["retail_price"] = row["retail_price"].to_f
    menu << row
  end
  menu
end

#output welcome + menu in specified format
def show_menu(menu)
  puts "Welcome to James' coffee emporium!\n"
  count = 1
  #enter hash menu --> sku = key and product_info = value
  menu.each do |product|
    #create variables for items in hash
    price = force_2decimals(product["retail_price"])
    name = product["name"]
    puts "#{count}) Add item - $#{price} - #{name}"
    count += 1
  end
  puts "#{count}) Complete Sale
  "
  count
end

#outputs a list of items purchased: cost/#/type
def show_order(cust_order, menu)
  puts "===Sale Complete===\n\n"

  #for every item in cust_order, print out subtotal, quantity, and name
  cust_order.each do |sku, quantity|
    product_info = menu.select{|item| item["SKU"].to_i==sku}.first
    item_subtotal = force_2decimals(quantity.to_i * product_info["retail_price"])
    name = product_info["name"]
    puts "$#{item_subtotal} - #{quantity} #{name}"
  end
end

#write csv to a new file
#cust_order is a hash with sku key and units value
def write_csv(cust_order)
  #add sku and units to exported hash
  CSV.open("final_cust_order.csv", "a") do |file|
    cust_order.to_a.each do |item_info|
      file << item_info
    end
  end
end

#=======================================================================

final_total = 0
line_items = []
cust_order = {}
menu = extract_csv_info
#options max menu options
options = show_menu(menu)


while true
  #prompt a selection
  puts "Make a selection:"
  selection = gets.chomp.to_i
  if selection == options
    break
  end
  #if the selection is invalid, output sorry message
  if selection > options or selection == 0
    puts "Sorry, that option isn't available.\n\n"
  else
    #while the transaction is still going
    if selection != options
      #prompt how many of selection
      how_many = ask_how_many()
      #if how_many isn't a valid number, re-ask how many
      while how_many != how_many.to_i.to_s
        puts "Sorry, that option isn't available.\n\n"
        how_many = ask_how_many()
      end
      #store information in line_items array
      line_items << [selection, how_many]

      price = menu[selection-1]["retail_price"]
      subtotal = price * how_many.to_f
      final_total += subtotal
      puts "Subtotal: $#{force_2decimals(final_total)}\n\n"
    end
  end
end

#cust_order contains sku key and quantity value
line_items.each do |selection, quantity|
  sku = menu[selection-1]["SKU"].to_i
  if cust_order.has_key?(sku)
    cust_order[sku] += quantity.to_i
  else
    cust_order[sku] = quantity.to_i
  end
end

#output complete sale!
#show_order outputs a list of items purchased: cost/#/type
show_order(cust_order, menu)
puts "Total: $#{force_2decimals(final_total)}"

#prompt for amount tendered
amount_tendered = gets_amount("amount tendered").to_f
change = amount_tendered - final_total

#while money owed, display warning and ask for amount again
while amount_tendered < final_total
    change = force_2decimals(change).to_f.abs
    puts "WARNING: Customer still owes $#{force_2decimals(change)}"
    amount_tendered = gets_amount("amount tendered").to_f
    change = amount_tendered - final_total
end

change = force_2decimals(change.abs)

puts "===Thank You!==="
puts "The total change due is $#{change}\n\n"
#output time in the format 02/12/2013 5:50PM
puts Time.now.strftime("%m/%d/%Y %l:%M%p")
puts "================"

write_csv(cust_order)

