//
//  XYZsurveyListTableViewController.m
//  wellness survey app
//
//  Created by Cindy Wang on 9/17/14.
//  Copyright (c) 2014 xinyi wang. All rights reserved.
//

#import "XYZsurveyListTableViewController.h"
#import "XYZquestionListTableViewController.h"
/*
#import "XYZsurveyListTableViewCell.h"
#import "XYZdetailQuestionTableViewController.h"
#import "XYZsingleSelectViewController.h"
#import "XYZmultiSelectTableViewController.h"
#import "XYZrateViewController.h"
#import "XYZtimeTableViewCell.h"
 */
#import "XYZtypeTableViewCell.h"
#import <Parse/Parse.h>

@interface XYZsurveyListTableViewController ()
@property (strong, nonatomic) NSArray *typeEntries;
@property (strong, nonatomic) PFObject *selectedType;   //type entry selected by clicking

/*
@property (strong, nonatomic) NSMutableArray *questionEntries;
@property (strong, nonatomic) NSArray *currentAnswers;
//index of questionEntries that needs to be deleted
//@property (nonatomic) NSInteger deleteQuesIndex;

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
    
    PFQuery *query = [PFQuery queryWithClassName:@"Type"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            
        } else {
            self.typeEntries = objects;
            [self.tableView reloadData];
        }
    }];
    /*
    //add notification for row delete
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setDeleteEntry:) name:@"DeleteNotification" object:nil]; */
    }

/*
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
*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.tableView reloadData];
    
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

    NSInteger counter = 0;
    counter = [self.typeEntries count];
    return counter;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XYZtypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"typeCell" ];
    PFObject *typeEntry = self.typeEntries[indexPath.row];
    cell.typeLabel.text = [typeEntry objectForKey:@"typeName"];
    
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
    self.selectedType = [self.typeEntries objectAtIndex:indexPath.row];
    if (self.selectedType != nil) {
        [self performSegueWithIdentifier:@"toQuestionList" sender:self];
    } else {
        //error! could not retrieve type entry
        
    }
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toQuestionList"]) {
        XYZquestionListTableViewController *questionVC = segue.destinationViewController;
        questionVC.type = self.selectedType;
    }
}


@end
