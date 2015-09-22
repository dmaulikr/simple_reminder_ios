//
//  MasterViewController.m
//  iOSReminder
//
//  Copyright (c) 2015 Jose Aponte. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

@interface MasterViewController ()

@property (nonatomic)  NSMutableArray *reminders;
@property EKCalendar *calendar;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    _eventStore = [[EKEventStore alloc]init];
    self.navigationController.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self checkEventStoreAccessForCalendar];
}




// Check the authorization status of our application for Calendar
-(void)checkEventStoreAccessForCalendar
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    switch (status)
    {
            // Update our UI if the user has granted access to their Calendar
        case EKAuthorizationStatusAuthorized: [self accessGrantedForCalendar];
            break;
            // Prompt the user for access to Calendar if there is no definitive answer
        case EKAuthorizationStatusNotDetermined: [self requestCalendarAccess];
            break;
            // Display a message if the user has denied or restricted access to Calendar
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Privacy Warning" message:@"Permission was not granted for Calendar"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

// Prompt the user for access to their Calendar
-(void)requestCalendarAccess
{
    [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             // Let's ensure that our code will be executed from the main queue
             dispatch_async(dispatch_get_main_queue(), ^{
                 // The user has granted access to their Calendar; let's populate our UI with all events occuring in the next 24 hours.
                 [self accessGrantedForCalendar];
             });
         }
     }];
}

// This method is called when the user has granted permission to Calendar
-(void)accessGrantedForCalendar
{
    // Let's get the default calendar associated with our event store
    _calendar = self.eventStore.defaultCalendarForNewReminders;
    NSLog(@"Calendar is ready");
    
    // Enable the Add button
    self.navigationController.navigationItem.rightBarButtonItem.enabled = YES;
    // Fetch all events happening in the next 24 hours and put them into eventsList
//    self.eventsList = [self fetchEvents];
    // Update the UI with the above events
    
    [self fetchReminders];
}

-(void) fetchReminders
{
    NSPredicate *predicate = [_eventStore predicateForRemindersInCalendars:@[_calendar]];

    [_eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
        
        self.reminders = [NSMutableArray arrayWithArray:reminders];
//        for (EKReminder *reminder in reminders)
//        {
//            NSLog(@"Reminder: %@", reminder.title);
//        }
        NSLog(@"self.reminders: %d", self.reminders.count);
        [self.tableView reloadData];

    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!self.reminders)
    {
        self.reminders = [[NSMutableArray alloc] init];
    }
    
    // Agregando nuevo recordatorio
    EKReminder *reminder = [EKReminder reminderWithEventStore:_eventStore];
    reminder.title = [NSString stringWithFormat:@"reminder - %@",[NSDate date]];
    reminder.calendar = _calendar;
    reminder.completed = YES;
    reminder.notes = @"Notas varias";
    NSError *error;
    
    [_eventStore saveReminder:reminder commit:YES error:&error];
    
    NSLog(@"Error: %@", error);
    if (!error)
    {
        [self.reminders insertObject:reminder atIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [self fetchReminders];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        EKReminder *reminder = self.reminders[indexPath.row];
        [[segue destinationViewController] setDetailItem:reminder];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.reminders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    EKReminder *reminder = self.reminders[indexPath.row];
    cell.textLabel.text = reminder.title;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        NSError *error;
        EKReminder *reminder = [self.reminders objectAtIndex:indexPath.row];
        [_eventStore removeReminder:reminder commit:YES error:&error];
        
        if (!error)
        {
            [self.reminders removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        
    }
}

@end
