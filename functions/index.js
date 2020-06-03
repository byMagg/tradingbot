const functions = require('firebase-functions');
const admin = require('firebase-admin');
const CoinbasePro = require('coinbase-pro');
const https = require('https');

admin.initializeApp(functions.config().firebase);

const key = "f5e39c91cc9636966d2a630f259f9cbc";
const secret = "Uhfp4rqy69aeoKotpjV2KoXxXH+It05yHiIjwFwrRTlk115XYGukuoSkFByiFE9+4X0DgIHmIk+btMwnvBxGyg==";
const passphrase = "vwvomszp10d";

const apiURI = 'https://api.pro.coinbase.com';
const sandboxURI = 'https://api-public.sandbox.pro.coinbase.com';

const publicClient = new CoinbasePro.PublicClient();
const authedClient = new CoinbasePro.AuthenticatedClient(
    key,
    secret,
    passphrase,
    sandboxURI
  );

var db = admin.firestore();
var ref = db.collection("currencies");



exports.scheduledFunction = functions.pubsub.schedule('* * * * *').onRun((context) => {
    var currencies = [];
    var tempCurrencies = [];

    authedClient
    .getAccounts()
    .then(data => {
        data.forEach(element => {
            registry = {
                "currency": element['currency'],
                "balance": element['balance'],
            };
            tempCurrencies.push(element['currency']);
            currencies.push(registry);
        });


        let temp = [];

        const request = https.get(`https://min-api.cryptocompare.com/data/pricemulti?fsyms=${tempCurrencies}&tsyms=USD&api_key=8a4db04554e090369b7d5a2efee990458811ff29b59da6176beb6450247cd5bb`, (res) => {
            res.on('data', (d) => {
                temp += d;
                temp = JSON.parse(temp);
                var cont = 0;
                tempCurrencies.forEach(element => {
                    var balance = currencies[cont++]['balance'];
                    var priceUSD = temp[element]['USD'];

                   ref.doc(element).set({
                        balance: balance,
                        priceUSD: priceUSD,
                        totalUSD: balance * priceUSD
                    });
                });
            });
        });
        console.log(currencies);

    })
    .catch(error => {
        console.log(error);
    });
    return null;
});






