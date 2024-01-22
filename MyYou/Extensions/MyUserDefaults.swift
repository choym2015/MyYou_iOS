//
//  MyUserDefaults.swift
//  MyYou
//
//  Created by SOO HYUN CHO on 1/19/24.
//

import Foundation

public class MyUserDefaults {
    public static func getString(with key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    public static func getData(with key: String) -> Data? {
        return UserDefaults.standard.value(forKey: key) as? Data
    }
    
    public static func saveString(with key: String, value: String) {
        DispatchQueue.main.async {
            UserDefaults.standard.setValue(value, forKey: key)
        }
    }
    
    public static func saveData(with key: String, value: Data) {
        DispatchQueue.main.async {
            UserDefaults.standard.setValue(value, forKey: key)
        }
    }
}
