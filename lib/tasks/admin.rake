namespace :admin do
  desc 'Setup admin user'
  task setup: :environment do
    print 'Email: '
    email = STDIN.gets.chomp
    print 'Password: '
    password = STDIN.noecho(&:gets).chomp
    puts

    result = AdminUser.create(email: email, password: password)
    if result.valid?
      puts "Admin #{email} is created!"
    else
      result.errors.full_messages.each do |message|
        puts message
      end
    end
  end
end
