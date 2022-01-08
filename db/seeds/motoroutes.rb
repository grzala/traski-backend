
module MotoRoutesSeed
    MOTO_ROUTES = [
        {
            name: "Mała pętla Bieszczadzka",
            description: "Mała pętla Bieszczadzka is a shorter variant of the famous loop road in the Bieszczady mountains. The loop takes us around the Solina lake, giving us a good taste of mountainous terrain we can expect on the bigger loop.",
            coordinates: [
                { lat: 49.470003, lng: 22.328589},
                { lat: 49.321988, lng: 22.668264},
                { lat: 49.304531, lng: 22.416348},
                { lat: 49.467955, lng: 22.320365},
            ],
            time_to_complete_h: 3,
            time_to_complete_m: 30,
            difficulty: 3,
            point_of_interests_attributes: [
                { 
                    name: "some FOOD",
                    description: Cryptozoologist.lorem(1),
                    coordinates: {lat: 49.394489, lng: 22.402796},
                    variant: :FOOD
                },
                { 
                    name: "some VISTA",
                    description: Cryptozoologist.lorem(1),
                    coordinates: {lat: 49.394489, lng: 22.422796},
                    variant: :VISTA
                },
                { 
                    name: "some URBEX",
                    description: Cryptozoologist.lorem(1),
                    coordinates: {lat: 49.394489, lng: 22.442796},
                    variant: :URBEX
                },
                { 
                    name: "some DANGER",
                    description: Cryptozoologist.lorem(1),
                    coordinates: {lat: 49.394489, lng: 22.462796},
                    variant: :DANGER
                },
                { 
                    name: "some FUEL",
                    description: Cryptozoologist.lorem(1),
                    coordinates: {lat: 49.394489, lng: 22.482796},
                    variant: :FUEL
                },
                { 
                    name: "some point",
                    description: Cryptozoologist.lorem(1),
                    coordinates: {lat: 49.394489, lng: 22.502796},
                    variant: :OTHER
                },
            ]
        },
        {
            name: "Duża pętla Bieszczadzka",
            description: "Duża pętla Bieszczadzka is a longer variant of the famous loop road in the Bieszczady mountains. Constant hikes and descends, fantastic turns and beautiful scenery place it in the 'must ride' category of Polish motorcycle routes. The bigger loop also takes us deeper into the mountains and forests of the Bieszczady national park.",
            coordinates: [
                { lat: 49.470003, lng: 22.328589},
                { lat: 49.106309, lng: 22.649962},
                { lat: 49.213745, lng: 22.327127},
                { lat: 49.467955, lng: 22.320365},
            ],
            time_to_complete_h: 5,
            time_to_complete_m: 30,
            difficulty: 4,
            
        },
        {
            name: "Jeziorsko",
            description: "A ride around the Jeziorsko artificial lake. Not very overwhelming. It is very uniqie to go there after September ends, as the lake is being drained of water from the winter. If you own a dirt bike you can try riding on the lake bed.",
            coordinates: [
                { lat: 51.691263, lng: 18.974299 }, 
                { lat: 51.716471, lng: 18.624769 }, 
                { lat: 51.864877, lng: 18.674026 },
                { lat: 51.830279, lng: 18.875813 }, 
            ],
            time_to_complete_h: 2,
            time_to_complete_m: 10,
            difficulty: 1,
        },
    ]
end