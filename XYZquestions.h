//
//  XYZquestions.h
//  wellness survey app
//
//  Created by Cindy Wang on 9/19/14.
//  Copyright (c) 2014 xinyi wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XYZquestion.h"

@class XYZquestion;

@interface XYZquestions : NSObject
-(NSInteger) count;
-(XYZquestion *)objectAtIndexedSubscript: (NSUInteger) questionNumber;
@end
