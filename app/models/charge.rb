class Charge < ApplicationRecord
	belongs_to :user
	validates :stripe_id, uniqueness: true

	def receipt
		Receipts::Receipt.new(
			id: id,
			product: "Auto Deploy",
			company: {
				name: "Intellecta.co Pty Ltd\n\n",
				address: "PECHS Block 4,\nShahra-e-faisal Progressive Center\nSuit # 312, Karachi",
				email: "services@intellecta.co",
				logo: Rails.root.join("app/assets/images/intellecta-logo.png")
			},
			line_items: [
				["Date",           created_at.to_s],
				["Account Billed", "#{user.email}"],
				["Product",        "Auto Deploy"],
				["Amount",         "$#{amount / 100}.00"],
				["Charged to",     "#{card_type} (**** **** **** #{card_last4})"],
			],
			font: {
				bold: Rails.root.join('app/assets/fonts/Montserrat-Bold.ttf'),
				normal: Rails.root.join('app/assets/fonts/Montserrat-Regular.ttf'),
			}
		)
	end
end


