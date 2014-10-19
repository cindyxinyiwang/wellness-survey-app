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

@property (nonatomic) BOOL *reviseClicked;

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
        self.answer.backgroundColor = [UIColor colorWithRed:160.0f/255.0f green:160.0f/255.0f blue:160.0f/255.0f alpha:1];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)revise:(id)sender {
    self.answer.userInteractionEnabled = true;
    self.answer.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1];
    PFQuery *queryAnswer = [PFQuery queryWithClassName:@"AnswerInProgress"];
    [queryAnswer whereKey:@"user" equalTo:[PFUser currentUser]];
    [queryAnswer whereKey:@"questionId" equalTo:self.questionId];
    if ([queryAnswer countObjects] == 0) {
        UIAlertView *noAnswer = [[UIAlertView alloc] initWithTitle:@"Message" message:@"This question has not been answered yet."delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [noAnswer show];
    } else {
        self.reviseClicked = YES;
    }

}

- (IBAction)submit:(id)sender {
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
                self.answer.backgroundColor = [UIColor colorWithRed:160.0f/255.0f green:160.0f/255.0f blue:160.0f/255.0f alpha:1];
                UIAlertView *savedSuccess = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Saved Successfully!"delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [savedSuccess show];
                
            } else if (self.reviseClicked) {
                [queryAnswer getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
                    object[@"answer"] =[NSString stringWithFormat:@"%f", self.answer.value];
                    [object saveInBackground];
                    self.answer.backgroundColor = [UIColor colorWithRed:160.0f/255.0f green:160.0f/255.0f blue:160.0f/255.0f alpha:1];
                    [object refresh];
                }];
                
                self.answer.userInteractionEnabled = false;
                self.reviseClicked = NO;
            } else {
                UIAlertView *saved = [[UIAlertView alloc]initWithTitle:@"Warning" message: @"Your have already answered the question" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [saved show];
            }
        }
    }];
    

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
