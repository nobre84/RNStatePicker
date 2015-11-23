//  Created by Dmitry Shmidt on 5/11/13.
//  Copyright (c) 2013 Shmidt Lab. All rights reserved.
//  mail@shmidtlab.com

#import <UIKit/UIKit.h>

@protocol RNState <NSObject>

@property (nonatomic, strong) NSString *stateName;
@property (nonatomic, strong) NSString *stateCode;
@property (nonatomic, strong) NSString *stateAssetPath;

@end

@interface RNState : NSObject<RNState>

@end

@interface RNStatePickerViewController : UITableViewController

@property (nonatomic, copy) void (^completionBlock)(id<RNState> state, UIImage *flag);

- (instancetype)initWithCountry:(NSString*)countryCode andStates:(NSArray*)states customBundle:(NSBundle*)bundle;

@end