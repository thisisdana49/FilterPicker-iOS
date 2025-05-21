//
//  StoreKitViewController.swift
//  FilterPicker
//
//  Created by 조다은 on 5/21/25.
//

import UIKit
import StoreKit

@available(iOS 15.0, *)
class StoreKitViewController: UIViewController {
    
    private let productIdentifiers: Set<Product.ID> = [
        "com.dana.FilterPickerApp.gem",
        "com.dana.FilterPickerApp.gem100"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            await loadProductData()
        }
    }
    
    func loadProductData() async {
        do {
            let product = try await Product.products(for: productIdentifiers)
            
            for item in product {
                print(item.displayName)
                print(item.displayPrice)
                print(item.id)
            }
            await purchaseProduct(product.first!)
        } catch {
            print("인앱 상품 로드 실패 \(error)")
        }
    }
    
    func purchaseProduct(_ product: Product) async {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verificationResult):
                print("Purchase success")
            case .userCancelled:
                print("Purchase cancelled")
            case .pending:
                print("Purchase pending")
            @unknown default :
                print("unknown case")
            }
        } catch {
            print("Purchase failed")
        }
    }
    
}
