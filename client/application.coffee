# This is the primary application code for backbone.bootstrap
module.exports = class Application

	constructor: (options = {}) ->
		# Establish a cache in the public zone for testing purposes
		@cache = new (require './cache')

		# Allow the constructor to chain calls
		return this

	# Retrieve all bootstrap data in the DOM, and if there are
	# items available override Backbone.ajax
	initialize: (options = {}) ->
		# Scan for bootstrap data and store it in the cache
		@_cacheBootstrapData()

		# If data has been cached, then override Backbone.ajax to make it available
		if @cache.count() > 0
			@_overrideBackboneSync()

		# Allow initialize to have chained calls
		return this

	# Isolate all bootstrap data and cache it
	_cacheBootstrapData: ->
		# Locate all matching script tags, and for each cache the value
		$('script[type="application/json"][data-url]').each @_cacheElement

	# Cache a DOM element
	_cacheElement: (index, element) =>
		# Turn the element into a jQuery object to parse easily
		bootstrap = $(element)
		# Try to parse data as JSON
		try
			html = bootstrap.html()
			data = JSON.parse(html)
			# Create the object to store in the cache
			cacheObject =
				value: data
				usage: bootstrap.data('usage') ? 'once'
			# cache object 'value' will be passed into functions which may modify it
			# convert value into a function that returns a new instance of the data
			if cacheObject.usage is 'forever'
				cacheObject.value = -> JSON.parse(html)
			# Cache it
			@cache.set bootstrap.data('url'), cacheObject
		catch e
			# Ignore this key as it isn't valid JSON data
			console?.warn 'backbone.bootstrap - Invalid JSON for ' + bootstrap.data('url') + ' was not cached.'

	# The method that should replace Backbone.ajax to pull items from cache
	_cacheSync: (options = {}) =>
		# Use the url to determine if the data is cached
		cacheKey = options.url
		# If there is data in options, append to cacheKey as thats the querystring
		if options.data?
			# Accomodate query string values already in the cache key
			if cacheKey.indexOf('?') < 0
				cacheKey += "?"
			else
				cacheKey += "&"
			# Add the param data now an appropriate prefix is applied
			cacheKey += if _.isString(options.data) then options.data else jQuery.param(options.data)

		# clean the cache key of any jQuery busting values. Format is _=<TIMESTAMP>
		cacheKey = cacheKey.replace(/((\?|&)_=([0-9]+))/ig, "")

		# Identify if this is a Backbone.ajax that can be cached
		method = options.type?.toLowerCase()
		if method is "get"
			if (data = @cache.get(cacheKey)) isnt null
				# If the cache data is available, call appropriate success
				# callbacks with the data
				value = if _.isFunction(data.value) then data.value() else data.value
				options.success?(value)
				options.complete?(value)
				# It should remove the cache item, as we don't want to breaking polling type use cases
				@cache.remove(cacheKey) if data.usage is 'once'
				# Return true as the function was successful
				return true

		# Identify if the backbone ajax is attempting to delete/update cached data
		else if method is "delete" or method is "put"
			# Delete the key from the cache
			@cache.remove(cacheKey)

		# If the item is not cached use the original backbone.ajax
		@BackboneSync.apply(this, [options])

	# Override backbone.ajax functionality to insert cached data when appropriate
	_overrideBackboneSync: ->
		# Save the original backbone.ajax method
		@BackboneSync = Backbone.ajax
		# Override backbone ajax
		Backbone.ajax = @_cacheSync