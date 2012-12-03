//
//  Charts.h
//  Pollster
//
//  Created by Chris Anderson on 11/28/12.
//  Copyright (c) 2012 Polutropos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Estimate.h"
#import "DateEstimates.h"

@interface Charts : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *slug;

@property (strong, nonatomic) NSArray *estimates;
@property (strong, nonatomic) NSArray *estimatesByDate;
@property (strong, nonatomic) NSDate *lastUpdated;


@end
