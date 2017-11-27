//  Created by Dmitry Shmidt on 5/11/13.
//  Copyright (c) 2013 Shmidt Lab. All rights reserved.
//  mail@shmidtlab.com

#import "RNStatePickerViewController.h"

static NSString *CellIdentifier = @"CountryCell";
static NSString *featureIndexTitle = @"\u2605";
static NSString *statePlistName = @"states";

@implementation RNState

@synthesize stateName, stateCode, stateImage;

+ (instancetype)stateWithCode:(NSString*)stateCode inCountry:(NSString*)countryCode {
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:statePlistName ofType:@"plist"];
    NSDictionary *statesDict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    NSArray *selectedStates = statesDict[countryCode];
    if (selectedStates) {
        NSDictionary *stateDict = [[selectedStates filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"code = %@", stateCode]] firstObject];
        if (statesDict) {
            RNState *state = [RNState new];
            state.stateCode = stateDict[@"code"];
            state.stateName = stateDict[@"name"];
            state.stateImage = [[self class] imageForState:state.stateCode inCountry:countryCode];
            return state;
        }
    }
    return nil;
}

+ (UIImage*)imageForState:(NSString*)stateCode inCountry:(NSString*)countryCode {
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@_%@", countryCode, stateCode] inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

@end

@interface RNStatePickerViewController ()<UISearchDisplayDelegate, UISearchBarDelegate>
@property (nonatomic) UISearchDisplayController *searchController;
@end

@implementation RNStatePickerViewController{
    NSMutableArray *_filteredList;
    NSArray *_sections;
    NSString *_countryCode;
    NSArray *_states;
}

- (instancetype)init {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        _countryCode = @"BR";
        NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:statePlistName ofType:@"plist"];
        NSDictionary *statesDict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        NSArray *brStates = statesDict[_countryCode];
        NSMutableArray *states = [NSMutableArray new];
        [brStates enumerateObjectsUsingBlock:^(NSDictionary *stateDict, NSUInteger idx, BOOL *stop) {
            RNState *state = [RNState new];
            state.stateCode = stateDict[@"code"];
            state.stateName = stateDict[@"name"];
            state.stateImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%@", _countryCode, state.stateCode]];
            [states addObject:state];
        }];
        _states = states;
    }
    return self;
}

- (instancetype)initWithCountry:(NSString *)countryCode andStates:(NSArray<RNState> *)states {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        _countryCode = countryCode;
        _states = states;
    }
    return self;
}

- (void)createSearchBar {
        if (self.tableView && !self.tableView.tableHeaderView) {
            UISearchBar * theSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,320,40)]; // frame has no effect.
            theSearchBar.delegate = self;

            theSearchBar.showsCancelButton = YES;
            
            
            self.tableView.tableHeaderView = theSearchBar;
            
            UISearchDisplayController *searchCon = [[UISearchDisplayController alloc]
                                                    initWithSearchBar:theSearchBar
                                                    contentsController:self ];
            self.searchController = searchCon;
            _searchController.delegate = self;
            _searchController.searchResultsDataSource = self;
            _searchController.searchResultsDelegate = self;
            
//            [_searchController setActive:YES animated:YES];
            [theSearchBar becomeFirstResponder];
//            _searchController.displaysSearchBarInNavigationBar = YES;
        }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createSearchBar];
    
    NSMutableArray *countriesUnsorted = [[NSMutableArray alloc] initWithCapacity:_states.count];
    _filteredList = [[NSMutableArray alloc] initWithCapacity:_states.count];
    
    for (id<RNState> state in _states) {
        
        [countriesUnsorted addObject:state];
        
    }
    _sections = [self partitionObjects:countriesUnsorted collationStringSelector:@selector(self)];

    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(preferredContentSizeChanged:)
     name:UIContentSizeCategoryDidChangeNotification
     object:nil];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

#pragma mark - Table view data source
-(NSArray *)partitionObjects:(NSArray *)states collationStringSelector:(SEL)selector
{
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    NSInteger sectionCount = [[collation sectionTitles] count];
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    for (int i = 0; i < sectionCount; i++) {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    
    for (id<RNState> state in states) {
        NSInteger index = [collation sectionForObject:state.stateName collationStringSelector:selector];
        [[unsortedSections objectAtIndex:index] addObject:state];
    }
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"stateName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    
    for (NSMutableArray *section in unsortedSections) {
        NSArray *sortedArray = [section sortedArrayUsingDescriptors:sortDescriptors];
        [sections addObject:sortedArray];
    }
    
    return sections;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSArray *localizedIndexTitles = [UILocalizedIndexedCollation.currentCollation sectionIndexTitles];
    return localizedIndexTitles;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return 1;
    }
    if (!_sections) return 0;
    //we use sectionTitles and not sections
    NSInteger count = [[UILocalizedIndexedCollation.currentCollation sectionTitles] count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [_filteredList count];
    }

    return [_sections[section] count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    BOOL showSection = [[_sections objectAtIndex:section] count] != 0;
    //only show the section title if there are rows in the section
    NSString *title = (showSection) ? [[UILocalizedIndexedCollation.currentCollation sectionTitles] objectAtIndex:section] : nil;
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    id<RNState> cd = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        cd = _filteredList[indexPath.row];
        
        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:cd.stateName attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.785 alpha:1.000], NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
        [attributedTitle addAttribute:NSForegroundColorAttributeName
                                value:[UIColor blackColor]
                                range:[attributedTitle.string.lowercaseString rangeOfString:_searchController.searchBar.text.lowercaseString]];
        
        cell.textLabel.attributedText = attributedTitle;
    }
	else
	{
        cd = _sections[indexPath.section][indexPath.row];
        
        cell.textLabel.text = cd.stateName;
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }

    cell.imageView.image = cd.stateImage;
    NSLog(@"%@", cd.stateCode);
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.completionBlock) {
        id<RNState> cd = nil;
        
        if(tableView == self.searchDisplayController.searchResultsTableView) {
            cd = _filteredList[indexPath.row];
        }
        else {
            cd = _sections[indexPath.section][indexPath.row];
        }
        self.completionBlock(cd);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[_filteredList removeAllObjects];
    
    for (NSArray *section in _sections) {
        for (id<RNState> state in section)
        {
            if ([[state stateName] length] >= [searchText length]) {
                NSComparisonResult result = [state.stateName compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
                if (result == NSOrderedSame)
                {
                    [_filteredList addObject:state];
                }
            }
        }
    }
}

#pragma mark - UISearchDisplayController Delegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [self.searchDisplayController.searchBar scopeButtonTitles][[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [self.searchDisplayController.searchBar scopeButtonTitles][searchOption]];
    
    return YES;
}

#pragma mark - searchBar delegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{

}

@end
