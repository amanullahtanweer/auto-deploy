Role.create(name: "admin")
@user = User.create!(email: "admin@admin.com", password: "admin123")
@user.add_role :admin
