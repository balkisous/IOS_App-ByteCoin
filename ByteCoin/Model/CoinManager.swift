//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation
// https://rest.coinapi.io/v1/exchangerate/BTC/USD?apikey=92106CE7-FA25-4881-BEA2-CAEC91C76FCF
// path -> rate

protocol CoinManagerDelegate {
    func didUpdateCoin(_ coinManager: CoinManager, coin: CoinModel)
    func didFailWithError(error: Error)
}


struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC/"
    let apiKey = "92106CE7-FA25-4881-BEA2-CAEC91C76FCF"
    var delegate: CoinManagerDelegate?
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String)
    {
        print(currency)
        let UrlString = baseURL + currency + "?apikey=" + apiKey
        print(UrlString)
        performRequest(with: UrlString)
    }
    
    func performRequest(with UrlString: String){
        //1. Create a URL
        if let url = URL(string: UrlString) {
            
            //2. Create a URLSession
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let coin = self.parseJson(safeData) {
                        self.delegate?.didUpdateCoin(self, coin: coin)
                    }
                }
            }
            
            //4. start the task
            task.resume()
        }
    }
    
    func parseJson(_ coinData: Data) -> CoinModel?
    {
        let decoder = JSONDecoder()
        do
        {
            let decodeData = try decoder.decode(CoinData.self, from: coinData)
            let rate = decodeData.rate
            print("rate is \(decodeData.rate)")
            let coin = CoinModel(rate: rate)
            return (coin)
        }
        catch
        {
            print(error)
            return (nil)
        }
    }
    
}
