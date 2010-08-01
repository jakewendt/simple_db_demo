class Post < ActiveResource::Base
	self.site = "http://localhost:8888" # AwsSdbProxy host + port
	self.prefix = "/my_new_domain/"     # use your SimpleDB domain enclosed in /s

	def self.all
		find(:all)
	end

	def title
		self.attributes['title'] || 'undefined'
	end

	def body
		self.attributes['body'] || 'undefined'
	end

	def update_attributes(options={})
		self.attributes.merge!(options)
		self.save
	end

end
