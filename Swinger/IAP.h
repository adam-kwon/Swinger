//
//  IAP.h
//  apocalypsemmxii
//
//  Created by Min Kwon on 12/22/11.
//  Copyright (c) 2011 GAMEPEONS LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAP : NSObject {
    int             sortOrder;
    NSString        *productId;
    NSString        *desc;
    NSString        *price;
}

- (NSString*) getPriceString;

@property (nonatomic, readwrite, assign) int sortOrder;
@property (nonatomic, readwrite, retain) NSString *productId;
@property (nonatomic, readwrite, retain) NSString *desc;
@property (nonatomic, readwrite, retain) NSString *price;

@end
