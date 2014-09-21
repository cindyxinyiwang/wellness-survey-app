//
//  XYZfirstwindowViewController.m
//  wellness survey app
//
//  Created by Cindy Wang on 9/12/14.
//  Copyright (c) 2014 xinyi wang. All rights reserved.
//

#import "XYZfirstwindowViewController.h"
#import <Parse/Parse.h>

@interface XYZfirstwindowViewController ()

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;

@end

@implementation XYZfirstwindowViewController

- (IBAction)logOff:(UIButton *)sender {
 
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = YES;
    // Query the question in database
    PFQuery *question = [PFQuery queryWithClassName:@"SurveyQuestion"];
    [question whereKey:@"index" equalTo:@1];
    [question findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            //The find succeeded
            NSLog(@"Successfully retrieved question %d", objects.count);
            for (PFObject *object in objects) {
                NSString *question = [object objectForKey:@"Question"];
                NSLog(@"%@", question);
                _questionLabel.text = question;
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
