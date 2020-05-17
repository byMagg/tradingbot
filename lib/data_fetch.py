import cbpro
import json
import pathlib
import shrimpy
import os
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from firebase_admin import db

from datetime import datetime


class DataFetch():

    def init(self):
        path = os.path.join(os.getcwd(), 'lib\\assets\\cred.json')
        cred = credentials.Certificate(path)
        firebase_admin.initialize_app(cred, {
            'databaseURL': 'https://tradingbot-9d99d.firebaseio.com'
        })
        self.db = firestore.client()

        data = json.load(open("lib/assets/api.json", "r"))
        self.public_key = data['public_key']
        self.private_key = data['private_key']
        self.auth_client = cbpro.AuthenticatedClient(
            data['api_key'], data['api_secret'], data['passphrase'], api_url="https://api-public.sandbox.pro.coinbase.com")

    def get_wallet_data(self):
        api_client = shrimpy.ShrimpyApiClient(
            self.public_key, self.private_key)
        ticker = api_client.get_ticker('coinbasepro')
        wallet = self.auth_client.get_accounts()

        for it0 in wallet:
            for it1 in ticker:
                if(it1['symbol'] == it0['currency']):
                    reg = {
                        u'name': str(it1['name']),
                        u'symbol': str(it0['currency']),
                        u'priceUSD': float(it1['priceUsd']),
                        u'totalUSD': float(float(it0['balance'])*float(it1['priceUsd'])),
                        u'balance': float(it0['balance'])
                    }
                    doc_ref = self.db.collection(u'currencies').document(
                        str(it0['currency'])).set(reg)
                    break

    def test_data(self):

        for i in range(12):
            data = {
                u'symbol': u'BTC',
                u'transaction': u'-1234.23',
                u'date': datetime.now(),
            }

        self.db.collection(u'operations').document().set(data)


if __name__ == "__main__":
    data_fetch = DataFetch()
    data_fetch.init()
    data_fetch.get_wallet_data()
    # data_fetch.test_data()
