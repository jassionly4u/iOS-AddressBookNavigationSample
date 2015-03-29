//
//  JSViewController.m
//  AddressBookExample
//
//  Created by Jasvinder Singh on 29/03/15.
//  Copyright (c) 2015 Jasvinder Singh. All rights reserved.
//

#import "JSViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>

@interface JSViewController ()<ABPeoplePickerNavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *peopleSelected;

@end

@implementation JSViewController

-(NSMutableArray *)peopleSelected
{
    if (!_peopleSelected) {
        _peopleSelected = [NSMutableArray new];
    }
    
    return _peopleSelected;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    
    UIBarButtonItem *selectPerson = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleBordered target:self action:@selector(btnSelectHandler:)];
    self.navigationItem.rightBarButtonItem = selectPerson;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnSelectHandler:(id)sender
{
    ABPeoplePickerNavigationController *peoplePicker = [ABPeoplePickerNavigationController new];
    peoplePicker.peoplePickerDelegate = self;
    [self.navigationController presentViewController:peoplePicker animated:YES completion:^{
        
    }];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.peopleSelected) {
            [self.tableView reloadData];
        }
    }];
}

//Deprecated in iOS 8.0.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    NSString *name =  (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
    ABMultiValueRef phoneNumbers = (ABRecordCopyValue(person, kABPersonPhoneProperty));
    NSString *mobile = @"";
    NSString *label = @"";
    for (CFIndex i=0 ; i<ABMultiValueGetCount(phoneNumbers); i++) {
        label = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phoneNumbers, i);
        if ([label isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
            mobile = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
        }else if([label isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel]){
            mobile = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            break;
        }
    }
    
    NSDictionary *dict = @{@"name":name,
                           @"phone":mobile};
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.phone == %@ && self.name == %@",mobile,name];
    
    NSArray *personAlready = [self.peopleSelected filteredArrayUsingPredicate:predicate];
    NSLog(@"personAlready %@",personAlready);
    if (!personAlready.count) {
        [self.peopleSelected addObject:dict];
    }
    
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    
    return YES;
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.peopleSelected.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSDictionary *dict = self.peopleSelected[indexPath.row];
    cell.textLabel.text = dict[@"name"];
    return cell;
}

#pragma mark - UITableViewDelegate

@end
