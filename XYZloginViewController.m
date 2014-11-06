//
//  XYZloginViewController.m
//  wellness survey app
//
//  Created by Cindy Wang on 9/10/14.
//  Copyright (c) 2014 xinyi wang. All rights reserved.
//

#import "XYZloginViewController.h"
#import <Parse/Parse.h>

@interface XYZloginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation XYZloginViewController

- (IBAction)loginButtonPressed:(UIButton *)sender {
       @try{
    [PFUser logInWithUsernameInBackground:_userName.text password:_password.text
       block:^(PFUser *user, NSError *error) {
      if (user) {
          // Do stuff after successful login.
          _userName.text = nil;
          _password.text = nil;
          [self performSegueWithIdentifier:@"successLogin" sender:self];
     } else {
     // The login failed. Check error to see why.
         [self Alert:@"Incorrect username or password"];
       }
       }];
    }
    @catch (NSException *e) {
        [self Alert:@"Incorrect username or password"];
       }
}



-(IBAction)Alert: (NSString*)errorMessage {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    [alert show];
}

- (IBAction)registerButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"registerSegue" sender:self];
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

    _password.secureTextEntry = YES;
}

//allow user to resign edit by clicking
- (void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event {
    if (self.userName) {
        if ([self.userName canResignFirstResponder]) [self.userName resignFirstResponder];
    }
    if (self.password) {
        if ([self.password canResignFirstResponder]) [self.password resignFirstResponder];
    }
    [super touchesBegan: touches withEvent: event];
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
