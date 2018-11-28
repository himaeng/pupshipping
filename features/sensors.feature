Feature: Tests related to IoT Devices
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
        And I have added the following participant of type org.pup.shipping.participant.GpsSensor
            | deviceId |
            | GPS_001  |
        And I have issued the participant org.pup.shipping.participant.Grower#grower@email.com with the identity grower1
        And I have issued the participant org.pup.shipping.participant.Shipper#shipper@email.com with the identity shipper1
        And I have issued the participant org.pup.shipping.participant.TemperatureSensor#TEMP_001 with the identity sensor_temp1
        And I have issued the participant org.pup.shipping.participant.GpsSensor#GPS_001 with the identity sensor_gps1
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
    Scenario: Test TemperatureThresholdEvent is emitted when the max temperature threshold is violated
        When I use the identity sensor_temp1
        When I submit the following transactions of type org.pup.shipping.shipment.TemperatureReading
            | shipment | centigrade |
            | SHIP_001 | 11         |
         
        Then I should have received the following event of type org.pup.shipping.shipment.TemperatureThresholdEvent
            | message                                                                          | temperature | shipment |
            | Temperature threshold violated! Emitting TemperatureEvent for shipment: SHIP_001 | 11          | SHIP_001 |    
 
    Scenario: Test TemperatureThresholdEvent is emitted when the min temperature threshold is violated
        When I use the identity sensor_temp1
        When I submit the following transactions of type org.pup.shipping.shipment.TemperatureReading
            | shipment | centigrade |
            | SHIP_001 | 0          |
         
        Then I should have received the following event of type org.pup.shipping.shipment.TemperatureThresholdEvent
            | message                                                                          | temperature | shipment |
            | Temperature threshold violated! Emitting TemperatureEvent for shipment: SHIP_001 | 0           | SHIP_001 |
     
    Scenario: Test ShipmentInPortEvent is emitted when GpsReading indicates arrival at destination port
        When I use the identity sensor_gps1
        When I submit the following transaction of type org.pup.shipping.shipment.GpsReading
            | shipment | readingTime | readingDate | latitude | latitudeDir | longitude | longitudeDir |
            | SHIP_001 | 120000      | 20171025    | 40.6840  | N           | 74.0062   | W            |
 
        Then I should have received the following event of type org.pup.shipping.shipment.ShipmentInPortEvent
            | message                                                                  | shipment |
            | Shipment has reached the destination port of /LAT:40.6840N/LONG:74.0062W | SHIP_001 |
 
    Scenario: GpsSensor sensor_gps1 can invoke GpsReading transaction
        When I use the identity sensor_gps1
        When I submit the following transaction of type org.pup.shipping.shipment.GpsReading
            | shipment | readingTime | readingDate | latitude | latitudeDir | longitude | longitudeDir |
            | SHIP_001 | 120000      | 20171025    | 40.6840  | N           | 74.0062   | W            |
        Then I should have received the following event of type org.pup.shipping.shipment.ShipmentInPortEvent
            | message                                                                  | shipment |
            | Shipment has reached the destination port of /LAT:40.6840N/LONG:74.0062W | SHIP_001 |
     
    Scenario: Temperature Sensor cannot invoke GpsReading transaction
        When I use the identity sensor_temp1
        When I submit the following transaction of type org.pup.shipping.shipment.GpsReading
            | shipment | readingTime | readingDate | latitude | latitudeDir | longitude | longitudeDir |
            | SHIP_001 | 120000      | 20171025    | 40.6840  | N           | 74.0062   | W            |
        Then I should get an error matching /Participant .* does not have 'CREATE' access to resource/
 
    Scenario: Gps Sensor cannot invoke TemperatureReading transaction
        When I use the identity sensor_gps1
        When I submit the following transactions of type org.pup.shipping.shipment.TemperatureReading
            | shipment | centigrade |
            | SHIP_001 | 11         |        
        Then I should get an error matching /Participant .* does not have 'CREATE' access to resource/
 
    Scenario: Grower cannot invoke TemperatureReading transaction
        When I use the identity sensor_gps1
        When I submit the following transactions of type org.pup.shipping.shipment.TemperatureReading
            | shipment | centigrade |
            | SHIP_001 | 11         |        
        Then I should get an error matching /Participant .* does not have 'CREATE' access to resource/
