app.service('DataSets', function($http, $cookieStore, $state) {
    var DataSets = {};

    DataSets.getDataSets = function() {
      var ds1, ds2;
      
      // ds1.charts = [
      //   { title: 'Pressure', chart: 'assets/graph_1.svg', channels: [
      //     { title: 'Pressure Sensors', group: [
      //       { title: 'fuel_pressure-d', category: 'pressure', key: { color: '#FF00D8', style: "dashed" } },
      //       { title: 'oil_pressure-3a', category: 'pressure', key: { color: '#FFF81D', style: "solid" } }
      //     ]}
      //   ]},                    
      //   { title: 'Speed', chart: 'assets/graph_2.svg', channels: [
      //     { title: 'Pressure Sensors', group: [
      //       { title: 'fuel_pressure-d', category: 'pressure', key: { color: '#AC00FF', style: "solid" } },
      //       { title: 'oil_pressure-3a', category: 'pressure', key: { color: '#FF00D8', style: "solid" } }
      //     ]},
      //     { title: 'random_sensor', category: 'pressure', key: { color: '#00E7FF', style: "solid" } }
      //   ]}
      // ];

      ds1 = new SciView.Models.UIDataset('0', 'Data Set 1');
      ds2 = new SciView.Models.UIDataset('1', 'Data Set 2');
      return [ds1, ds2];
    }

    return DataSets;
});
