describe "UI Models", ->
  svm = SciView.Models

  describe "Base", ->
    it 'sets a title', ->
      m = new svm.UIBase
      m.default('title', 'custom title')
      expect(m.title).toEqual('custom title')

    it 'defaults to "untitled"', ->
      m = new svm.UIBase
      m.default('title')
      expect(m.title).toEqual('untitled')



  describe "UISeries", ->
    series = new svm.UISeries('test title', 'test category')
    serialized =
      title: 'test title'
      category: 'test category'
      key: { color: '#1ABC9C', style: 'solid' }

    it 'has title, category, and key properties', ->
      expect(series.title).toBe('test title')
      expect(series.category).toBe('test category')
      expect(series.key).toEqual({ color: '#1ABC9C', style: 'solid' })

    describe 'serialization', ->
      it 'serializes to a basic object', ->
        expect(series.serialize()).toEqual(serialized)

      it 'deserializes to a UISeries', ->
        expect(svm.UISeries.deserialize(serialized)).toEqual(series)


  describe "UIChannel", ->
    channel = new svm.UIChannel('channel title')
    channel.series = [
      new svm.UISeries('series A', 'category A')
      new svm.UISeries('series B', 'category B')
    ]

    serialized =
      title: "channel title"
      series: [
        { title: 'series A', category: 'category A', key: { color: '#1ABC9C', style: 'solid' } }
        { title: 'series B', category: 'category B', key: { color: '#1ABC9C', style: 'solid' } }
      ]


    it 'has a title', ->
      expect(channel.title).toEqual('channel title')

    describe 'serialization', ->
      it 'serializes to a basic object', ->
        expect(channel.serialize()).toEqual(serialized)

      it 'deserializes to a UIChannel', ->
        expect(svm.UIChannel.deserialize(serialized)).toEqual(channel)

      


  describe "UIChart", ->

  describe "UIDataset", ->

    
