
#angular.module('testApp', ['angular-data.DS'])

describe 'test setup', ->
  DS = null

  # This is adapted from the angular-data-mocks test setup example at
  # http://angular-data.pseudobry.com/documentation/guide/angular-data-mocks/setup.
  # Should be applicable to any DS-related tests.
  beforeEach -> angular.module('sv.ui.services')
  beforeEach -> angular.mock.module('angular-data.mocks')
  beforeEach (done) ->
    inject (_DS_, _DSHttpAdapter_) ->
      DS = _DS_
      DSHttpAdapter = _DSHttpAdapter_
      done()


  it 'works!', -> expect(true).toBe(true)

  describe 'Observation test setup', ->
    Observation = null
    beforeEach (done) ->
      inject (_Observation_) -> Observation = _Observation_
      done()

    it 'will be defined', ->
      expect(Observation).toBeDefined()

    it 'creates an instance', ->
      observation = Observation.createInstance({ message: "hello, world" })
      console.log('obs', observation)


