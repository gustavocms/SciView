app.service('Observations', function($http, $cookieStore, $state) {
    var Observations = {};

    Observations.getObservations = function() {
        return [
            {
                data_set: "launch_39.2",
                data_point: "C",
                img: "../img/prof-1.png",
                author: "Blake Benthall",
                created: "1288323623006",
                observation: "This doesn't look good, it could be X or Y, but not Z."
            },                
            {
                data_set: "TEST_3A",
                data_point: "F",
                img: "../img/prof-2.png",
                author: "Paul Mestemaker",
                created: "1288323623006",
                observation: "I think this problem will continue to grow if we don't address immediately. I think we could do Z if we had A and B, but that's up to Stan."
            },              
            {
                data_set: "TEST_3A",
                data_point: "F",
                img: "../img/prof-2.png",
                author: "Paul Mestemaker",
                created: "1288323623006",
                observation: "I think this problem will continue to grow if we don't address immediately. I think we could do Z if we had A and B, but that's up to Stan."
            },             
            {
                data_set: "TEST_3A",
                data_point: "F",
                img: "../img/prof-2.png",
                author: "Paul Mestemaker",
                created: "1288323623006",
                observation: "I think this problem will continue to grow if we don't address immediately. I think we could do Z if we had A and B, but that's up to Stan."
            },            
            {
                data_set: "launch_39.2",
                data_point: "C",
                img: "../img/prof-1.png",
                author: "Blake Benthall",
                created: "1288323623006",
                observation: "This doesn't look good, it could be X or Y, but not Z."
            }
        ];
    }

    return Observations;
});





















