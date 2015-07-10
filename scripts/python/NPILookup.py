__author__ = 'pramod'

import requests
import json
import csv
import re


def getApiData(url, payload):
    r = requests.get(url, params=payload, verify=False)
    data = r.json()
    count = int(data['result_count'])
    return count, data


url = "https://npiregistry.cms.hhs.gov/api/"
filename = "npi.csv"
payload=""
count=0
npiData=""
with open(filename, 'r') as handle:
    reader = csv.DictReader(handle,
                            ['ServiceFacilityId', 'FacilityName', 'ServiceFacilityAddressLine1', 'ServiceFacilityCity',
                             'ServiceFacilityPostalCode', 'FacilityNPI', 'Empty', 'ProviderNPI'])
    for line in reader:
        org_name = line['FacilityName']
        postal = line['ServiceFacilityPostalCode']
        payload = {"organization_name": org_name, "postal_code": postal}
        count, npiData = getApiData(url, payload)
        try:
            with open('out.csv', 'a') as csvfile:
                spamwriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
                if count <= 0:
                    tokens = re.split('[ ,]', org_name)
                    tokenlist = [token for token in tokens if len(token)>0 and '.' not in token]
                    if ',' in org_name:
                        payload = {"first_name": tokenlist[1], "last_name": tokenlist[0], "postal_code": postal}
                    else:
                        payload = {"first_name": tokenlist[0], "last_name": tokenlist[1], "postal_code": postal}

                    print(payload)
                    count, npiData = getApiData(url, payload)
                    if count > 0:
                        print("Writing: ", npiData['results'][0]['basic']['first_name'], " ", npiData['results'][0]['basic']['last_name'])
                        for info in npiData['results']:
                            spamwriter.writerow([line['ServiceFacilityId'], org_name, line['ServiceFacilityAddressLine1'], postal,' ', info['number'],
                                                 info['basic']['first_name']+" "+info['basic']['last_name'], info['addresses'][0]['address_1'],
                                                 9 if line['ServiceFacilityAddressLine1'].strip().upper() ==
                                                      info['addresses'][0]['address_1'].strip().upper() else 1])

                else:

                    for info in npiData['results']:
                        # print(org_name, ":", info['number'])
                        spamwriter.writerow([line['ServiceFacilityId'], org_name, line['ServiceFacilityAddressLine1'], postal, ' ', info['number'],
                                             info['basic']['organization_name'], info['addresses'][0]['address_1'],
                                             9 if line['ServiceFacilityAddressLine1'].strip().upper() ==
                                                  info['addresses'][0]['address_1'].strip().upper() else 1])
        except ValueError as e:
            print("Couldn't parse response to JSON!", str(e))
        except BaseException as e:
            print(str(e))

print("Complete!!")

# {
#     result_count: 5
#     results: [5]
#     0: {
#         taxonomies: [1]
#         0: {
#                state: "WI"
#                code: "282N00000X"
#                primary: true
#                license: "390200000X"
#                desc: "General Acute Care Hospital"
#            } -
#            -
#            addresses: [2]
# 0:  {
#         city: "MILWAUKEE"
#         address_2: ""
#         telephone_number: "414-649-3323"
#         state: "WI"
#         postal_code: "532154330"
#         address_1: "2900 W OKLAHOMA AVE"
#         country_code: "US"
#         country_name: "United States"
#         address_type: "DOM"
#         address_purpose: "LOCATION"
#     } -
#     1:  {
#             city: "MILWAUKEE"
#             address_2: ""
#             telephone_number: "414-649-3323"
#             state: "WI"
#             postal_code: "532154330"
#             address_1: "2900 W OKLAHOMA AVE"
#             country_code: "US"
#             country_name: "United States"
#             address_type: "DOM"
#             address_purpose: "MAILING"
#         } -
#         -
#         created_epoch: 1240444800
# identifiers: [0]
# other_names: [0]
# number: 1841434644
# last_updated_epoch: 1240444800
# basic: {
#            status: "A"
#            authorized_official_telephone_number: "414-649-3323"
#            last_updated: "2009-04-23"
#            authorized_official_last_name: "WISE-ACKER"
#            organization_name: "AURORA ST. LUKE'S MEDICAL CENTER"
#            organizational_subpart: "NO"
#            authorized_official_title_or_position: "COORDINATOR TRANSITIONAL YEAR RESID"
#            enumeration_date: "2009-04-23"
#            authorized_official_first_name: "KAREN"
#        } -
#        enumeration_type: "NPI-2"
# }
# }


# 7497335F5A644CF29A1B844435AF0BD5B4ECBDC6D74643CA8DD1D3F0CD709243