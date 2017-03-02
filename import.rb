# Use this file to import the sales information into the
# the database.

require "pg"
require "csv"
require "pry"

def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  ensure
    connection.close
  end
end

csv_sales = CSV.readlines('sales.csv', headers: true)

def confirm?(table_matches, row_check, customer_data)
  db_connection do |conn|
    customer_check = conn.exec_params('SELECT id FROM customers WHERE name=$1', ["#{customer_data[0]}"])
    if table_matches.to_a.empty? # if no invoice numbers are within table
      return true

      # this statement is to add the row if the invoice number is duplicated once,
      # and if the customers are different then add it to the list
    elsif table_matches.to_a.length == 1 && table_matches[0]["customer_id"] != customer_check[0]["id"]
      return true

      # starts logic if more than one match
    elsif table_matches.to_a.length > 1
      # cycles through each match, if any of the table entries with matching invoice
      # numbers have matching customers, the row will not be added to the able.
      table_matches.each do |match|
        if match["customer_id"] == customer_check[0]["id"]
          return false
        end
      end
      return true
    end

  end
end

csv_sales.each do |sale|
  db_connection do |conn|
    # filling out employee table
    employee_data = sale["employee"].gsub(")","").split(" (")
    result = conn.exec_params("SELECT name FROM employees WHERE name=$1", [employee_data[0]])

    if result.to_a.empty? # adds to table if not apparent
      conn.exec_params("INSERT INTO employees (name, email) VALUES($1, $2)",
        [employee_data[0], employee_data[1]])
    end


    #filling out customers table
    customer_data = sale["customer_and_account_no"].gsub(")","").split(" (")
    result = conn.exec_params("SELECT name FROM customers WHERE name=$1", [customer_data[0]])

    if result.to_a.empty?
      conn.exec_params("INSERT INTO customers (name, account_no) VALUES($1, $2)",
        [customer_data[0], customer_data[1]])
    end


    #filling out invoice_types table
    invoice_type = sale["invoice_frequency"]
    result = conn.exec_params("SELECT type FROM invoice_types WHERE type=$1", [invoice_type])

    if result.to_a.empty?
      conn.exec_params("INSERT INTO invoice_types (type) VALUES($1)",
        [invoice_type])
    end


    #filling out products table
    product_type = sale["product_name"]
    result = conn.exec_params("SELECT glass_type FROM products WHERE glass_type=$1", [product_type])

    if result.to_a.empty?
      conn.exec_params("INSERT INTO products (glass_type) VALUES($1)",
        [product_type])
    end


    #filling out sales table
    send_object = conn.exec_params("SELECT invoice_no, customer_id FROM sales WHERE invoice_no=$1", [sale["invoice_no"]])
    add_to_table = confirm?(send_object, sale, customer_data) # sending it the search result, the current row, and an array of customer_data

    if add_to_table == true
      employee_id = conn.exec_params('SELECT id FROM employees WHERE name=$1', [employee_data[0]])[0]["id"]
      customer_id = conn.exec_params('SELECT id FROM customers WHERE name=$1', [customer_data[0]])[0]["id"]
      product_id = conn.exec_params('SELECT id FROM products WHERE glass_type=$1', [product_type])[0]["id"]
      invoice_type_id = conn.exec_params('SELECT id FROM invoice_types WHERE type=$1', [invoice_type])[0]["id"]

      conn.exec_params("INSERT INTO sales (
      invoice_no, employee_id, customer_id,
      product_id, sale_date, sale_amount, units_sold, invoice_type_id)
      VALUES($1, $2, $3, $4, $5, $6, $7, $8)",[sale["invoice_no"], employee_id, customer_id, product_id, sale["sale_date"], (sale["sale_amount"].gsub("$","").to_f), sale["units_sold"], invoice_type_id])
    end

  end
end
