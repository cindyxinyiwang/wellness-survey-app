//
//  XYZquestionListTableViewController.h
//  wellness survey app
//
//  Created by Cindy Wang on 1/15/15.
//  Copyright (c) 2015 xinyi wang. All rights reserved.
//
//  source code for the second scene displaying a table of questions of a particular type

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface XYZquestionListTableViewController : UITableViewController

@property (strong, nonatomic) PFObject *type;

@end
