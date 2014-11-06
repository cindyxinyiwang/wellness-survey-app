//
//  XYZsignupViewController.m
//  wellness survey app
//
//  Created by Cindy Wang on 9/10/14.
//  Copyright (c) 2014 xinyi wang. All rights reserved.
//

#import "XYZsignupViewController.h"
#import <Parse/Parse.h>

@interface XYZsignupViewController ()

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *email;

@end

@implementation XYZsignupViewController
- (IBAction)goBack:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//allow user to resign edit by clicking
- (void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event {
    if (self.userName) {
        if ([self.userName canResignFirstResponder]) [self.userName resignFirstResponder];
    }
    if (self.password) {
        if ([self.password canResignFirstResponder]) [self.password resignFirstResponder];
    }
    if (self.name) {
        if ([self.name canResignFirstResponder]) [self.name resignFirstResponder];
    }
    if (self.email) {
        if ([self.email canResignFirstResponder]) [self.email resignFirstResponder];
    }
    [super touchesBegan: touches withEvent: event];
}
- (IBAction)signUpMethod {
    PFUser *user = [PFUser user];
    user.username = _userName.text;
    user.password = _password.text;
    user.email = _email.text;
    
    // other fields can be set just like with PFObject
    user[@"name"] = _name.text;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hooray! Let them use the app now.
            NSLog(@"success!");
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            NSString *errorString = [error userInfo][@"error"];
            
            // Show the errorString somewhere and let the user try again.
        [self Alert:errorString];
        }
    }];
}
-(IBAction)Alert: (NSString*)errorMessage {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    [alert show];
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
    self.password.delegate = self;
    self.userName.delegate = self;
    self.email.delegate = self;
    _password.secureTextEntry = YES;
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
