'use strict';
/**
 * A temperature reading has been received for a shipment
 * @param {org.pup.shipping.shipment.TemperatureReading} temperatureReading - the TemperatureReading transaction
 * @transaction
 */
async function temperatureReading(temperatureReading) {  // eslint-disable-line no-unused-vars

    const shipment = temperatureReading.shipment;
    const NS = 'org.pup.shipping.shipment';
    let contract = shipment.contract;

    console.log('Adding temperature ' + temperatureReading.centigrade + ' to shipment ' + shipment.$identifier);

    if (shipment.temperatureReadings) {
        shipment.temperatureReadings.push(temperatureReading);
    } else {
        shipment.temperatureReadings = [temperatureReading];
    }

    if (temperatureReading.centigrade < contract.minTemperature ||
        temperatureReading.centigrade > contract.maxTemperature) {
        var temperatureEvent = getFactory().newEvent(NS, 'TemperatureThresholdEvent');
        temperatureEvent.shipment = shipment;
        temperatureEvent.temperature = temperatureReading.centigrade;
        temperatureEvent.message = 'Temperature threshold violated! Emitting TemperatureEvent for shipment: ' + shipment.$identifier;
        emit(temperatureEvent);
    }

    // add the temp reading to the shipment
    const shipmentRegistry = await getAssetRegistry('org.pup.shipping.shipment.Shipment');

    let TemperatureReadEvent = await getFactory().newEvent(NS, 'TemperatureRead');
    TemperatureReadEvent.shipmentId = await temperatureReading.shipment.shipmentId;
    await emit(TemperatureReadEvent);
    await shipmentRegistry.update(shipment);
}

/**
 * A shipment has been received by an importer
 * @param {org.pup.shipping.shipment.ShipmentReceived} shipmentReceived - the ShipmentReceived transaction
 * @transaction
 */
async function receiveShipment(shipmentReceived) {  // eslint-disable-line no-unused-vars

    const contract = shipmentReceived.shipment.contract;
    const shipment = shipmentReceived.shipment;
    let payOut = contract.unitPrice * shipment.unitCount;

    console.log('Received at: ' + shipmentReceived.timestamp);
    console.log('Contract arrivalDateTime: ' + contract.arrivalDateTime);

    // set the status of the shipment
    shipment.status = 'ARRIVED';

    // if the shipment did not arrive on time the payout is zero
    if (shipmentReceived.timestamp > contract.arrivalDateTime) {
        payOut = 0;
        console.log('Late shipment');
    } else {
        // find the lowest temperature reading
        if (shipment.temperatureReadings) {
            // sort the temperatureReadings by centigrade
            shipment.temperatureReadings.sort(function (a, b) {
                return (a.centigrade - b.centigrade);
            });
            const lowestReading = shipment.temperatureReadings[0];
            const highestReading = shipment.temperatureReadings[shipment.temperatureReadings.length - 1];
            let penalty = 0;
            console.log('Lowest temp reading: ' + lowestReading.centigrade);
            console.log('Highest temp reading: ' + highestReading.centigrade);

            // does the lowest temperature violate the contract?
            if (lowestReading.centigrade < contract.minTemperature) {
                penalty += (contract.minTemperature - lowestReading.centigrade) * contract.minPenaltyFactor;
                console.log('Min temp penalty: ' + penalty);
            }

            // does the highest temperature violate the contract?
            if (highestReading.centigrade > contract.maxTemperature) {
                penalty += (highestReading.centigrade - contract.maxTemperature) * contract.maxPenaltyFactor;
                console.log('Max temp penalty: ' + penalty);
            }

            // apply any penalities
            payOut -= (penalty * shipment.unitCount);

            if (payOut < 0) {
                payOut = 0;
            }
        }
    }

    console.log('Payout: ' + payOut);
    contract.grower.accountBalance += payOut;
    contract.importer.accountBalance -= payOut;

    console.log('Grower: ' + contract.grower.$identifier + ' new balance: ' + contract.grower.accountBalance);
    console.log('Importer: ' + contract.importer.$identifier + ' new balance: ' + contract.importer.accountBalance);

    // Store the ShipmentReceived transaction with the Shipment asset it belongs to
    shipment.shipmentReceived = shipmentReceived;
 
    const factory = getFactory();
    let shipmentReceivedEvent = factory.newEvent('org.pup.shipping.shipment', 'ShipmentReceivedEvent');
    const message = 'Shipment ' + shipment.$identifier + ' received';
    //console.log(message);
    shipmentReceivedEvent.message = message;
    shipmentReceivedEvent.shipment = shipment;
    emit(shipmentReceivedEvent);

    // update the grower's balance
    const growerRegistry = await getParticipantRegistry('org.pup.shipping.participant.Grower');
    await growerRegistry.update(contract.grower);

    // update the importer's balance
    const importerRegistry = await getParticipantRegistry('org.pup.shipping.participant.Importer');
    await importerRegistry.update(contract.importer);

    // update the state of the shipment
    const shipmentRegistry = await getAssetRegistry('org.pup.shipping.shipment.Shipment');
    await shipmentRegistry.update(shipment);
}

/**
 * A GPS reading has been received for a shipment
 * @param {org.pup.shipping.shipment.GpsReading} gpsReading - the GpsReading transaction
 * @transaction
 */
async function gpsReading(gpsReading) {
    var factory = getFactory();
    var NS = 'org.pup.shipping.shipment';
    var shipment = gpsReading.shipment;
    var PORT_OF_NEW_YORK = '/LAT:40.6840N/LONG:74.0062W';

    var latLong = '/LAT:' + gpsReading.latitude + gpsReading.latitudeDir + '/LONG:' +
        gpsReading.longitude + gpsReading.longitudeDir;

    if (shipment.gpsReadings) {
        shipment.gpsReadings.push(gpsReading);
    } else {
        shipment.gpsReadings = [gpsReading];
    }

    if (latLong === PORT_OF_NEW_YORK) {
        var shipmentInPortEvent = factory.newEvent(NS, 'ShipmentInPortEvent');
        shipmentInPortEvent.shipment = shipment;
        var message = 'Shipment has reached the destination port of ' + PORT_OF_NEW_YORK;
        shipmentInPortEvent.message = message;
        emit(shipmentInPortEvent);
    }

    const shipmentRegistry = await getAssetRegistry(NS + '.Shipment');
    await shipmentRegistry.update(shipment);
}
