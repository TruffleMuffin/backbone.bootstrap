exports.config =

	server:
		port: 3000

	paths:
		watched: [
			'client'
			'test'
		]

	modules:
		nameCleaner: (path) ->
			path = path.replace /^client/, 'backbone.bootstrap'
			path


	conventions:
		vendor: /(bower_components|auto_start.coffee)/

	files:
		javascripts:
			joinTo:
				'javascripts/vendor.js': /^(bower_components)/
				'javascripts/backbone.bootstrap.js': /^(client)/

				'../lib/backbone.bootstrap.js': /^(client)/

				'test/javascripts/test.js': /^test/

			order:
				before: [
					'bower_components/jquery/dist/jquery.js'
				]
				after: [
					'client/auto_start.coffee'
				]

	plugins:
		uglify:
			mangle: false
			compress: true

	sourceMaps: no