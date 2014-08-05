app.service('DataSets', function($http, $cookieStore, $state) {
    var DataSets = {};

    DataSets.getDataSets = function() {
      var ds1, ds2;
      ds1 = new SciView.Models.Dataset('0', 'Data Set 1');
      ds1.batches = [
        { title: 'Pressure', chart: 'assets/graph_1.svg', channel: [
          { title: 'Pressure Sensors', group: [
            { title: 'fuel_pressure-d', category: 'pressure', key: { color: '#FF00D8', style: "dashed" } },
            { title: 'oil_pressure-3a', category: 'pressure', key: { color: '#FFF81D', style: "solid" } }
          ]}
        ]},                    
        { title: 'Speed', chart: 'assets/graph_2.svg', channel: [
          { title: 'Pressure Sensors', group: [
            { title: 'fuel_pressure-d', category: 'pressure', key: { color: '#AC00FF', style: "solid" } },
            { title: 'oil_pressure-3a', category: 'pressure', key: { color: '#FF00D8', style: "solid" } }
          ]},
          { title: 'random_sensor', category: 'pressure', key: { color: '#00E7FF', style: "solid" } }
        ]}
      ];

      ds2 = new SciView.Models.Dataset('1', 'Data Set 2');
      return [ds1, ds2];
    }

    return DataSets;
});
