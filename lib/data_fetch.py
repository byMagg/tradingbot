import cbpro
import json
import pathlib
import shrimpy
import os
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore


class DataFetch():

    def init(self):
        os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = r'C:\Users\Dani\Documents\src\tradingbot\lib\assets\cred.json'
        cred = credentials.ApplicationDefault()
        firebase_admin.initialize_app(cred, {
            'projectId': 'tradingbot-9d99d',
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
                        u'balance': float(it0['balance'])
                    }
                    doc_ref = self.db.collection(
                        u'currencies').document(str(it0['currency'])).set(reg)
                    break

    def get_balance(self):
        api_client = shrimpy.ShrimpyApiClient(
            self.public_key, self.private_key)
        ticker = api_client.get_ticker('coinbasepro')
        wallet = self.auth_client.get_accounts()

        balance = 0

        for it0 in wallet:
            if(it0['balance'] == 0):
                continue
            for it1 in ticker:
                if(it1['symbol'] == it0['currency']):
                    balance += float(it1['priceUsd']) * float(it0['balance'])
                    break

        reg = {
            u"balance": balance
        }

        doc_ref = self.db.collection(u'balances').document(u'balance').set(reg)


if __name__ == "__main__":
    data_fetch = DataFetch()
    data_fetch.init()
    data_fetch.get_balance()
    data_fetch.get_wallet_data()
