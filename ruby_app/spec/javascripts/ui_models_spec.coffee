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

  ############## # shared variables
  series = new svm.UISeries('test title', 'test category')
  serializedSeries =
    title: 'test title'
    category: 'test category'
    key: { color: '#1ABC9C', style: 'solid' }
    state: "retracted"

  channel = new svm.UIChannel('channel title')
  channel.series = [
    new svm.UISeries('series_A', 'category A')
    new svm.UISeries('series_B', 'category B')
  ]
  chart = new svm.UIChart('test chart')
  chart.addChannel(channel)
  ##############

  describe "UISeries", ->
    it 'has title, category, and key properties', ->
      expect(series.title).toBe('test title')
      expect(series.category).toBe('test category')
      expect(series.key).toEqual({ color: '#1ABC9C', style: 'solid' })

    describe 'serialization', ->
      for key, value of series.serialize()
        do (key, value) ->
          it "serializes #{key}", ->
            expect(value).toEqual(serializedSeries[key])

      #it 'serializes to a basic object', ->
      #expect(series.serialize()).toEqual(serializedSeries)

      it 'deserializes to a UISeries', ->
        expect(svm.UISeries.deserialize(serializedSeries)).toEqual(series)


  describe "UIChannel", ->
    serializedChannel =
      title: "channel title"
      state: 'retracted'
      series: [
        { title: 'series_A', category: 'category A', key: { color: '#1ABC9C', style: 'solid' } }
        { title: 'series_B', category: 'category B', key: { color: '#1ABC9C', style: 'solid' } }
      ]

    it 'has a title', ->
      expect(channel.title).toEqual('channel title')

    describe 'serialization', ->
      serialized = channel.serialize()

      it 'serializes to a basic object - title', ->
        expect(serialized.title).toEqual("channel title")
      it 'serializes to a basic object - state', ->
        expect(serialized.state).toEqual('retracted')
      it 'serializes to a basic object - series', ->
        expect(serialized.series.map((a) -> a.title)).toEqual(['series_A', 'series_B'])

      it 'deserializes to a UIChannel', ->
        expect(svm.UIChannel.deserialize(serializedChannel)).toEqual(channel)

  describe "UIChart", ->
    it 'has some attributes', ->
      expect(chart.title).toEqual('test chart')
      expect(chart.channels[1]).toEqual(channel)

    it 'tracks the data url', ->
      expect(chart.dataUrl).toEqual('/api/v1/datasets/multiple?series_0=series_A&series_1=series_B')

    it 'tracks all series keys', ->
      expect(chart._allSeriesKeys()).toEqual(['series_A', 'series_B'])

    describe "serialization", ->
      chart2 = new svm.UIChart('chart 2')
      chart2.addSeries('new_series',false)
      serializedChart = {
        title: 'chart 2',
        channels: [
          {
            title: 'default channel'
            state: 'expanded'
            series: [
              {
                title: 'new_series'
                category: 'default category'
                state: 'retracted'
                key: { color: '#F39C12', style: 'solid' }
              }
            ]
          }
        ]
      }

      for key, value of chart2.serialize()
        do (key, value) ->
          it "serializes #{key}", ->
            expect(value).toEqual(serializedChart[key])

      it 'deserializes from a basic object', ->
        ui_chart = svm.UIChart.deserialize(serializedChart)
        expect(ui_chart.title).toEqual(chart2.title)
        expect(ui_chart.channels).toEqual(chart2.channels)


  describe "UIDataset", ->
    dataset = new svm.UIDataset('0', 'test dataset')
    dataset.charts = [chart]

    #it 'serializes to a basic object', ->
    #  console.log(dataset.serialize())
