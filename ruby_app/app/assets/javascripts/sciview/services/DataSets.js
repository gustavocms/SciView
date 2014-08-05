app.service('DataSets', function($http, $cookieStore, $state) {
    var DataSets = {};

    DataSets.getDataSets = function() {
        return [
            {
              id: '0',
              title: 'Data Set 1',
              batch: [
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
              ]
              // Dummy chart for now
            },            
            {
                id: '1',
                title: 'Data Set 2'
            }
        ];
    }

    return DataSets;
});





















