describe 'backbone.bootstrap/cache', ->

	sut = null

	beforeEach ->
		sut = new (require 'backbone.bootstrap/cache')()

	it 'should establish an internal cache', ->
		_.isObject(sut._cache).should.equal true

	describe 'get', ->

		it 'should return null when the key is not in the internal cache', ->
			result = sut.get('myfakekey')
			expect(result).to.equal null

		it 'should return the value in the cache if the key is present', ->
			sut._cache['myfakekey'] = data = { prop: true }
			result = sut.get('myfakekey')
			result.should.equal data


	describe 'set', ->

		it 'should add a new value to the cache', ->
			data = { prop: true }
			result = sut.set('myfakekey', data)
			result.should.equal true
			sut._cache['myfakekey'].should.equal data

		it 'should overwrite an existing value with the same key', ->
			data = { prop: true }
			sut._cache['myfakekey'] = { prop: false }
			result = sut.set('myfakekey', data)
			result.should.equal true
			sut._cache['myfakekey'].should.equal data

	describe 'remove', ->

		it 'should delete the cache key', ->
			sut._cache['myfakekey'] = { prop: false }
			result = sut.remove('myfakekey')
			result.should.equal true
			expect(sut._cache['myfakekey']).to.not.exist

	describe 'listKeys', ->

		it 'should list all keys in the cache', ->
			sut._cache['myfakekey'] = { prop: false }
			result = sut.listKeys()
			result.should.deep.equal ['myfakekey']

	describe 'count', ->

		it 'should give an accurate count of keys in the cache', ->
			sut._cache['myfakekey'] = { prop: false }
			result = sut.count()
			result.should.equal 1

	describe 'intergration tests', ->

		it 'should correct set/remove/get cache items', ->
			data = { prop: true }
			expect(sut.get('myfakekey')).to.equal null
			sut.set('myfakekey', data)
			sut.get('myfakekey').should.equal data
			sut.remove('myfakekey')
			expect(sut.get('myfakekey')).to.equal null




