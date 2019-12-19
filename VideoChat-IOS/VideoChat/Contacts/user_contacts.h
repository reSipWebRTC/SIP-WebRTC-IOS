
#ifndef user_contacts_cpp_h
#define user_contacts_cpp_h

#include <vector>
#include <string>

#define kGroupFavourate     "filter_favourate"
#define kGroupVoip          "filter_voip"
        
#define SEARCH_FILTER_ALL (0)
#define SEARCH_FILTER_VOIP (1)
#define SEARCH_FILTER_FAVORITED (1<<1)

typedef struct phone_info_t
{
    std::string phonenum;
    std::string type;
}phone_info;

    class Contact{
    public:
        Contact();
        Contact(std::string name, std::string num, std::string pinyin, bool favorited, bool is_voip){
            _name=name;
            _num=num;
            _pinyin=pinyin;
            _favorited = favorited;
            _is_voip = is_voip;
        };
        ~Contact(){};
        
        const std::string& displayname() const {return _display_name;};
        const std::string& name() const { return _name;};
        const std::string& phone() const { return _num;};
        const std::string& pinyin() const { return _pinyin;};
        const std::vector<std::string> &types() const {return _phone_types;};
        const std::vector<std::string> &phones() const {return _phones;};
        const std::vector<std::string> &originphones() const {return _origin_phones;};
        const std::vector<phone_info> &phoneInfo() const {return _phones_info;};
        const std::string & get_origin(std::string phonenum) const 
        {
            for (int i = 0; i < _phones.size(); i++) {
                std::string phone = _phones[i];
                if (phone.compare(phonenum) == 0) {
                    return _origin_phones[i];
                }
            }
            return *(new std::string(phonenum));
        };
        const std::string& get_type(std::string phonenum) const
        {
            for (int i = 0; i < _phones.size(); i++) {
                std::string phone = _phones[i];
                if (phone.compare(phonenum) == 0) {
                    return _phone_types[i];
                }
            }
            return *(new std::string("Mobile"));
        }
        bool has_number(std::string phonenum){
            for (int i = 0; i < _phones.size(); i++) {
                std::string phone = _phones[i];
                if (phone.compare(phonenum) == 0) {
                    return true;
                }
            }
            return false;
        };
        const std::string& signature() const {return _signature;};
        unsigned char* image_data() {return _image_data;};
        bool has_image(){return _hasimage;};
        bool is_favorited(){return _favorited;};
        bool is_voip(){return _is_voip;};
        int addressId(){return _addressbook_record_id;};
        
        void set_display_name(std::string displayname){_display_name = displayname;};
        void set_name(std::string name){ _name=name; };
        void set_phone(std::string phone){ _num=phone; };
        void set_phones(std::string phone){_phones.push_back(phone);};
        void set_origin_phones(std::string phone){_origin_phones.push_back(phone);};
        void set_types(std::string types){_phone_types.push_back(types);};
        void set_phone_info(phone_info phoneInfo){_phones_info.push_back(phoneInfo);};
        void set_pinyin(std::string pinyin){ _pinyin=pinyin; };
        void set_favorited(bool yesno){ _favorited=yesno; };
        void set_voip(bool yesno){ _is_voip=yesno; };
        void set_has_image(bool yesno){_hasimage = yesno;};
        void set_signature(std::string signature){_signature = signature;};
        void set_image_data(unsigned char* imagedata){_image_data = imagedata;};
        void set_image_length(int length){_image_length = length;};
        void remove_all_phones(){_phones.clear();};
        void set_id(int id){_id=id;};
        int get_id(){return _id;};
        
        void set_address_id(int _id){_addressbook_record_id = _id;};
        int get_address_id(){return _addressbook_record_id;};
        int get_image_length(){return _image_length;};
        
    private:
        std::string _name;
        std::string _display_name;
        std::string _num;
        std::string _pinyin;
        std::vector<std::string> _phones;
        std::vector<std::string> _origin_phones;
        std::vector<std::string> _phone_types;
        std::vector<phone_info> _phones_info;
        std::string _signature;
        bool _hasimage;
        unsigned char* _image_data;
        bool _favorited;
        bool _is_voip;
        int _id;
        int _addressbook_record_id;
        int _image_length;
    };
    
    typedef std::vector<Contact> ConatctList;
    
    
    class ContactGroup{
    public:
        ContactGroup();
        ContactGroup(ConatctList& list);
        ~ContactGroup(){};
        
        std::string group_name(){ return _name;};
        void set_group_name(std::string name){ _name=name; };
        int add_contact(Contact *cc);
        
        int contacts_size();
        Contact& contacts_at_index(int index);
        
        void remove_all_contacts();
        void sort();
    private:
        std::string _name;
        ConatctList _cc_list;
    };

    typedef std::vector<ContactGroup> ContactGroupList;
    
    class ContactManager{
    public:
        ContactManager();
        ~ContactManager(){};
        
        void remove_all_contacts();
        void remove_all_voip_contacts();
        void add_contact(Contact cc);
        void replace_contact_at_index(int index, Contact cc);
        
        
        int group_size();
        ContactGroup& group_at_index(int idx);
        int get_group_index_by_title(std::string title);
        
        int all_contacts_size();
        Contact& all_contacts_at_index(int idx);
        Contact* find_contact_by_id(int id);
        
        ContactGroup& group_search();
        ContactGroup& voip_group(){return _voip_list;};
        int add_voip_contact(Contact contact);
        bool number_in_voip_contact_list(std::string& number);
        int build_group_list();
        bool do_filter(int filter);

        bool do_search(bool do_search, std::string num_or_nam);
        
        std::string do_phone_search(std::string num);
        std::string do_pinyin_search(std::string num);
        
        Contact* do_search(std::string phonenum);
        Contact* do_origin_search(std::string phonenum);
        Contact& get_result(){return _result_contact;};

    private:
        ContactGroupList _cc_group_list;
        ConatctList _all_cc_list;
        ContactGroup _contacts_search_list;
        ContactGroup _search_list;
        ContactGroup _voip_list;
        int _filter;
        bool _do_search;
        Contact _result_contact;
    };

#endif
