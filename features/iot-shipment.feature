Feature: Basic Test Scenarios
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
        And I have issued the participant org.pup.shipping.participant.Importer#supermarket@email.com with the identity importer1
        And I have issued the participant org.pup.shipping.participant.TemperatureSensor#TEMP_001 with the identity sensor_temp1
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
        And I submit the following transactions of type org.pup.shipping.shipment.TemperatureReading
            | shipment | centigrade |
            | SHIP_001 | 4          |
            | SHIP_001 | 5          |
            | SHIP_001 | 10         |
        When I use the identity importer1

    Scenario: When the temperature range is within the agreed-upon boundaries
        When I use the identity importer1
        And I submit the following transaction of type org.pup.shipping.shipment.ShipmentReceived
            | shipment |
            | SHIP_001 |
        Then I should have the following participants
            """
            [
            {"$class":"org.pup.shipping.participant.Grower", "email":"grower@email.com", "address":{"$class":"org.pup.shipping.participant.Address", "line1":"7586 Thatcher St.", "province":"Hastings", "country":"USA"}, "accountBalance":2500},
            {"$class":"org.pup.shipping.participant.Importer", "email":"supermarket@email.com", "address":{"$class":"org.pup.shipping.participant.Address", "line1":"71  Argyll Street", "province":"STAINTON", "country":"UK"}, "accountBalance":-2500}
            ]
            """

    Scenario: When the low/min temperature threshold is breached by 2 degrees C
        Given I use the identity sensor_temp1
        And I submit the following transaction of type org.pup.shipping.shipment.TemperatureReading
            | shipment | centigrade |
            | SHIP_001 | 0          |
        When I use the identity importer1
        And I submit the following transaction of type org.pup.shipping.shipment.ShipmentReceived
            | shipment |
            | SHIP_001 |
        
        Then I should have the following participants
            """
            [
            {"$class":"org.pup.shipping.participant.Grower", "email":"grower@email.com", "address":{"$class":"org.pup.shipping.participant.Address", "line1":"7586 Thatcher St.", "province":"Hastings", "country":"USA"}, "accountBalance":500},
            {"$class":"org.pup.shipping.participant.Importer", "email":"supermarket@email.com", "address":{"$class":"org.pup.shipping.participant.Address", "line1":"71  Argyll Street", "province":"STAINTON", "country":"UK"}, "accountBalance":-500}
            ]
            """
    Scenario: When the hi/min temperature threshold is breached by 2 degrees C
        Given I use the identity sensor_temp1
        And I submit the following transaction of type org.pup.shipping.shipment.TemperatureReading
            | shipment | centigrade |
            | SHIP_001 | 12          |
        When I use the identity importer1
        And I submit the following transaction of type org.pup.shipping.shipment.ShipmentReceived
            | shipment |
            | SHIP_001 |
        
        Then I should have the following participants
            """
            [
            {"$class":"org.pup.shipping.participant.Grower", "email":"grower@email.com", "address":{"$class":"org.pup.shipping.participant.Address", "line1":"7586 Thatcher St.", "province":"Hastings", "country":"USA"}, "accountBalance":1500},
            {"$class":"org.pup.shipping.participant.Importer", "email":"supermarket@email.com", "address":{"$class":"org.pup.shipping.participant.Address", "line1":"71  Argyll Street", "province":"STAINTON", "country":"UK"}, "accountBalance":-1500}
            ]
            """

    Scenario: When shipment is received a ShipmentReceivedEvent should be broadcast
        When I use the identity importer1
        And I submit the following transactions of type org.pup.shipping.shipment.ShipmentReceived
            | shipment |
            | SHIP_001 |
        Then I should have received the following event of type org.pup.shipping.shipment.ShipmentReceivedEvent
            | message                    | shipment |
            | Shipment SHIP_001 received | SHIP_001 |
 