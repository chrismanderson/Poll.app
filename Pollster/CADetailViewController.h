//
//  CADetailViewController.h
//  Pollster
//
//  Created by Chris Anderson on 11/28/12.
//  Copyright (c) 2012 Polutropos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CADetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *estimate;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
