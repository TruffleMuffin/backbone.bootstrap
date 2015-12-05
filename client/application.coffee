# This is the primary application code for backbone.bootstrap
module.exports = class Application

	constructor: (options = {}) ->
		# Establish a cache in the public zone for testing purposes
		@cache = new (require './cache')

		# Initialize the application
		@initialize()

		# Allow the constructor to chain calls
		return this

	# Retrieve all bootstrap data in the DOM, and if there are
	# items available override Backbone.sync
	initialize: (options = {}) ->
		# Scan for bootstrap data and store it in the cache
		@_cacheBootstrapData()

		# If data has been cached, then override Backbone.sync to make it available
		if @cache.count() > 0
			@_overrideBackboneSync()

		# Allow initialize to have chained calls
		return this

	# Isolate all bootstrap data and cache it
	_cacheBootstrapData: ->
		# Locate all matching script tags, and for each cache the value
		$('script[type="application/json"][data-url]').each (index, element) =>
			# Turn the element into a jQuery object to parse easily
			bootstrap = $(element)
			# Try to parse data as JSON
			try
				data = JSON.parse(bootstrap.html())
				# Cache it
				@cache.set bootstrap.data('url'), data
			catch e
				# Ignore this key as it isn't valid JSON data
				console?.warn 'backbone.bootstrap - Invalid JSON for ' + bootstrap.data('url') + ' was not cached.'

	# The method that should replace Backbone.sync to pull items from cache
	_cacheSync: (method, model, options) =>
		# Use the url to determine if the data is cached
		cacheKey = options?.url ? _.result(model, 'url')

		# Identify if this is a backbone sync that is cached
		if method is "read"
			if (data = @cache.get(cacheKey)) isnt null
				# If the cache data is available, call appropriate success
				# callbacks wit hthe data
				model.trigger("sync", model, data, options)
				options.success(data)
				# Return true as the function was successful
				return true

		# Identify if the backbone sync is attempting to delete/update cached data
		else if method is "delete" or method is "update"
			# Delete the key from the cache
			@cache.remove(cacheKey)

		# If the item is not cache use the original backbone.sync
		@BackboneSync.apply(this, [method, model, options])

	# Override backbone.sync functionality to insert cached data when appropriate
	_overrideBackboneSync: ->
		# Save the original backbone.sync method
		@BackboneSync = Backbone.sync
		# Override backbone sync
		Backbone.sync = @_cacheSync

