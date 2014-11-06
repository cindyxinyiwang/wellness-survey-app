//
//  XYZrateViewController.m
//  wellness survey app
//
//  Created by Cindy Wang on 10/11/14.
//  Copyright (c) 2014 xinyi wang. All rights reserved.
//

#import "XYZrateViewController.h"
#import <Parse/Parse.h>
@interface XYZrateViewController ()

@property (weak, nonatomic) IBOutlet UILabel *questionShow;
@property (weak, nonatomic) IBOutlet UISlider *answer;
@property (weak, nonatomic) IBOutlet UILabel *sliderMax;
@property (weak, nonatomic) IBOutlet UILabel *sliderMin;


@property (weak, nonatomic) IBOutlet UITextField *textAnswer;
@property (nonatomic) BOOL reviseClicked;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *submitButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *reviseButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@end

@implementation XYZrateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.questionShow.text = _question;
    self.navigationItem.title = [NSString stringWithFormat:@"Question %@", self.questionIndex];

    if (self.prevAnswer != nil) {
        self.answer.value = [self.prevAnswer floatValue];
        self.answer.userInteractionEnabled = false;
        self.navigationItem.rightBarButtonItem = self.reviseButton;
    } else {
        self.navigationItem.rightBarButtonItem = self.submitButton;
    }
    //configure slider and text view
    self.sliderMin.text =self.sliderConfig[0];
    self.sliderMax.text = self.sliderConfig[1];
    [self.answer setMinimumValue:[self.sliderConfig[0] floatValue]];
    [self.answer setMaximumValue:[self.sliderConfig[1] floatValue]];
    self.textAnswer.text = [NSString stringWithFormat:@"%.1f", [self.answer value]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//sync slider and text field
- (IBAction) sliderValueChanged:(UISlider *)sender {
    self.textAnswer.text = [NSString stringWithFormat:@"%.1f", [sender value]];
}

- (IBAction) textValueChanged:(UITextField *)sender {
    NSString *textValue = [self.textAnswer text];
    float value = [textValue floatValue];
    if (value < 0) value = 0;
    if (value > 1) value = 1;
    self.answer.value = value;
    self.textAnswer.text = [NSString stringWithFormat:@"%.1f", value];
    if ([self.textAnswer canResignFirstResponder]) [self.textAnswer resignFirstResponder];
}

//allow user to resign edit by clicking
- (void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event {
    if (self.textAnswer) {
        if ([self.textAnswer canResignFirstResponder]) [self.textAnswer resignFirstResponder];
    }
    [super touchesBegan: touches withEvent: event];
}

- (IBAction)revise:(id)sender {
    self.answer.userInteractionEnabled = true;
    self.navigationItem.leftBarButtonItem = self.cancelButton;
    self.reviseClicked = YES;
    self.navigationItem.rightBarButtonItem = self.submitButton;
}

- (IBAction)submit:(id)sender {
    // Open a dialog with just an OK button.
    NSString *actionTitle = NSLocalizedString(@"Are you sure you want to submit your answers?", @"");
    NSString *cancelTitle = NSLocalizedString(@"Cancel", @"Cancel title for item removal action");
    NSString *okTitle = NSLocalizedString(@"OK", @"OK title for item removal action");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionTitle
                                                             delegate:self
                                                    cancelButtonTitle:cancelTitle
                                               destructiveButtonTitle:okTitle
                                                    otherButtonTitles:nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    
    // Show from our table view (pops up in the middle of the table).
    [actionSheet showInView:self.view];
    
   }

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        PFQuery *queryAnswer = [PFQuery queryWithClassName:@"AnswerInProgress"];
        [queryAnswer whereKey:@"user" equalTo:[PFUser currentUser]];
        
        
        PFQuery *matchQuestion = [PFQuery queryWithClassName:@"SurveyQuestion"];
        [matchQuestion getObjectInBackgroundWithId:self.questionId block:^(PFObject *object, NSError *error) {
            if (!error){
                [queryAnswer whereKey:@"question" equalTo:object];
                
                if ([queryAnswer countObjects] == 0){
                    PFObject *newAnswer = [PFObject objectWithClassName: @"AnswerInProgress"];
                    [newAnswer setObject:[NSString stringWithFormat:@"%f", self.answer.value] forKey:@"answer"];
                    [newAnswer setObject:[PFUser currentUser] forKey:@"user"];
                    [newAnswer setObject:object forKey:@"question"];
                    [newAnswer setObject:[object objectId] forKey:@"questionId"];
                    [newAnswer saveInBackground];
                    self.answer.userInteractionEnabled = false;
                    self.navigationItem.rightBarButtonItem = self.reviseButton;
                    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
                    
                } else if (self.reviseClicked) {
                    [queryAnswer getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
                        object[@"answer"] =[NSString stringWithFormat:@"%f", self.answer.value];
                        [object saveInBackground];
                        [object refresh];
                    }];
                    self.navigationItem.rightBarButtonItem = self.reviseButton;
                    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
                    self.answer.userInteractionEnabled = false;
                    self.reviseClicked = NO;
                    
                } else {
                    UIAlertView *saved = [[UIAlertView alloc]initWithTitle:@"Warning" message: @"Your have already answered the question" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [saved show];
                }
            }
        }];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (IBAction)cancel:(id)sender {
    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.reviseButton;
    self.reviseClicked = NO;
    self.answer.userInteractionEnabled = false;
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
