
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ContactsTableViewController : UITableViewController <ABNewPersonViewControllerDelegate>
{
    NSInteger filter;
    NSInteger selectType;
    bool do_filter;
    BOOL searching;
    BOOL peopleLoaded;
}

-(void)reloadAllContacts;

+(ContactsTableViewController *) instance;

@end
