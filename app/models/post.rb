class Post < ActiveResource::Base
	self.site = "http://localhost:8888" # AwsSdbProxy host + port
	self.prefix = "/my_new_domain/"     # use your SimpleDB domain enclosed in /s

	def self.all
		find(:all)
	end

	#####

	def self.attr_accessible(*attributes)
		write_inheritable_attribute(:attr_accessible, Set.new(attributes.map(&:to_s)) + (accessible_attributes || []))
	end

	def self.accessible_attributes
		read_inheritable_attribute(:attr_accessible)
	end

	def self.protected_attributes # :nodoc:
		read_inheritable_attribute(:attr_protected)
	end

	def attributes_protected_by_default
		default = []	#[ self.class.primary_key, self.class.inheritance_column ]
#		default << 'id' unless self.class.primary_key.eql? 'id'
		default
	end

	def self.inheritance_column
		@inheritance_column ||= "type".freeze
	end

	def assign_attributes(attributes={})
		multiparameter_attributes = []
        
		attributes.each do |k, v|
			if k.to_s.include?("(")
				multiparameter_attributes << [ k, v ]
			else
				#	respond_to?(:"#{k}=") ? send(:"#{k}=", v) : raise(UnknownAttributeError, "unknown attribute: #{k}")
				#	There are no predefined columns with SimpleDB so just ...
				send(:"#{k}=", v)
			end
		end

		assign_multiparameter_attributes(multiparameter_attributes) unless  multiparameter_attributes.empty?        
	end

	def log_protected_attribute_removal(*attributes)
		#	There is no logger set up yet so ...
		#logger.debug "WARNING: Can't mass-assign these protected attributes: #{attributes.join(', ')}"
	end

	def attributes=(new_attributes, guard_protected_attributes = true)
		return if new_attributes.nil?
		attributes = new_attributes.dup
		attributes.stringify_keys!

		attributes = remove_attributes_protected_from_mass_assignment(attributes) if guard_protected_attributes
		assign_attributes(attributes) if attributes and attributes.any?
	end

	def remove_attributes_protected_from_mass_assignment(attributes)
		safe_attributes =
			if self.class.accessible_attributes.nil? && self.class.protected_attributes.nil?
				attributes.reject { |key, value| 
					attributes_protected_by_default.include?(key.gsub(/\(.+/, "")) }
			elsif self.class.protected_attributes.nil?
				attributes.reject { |key, value| 
					!self.class.accessible_attributes.include?(key.gsub(/\(.+/, "")) || 
						attributes_protected_by_default.include?(key.gsub(/\(.+/, "")) }
			elsif self.class.accessible_attributes.nil?
				attributes.reject { |key, value| 
					self.class.protected_attributes.include?(key.gsub(/\(.+/,"")) || 
						attributes_protected_by_default.include?(key.gsub(/\(.+/, "")) }
			else
				raise "Declare either attr_protected or attr_accessible for #{self.class}, but not both."
			end

		removed_attributes = attributes.keys - safe_attributes.keys

		if removed_attributes.any?
			log_protected_attribute_removal(removed_attributes)
		end

		safe_attributes
	end

	#	initialize fires on new/create as well as find
	def initialize(attributes = {})
		@attributes     = {}
		@prefix_options = {}

		#	This command effectively filters
		self.attributes = ( attributes.empty? ) ? {} : attributes 
		load(self.attributes)

#		load(attributes)
	end

#	All of the above is from ActiveRecord::Base to restrict field names
#	but so far only works on update.  Still working on getting the restriction
#	to work at create

	#	MUST include :id until find a better way
	#	without some type of id blocking, using ActiveResource and SimpleDB doesn't seem secure
	# particularly due to all of the hacking that I've been doing.
	#	The app is the assigner of the id, NOT the SimpleDB.  Because of this
	#	a hacker could include ids and 'steal' records.	
	#	There has to be a better way
	attr_accessible :title, :body, :id	

	def title
		self.attributes['title'] || nil
	end

	def body
		self.attributes['body'] || nil
	end

	def update_attributes(attributes={})
#		self.attributes.merge!(options)
#		self.save
		self.attributes = attributes
		save
	end

end
