//
//  IAPHelper.h
//  Scroller
//
//  Created by Min Kwon on 12/20/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"


#define kProductsLoadedNotification         @"ProductsLoaded"
#define kProductPurchasedNotification       @"ProductPurchased"
#define kProductPurchaseFailedNotification  @"ProductPurchaseFailed"

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    NSSet               *_productIdentifiers;    
    NSArray             *_products;
//    NSMutableSet        *_purchasedProducts;
    SKProductsRequest   *_request;
}

@property (retain) NSSet *productIdentifiers;
@property (retain) NSArray * products;
//@property (retain) NSMutableSet *purchasedProducts;
@property (retain) SKProductsRequest *request;

+ (IAPHelper*) sharedInstance;
- (void)requestProducts;
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)buyProductIdentifier:(NSString *)productIdentifier;

@end
