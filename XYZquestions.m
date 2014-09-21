//
//  XYZquestions.m
//  wellness survey app
//
//  Created by Cindy Wang on 9/19/14.
//  Copyright (c) 2014 xinyi wang. All rights reserved.
//
#import "XYZquestion.h"
#import "XYZquestions.h"
#import <Parse/Parse.h>

@interface XYZquestions()
@property (copy, nonatomic) NSArray *privateListOfQuestions;
@end

@implementation XYZquestions

-(NSArray *)getObjectsFromParse{
    NSMutableArray *questionArray = [NSMutableArray array];
    // Query the question in database
    
    PFQuery *question = [PFQuery queryWithClassName:@"SurveyQuestion"];
    NSArray *questionEntries = [question findObjects];
    for (PFObject *qs in questionEntries) {
        NSString *q = [qs objectForKey:@"Question"];
        [questionArray addObject:q];
    }
    NSArray *array = [questionArray copy];
    return array;
}

- (NSArray *)privateListOfQuestions{
    if(!_privateListOfQuestions) {
        NSArray *questionArray = [self getObjectsFromParse];
        int num = [questionArray count];
        int i = 0;
        NSMutableArray *mutable = [[NSMutableArray alloc] init];
        while (i < num){
            NSString *ques = [questionArray objectAtIndex:i];
            [mutable addObject:[[XYZquestion alloc]initWithNumber:i+1 category:ques]];
            i = i + 1;
        }
        _privateListOfQuestions = [mutable copy];
    }
    return _privateListOfQuestions;
}

-(NSInteger)count {
    return [self.privateListOfQuestions count];
}

-(XYZquestion *)objectAtIndexedSubscript:(NSUInteger)questionNumber{
    return self.privateListOfQuestions[questionNumber];
}
@end
