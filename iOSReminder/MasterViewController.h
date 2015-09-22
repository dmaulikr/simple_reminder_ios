//
//  MasterViewController.h
//  iOSReminder
//
//  Copyright (c) 2015 Jose Aponte. All rights reserved.
//

#import <UIKit/UIKit.h>
@import EventKit;


@interface MasterViewController : UITableViewController

@property(strong, nonatomic) EKEventStore *eventStore;

@end

