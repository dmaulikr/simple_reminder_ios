//
//  DetailViewController.h
//  iOSReminder
//
//  Copyright (c) 2015 Jose Aponte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

