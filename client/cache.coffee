# This is the cache for storing bootstrap data
module.exports = class Cache

	constructor: (options = {}) ->
		# The cache should be bound to this instance
		@_cache = {}
		# Allow the constructor to be chained
		return this

	# Get an item from the cache, return null if none exists
	get: (key) ->
		# Check for the key before trying to access
		if _.has(@_cache, key)
			return @_cache[key]

		# The default is null
		return null

	# Set an item into the cache
	set: (key, object) ->
		# Set the key
		@_cache[key] = object
		# Return if it was set successfully, this should always be true
		return _.has(@_cache, key)

	# Remove the provided key form the cache
	remove: (key) ->
		# Delete the key
		delete @_cache[key]
		# Verify it is gone as the reponse
		return not _.has(@_cache, key)

	# Return all available cache keys
	listKeys: ->
		return _.keys(@_cache)

	# Return the total items in the cache
	count: ->
		return _.size(@_cache)

