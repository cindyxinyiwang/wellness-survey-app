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

@property (nonatomic) BOOL *answered;

@property (nonatomic) NSString *previousAnswer;
@end

@implementation XYZrateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.questionShow.text = _question;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submit:(id)sender {
    self.answer.userInteractionEnabled = false;
    self.previousAnswer = [NSString stringWithFormat:@"%f",[self.answer value]];
    PFObject *newAnswer = [PFObject objectWithClassName: @"AnswerInProgress"];
    [newAnswer setObject:self.previousAnswer forKey:@"answer"];
    [newAnswer setObject:[PFUser currentUser] forKey:@"user"];
    PFQuery *matchQuestion = [PFQuery queryWithClassName:@"SurveyQuestion"];
    [matchQuestion getObjectInBackgroundWithId:self.questionId block:^(PFObject *object, NSError *error) {
        if (!error){
            
            [newAnswer setObject:object forKey:@"question"];
            [newAnswer saveInBackground];
            _answered = YES;
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
