//  Created by Dmitry Shmidt on 5/11/13.
//  Copyright (c) 2013 Shmidt Lab. All rights reserved.
//  mail@shmidtlab.com

#import <UIKit/UIKit.h>

@protocol RNState <NSObject>

@property (nonatomic, strong) NSString *stateName;
@property (nonatomic, strong) NSString *stateCode;
@property (nonatomic, strong) UIImage *stateImage;

@end

@interface RNState : NSObject<RNState>

+ (instancetype)stateWithCode:(NSString*)stateCode inCountry:(NSString*)countryCode;
+ (UIImage*)imageForState:(NSString*)stateCode inCountry:(NSString*)countryCode;


@end

@interface RNStatePickerViewController : UITableViewController

@property (nonatomic, copy) void (^completionBlock)(id<RNState> state);

- (instancetype)initWithCountry:(NSString*)countryCode andStates:(NSArray*)states;

@end