class Post < ActiveResource::Base
	self.site = "http://localhost:8888" # AwsSdbProxy host + port
	self.prefix = "/my_new_domain/"     # use your SimpleDB domain enclosed in /s

	def self.all
		find(:all)
	end

#      def self.attr_accessible(*attributes)
##        write_inheritable_attribute(:attr_accessible, Set.new(attributes.map(&:to_s)) + (accessible_attributes || []))
#        write_inheritable_attribute(:attr_accessible, Set.new(attributes.map(&:to_s)) )
#      end
#
#	# A little macro like ... 
#		attr_accessible :title, :body
#	#	would be nice

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
