__author__ = 'pramod'

import requests
import json
import pypyodbc
from bs4 import BeautifulSoup

def getPrice(zip,procedure):
    url = "https://healthcarebluebook.com/page_SearchResults.aspx?SearchTerms=Colonoscopy (screening)"

    # data = {'SearchTerms':'Colonoscopy (screening)'}
    # cookies = {'hcbb':'language=English&zip=57042'}
    data = {'SearchTerms':procedure}
    cookies = {'hcbb':'language=English&zip='+zip}
    html_doc= requests.get(url,cookies=cookies).text

    soup = BeautifulSoup(html_doc, 'html.parser')
    return soup.find_all(class_='total-line')[0].get_text()
    # print(soup.find_all(class_='total-line')[0].get_text())