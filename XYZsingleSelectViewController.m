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


@end

@implementation XYZsingleSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
   self.picker.dataSource = self;
   self.picker.delegate = self;
    self.questionShow.text = self.question;

}

- (IBAction)saveAnswer:(UIButton *)sender {
    NSInteger row = [self.picker selectedRowInComponent:0];
    NSString *answer = [self.pickerData objectAtIndex:row];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int)numberOfComponentsInPickerView: (UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
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
