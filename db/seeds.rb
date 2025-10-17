# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Admin creation: only from environment variables. Do NOT hardcode credentials here.
admin_email    = ENV["ADMIN_EMAIL"]
admin_password = ENV["ADMIN_PASSWORD"]
admin_name     = ENV["ADMIN_NAME"]

if admin_email && admin_password
	admin = Admin.find_or_initialize_by(email: admin_email)
	admin.password = admin_password
	admin.password = admin_password
	admin.save!
	puts "Admin ensured: #{admin_email}"
else
	puts "Skipping admin creation: set ADMIN_EMAIL and ADMIN_PASSWORD to create an admin user."
end

# Optional demo data: create sample tags and books if DEMO_DATA env flag set
if ENV['SEED_DEMO'] == '1'
	tags = %w[Fiction Science History].map { |n| Tag.find_or_create_by!(name: n) }

	Book.find_or_create_by!(title: 'Example Book') do |b|
		b.author = 'Author A'
		b.published_at = Date.today - 365
		b.price = 1000
		b.status = 'on_sale'
		b.tags = tags.first(2)
	end
	puts 'Sample books and tags created.'
end
