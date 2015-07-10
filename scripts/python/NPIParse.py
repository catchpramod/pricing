__author__ = 'pramod'

import requests
import json
import csv
import re
from bs4 import BeautifulSoup

def getStreedAddress(url):
    r = requests.get(url, verify=False)
    html = r.text
    soup = BeautifulSoup(html, 'html.parser')
    addressTag = soup.find_all("address", class_="lead")
    spans = addressTag[0].find_all("span")
    address = [span.get_text() for span in spans]
    return address


url = "https://npidb.org/npi-lookup/"
filename = "npi_rem.csv"
payload = ""
count = 0
npiData = ""
with open('out_new.csv', 'a') as csvfile:
    rowriter = csv.writer(csvfile, delimiter=',', lineterminator='\n', quotechar='"', quoting=csv.QUOTE_MINIMAL)
    with open(filename, 'r') as handle:
        reader = csv.DictReader(handle,
                                ['ServiceFacilityId', 'FacilityName', 'ServiceFacilityAddressLine1',
                                 'ServiceFacilityCity',
                                 'ServiceFacilityPostalCode', 'FacilityNPI', 'Empty', 'ProviderNPI'])
        for line in reader:
            name = line['FacilityName']
            postal = line['ServiceFacilityPostalCode']
            fName = ""
            if ',' in name:
                tokens = re.split('[ ,]', name)
                tokenlist = [token for token in tokens if len(token) > 0 and '.' not in token]
                fName = tokenlist[0] + " " + tokenlist[1]
            elif '-' in name:
                fName = name.split("-")[0].strip()
            else:
                fName = name

            payload = {"search": fName, "state": "wi"}
            r = requests.get(url, params=payload, verify=False)
            html = r.text
            soup = BeautifulSoup(html, 'html.parser')
            tbody = soup.find(id="result").find("tbody")
            try:
                trList = tbody.findAll('tr')
                for tr in trList:
                    tdList = tr.findAll('td')
                    link = "https://npidb.org" + tdList[1].a.get('href')
                    npi = tdList[1].get_text()
                    rname = tdList[2].get_text()
                    cred = tdList[3].get_text()
                    city = tdList[4].get_text()
                    address = getStreedAddress(link)
                    tax = tdList[5].get_text()
                    zipcode = (address[-1]).split("-")[0]
                    print(postal,":",zipcode)
                    if postal.strip() == zipcode.strip():
                        print(line['ServiceFacilityId'], name, line['ServiceFacilityAddressLine1'], postal, ' ', npi,
                             rname + " " + cred, " ".join(address[:-1]), zipcode)
                        rowriter.writerow(
                            [line['ServiceFacilityId'], name, line['ServiceFacilityAddressLine1'], postal, ' ', npi,
                             rname + " " + cred, " ".join(address[:-1]), zipcode, tax, link])
            except AttributeError:
                print("No records on result!")
            except BaseException as e:
                print(str(e))
            finally:
                pass

print("Complete!!")