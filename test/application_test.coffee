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

	describe '_cacheSync', ->

		model = options = null

		beforeEach ->
			model = new Backbone.Model()
			model.url = "/api"
			model.trigger = sinon.stub()
			options = { success: sinon.stub() }
			sut.BackboneSync = sinon.stub()
			sinon.stub sut.cache, 'remove'

		describe 'method is create', ->

			it 'should call the original backbone sync', ->
				sut._cacheSync 'create', model, options
				sut.BackboneSync.should.have.been.calledWith 'create', model, options

		describe 'method is delete', ->

			it 'should remove the cache key', ->
				sut._cacheSync 'delete', model, options
				sut.cache.remove.should.have.been.calledWith '/api'

		describe 'method is update', ->

			it 'should remove the cache key', ->
				sut._cacheSync 'delete', model, options
				sut.cache.remove.should.have.been.calledWith '/api'

		describe 'method is read', ->

			describe 'when there is data in the cache', ->

				data = null

				beforeEach ->
					data = { prop: true }
					sinon.stub sut.cache, 'get', -> data

				it 'should retrieve the cache key', ->
					sut._cacheSync 'read', model, options
					sut.cache.get.should.have.been.calledWith '/api'

				it 'should trigger sync with the cache data', ->
					sut._cacheSync 'read', model, options
					model.trigger.should.have.been.calledWith 'sync', model, data, options

				it 'should trigger the success callback', ->
					sut._cacheSync 'read', model, options
					options.success.should.have.been.calledWith data

			describe 'when there are options provided for a query string', ->

				data = null

				beforeEach ->
					options =
						success: sinon.stub()
						data:
							query: 'value'
					data = { prop: true }
					sinon.stub sut.cache, 'get', -> data

				it 'should retrieve the cache key', ->
					sut._cacheSync 'read', model, options
					sut.cache.get.should.have.been.calledWith '/api?query=value'

			describe 'when there is no data in the cache', ->

				beforeEach ->
					sinon.stub sut.cache, 'get', -> null

				it 'should call the original backbone sync', ->
					sut._cacheSync 'read', model, options
					sut.BackboneSync.should.have.been.calledWith 'read', model, options

	describe '_overrideBackboneSync', ->

		sync = proxySync = null

		beforeEach ->
			sync = Backbone.sync
			proxySync = sinon.stub()
			Backbone.sync = proxySync

		afterEach ->
			Backbone.sync = sync

		it 'should save the original backbone.sync method on the instance', ->
			sut._overrideBackboneSync()
			sut.BackboneSync.should.equal proxySync

		it 'should replace backbone.sync with _cacheSync', ->
			sut._overrideBackboneSync()
			Backbone.sync.should.equal sut._cacheSync
