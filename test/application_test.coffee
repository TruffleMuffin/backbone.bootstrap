describe 'backbone.bootstrap/application', ->

	sut = null

	beforeEach ->
		sut = new (require 'backbone.bootstrap/application')()

	it 'should establish a cache', ->
		sut.cache.should.be.instanceOf require 'backbone.bootstrap/cache'

	describe 'initialize', ->

		beforeEach ->
			sinon.stub sut, '_cacheBootstrapData'
			sinon.stub sut, '_overrideBackboneSync'

		it 'should attempt to cache any bootstrap data', ->
			sut.initialize()
			sut._cacheBootstrapData.should.have.been.called

		describe 'when there is bootstrap data', ->

			beforeEach ->
				sinon.stub sut.cache, 'count', -> 1

			it 'should call _overrideBackboneSync', ->
				sut.initialize()
				sut._overrideBackboneSync.should.have.been.called

		describe 'when there is no bootstrap data', ->

			beforeEach ->
				sinon.stub sut.cache, 'count', -> 0

			it 'should call _overrideBackboneSync', ->
				sut.initialize()
				sut._overrideBackboneSync.should.not.have.been.called

	describe '_cacheBootstrapData', ->

		dataIterator = null

		beforeEach ->
			dataIterator =
				each: sinon.stub()
			sinon.stub window, '$', (selector) ->
				return dataIterator if selector is 'script[type="application/json"][data-url]'
				return selector

		afterEach ->
			window.$.restore()

		it 'should use the each function with _cacheElement', ->
			sut._cacheBootstrapData()
			dataIterator.each.should.have.been.calledWith sut._cacheElement

	describe '_cacheElement', ->

		element = null

		beforeEach ->
			element =
				html: sinon.stub().returns('{ "id": 1 }')
				data: sinon.stub().returns('/api')

			sinon.stub sut.cache, 'set'
			sinon.stub window, '$', (selector) ->
				return element if selector is element
				return selector

		afterEach ->
			window.$.restore()

		it 'should get the html from the element', ->
			sut._cacheElement(0, element)
			element.html.should.have.been.called

		it 'should set an item into the cache', ->
			sut._cacheElement(0, element)
			sut.cache.set.should.have.been.calledWith '/api', sinon.match.object

		describe 'invalid JSON', ->

			originalConsole = fakeConsole = null

			beforeEach ->
				element =
					html: sinon.stub().returns("{ id: asdgf }")
					data: sinon.stub().returns('/api')
				fakeConsole =
					warn: sinon.stub()
				originalConsole = window.console
				window.console = fakeConsole

			afterEach ->
				window.console = originalConsole

			it 'should warn on the console', ->
				sut._cacheElement(0, element)
				console.warn.should.have.been.called

	describe '_executeCallback', ->

		options = value = null

		beforeEach ->
			value = {}
			options = { success: sinon.stub() }

		it 'should trigger the success callback', ->
			sut._executeCallback options, value
			options.success.should.have.been.calledWith value

		describe 'when there is a complete callback in the options', ->

			data = null

			beforeEach ->
				options = _.extend options,
					complete: sinon.stub()

			it 'should trigger the complete callback', ->
				sut._executeCallback options, value
				options.complete.should.have.been.calledWith value

	describe '_cacheSync', ->

		options = null

		beforeEach ->
			options = { success: sinon.stub(), url: '/api' }
			sut.BackboneSync = sinon.stub()
			sinon.stub sut.cache, 'remove'

		describe 'method is post', ->

			it 'should call the original backbone sync', ->
				options.type = 'POST'
				sut._cacheSync options
				sut.BackboneSync.should.have.been.calledWith options

		describe 'method is delete', ->

			it 'should remove the cache key', ->
				options.type = 'DELETE'
				sut._cacheSync options
				sut.cache.remove.should.have.been.calledWith '/api'

		describe 'method is put', ->

			it 'should remove the cache key', ->
				options.type = 'PUT'
				sut._cacheSync options
				sut.cache.remove.should.have.been.calledWith '/api'

		describe 'method is get', ->

			describe 'when there is data in the cache', ->

				data = null

				beforeEach ->
					options.type = "GET"
					data = { value: { prop: true }, usage: 'once' }
					sinon.stub sut.cache, 'get', -> data

				it 'should retrieve the cache key', ->
					sut._cacheSync options
					sut.cache.get.should.have.been.calledWith '/api'

				it 'should remove the cache key', ->
					sut._cacheSync options
					sut.cache.remove.should.have.been.calledWith '/api'

				describe 'when the usage is forever', ->

					value = null

					beforeEach ->
						value = { prop: true }
						data =
							value: -> return value
							usage: 'forever'

					it 'should retrieve the cache key', ->
						sut._cacheSync options
						sut.cache.get.should.have.been.calledWith '/api'

					it 'should NOT remove the cache key', ->
						sut._cacheSync options
						sut.cache.remove.should.not.have.been.calledWith '/api'

				describe 'when there is a jquery cache busting value applied in the query string', ->

						beforeEach ->
							options.url = "/api?query=test&_=1460647367784"

						it 'should retrieve the cache key', ->
							sut._cacheSync options
							sut.cache.get.should.have.been.calledWith '/api?query=test'

						it 'should remove the cache key', ->
							sut._cacheSync options
							sut.cache.remove.should.have.been.calledWith '/api?query=test'

			describe 'when there are options provided for a query string', ->

				data = null

				beforeEach ->
					options = _.extend options,
						type: "GET"
						success: sinon.stub()
						data:
							query: 'value'
					data = { prop: true }
					sinon.stub sut.cache, 'get', -> data

				it 'should retrieve the cache key', ->
					sut._cacheSync options
					sut.cache.get.should.have.been.calledWith '/api?query=value'

				describe 'when the data value is just a string', ->

					it 'should retrieve the cache key', ->
						options.data = "query=value"
						sut._cacheSync options
						sut.cache.get.should.have.been.calledWith '/api?query=value'

				describe 'when the models url returns a query string parameter already', ->

					it 'should should combine the query strings', ->
						options.url = "/api?sort=desc"
						sut._cacheSync options
						sut.cache.get.should.have.been.calledWith '/api?sort=desc&query=value'

			describe 'when there is no data in the cache', ->

				beforeEach ->
					sinon.stub sut.cache, 'get', -> null

				it 'should call the original backbone sync', ->
					sut._cacheSync options
					sut.BackboneSync.should.have.been.calledWith options

	describe '_overrideBackboneSync', ->

		ajax = proxySync = null

		beforeEach ->
			ajax = Backbone.ajax
			proxySync = sinon.stub()
			Backbone.ajax = proxySync

		afterEach ->
			Backbone.ajax = ajax

		it 'should save the original backbone.ajax method on the instance', ->
			sut._overrideBackboneSync()
			sut.BackboneSync.should.equal proxySync

		it 'should replace backbone.ajax with _cacheSync', ->
			sut._overrideBackboneSync()
			Backbone.ajax.should.equal sut._cacheSync
