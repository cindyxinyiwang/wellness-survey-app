//
//  XYZsurveyListTableViewController.m
//  wellness survey app
//
//  Created by Cindy Wang on 9/17/14.
//  Copyright (c) 2014 xinyi wang. All rights reserved.
//

#import "XYZsurveyListTableViewController.h"
#import "XYZsurveyListTableViewCell.h"
#import "XYZdetailQuestionTableViewController.h"
#import "XYZsingleSelectViewController.h"
#import "XYZmultiSelectTableViewController.h"
#import "XYZrateViewController.h"
#import "XYZtimeTableViewCell.h"
#import <Parse/Parse.h>

@interface XYZsurveyListTableViewController ()
@property (strong, nonatomic) NSMutableArray *questionEntries;
@property (strong, nonatomic) NSArray *currentAnswers;
//index of questionEntries that needs to be deleted
@property (nonatomic) NSInteger deleteQuesIndex;
/*
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSArray *issueTime;
 */
////////////////////////
//problems:
//1. how to set up a dictionary of the data stored in Parse(given the fact that findObject is synchronized and block main thread)
//2. when one of the entries is not defined, it gives and error (could define set up at the web end)

@end

@implementation XYZsurveyListTableViewController

- (IBAction)logOff:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.deleteQuesIndex = -1;
    
    PFQuery *query = [PFQuery queryWithClassName:@"SurveyQuestion"];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            
        } else {
            self.questionEntries = [NSMutableArray arrayWithArray:objects];
            [self updateQuestionEntries];
        }
    }];
    //add notification for row delete
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setDeleteEntry:) name:@"DeleteNotification" object:nil];
    /*
    PFQuery *queryCategory = [PFQuery queryWithClassName:@"Category"];
    [queryCategory findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            
        } else {
            self.categories = objects;
            [self.tableView reloadData];
        }
    }];
    PFQuery *queryTime = [PFQuery queryWithClassName:@"IssueTime"];
    [queryTime findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            
        } else {
            self.issueTime = objects;
            [self.tableView reloadData];
        }
    }];
    */
}
//receive notifications
- (void) setDeleteEntry: (NSNotification *) notification {
    if ([[notification name] isEqualToString:@"DeleteNotification"]){
        NSDictionary *dict = [notification userInfo];
        //real index needs to be deducted by 1
        NSInteger retrieve = [[dict objectForKey:@"index"] intValue];
        self.deleteQuesIndex = retrieve - 1;
    }
}

//after getting questionEntries, delete ones already answered
- (void) updateQuestionEntries {
    PFQuery *answerQuery = [PFQuery queryWithClassName:@"AnswerInProgress"];
    [answerQuery whereKey:@"user" equalTo:[PFUser currentUser]];

    [answerQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if  (error) {
            NSLog(@"Error");
        } else {
            self.currentAnswers = objects;
            //delete the entry from questionEntries if it is answered
            for (PFObject *p in objects) {
                NSString *removeQuestion = [p objectForKey:@"questionId"];
                for(PFObject *q in self.questionEntries){
                    if ([[q objectId] isEqualToString:removeQuestion]){
                        [self.questionEntries removeObject:q];
                        break;
                    }
                }
            }
            [self.tableView reloadData];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //if delete the row if deleteIndex is greater than 0
    if (self.deleteQuesIndex >= 0){
        [self.questionEntries removeObjectAtIndex:self.deleteQuesIndex];
    }
    //reset deleteRow value
    self.deleteQuesIndex = -1;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
        // Return the number of sections.Add one for expire date
    return [self.categories count]+1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *header;
    if (section == 0){
        //if it is the top section
        header = @"Timeline";
    } else {
        PFObject *currentCategory = self.categories[section-1];
        header = [currentCategory objectForKey:@"type"];
    }
    return header;
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    /*
    NSInteger counter = 0;
    if (section == 0){
        counter = 2;
    } else {
        PFObject *currentCategory = self.categories[section - 1];
        NSString *categoryName = [currentCategory objectForKey:@"type"];
        for (PFObject *q in self.questionEntries){
            if([[q objectForKey:@"type"] isEqualToString:categoryName]){
                counter ++;
            }
        }
    }
    return counter;
     */
    NSInteger counter = 0;
    counter = [self.questionEntries count];
    return counter;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    if (indexPath.section == 0) {
        PFObject *timeItem = self.issueTime[0];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        NSDate *date = [NSDate date];
        XYZtimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timeCell"];
        
        if (indexPath.row == 0){
            cell.timeTitleLabel.text = @"Issued at: ";
            date = timeItem.updatedAt;
            cell.timeSetupLabel.text = [dateFormatter stringFromDate:date];
        } else {
            cell.timeTitleLabel.text = @"Expire at: ";
            date = [timeItem objectForKey:@"endDate"];
            cell.timeSetupLabel.text = [dateFormatter stringFromDate:date];
        }
        cell.timeSetupLabel.font = [UIFont systemFontOfSize:12.0];
        return cell;
    } else {
     PFObject *currentCategory = self.categories[indexPath.section - 1];
     NSString *categoryName = [currentCategory objectForKey:@"type"];
     
        XYZsurveyListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"questionCell" ];
    
    
        NSMutableArray *aspects = [[NSMutableArray alloc]init];
        for (PFObject *q in self.questionEntries){
            if([[q objectForKey:@"type"] isEqualToString:categoryName]){
                [aspects addObject:[q objectForKey:@"aspect"]];
            }
        }
        cell.questionCategoryLabel.text = aspects[indexPath.row];
     */
    XYZsurveyListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"questionCell" ];
    PFObject *questionEntry = self.questionEntries[indexPath.row];
    NSString *questionAspect = [questionEntry objectForKey:@"aspect"];
    NSString *questionCategory = [questionEntry objectForKey:@"type"];
    NSDate *endDate = [questionEntry objectForKey:@"endDate"];
    //configure cell
    cell.questionCategoryLabel.text = questionCategory;
    cell.questionAspectLabel.text = questionAspect;
    //cell displays how much time left for survey at the point of loading table view
    NSTimeInterval secondsBetween = [endDate timeIntervalSinceNow];
    int numberOfHours = secondsBetween / 3600;
    NSString *expireHour = [NSString stringWithFormat:@"Expire in %d hours", numberOfHours];
    cell.questionExpireLabel.text = expireHour;
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    if (indexPath.section == 0) return;
    
    PFObject *currentCategory = self.categories[indexPath.section - 1];
    NSString *categoryName = [currentCategory objectForKey:@"type"];
    NSMutableArray *answerType = [[NSMutableArray alloc]init];
    for (PFObject *q in self.questionEntries){
        if([[q objectForKey:@"type"] isEqualToString:categoryName]){
            [answerType addObject:[q objectForKey:@"answerType"]];
        }
    }
    NSString *type = answerType[indexPath.row];
     */
    NSString *type = [[self.questionEntries objectAtIndex:indexPath.row] objectForKey:@"answerType"];
    if ([type isEqualToString:@"text"]) {
        [self performSegueWithIdentifier:@"text" sender:self];
    } else if ([type isEqualToString:@"singleSelect"]) {
        [self performSegueWithIdentifier:@"singleSelect" sender:self];
    } else if ([type isEqualToString:@"multiSelect"]) {
        [self performSegueWithIdentifier:@"multiSelect" sender:self];
    }   else if ([type isEqualToString:@"rate"]) {
        [self performSegueWithIdentifier:@"rate" sender:self];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    /*
    if ([self.tableView indexPathForSelectedRow].section == 0) return;
    
    NSInteger categoryNumber = [self.tableView indexPathForSelectedRow].section - 1;
    NSInteger rowNumber = [self.tableView indexPathForSelectedRow].row;
    
    PFObject *currentCategory = self.categories[categoryNumber];
    NSString *categoryName = [currentCategory objectForKey:@"type"];
    NSMutableArray *currentQuestions = [[NSMutableArray alloc]init];
    NSMutableArray *questionIds = [[NSMutableArray alloc]init];
    for (PFObject *q in self.questionEntries){
        if([[q objectForKey:@"type"] isEqualToString:categoryName]){
            [currentQuestions addObject:[q objectForKey:@"Question"]];
            [questionIds addObject:[q objectId]];
            
        }
    }
    NSString *answerNow;
    PFQuery *answerQuery = [PFQuery queryWithClassName:@"AnswerInProgress"];
    [answerQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [answerQuery whereKey:@"questionId" equalTo:questionIds[rowNumber]];
    for (PFObject *a in self.currentAnswers) {
        if([[a objectForKey:@"questionId"] isEqualToString:questionIds[rowNumber]]){
            answerNow = [a objectForKey:@"answer"];
            
        }
    }
 
    if ([[segue identifier] isEqualToString:@"text"]) {
        XYZdetailQuestionTableViewController *questionVC = segue.destinationViewController;
        questionVC.question = currentQuestions[rowNumber];
        questionVC.questionId = questionIds[rowNumber];
        questionVC.questionIndex = [NSString stringWithFormat:@"%d",(int)rowNumber+1];
        questionVC.prevAnswer = answerNow;

    }
    if ([[segue identifier] isEqualToString:@"rate"]) {
        XYZrateViewController *questionVC = segue.destinationViewController;
        questionVC.question = currentQuestions[rowNumber];
        questionVC.questionId = questionIds[rowNumber];
        questionVC.questionIndex = [NSString stringWithFormat:@"%d",(int)rowNumber+1];
        questionVC.prevAnswer = answerNow;
        for (PFObject *q in self.questionEntries){
            NSString *i = q.objectId ;
            if ([i isEqualToString:questionIds[rowNumber]]){
                questionVC.sliderConfig = [q objectForKey:@"config"];
                break;
            }
        }

    }
    if ([[segue identifier] isEqualToString:@"multiSelect"]) {
        XYZmultiSelectTableViewController *questionVC = segue.destinationViewController;
        questionVC.question = currentQuestions[rowNumber];
        questionVC.questionId = questionIds[rowNumber];
        questionVC.questionIndex = [NSString stringWithFormat:@"%d",(int)rowNumber+1];
        for (PFObject *q in self.questionEntries){
            NSString *i = q.objectId ;
            if ([i isEqualToString:questionIds[rowNumber]]){
                questionVC.pickerData = [q objectForKey:@"config"];
                break;
            }
        }
        
    }
    if ([[segue identifier] isEqualToString:@"singleSelect"]) {
        XYZsingleSelectViewController *questionVC = segue.destinationViewController;
        questionVC.question = currentQuestions[rowNumber];
        questionVC.questionId = questionIds[rowNumber];
        questionVC.questionIndex = [NSString stringWithFormat:@"%d",(int)rowNumber+1];
        for (PFObject *q in self.questionEntries){
            NSString *i = q.objectId ;
            if ([i isEqualToString:questionIds[rowNumber]]){
                questionVC.pickerData = [q objectForKey:@"config"];
                break;
            }
        }
        questionVC.prevAnswer = answerNow;
        
    }
     */
    NSInteger rowNumber = [self.tableView indexPathForSelectedRow].row;
    if ([[segue identifier] isEqualToString:@"text"]) {
        XYZdetailQuestionTableViewController *questionVC = segue.destinationViewController;
        questionVC.question = [self.questionEntries[rowNumber] objectForKey:@"Question"];
        questionVC.questionId = [self.questionEntries[rowNumber] objectId];
        questionVC.questionIndex = [NSString stringWithFormat:@"%d",(int)rowNumber+1];
    }
    if ([[segue identifier] isEqualToString:@"rate"]) {
        XYZrateViewController *questionVC = segue.destinationViewController;
        questionVC.question = [self.questionEntries[rowNumber] objectForKey:@"Question"];
        questionVC.questionId = [self.questionEntries[rowNumber] objectId];
        questionVC.questionIndex = [NSString stringWithFormat:@"%d",(int)rowNumber+1];
        questionVC.sliderConfig = [self.questionEntries[rowNumber] objectForKey:@"config"];
        
    }
    if ([[segue identifier] isEqualToString:@"multiSelect"]) {
        XYZmultiSelectTableViewController *questionVC = segue.destinationViewController;
        questionVC.question = [self.questionEntries[rowNumber] objectForKey:@"Question"];
        questionVC.questionId = [self.questionEntries[rowNumber] objectId];
        questionVC.questionIndex = [NSString stringWithFormat:@"%d",(int)rowNumber+1];
        questionVC.pickerData = [self.questionEntries[rowNumber] objectForKey:@"config"];
        
    }
    if ([[segue identifier] isEqualToString:@"singleSelect"]) {
        XYZsingleSelectViewController *questionVC = segue.destinationViewController;
        questionVC.question = [self.questionEntries[rowNumber] objectForKey:@"Question"];
        questionVC.questionId = [self.questionEntries[rowNumber] objectId];
        questionVC.questionIndex = [NSString stringWithFormat:@"%d",(int)rowNumber+1];
        questionVC.pickerData = [self.questionEntries[rowNumber] objectForKey:@"config"];
        
    }

}


@end
