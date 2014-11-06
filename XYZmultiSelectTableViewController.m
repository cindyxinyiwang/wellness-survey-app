//
//  XYZmultiSelectTableViewController.m
//  wellness survey app
//
//  Created by Cindy Wang on 10/14/14.
//  Copyright (c) 2014 xinyi wang. All rights reserved.
//

#import "XYZmultiSelectTableViewController.h"
#import <Parse/Parse.h>

@interface XYZmultiSelectTableViewController ()

@property (nonatomic, strong) IBOutlet UIBarButtonItem *submitButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *reviseButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;

@property (nonatomic, strong) NSMutableArray *answers;

@property (nonatomic) BOOL reviseClicked;
@end

@implementation XYZmultiSelectTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.answers = [NSMutableArray new];
    PFQuery *queryAnswer = [PFQuery queryWithClassName:@"AnswerInProgress"];
    [queryAnswer whereKey:@"user" equalTo:[PFUser currentUser]];
    [queryAnswer whereKey:@"questionId" equalTo:self.questionId];
    if ([queryAnswer countObjects] == 0){
        self.navigationItem.rightBarButtonItem = self.submitButton;
        self.tableView.allowsMultipleSelectionDuringEditing = YES;
        
        [self.tableView setEditing:YES animated:YES];
        
        
    } else {
        [self.tableView setEditing:NO animated:YES];
        self.navigationItem.rightBarButtonItem = self.reviseButton;
        [self.answers addObjectsFromArray:[[queryAnswer getFirstObject] objectForKey:@"answerArray"] ];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    if (section == 0){
        return 1;
    } else {
        return self.pickerData.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    // Configure the cell...
    if (indexPath.section == 0){
        cell.textLabel.text = self.question;
    } else {
        cell.textLabel.text = [self.pickerData objectAtIndex:indexPath.row];
        if ([self.answers containsObject:cell.textLabel.text]){
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 0) {
        return NO;
    } else {
        return YES;
    }
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
    if (buttonIndex == 0){
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        [self.answers removeAllObjects];
        for (NSIndexPath *index in selectedRows) {
            [self.answers addObject: [self.pickerData objectAtIndex:index.row]];
        }
        
        PFQuery *queryAnswer = [PFQuery queryWithClassName:@"AnswerInProgress"];
        [queryAnswer whereKey:@"user" equalTo:[PFUser currentUser]];
        
        PFQuery *matchQuestion = [PFQuery queryWithClassName:@"SurveyQuestion"];
        [matchQuestion getObjectInBackgroundWithId:self.questionId block:^(PFObject *object, NSError *error) {
            if (!error){
                [queryAnswer whereKey:@"question" equalTo:object];
                
                if ([queryAnswer countObjects] == 0){
                    PFObject *newAnswer = [PFObject objectWithClassName: @"AnswerInProgress"];
                    [newAnswer setObject:self.answers forKey:@"answerArray"];
                    [newAnswer setObject:[PFUser currentUser] forKey:@"user"];
                    [newAnswer setObject:object forKey:@"question"];
                    [newAnswer setObject:[object objectId] forKey:@"questionId"];
                    [newAnswer saveInBackground];
                    self.reviseClicked = NO;
                    [self.tableView setEditing:NO animated:YES];
                    self.navigationItem.rightBarButtonItem = self.reviseButton;
                    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
                    [self.tableView reloadData];
                    
                } else if (self.reviseClicked) {
                    [queryAnswer getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
                        object[@"answerArray"] = self.answers;
                        [object saveInBackground];
                        
                        [object refresh];
                    }];
                    self.reviseClicked = NO;
                    [self.tableView setEditing:NO animated:YES];
                    self.navigationItem.rightBarButtonItem = self.reviseButton;
                    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
                    [self.tableView reloadData];
                    
                } else {
                    UIAlertView *saved = [[UIAlertView alloc]initWithTitle:@"Warning" message: @"Your have already answered the question" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [saved show];
                }
            }
        }];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

- (IBAction)revise:(id)sender {
    self.navigationItem.leftBarButtonItem = self.cancelButton;
    self.reviseClicked = YES;
    self.navigationItem.rightBarButtonItem = self.submitButton;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.tableView setEditing:YES animated:YES];

}

- (IBAction)cancel:(id)sender {
    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.reviseButton;
    self.reviseClicked = NO;
    [self.tableView setEditing:NO animated:YES];
}
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
