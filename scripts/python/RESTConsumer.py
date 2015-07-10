__author__ = 'pramod'

import requests
import json
import pypyodbc


url = "https://test02.payercompass.com/apps/pricer/services/v2/insight.aspx"
headers = {"Authorization": "Basic YXBpLmFsaXRoaWFzLndlbGxjYXJlOlJKRXBkWThQ",
           "IsCompressed": "False", "Environment": "Sandbox", "Format": "JSON"}
payload = {"BundleID": 1001, "ReturnDetail": True,
           "Components": [
               {"PricingInfo": None, "ServiceUnits": 0, "Type": 6, "Value": "45378"}
           ],
           "PostalCode": "532"}

r = requests.post(url, headers=headers, data=json.dumps(payload, allow_nan=True))

connection = pypyodbc.connect("driver={SQL Server};server=work-pc;database=test;uid=root;pwd=root")
cursor = connection.cursor()

try:
    pricing = r.json()
    for info in pricing['Components'][0]['PricingInfo']:
        print(info['NPI'])
        SQLCommand = ("INSERT INTO pricetest "
                 "(npi, rate) "
                 "VALUES (?,?)")

        Values = [info['NPI'], info['FacilityRate']]
        cursor.execute(SQLCommand, Values)

except ValueError:
    print("Couldn't parse response to JSON!")
except:
    print("Unexpected error occurred!")
finally:
    connection.commit()
    connection.close()
