//
//  XYZsingleSelectViewController.m
//  wellness survey app
//
//  Created by Cindy Wang on 10/11/14.
//  Copyright (c) 2014 xinyi wang. All rights reserved.
//

#import "XYZsingleSelectViewController.h"
#import <Parse/Parse.h>

@interface XYZsingleSelectViewController ()
@property (weak, nonatomic) IBOutlet UILabel *questionShow;
@property (nonatomic) BOOL reviseClicked;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *submitButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *reviseButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;

@end

@implementation XYZsingleSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
   self.picker.dataSource = self;
   self.picker.delegate = self;
    self.questionShow.text = self.question;
    
    self.navigationItem.title = [NSString stringWithFormat:@"Question %@", self.questionIndex];
    
    if (self.prevAnswer != nil) {
        NSUInteger row = [self.pickerData indexOfObject:self.prevAnswer];
        [self.picker selectRow:row inComponent:0 animated:YES];
        self.picker.userInteractionEnabled = false;
        self.navigationItem.rightBarButtonItem = self.reviseButton;
        
    } else {
        self.navigationItem.rightBarButtonItem = self.submitButton;
    }

}
- (IBAction)revise:(id)sender {
    self.navigationItem.leftBarButtonItem = self.cancelButton;
    self.reviseClicked = YES;
    self.navigationItem.rightBarButtonItem = self.submitButton;
    self.picker.userInteractionEnabled = YES;
}

- (IBAction)saveAnswer:(UIButton *)sender {
    NSUInteger row = [self.picker selectedRowInComponent:0];
    NSString *answer = [self.pickerData objectAtIndex:row];
    
    
    PFQuery *queryAnswer = [PFQuery queryWithClassName:@"AnswerInProgress"];
    [queryAnswer whereKey:@"user" equalTo:[PFUser currentUser]];
    
    
    PFQuery *matchQuestion = [PFQuery queryWithClassName:@"SurveyQuestion"];
    [matchQuestion getObjectInBackgroundWithId:self.questionId block:^(PFObject *object, NSError *error) {
        if (!error){
            [queryAnswer whereKey:@"question" equalTo:object];
            
            if ([queryAnswer countObjects] == 0){
                PFObject *newAnswer = [PFObject objectWithClassName: @"AnswerInProgress"];
                [newAnswer setObject:answer forKey:@"answer"];
                [newAnswer setObject:[PFUser currentUser] forKey:@"user"];
                [newAnswer setObject:object forKey:@"question"];
                [newAnswer setObject:[object objectId] forKey:@"questionId"];
                [newAnswer saveInBackground];
                self.picker.userInteractionEnabled = false;
                self.navigationItem.rightBarButtonItem = self.reviseButton;
                self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
                
            } else if (self.reviseClicked) {
                [queryAnswer getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
                    object[@"answer"] = answer;
                    [object saveInBackground];
                    
                    [object refresh];
                }];
                self.navigationItem.rightBarButtonItem = self.reviseButton;
                self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
                self.picker.userInteractionEnabled = false;
                self.reviseClicked = NO;
            } else {
                UIAlertView *saved = [[UIAlertView alloc]initWithTitle:@"Warning" message: @"Your have already answered the question" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [saved show];
            }
        }
    }];

    
}

- (IBAction)cancel:(id)sender {
    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.reviseButton;
    self.reviseClicked = NO;
    self.picker.userInteractionEnabled = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView: (UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //NSLog(@"The first value is %@", _pickerData);
    //NSArray *data = [_pickerData objectForKey:@"config"];
    //NSLog(@"The second value is %@", data);
    return (int)[_pickerData count];
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //NSArray *data = [_pickerData objectForKey:@"config"];
  
    return _pickerData[row];
}
 
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
