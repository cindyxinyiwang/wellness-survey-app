//
//  XYZquestionListTableViewController.m
//  wellness survey app
//
//  Created by Cindy Wang on 1/15/15.
//  Copyright (c) 2015 xinyi wang. All rights reserved.
//

#import "XYZquestionListTableViewController.h"
#import "XYZpromptTableViewCell.h"
#import "XYZquestionTableViewCell.h"
#import "XYZsliderTableViewCell.h"
#import "XYZswitchTableViewCell.h"
#import "XYZselectTableViewCell.h"


@interface XYZquestionListTableViewController ()

@property (strong, nonatomic) NSArray *questionEntries;
@property (strong, nonatomic) NSMutableArray *userAnswers;

@property (strong, nonatomic) NSMutableDictionary *questionAnswerPairs;

// keep track which indexPath points to the cell with UIDatePicker
@property (nonatomic, strong) NSIndexPath *inlineCellIndexPath;

@end

@implementation XYZquestionListTableViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //setup auto row height
    self.tableView.estimatedRowHeight = 70.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    PFQuery *query = [PFQuery queryWithClassName:@"SurveyQuestion"];
    [query whereKey:@"type" equalTo:[self.type objectForKey:@"typeName"]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            
        } else {
            self.questionEntries = objects;
            
            
            [self.tableView reloadData];
        }
    }];
    
    
    //notification center for receiving questionAnswerPair updates
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(triggerAction:) name:@"NotificationMessageEvent" object:nil];
    
    }


#pragma mark - Notification
-(void) triggerAction:(NSNotification *) notification
{
    if ([notification.object isKindOfClass:[NSString class]])
    {
        NSString *message = [notification object];
        // update corresponding question entry and save answer to dictionary
        /* NSIndexPath *questionTableIndex = [NSIndexPath indexPathForRow:self.inlineCellIndexPath.row - 1 inSection:0];
        XYZquestionTableViewCell *questionCell = [self.tableView cellForRowAtIndexPath:questionTableIndex];
        questionCell.answer.text = message; */
        
        NSInteger questionEntryIndex = self.inlineCellIndexPath.row - 2;
        [self.questionAnswerPairs setValue:message forKey:[NSString stringWithFormat:@"%ld", (long)questionEntryIndex]];
        
        [self.tableView reloadData];
        
        
    }
    else
    {
        NSLog(@"Error, object not recognised.");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*! Determines if the UITableViewController has a UIDatePicker in any of its cells.
 */
- (BOOL)hasInlineCell
{
    return (self.inlineCellIndexPath != nil);
}

/*! Determines if the given indexPath points to a cell that was initially hidden.
 
 @param indexPath The indexPath to check if it represents a cell was initially hidden.
 */
- (BOOL)indexPathWasHidden:(NSIndexPath *)indexPath
{
    return ([self hasInlineCell] && self.inlineCellIndexPath.row == indexPath.row);
}

/*! Determines if the given indexPath points to a question cell.
 
 @param indexPath The indexPath to check if it represents question cell.
 */
- (BOOL)indexPathIsQuestion:(NSIndexPath *)indexPath
{
    BOOL isQuestion = YES;
   
    if (indexPath.row == 0 || indexPath.row == self.inlineCellIndexPath.row) {
        isQuestion = NO;
    }
    
    return isQuestion;
}

/*! Determines the question entry of a indexPath that points to a inline cell.
 
 @param indexPath The indexPath of the inline cell to be checked.
 */
- (NSInteger) hiddenCellQuestionIndexAtIndexPath: (NSIndexPath *) indexPath {
    NSInteger questionIndex = indexPath.row - 2;    // the index of the question corresponds to this hidden cell
    return questionIndex;
    
}

#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if ([self hasInlineCell])
    {
        // we have a date picker, so allow for it in the number of rows in this section
        NSInteger numRows = self.questionEntries.count + 1;
        return ++numRows;
    }
    
    return self.questionEntries.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0){
        //configure the prompt cell
        XYZpromptTableViewCell *promptCell = [tableView dequeueReusableCellWithIdentifier:@"promptCell" ];
        promptCell.prompt.text =  [self.type objectForKey:@"prompt"];
        
        return promptCell;
        
    } else if ([self indexPathWasHidden: indexPath]) {
        //configure hidden cell
        NSInteger questionIndex = [self hiddenCellQuestionIndexAtIndexPath:indexPath];
        PFObject *questionEntry = [self.questionEntries objectAtIndex:questionIndex];
        
        NSString *cellId = [questionEntry objectForKey:@"answerType"];
        if ([cellId isEqualToString:@"rate"]) {
            XYZsliderTableViewCell *sliderCell = [self.tableView dequeueReusableCellWithIdentifier:@"sliderCell"];
            
            return sliderCell;
        } else if ([cellId isEqualToString:@"singleSelect"]) {
            XYZselectTableViewCell *selectCell = [self.tableView dequeueReusableCellWithIdentifier:@"selectCell"];
            
        
            selectCell.myPicker = [[UIPickerView alloc] init];
            selectCell.pickerData = [questionEntry objectForKey:@"config"];

            return selectCell;
            
        } else {
            XYZswitchTableViewCell *switchCell = [self.tableView dequeueReusableCellWithIdentifier:@"switchCell"];
            
            return switchCell;
            
        }
        
            
    } else {
        // if we have a inline cell open whose cell is above the cell we want to update,
        // then we have one more cell than the model allows
        //
        NSInteger modelRow = indexPath.row;
        if (self.inlineCellIndexPath != nil && self.inlineCellIndexPath.row <= indexPath.row)
        {
            modelRow--;
        }
        PFObject *questionEntry = [self.questionEntries objectAtIndex:modelRow - 1];    //question entry at current row
        //configure question cells
        XYZquestionTableViewCell *questionCell = [tableView dequeueReusableCellWithIdentifier:@"questionCell"];
        
        
        NSString *questionString = [questionEntry objectForKey:@"Question"];
        NSString *answerString = self.questionAnswerPairs[([NSString stringWithFormat:@"ld", (long)(modelRow - 1)])];
        questionCell.question.text = questionString;
        questionCell.answer.text = answerString;
        return questionCell;
        
    }

}

/*! Determines if the given indexPath has a cell below it with a UIDatePicker.
 
 @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
 */
- (BOOL)hasInlineCellForIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasInlineCell = NO;
    
    NSInteger targetedRow = indexPath.row;
    targetedRow++;
    
    UITableViewCell *checkDatePickerCell =
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:0]];
    NSIndexPath *targetedIndexPath = [NSIndexPath indexPathForRow:targetedRow inSection:0];
    
    hasInlineCell = [self indexPathWasHidden:targetedIndexPath];
    return hasInlineCell;
}

/*! Adds or removes a UIDatePicker cell below the given indexPath.
 
 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)toggleDatePickerForSelectedIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
    
    // check if 'indexPath' has an attached date picker below it
    if ([self hasInlineCellForIndexPath:indexPath])
    {
        // found a picker below it, so remove it
        [self.tableView deleteRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        // didn't find a picker below it, so we should insert it
        [self.tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
}


/*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
 
 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)displayInlineCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // display the date picker inline with the table content
    [self.tableView beginUpdates];
    
    BOOL before = NO;   // indicates if the date picker is below "indexPath", help us determine which row to reveal
    if ([self hasInlineCell])
    {
        before = self.inlineCellIndexPath.row < indexPath.row;
    }
    
    BOOL sameCellClicked = (self.inlineCellIndexPath.row - 1 == indexPath.row);
    
    // remove any date picker cell if it exists
    if ([self hasInlineCell])
    {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.inlineCellIndexPath.row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.inlineCellIndexPath = nil;
    }
    
    if (!sameCellClicked)
    {
        // hide the old date picker and display the new one
        NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:0];
        
        [self toggleDatePickerForSelectedIndexPath:indexPathToReveal];
        self.inlineCellIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:0];
    }
    
    // always deselect the row containing the start or end date
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView endUpdates];
    
    // inform our date picker of the current date to match the current cell
    //[self updateDatePicker];
}

-(IBAction)pickerAction:(id)sender {
    NSIndexPath *targetedCellIndexPath = nil;
    
    if ([self hasInlineCell])
    {
        // inline date picker: update the cell's date "above" the date picker cell
        //
        targetedCellIndexPath = [NSIndexPath indexPathForRow:self.inlineCellIndexPath.row - 1 inSection:0];
    }
    
    XYZselectTableViewCell *pickerCell = [self.tableView cellForRowAtIndexPath:self.inlineCellIndexPath];
    XYZquestionTableViewCell *questionCell = [self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
    
    UIDatePicker *targetedDatePicker = sender;
    
    // update our data model
    
    
    // update the cell's date string
    questionCell.answer.text = [pickerCell.pickerData objectAtIndex:pickerCell.selectedIndex];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([self indexPathIsQuestion:indexPath])
    {
        [self displayInlineCellForRowAtIndexPath: indexPath];
        
        /*if (EMBEDDED_DATE_PICKER)
            [self displayInlineDatePickerForRowAtIndexPath:indexPath];
        else
            [self displayExternalDatePickerForRowAtIndexPath:indexPath]; */
    }
    
}

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
