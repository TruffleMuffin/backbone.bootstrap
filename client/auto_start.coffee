# This will automatically initialize and bind the backbone.bootstrap
# utility.

# Initialize the application
$(document).ready ->
	(new (require 'backbone.bootstrap/application')).initialize()