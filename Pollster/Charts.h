//
//  Charts.h
//  Pollster
//
//  Created by Chris Anderson on 11/28/12.
//  Copyright (c) 2012 Polutropos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Estimate.h"

@interface Charts : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray *estimates;

@end
