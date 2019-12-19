#include "user_contacts.h"
#include "iostream"



static char ALPHA_TABLE[27] = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','#'};

Contact::Contact():
_favorited(false),
_is_voip(false)
{
    
}

ContactGroup::ContactGroup()
{
    
}

ContactGroup::ContactGroup(ConatctList& list)
{
    _cc_list = list;
}

int ContactGroup::add_contact(Contact *cc){
    _cc_list.push_back(*cc);
    return  (int)_cc_list.size();
}

int ContactGroup::contacts_size(){
    return (int)_cc_list.size();
}

Contact& ContactGroup::contacts_at_index(int idx){
    return _cc_list.at(idx);
}

void ContactGroup::remove_all_contacts(){
    _cc_list.clear();
}

bool contact_list_sort(const Contact & c1, const Contact & c2)
{
    return (c2.pinyin().compare(c1.pinyin())>0);
}

void ContactGroup::sort(){
    std::sort(_cc_list.begin(),_cc_list.end(),contact_list_sort);
}


ContactManager::ContactManager():
_filter(0),
_do_search(false)
{
    
}

void ContactManager::add_contact(Contact cc){
    cc.set_id((int)_all_cc_list.size());
    _all_cc_list.push_back(cc);
}

void ContactManager::replace_contact_at_index(int index, Contact cc)
{
    cc.set_id(index);
    _all_cc_list.erase(_all_cc_list.begin() + index);
    _all_cc_list.insert(_all_cc_list.begin() + index, cc);
}

int ContactManager::group_size(){
    if(_filter || _do_search)
        return 1;
    else
        return (int)_cc_group_list.size();
}

ContactGroup& ContactManager::group_search()
{
    return _search_list;
}

bool ContactManager::number_in_voip_contact_list(std::string& number){
  
    for(int i=0; i<_voip_list.contacts_size(); i++){
        Contact cc = _voip_list.contacts_at_index(i);
        if(cc.has_number(number)){
            return true;
        }
    }
    return false;
}

int ContactManager::add_voip_contact(Contact contact)
{
    _voip_list.add_contact(&contact);
    return 1;
}

ContactGroup& ContactManager::group_at_index(int idx){
    if (_do_search) {
        return _contacts_search_list;
    }
    if (_filter == SEARCH_FILTER_VOIP) {
        return _voip_list;
    }
    else if(_filter == SEARCH_FILTER_FAVORITED)
        return _contacts_search_list;
    else
        return _cc_group_list.at(idx);
}


int ContactManager::get_group_index_by_title(std::string title){
    int i = 0;
    
    for( std::vector<ContactGroup>::iterator itr = _cc_group_list.begin(); itr != _cc_group_list.end(); itr++ ){
        
        if(title == itr->group_name())
            return i;
        
        i++;
    }
    return -1;
}

int ContactManager::all_contacts_size(){
    return (int)_all_cc_list.size();
}

Contact& ContactManager::all_contacts_at_index(int idx){
    return _all_cc_list.at(idx);
}

Contact* ContactManager::find_contact_by_id(int id){
    
    for( std::vector<Contact>::iterator itr = _all_cc_list.begin(); itr != _all_cc_list.end(); itr++ ){
         if(itr->get_id()==id)
             return &(*itr);
    } 
    
   return NULL;
}


int ContactManager::build_group_list(){
    int i;
    
    if(group_size()>0)
        _cc_group_list.clear();
    
    if(_filter == SEARCH_FILTER_FAVORITED){
        
        _contacts_search_list.remove_all_contacts();
        
//        for( std::vector<Contact>::iterator itr = _all_cc_list.begin(); itr != _all_cc_list.end(); itr++ ){
//            if(_filter > 0){
//                
//                if(itr->is_favorited()){
//                    _contacts_search_list.add_contact(&(*itr));
//                }
//            }
//        }
        for (int i = 0; i < _voip_list.contacts_size(); i++) {
            Contact contact = _voip_list.contacts_at_index(i);
            if (contact.is_favorited()) {
                _contacts_search_list.add_contact(&contact);
            }
        }
        _contacts_search_list.sort();
        _contacts_search_list.set_group_name("filter_favorited");
        return _contacts_search_list.contacts_size();
        
    }
    else if(_filter == SEARCH_FILTER_VOIP){
        
//        _contacts_search_list.remove_all_contacts();
//        
//        for( std::vector<Contact>::iterator itr = _all_cc_list.begin(); itr != _all_cc_list.end(); itr++ ){
//            if(_filter > 0){
//                
//                if(itr->is_voip()){
//                    _contacts_search_list.add_contact(&(*itr));
//                }
//            }
//        }
//        _contacts_search_list.sort();
//        _contacts_search_list.set_group_name("filter_voip");
//        return _contacts_search_list.contacts_size();
        return _voip_list.contacts_size();
    }
    else{
        for (i=0; i<27; i++) {
            
            char first_letter = ALPHA_TABLE[i];
            std::string title= std::string(1,first_letter);
            int idx = get_group_index_by_title(title);
            bool is_new_grp=false;
            
            ContactGroup *group;
            
            if(idx!=-1){
                group = &group_at_index(idx);
            }else{
                group = new ContactGroup();
                group->set_group_name(title);
                is_new_grp = true;
            }
            
            group->remove_all_contacts();
            
            for( std::vector<Contact>::iterator itr = _all_cc_list.begin(); itr != _all_cc_list.end(); itr++ ){
                if(_filter > 0){
                    
                    if((_filter & SEARCH_FILTER_VOIP) && itr->pinyin().c_str()[0] == first_letter && itr->is_voip() ){
                        group->add_contact(&(*itr));
                    }
                }else {
                    if(itr->pinyin().c_str()[0] == first_letter){
                        group->add_contact(&(*itr));
                    }
                }
            }
            
            if(group->contacts_size()>0){
                group->sort();
                _cc_group_list.push_back(*group);
            }else{
                if(is_new_grp) delete group;
            }
            
        }

    }
    
    return (int)_cc_group_list.size();
}

bool ContactManager::do_filter(int filter){
    _filter = filter;
    return (build_group_list()>0);
}

static bool do_contact_search(Contact& cc, std::string num_or_name){
    
    if(cc.name().find(num_or_name)!=std::string::npos)
    {
        return true; 
    }
    else
    {
        for (int i = 0; i < cc.phones().size(); i++) {
            std::string phone = cc.phones()[i];
            if (phone.find(num_or_name) != std::string::npos) {
                return true;
            }
        }
    }
    std::transform(num_or_name.begin(), num_or_name.end(), num_or_name.begin(), ::toupper);
    if (cc.pinyin().find(num_or_name)!=std::string::npos) {
        return true;
    }
    return false;
}

std::string ContactManager::do_phone_search(std::string num)
{
    for( std::vector<Contact>::iterator itr = _all_cc_list.begin(); itr != _all_cc_list.end(); itr++ ){
        for (int i = 0; i < ((*itr).phones()).size(); i++) {
            std::string phone = ((*itr).phones())[i];
            if (phone.compare(num) == 0) {
                return (*itr).name();
            }
        }
    }
    return "Unknown";
}

std::string ContactManager::do_pinyin_search(std::string num)
{
    for( std::vector<Contact>::iterator itr = _all_cc_list.begin(); itr != _all_cc_list.end(); itr++ ){
        for (int i = 0; i < ((*itr).phones()).size(); i++) {
            std::string phone = ((*itr).phones())[i];
            if (phone.compare(num) == 0) {
                return (*itr).pinyin();
            }
        }
    }
    return "Unknown";
}

bool ContactManager::do_search(bool do_search, std::string num_or_name){
    _do_search = do_search;
    
    if(_do_search){
        _contacts_search_list.remove_all_contacts();
        
        for( std::vector<Contact>::iterator itr = _all_cc_list.begin(); itr != _all_cc_list.end(); itr++ ){
            if(_filter > 0){
                
                /*查询voip好友*/
                
                if(_filter & SEARCH_FILTER_VOIP){
                    if(itr->is_voip() && do_contact_search(*itr,num_or_name))
                        _contacts_search_list.add_contact(&(*itr));
                }
                else if (_filter & SEARCH_FILTER_FAVORITED) {
                    if(itr->is_favorited() && do_contact_search(*itr,num_or_name))
                        _contacts_search_list.add_contact(&(*itr));
                }
            }else{
                if(do_contact_search(*itr,num_or_name))
                    _contacts_search_list.add_contact(&(*itr));
            }
        }
        _contacts_search_list.sort();
        return _contacts_search_list.contacts_size();
    }else{
        build_group_list();
    }
 
    return false;
}

Contact* ContactManager::do_search(std::string phonenum)
{
    for( std::vector<Contact>::iterator itr = _all_cc_list.begin(); itr != _all_cc_list.end(); itr++ )
    {
        Contact* contact = &(*itr);
        std::vector<std::string> phones = contact->phones();
        for (int j = 0; j < phones.size(); j++) {
            std::string phone = phones[j];
            if (phone.compare(phonenum) == 0) {
                return &(*itr);
            }
        }
    }
#if 0
    Contact *contact = new Contact();
    contact->set_name("Unknown");
    contact->set_address_id(-1);
#endif
    return NULL;
}

Contact* ContactManager::do_origin_search(std::string phonenum) {
    return NULL;
}

void ContactManager::remove_all_contacts(){
    _contacts_search_list.remove_all_contacts();
    _all_cc_list.clear();
    _cc_group_list.clear();
}

void ContactManager::remove_all_voip_contacts()
{
    _voip_list.remove_all_contacts();
}

