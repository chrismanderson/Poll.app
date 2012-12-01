//
//  Estimate.h
//  Pollster
//
//  Created by Chris Anderson on 11/28/12.
//  Copyright (c) 2012 Polutropos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Estimate : NSObject

@property (strong, nonatomic) NSNumber *value;
@property (strong, nonatomic) NSString *choice;

- (id)initWithValue:(double)value andChoice:(NSString *)choice;

@end
