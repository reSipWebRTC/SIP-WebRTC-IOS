//
//  ContactsTableViewController.m
//  VideoChat
//
//  Created by DuanWeiwei on 15/1/26.
//  Copyright (c) 2015年 DuanWeiwei. All rights reserved.
//

#import "ContactsTableViewController.h"
#import "ContactDetailViewController.h"
#import "ContactsCell.h"
#import "CommonTypes.h"
#import "UserContactUtil.h"
#import "UIImage+ARDUtilities.h"

static ContactsTableViewController *the_instance_ = nil;

@interface ContactsTableViewController ()

@end

@implementation ContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageForName:@"add_buddy.png" color:buttonBlueColor]
                      forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addContact)
     forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 22, 22);
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = menuButton;
    
    [self reloadAllContacts];
    
    the_instance_ = self;
}

+(ContactsTableViewController *) instance
{
    return the_instance_;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)addContact
{

    ABNewPersonViewController *npvc = [[ABNewPersonViewController alloc] init] ;
    CFErrorRef error = NULL;
    ABRecordRef people = ABPersonCreate();
    ABMutableMultiValueRef mutiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    //ABMultiValueIdentifier outIdentifier = 0;
    //ABMultiValueAddValueAndLabel(mutiPhone,(__bridge CFTypeRef)phoneNum,kABPersonPhoneMainLabel, &outIdentifier);
    ABRecordSetValue(people, kABPersonPhoneProperty, mutiPhone, &error);
    CFRelease(mutiPhone);
    if (!error) {
        npvc.displayedPerson = people;
    }
    CFRelease(people);
    
    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:npvc];
    npvc.newPersonViewDelegate = self;
    [self presentModalViewController:controller animated:YES];
}


#pragma mark NEW PERSON DELEGATE METHODS
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
    if (person)
    {
        [[ContactManagerUtil instance] readAllPeoples];
        [self dismissModalViewControllerAnimated:YES];
        [self reloadAllContacts];
    }else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

-(void)reloadAllContacts
{
    [[ContactManagerUtil instance] getContactManager].do_filter(do_filter);
    if([[ContactManagerUtil instance] peopleCount] == 0)
        [[ContactManagerUtil instance] readAllPeoples];
    
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    {
        if ([[ContactManagerUtil instance] getContactManager].all_contacts_size() > 0) {
            if (do_filter) {
                return 1;
            }
            else
            {
                return [[ContactManagerUtil instance] getContactManager].group_size();
            }
        }
        return 0;
    }
}


- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView
{
   {
        if (searching || do_filter) {
            return nil;
        }
        NSMutableArray *indices = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
        NSInteger cc_grp_size = [[ContactManagerUtil instance] getContactManager].group_size();
        
        for (int i = 0; i < cc_grp_size; i++)
        {
            ContactGroup cc_grp = [[ContactManagerUtil instance] getContactManager].group_at_index(i);
            
            [indices addObject:[NSString stringWithFormat:@"%s", cc_grp.group_name().c_str()]];
        }
        return indices;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //if (tableView == sourceTableView) {
        if ([[ContactManagerUtil instance] getContactManager].all_contacts_size() > 0)
        {
            //IVLog(@"Number Count: %d, group = %s", [[ContactManagerUtil instance] getContactManager].group_at_index(section).contacts_size(),[[ContactManagerUtil instance] getContactManager].group_at_index(section).group_name().c_str());
            
            if (do_filter) {
                return [[ContactManagerUtil instance] getContactManager].group_at_index((int)section).contacts_size();
            }
            return [[ContactManagerUtil instance] getContactManager].group_at_index((int)section).contacts_size();
        }
        return 0;
    //}
    //else {
    //    return [[ContactManagerUtil instance] getContactManager].group_at_index(0).contacts_size();
    //}
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    //if (tableView == sourceTableView && !do_filter)
    {
        if ([[ContactManagerUtil instance] getContactManager].all_contacts_size() > 0) {
            return [[ContactManagerUtil instance] getContactManager].get_group_index_by_title([title cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if (!do_filter && [[ContactManagerUtil instance] getContactManager].all_contacts_size() > 0) {
        ContactGroup grp = [[ContactManagerUtil instance] getContactManager].group_at_index((int)section);
        return [NSString stringWithFormat:@"%s", grp.group_name().c_str()];
    }
    return nil;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if (tableView == sourceTableView)
    {
        static NSString* identifier = @"ContactsCell";
        ContactsCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            NSArray* array = [[UINib nibWithNibName:@"ContactsCell" bundle:nil] instantiateWithOwner:self options:nil];
            cell = [array lastObject];
            [cell initSubviews];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
        // IVLog(@"number in cell:%d", [[ContactManagerUtil instance] getContactManager].group_at_index(indexPath.section).contacts_size());
        Contact& cc = [[ContactManagerUtil instance] getContactManager].group_at_index((int)indexPath.section).contacts_at_index((int)indexPath.row);
        cc.set_voip(YES);
        CGRect bounds = self.view.bounds;
        float MaxX = CGRectGetMaxX(bounds);
        cell.frame = CGRectMake(0,0,MaxX, kContactsCellHeight);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell setUserInfo:&cc];
#if 0
        if (cc.is_voip()) {
            if (&cc.signature() && cc.signature().length() > 0) {
                [cell setSignature:[NSString stringWithCString:cc.signature().c_str() encoding:NSUTF8StringEncoding]];
            }
            else {
                [cell setSignature:NSLocalizedString(@"I'm on BeeChat!", @"")];
            }
        }
        else {
            [cell setSignature:nil];
        }
#endif
#if 0
        if (cc.is_voip()) {
            if (filter == SEARCH_FILTER_ALL) {
                for (int i = 0; i < cc.phones().size(); i++) {
                    NSString* phone = [NSString stringWithCString:cc.phones()[i].c_str() encoding:[NSString defaultCStringEncoding]];

                    if (UserLoadState* state = [self.accountStateDic valueForKey:phone]) {
                        if (state.loadState == 1) {
                            [self getFriendUserInfo:phone];
                        }
                    }

                }
            }
            else {
                NSString* phone = [NSString stringWithCString:cc.phone().c_str() encoding:[NSString defaultCStringEncoding]];

                if (UserLoadState* state = [self.accountStateDic valueForKey:phone]) {
                    if (state.loadState == 1) {
                        [self getFriendUserInfo:phone];
                    }
                }
            }
        }
       [cell setEnableBeechatIconClick:YES];
#endif
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kContactsCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactDetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ContactDetailViewController"];
    ContactGroup& group = [[ContactManagerUtil instance] getContactManager].group_at_index((int)indexPath.section);
    Contact* contact= &group.contacts_at_index((int)indexPath.row);
    controller.contact = contact;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    //离开设置界面时保存设置
    [self reloadAllContacts];
    [self.tableView reloadData];
}

@end
