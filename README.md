# pupshipping

# advanced ACL
 composer participant add -d '{"$class": "org.pup.shipping.participant.Importer", "email": "tom@example.com", "address": { "$class": "org.pup.shipping.participant.Address", "line1": "one condo", "province": "Bangkok", "country": "Thailand" }, "accountBalance": 100000}' -c admin@pupshipping

# issue identity

 composer identity issue -u tom@example.com -a org.pup.shipping.participant.Importer#tom@example.com -c admin@pupshipping -x

# list identity
 composer identity list -c admin@pupshipping
