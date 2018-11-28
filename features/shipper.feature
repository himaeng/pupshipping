Feature: Test related to Growers
    Background:
        Given I have deployed the business network definition ..
        And I have added the following participants
        """
        [
            {"$class":"org.pup.shipping.participant.Grower", "email":"grower@email.com", "address":{"$class":"org.pup.shipping.participant.Address", "line1":"7586 Thatcher St.", "province":"Hastings", "country":"USA"}, "accountBalance":0},
            {"$class":"org.pup.shipping.participant.Importer", "email":"supermarket@email.com", "address":{"$class":"org.pup.shipping.participant.Address", "line1":"71  Argyll Street", "province":"STAINTON", "country":"UK"}, "accountBalance":0},
            {"$class":"org.pup.shipping.participant.Shipper", "email":"shipper@email.com", "address":{"$class":"org.pup.shipping.participant.Address", "line1":"17 petchkasem", "province":"Bangkok", "country":"THA"}, "accountBalance":0}
        ]
        """
        And I have added the following participants of type org.pup.shipping.participant.TemperatureSensor
            | deviceId |
            | TEMP_001 |
        And I have issued the participant org.pup.shipping.participant.Grower#grower@email.com with the identity grower1
        And I have issued the participant org.pup.shipping.participant.Shipper#shipper@email.com with the identity shipper1
        And I have added the following asset
            """
            [
                {
                    "$class": "org.pup.shipping.contract.Contract",
                    "contractId": "CONT_001",
                    "grower": "resource:org.pup.shipping.participant.Grower#grower@email.com",
                    "shipper": "resource:org.pup.shipping.participant.Shipper#shipper@email.com",
                    "importer": "resource:org.pup.shipping.participant.Importer#supermarket@email.com",
                    "arrivalDateTime": "10/26/2019 00:00",
                    "unitPrice": 0.5,
                    "minTemperature": 2,
                    "maxTemperature": 10,
                    "minPenaltyFactor": 0.2,
                    "maxPenaltyFactor": 0.1
                }
            ]
            """
        And I have added the following asset
            """
            [
                {
                    "$class": "org.pup.shipping.shipment.Shipment",
                    "shipmentId": "SHIP_001",
                    "type": "BANANAS",
                    "status": "IN_TRANSIT",
                    "unitCount": 5000,
                    "contract": "resource:org.pup.shipping.contract.Contract#CONT_001"
                }
            ]
            """
        When I use the identity shipper1

    Scenario: shipper1 can read Shipper assets
        Then I should have the following participants
        """
        [
        {"$class":"org.pup.shipping.participant.Shipper", "email":"shipper@email.com", "address":{"$class":"org.pup.shipping.participant.Address", "line1":"17 petchkasem", "province":"Bangkok", "country":"THA"}, "accountBalance":0}
        ]
        """
     
    Scenario: shipper1 invokes the ShipmentPickup transaction
        And I submit the following transaction of type org.pup.shipping.shipment.ShipmentPickup
            | shipment |
            | SHIP_001 |
        Then I should have received the following event of type org.pup.shipping.shipment.ShipmentPickupEvent
            | message                                  | shipment |
            | Shipment picked up for shipment SHIP_001 | SHIP_001 |
 
    Scenario: shipper1 invokes the ShipmentLoaded transaction
        And I submit the following transaction of type org.pup.shipping.shipment.ShipmentLoaded
            | shipment |
            | SHIP_001 |
        Then I should have received the following event of type org.pup.shipping.shipment.ShipmentLoadedEvent
            | message                               | shipment |
            | Shipment loaded for shipment SHIP_001 | SHIP_001 |
 
    Scenario: grower1 cannot invoke the ShipmentPickup transaction
        When I use the identity grower1
        And I submit the following transaction of type org.pup.shipping.shipment.ShipmentPickup
            | shipment |
            | SHIP_001 |
        Then I should get an error matching /Participant .* does not have 'CREATE' access to resource/
 
    Scenario: grower1 cannot invoke the ShipmentPickup transaction
        When I use the identity grower1
        And I submit the following transaction of type org.pup.shipping.shipment.ShipmentLoaded
            | shipment |
            | SHIP_001 |
        Then I should get an error matching /Participant .* does not have 'CREATE' access to resource/
