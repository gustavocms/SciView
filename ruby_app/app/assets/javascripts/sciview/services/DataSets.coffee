module = angular.module('sv.ui.services')

module.service "DataSets", ->
  DataSets = {}
  DataSets.getDataSets = ->
    ds1 = undefined
    ds2 = undefined

    # ds1.charts = [
    #   { title: 'Pressure', chart: 'assets/graph_1.svg', channels: [
    #     { title: 'Pressure Sensors', group: [
    #       { title: 'fuel_pressure-d', category: 'pressure', key: { color: '#FF00D8', style: "dashed" } },
    #       { title: 'oil_pressure-3a', category: 'pressure', key: { color: '#FFF81D', style: "solid" } }
    #     ]}
    #   ]},
    #   { title: 'Speed', chart: 'assets/graph_2.svg', channels: [
    #     { title: 'Pressure Sensors', group: [
    #       { title: 'fuel_pressure-d', category: 'pressure', key: { color: '#AC00FF', style: "solid" } },
    #       { title: 'oil_pressure-3a', category: 'pressure', key: { color: '#FF00D8', style: "solid" } }
    #     ]},
    #     { title: 'random_sensor', category: 'pressure', key: { color: '#00E7FF', style: "solid" } }
    #   ]}
    # ];

    #ds1 = new SciView.Models.UIDataset('0', 'Data Set 1');
    #ds2 = new SciView.Models.UIDataset('1', 'Data Set 2');
    #return [ds1, ds2];
    json =
      id: "0"
      title: "Data Set 1"
      charts: [
        title: "Untitled Chart"
        channels: [
          title: "default channel"
          state: "expanded"
          series: [
            title: "test"
            category: "default category"
            key:
              color: "#1ABC9C"
              style: "solid"
          ]
        ]
      ]

    [SciView.Models.UIDataset.deserialize(json)]

  DataSets