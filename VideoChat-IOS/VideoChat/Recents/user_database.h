#ifndef USER_DATABASE_H
#define USER_DATABASE_H

struct user_data;
typedef struct user_data user_data_t;

class FriendDatabase;
class CdrDatabase;
class ChatDatabase;


class UserDataBase
{
public:
	UserDataBase();
	~UserDataBase();

public:
	static UserDataBase* get_instance();

public:/*打开数据库*/
	int open_db(const char *db_name);
	int close_db();
	bool db_is_open();


	user_data_t *get_db(){
		return db_ptr_;
	}

	FriendDatabase *GetFriendDatabase() {
		return fr_db_;
	}

	CdrDatabase *GetCdrDatabase(){
		return cdr_db_;
	}

	ChatDatabase *GetChatDatabase(){
		return chat_db_;
	}

private:
	user_data_t *db_ptr_;
	FriendDatabase *fr_db_;
	CdrDatabase *cdr_db_;
	ChatDatabase *chat_db_;
    
    int get_db_version();
    bool set_db_version(int version);
};

#endif
