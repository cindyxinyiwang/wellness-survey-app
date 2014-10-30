//
//  XYZdetailQuestionTableViewController.m
//  wellness survey app
//
//  Created by Cindy Wang on 9/24/14.
//  Copyright (c) 2014 xinyi wang. All rights reserved.
//

#import "XYZdetailQuestionTableViewController.h"
#import <Parse/Parse.h>

@interface XYZdetailQuestionTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *questionListed;
@property (weak, nonatomic) IBOutlet UITextField *answer;
@property (nonatomic) BOOL reviseClicked;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *submitButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *reviseButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;

@end

@implementation XYZdetailQuestionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = [NSString stringWithFormat:@"Question %@", self.questionIndex];
    self.questionListed.text = _question;
    if (self.prevAnswer != nil) {
        self.answer.text = self.prevAnswer;
        self.answer.userInteractionEnabled = false;
        self.navigationItem.rightBarButtonItem = self.reviseButton;
    } else {
        self.navigationItem.rightBarButtonItem = self.submitButton;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)editAnswer:(UIButton *)sender {
    self.answer.userInteractionEnabled = true;
    self.navigationItem.leftBarButtonItem = self.cancelButton;
    self.reviseClicked = YES;
    self.navigationItem.rightBarButtonItem = self.submitButton;
}

- (IBAction)saveAnswer {
    

    PFQuery *queryAnswer = [PFQuery queryWithClassName:@"AnswerInProgress"];
    [queryAnswer whereKey:@"user" equalTo:[PFUser currentUser]];
    
   
    PFQuery *matchQuestion = [PFQuery queryWithClassName:@"SurveyQuestion"];
    [matchQuestion getObjectInBackgroundWithId:self.questionId block:^(PFObject *object, NSError *error) {
        if (!error){
            [queryAnswer whereKey:@"question" equalTo:object];
            
            if ([queryAnswer countObjects] == 0){
                PFObject *newAnswer = [PFObject objectWithClassName: @"AnswerInProgress"];
                [newAnswer setObject:[self.answer text] forKey:@"answer"];
                [newAnswer setObject:[PFUser currentUser] forKey:@"user"];
                [newAnswer setObject:object forKey:@"question"];
                [newAnswer setObject:[object objectId] forKey:@"questionId"];
                [newAnswer saveInBackground];
                self.answer.userInteractionEnabled = false;
                self.navigationItem.rightBarButtonItem = self.reviseButton;
                self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
                
            } else if (self.reviseClicked) {
                [queryAnswer getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
                    object[@"answer"] =self.answer.text;
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
}

- (IBAction)cancel:(id)sender {
    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.reviseButton;
    self.reviseClicked = NO;
    self.answer.userInteractionEnabled = false;
}


#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}
*/
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"detailQuestionCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

*/
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
