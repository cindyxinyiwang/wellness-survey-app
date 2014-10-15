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
#import <Parse/Parse.h>

@interface XYZsurveyListTableViewController ()
@property (strong, nonatomic) NSArray *questionEntries;
@property (strong, nonatomic) NSArray *categories;
////////////////////////
//problems:
//1. how to set up a dictionary of the data stored in Parse(given the fact that findObject is synchronized and block main thread)
//2. when one of the entries is not defined, it gives and error (could define set up at the web end)
@property (strong, nonatomic) NSMutableDictionary *typeQuestionPair;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    PFQuery *query = [PFQuery queryWithClassName:@"SurveyQuestion"];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            
        } else {
            self.questionEntries = objects;
            [self.tableView reloadData];
        }
    }];
    PFQuery *queryCategory = [PFQuery queryWithClassName:@"Category"];
    [queryCategory findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            
        } else {
            self.categories = objects;
            [self.tableView reloadData];
            

        }
    }];

    for (PFObject *q in self.categories){
        NSString *categoryName = [q objectForKey:@"type"];
        NSMutableArray *aspects = [[NSMutableArray alloc] init];
        for (PFObject *entry in self.questionEntries){
            if([[entry objectForKey:@"type"] isEqualToString:categoryName]){
                [aspects addObject:[entry objectForKey:@"aspect"]];
            }
        }
        [self.typeQuestionPair setObject:aspects forKey:categoryName];
    }

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
        // Return the number of sections.
    return [self.categories count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    PFObject *currentCategory = self.categories[section];
    NSString *header = [currentCategory objectForKey:@"type"];
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    PFObject *currentCategory = self.categories[section];
    NSString *categoryName = [currentCategory objectForKey:@"type"];
    NSInteger counter = 0;
    for (PFObject *q in self.questionEntries){
        if([[q objectForKey:@"type"] isEqualToString:categoryName]){
            counter ++;
        }
    }
    return counter;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XYZsurveyListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"questionCell" ];

    PFObject *currentCategory = self.categories[indexPath.section];
    NSString *categoryName = [currentCategory objectForKey:@"type"];
    NSMutableArray *aspects = [[NSMutableArray alloc]init];
    for (PFObject *q in self.questionEntries){
        if([[q objectForKey:@"type"] isEqualToString:categoryName]){
            [aspects addObject:[q objectForKey:@"aspect"]];
        }
    }

    cell.questionCategoryLabel.text = aspects[indexPath.row];
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
    PFObject *currentCategory = self.categories[indexPath.section];
    NSString *categoryName = [currentCategory objectForKey:@"type"];
    NSMutableArray *answerType = [[NSMutableArray alloc]init];
    for (PFObject *q in self.questionEntries){
        if([[q objectForKey:@"type"] isEqualToString:categoryName]){
            [answerType addObject:[q objectForKey:@"answerType"]];
        }
    }
    NSString *type = answerType[indexPath.row];
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
    
    NSInteger sectionNumber = [self.tableView indexPathForSelectedRow].section;
    NSInteger rowNumber = [self.tableView indexPathForSelectedRow].row;
    
    PFObject *currentCategory = self.categories[sectionNumber];
    NSString *categoryName = [currentCategory objectForKey:@"type"];
    NSMutableArray *currentQuestions = [[NSMutableArray alloc]init];
    NSMutableArray *questionIds = [[NSMutableArray alloc]init];
    for (PFObject *q in self.questionEntries){
        if([[q objectForKey:@"type"] isEqualToString:categoryName]){
            [currentQuestions addObject:[q objectForKey:@"Question"]];
            [questionIds addObject:[q objectId]];
            
        }
    }
    if ([[segue identifier] isEqualToString:@"text"]) {
        XYZdetailQuestionTableViewController *questionVC = segue.destinationViewController;
        questionVC.question = currentQuestions[rowNumber];
        questionVC.questionId = questionIds[rowNumber];
        questionVC.questionIndex = [NSString stringWithFormat:@"%d",(int)rowNumber+1];
    }
    if ([[segue identifier] isEqualToString:@"rate"]) {
        XYZrateViewController *questionVC = segue.destinationViewController;
        questionVC.question = currentQuestions[rowNumber];
        questionVC.questionId = questionIds[rowNumber];
        questionVC.questionIndex = [NSString stringWithFormat:@"%d",(int)rowNumber+1];
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
        
    }
}


@end
