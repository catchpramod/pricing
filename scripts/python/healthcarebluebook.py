__author__ = 'pramod'

import requests
import json
import pypyodbc

#[{"DisplayNameEnglish":"17-Hydroxypregnenolone","DisplayNameSpanish":"17-Hidroxipregnenolona","MenuId":1,"DrugPriceSet":0,"GoodRx":0,"Hcbb":0}]
#MenuId is 7 for consumer search

url = "https://healthcarebluebook.com/api/procedures"

r=requests.get(url)
# connection = pypyodbc.connect("driver={SQL Server};server=work-pc;database=test;uid=root;pwd=root")
connection = pypyodbc.connect(
    "driver={SQL Server};server=astaging.arvixecloud.com;database=NS_Import;uid=stagingsqladmin;pwd=p@ssw0rd")

cursor = connection.cursor()
try:
    pricing = r.json()
    for info in pricing:
        if info['MenuId'] == 7:
            SQLCommand = ("INSERT INTO HBB_Procedure_Dump "
                     "(ProcedureName, HBBUrl) "
                     "VALUES (?,?)")

            Values = [info['DisplayNameEnglish'], "https://healthcarebluebook.com/page_SearchResults.aspx?SearchTerms="+info['DisplayNameEnglish']]
            print(Values)
            cursor.execute(SQLCommand, Values)

except ValueError:
    print("Couldn't parse response to JSON!")
except:
    print("Unexpected error occurred!")
finally:
   connection.commit()
   connection.close()