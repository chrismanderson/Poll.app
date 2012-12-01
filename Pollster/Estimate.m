//
//  Estimate.m
//  Pollster
//
//  Created by Chris Anderson on 11/28/12.
//  Copyright (c) 2012 Polutropos. All rights reserved.
//

#import "Estimate.h"

@implementation Estimate

- (id)initWithValue:(double)value andChoice:(NSString *)choice
{
    self = [super init];
    
    if (self) {
        _choice = choice;
        _value  = [NSNumber numberWithDouble:value];
    }
    return self;
}

@end
