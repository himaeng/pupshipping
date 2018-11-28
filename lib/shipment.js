'strict';

/**
 * ShipmentPacked transaction - ถูกยิงเมื่อตู้คอนเทนเนอร์ปิดผนึกเรียบร้อย พร้อมให้ยกลงเรือ
 * @param {org.pup.shipping.shipment.ShipmentPacked} shipmentPacked - the ShipmentPacked transaction
 * @transaction
 */
async function packShipment(shipmentPacked) {
    let shipment = shipmentPacked.shipment;
    const NS = 'org.pup.shipping.shipment';
    const factory = getFactory();
 
    // Add the ShipmentPacked transaction to the ledger (via the Shipment asset)
    shipment.shipmentPacked = shipmentPacked;
 
    // Create the message
    const message = 'Shipment packed for shipment ' + shipment.$identifier;
 
    // Log it to the JavaScript console
    //console.log(message);
 
    // Emit a notification telling subscribed listeners that the shipment has been packed
    let shipmentPackedEvent = factory.newEvent(NS, 'ShipmentPackedEvent');
    shipmentPackedEvent.shipment = shipment;
    shipmentPackedEvent.message = message;
    emit(shipmentPackedEvent);
 
    // Update the Asset Registry
    const shipmentRegistry = await getAssetRegistry(NS + '.Shipment');
    await shipmentRegistry.update(shipment);
}

/**
 * ShipmentPickup - ถูกยิงเมื่อมีการยก หรือขนส่งตู้คอนเทนเนอร์ไปเพื่อโหลดลงเรือ
 * 
 * @param {org.pup.shipping.shipment.ShipmentPickup} shipmentPickup - the ShipmentPickup transaction
 * @transaction
 */
async function pickupShipment(shipmentPickup) {
    let shipment = shipmentPickup.shipment;
    const NS = 'org.pup.shipping.shipment';
    const factory = getFactory();
 
    // Add the ShipmentPacked transaction to the ledger (via the Shipment asset)
    shipment.shipmentPickup = shipmentPickup;
 
    // Create the message
    const message = 'Shipment picked up for shipment ' + shipment.$identifier;
 
    // Log it to the JavaScript console
    //console.log(message);
 
    // Emit a notification telling subscribed listeners that the shipment has been packed
    let shipmentPickupEvent = factory.newEvent(NS, 'ShipmentPickupEvent');
    shipmentPickupEvent.shipment = shipment;
    shipmentPickupEvent.message = message;
    emit(shipmentPickupEvent);
 
    // Update the Asset Registry
    const shipmentRegistry = await getAssetRegistry(NS + '.Shipment');
    await shipmentRegistry.update(shipment);
}

/**
 * ShipmentLoaded - ถูกยิงเมื่อตู้คอนเทนเนอร์ถูกโหลดลงเรือ
 * 
 * @param {org.pup.shipping.shipment.ShipmentLoaded} shipmentLoaded - the ShipmentLoaded transaction
 * @transaction
 */
async function loadShipment(shipmentLoaded) {
    let shipment = shipmentLoaded.shipment;
    const NS = 'org.pup.shipping.shipment';
    const factory = getFactory();
 
    // Add the ShipmentPacked transaction to the ledger (via the Shipment asset)
    shipment.shipmentLoaded = shipmentLoaded;
 
    // Create the message
    const message = 'Shipment loaded for shipment ' + shipment.$identifier;
 
    // Log it to the JavaScript console
    //console.log(message);
 
    // Emit a notification telling subscribed listeners that the shipment has been packed
    let shipmentLoadedEvent = factory.newEvent(NS, 'ShipmentLoadedEvent');
    shipmentLoadedEvent.shipment = shipment;
    shipmentLoadedEvent.message = message;
    emit(shipmentLoadedEvent);
 
    // Update the Asset Registry
    const shipmentRegistry = await getAssetRegistry(NS + '.Shipment');
    await shipmentRegistry.update(shipment);
}
