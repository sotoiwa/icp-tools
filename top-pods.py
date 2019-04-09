import logging
import pprint

import pandas
import requests
import urllib3

# 警告を非表示にする
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

formatter = '%(asctime)s %(name)-12s %(levelname)-8s %(message)s'
logging.basicConfig(level=logging.WARNING, format=formatter)
logger = logging.getLogger(__name__)

token = 'hogehoge'

url = 'https://9.188.124.130:8001/apis/metrics.k8s.io/v1beta1/pods'

headers = {'Authorization': 'Bearer {}'.format(token)}
response = requests.get(url, headers=headers, verify=False)
response.raise_for_status()

pprint.pprint(response.json())

#df = pandas.read_json(response.json())
#df.to_csv('hogehoge.csv')

