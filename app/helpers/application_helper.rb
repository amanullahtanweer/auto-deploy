module ApplicationHelper
	def active_class(link_path)
	 current_page?(link_path) ? 'active' : ''
	end

	def avatar_url(user)
		default_url = "https://www.gravatar.com/avatar/00000000000000000000000000000000?s=24&d=retro&f=y"
		gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
		"https://gravatar.com/avatar/#{gravatar_id}.png?s=24&d=#{CGI.escape(default_url)}"
	end


	def standard_table_class 
		"table table-hover"
	end

	def admin_aside_left_class
		"col-lg-2 text-left pr-0"
	end

	def admin_aside_right_class
		"col-lg-10 pr-0"
	end

	def formatted_date(date)
		"<i class='paragraph-icon material-icons'>date_range</i> #{date.strftime("%d-%m-%Y")}".html_safe
	end

	def filter_button
		return '<a href="#" id="search_fields_button" class="btn btn-warning btn-sm text-right float-right"><i class="align-middle material-icons">filter_list</i> <span class="align-middle">Filters</span></a>'.html_safe
	end

	def order_by_dropdown
		return '<div class="dropdown"> <button class="btn btn-outline btn-outline-secondary dropdown-toggle btn-sm" type="button" data-toggle="dropdown"> Last Created </button> <div class="dropdown-menu" aria-labelledby="dropdownMenuButton"> <a class="dropdown-item" href="?q%5Bs%5D=created_at+desc">Last Created</a> <a class="dropdown-item" href="?q%5Bs%5D=created_at+asc">Oldest created</a> <a class="dropdown-item" href="?q%5Bs%5D=updated_at+asc">Oldest updated</a> </div> </div>'.html_safe
	end

	def filter_params_present
		"display-force" if params[:q]
	end
end
