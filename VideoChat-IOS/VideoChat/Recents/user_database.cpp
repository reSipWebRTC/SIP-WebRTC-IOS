#include "user_database.h"
#include "private.h"

using namespace std;

UserDataBase::UserDataBase():
fr_db_(NULL),
cdr_db_(NULL),
chat_db_(NULL)
{
	db_ptr_ = new user_data_t;
}

UserDataBase::~UserDataBase()
{
	close_db();
	delete db_ptr_;
}

int UserDataBase::get_db_version()
{
    char szQuery[1024];
	
    int versio_num=-1;
    
	if(!db_ptr_->sql_db.db_is_open())
		return -1;
    
	snprintf(szQuery,sizeof(szQuery),"SELECT version FROM version WHERE table_name='all';");
    
	CppSQLite3Query q = db_ptr_->sql_db.execQuery(szQuery);
    
	while(!q.eof()){
		versio_num = q.getIntField(0);
		q.nextRow();
	}
 
	return versio_num;
}

bool UserDataBase::set_db_version(int version)
{
    char szQuery[1024];
	
    int versio_num=0;
    
	if(!db_ptr_->sql_db.db_is_open())
		return false;
    
    snprintf(szQuery,sizeof(szQuery),
             "UPDATE version SET version='%d' WHERE table_name='all';",version);
    
    if(db_ptr_->sql_db.execDML(szQuery) >= SQLITE_OK){
        return true;
    }
    
    return false;
}


int UserDataBase::open_db( const char *db_name ){

	char buf[2048];
	if(!db_ptr_->sql_db.db_is_open()){
		
#ifdef WIN32
		memset(buf,0,sizeof(buf));
		snprintf(buf,sizeof(buf),"%s.dat",db_name);
		char *utf_str = G2U(buf);
#else
		const char *utf_str = db_name;
#endif

		if(db_ptr_->sql_db.open(utf_str,SQLITE3_KEY,SQLITE3_KEY_LEN)){

			/*优化数据库读写入性能*/

			if(db_ptr_->sql_db.execDML("PRAGMA cache_size = 8000")==0){

			}
			
			if(db_ptr_->sql_db.execDML("PRAGMA synchronous = off")==0){

			}

			if(db_ptr_->sql_db.execDML("PRAGMA case_sensitive_like=1")==0){

			}

			if (!db_ptr_->sql_db.tableExists("version")){
				db_ptr_->sql_db.execDML(SQLITE3_CREATE_TABLE_VERSION);
			}

			if (!db_ptr_->sql_db.tableExists("friends")){
				db_ptr_->sql_db.execDML(SQLITE3_CREATE_CONTACTS_TABLE); 
			}

			if (!db_ptr_->sql_db.tableExists("cdr")){
				db_ptr_->sql_db.execDML(SQLITE3_CREATE_CDR_TABLE); 
			}

			if (!db_ptr_->sql_db.tableExists("cdr_detail")){
				db_ptr_->sql_db.execDML(SQLITE3_CREATE_CDR_DETAIL_TABLE); 
			}

			if (!db_ptr_->sql_db.tableExists("chat")){
				db_ptr_->sql_db.execDML(SQLITE3_CREATE_CHAT_TABLE); 
			}

			if (!db_ptr_->sql_db.tableExists("message")){
				db_ptr_->sql_db.execDML(SQLITE3_CREATE_MESSAGE_TABLE); 
			}

			{/*check table version*/
                int current_ver = get_db_version();
                
                if(current_ver == -1){
                    char szQuery[1024];
                    if(db_ptr_->sql_db.db_is_open()){
                        
                        snprintf(szQuery,sizeof(szQuery),
                                 "INSERT INTO version VALUES(NULL,'all','0');");
                        
                        if(db_ptr_->sql_db.execDML(szQuery) >= SQLITE_OK){
                            current_ver = 0;
                        }
                    }
                }
#if 1
                if(current_ver != -1 && current_ver < CURRENT_TAB_VER &&
                   (CURRENT_TAB_VER == SQLITE3_TABLE_UPDATE &&  current_ver == 0)
                   ){
                    /* version 0 ---> version 1*/
                    db_ptr_->sql_db.execDML(SQLITE3_TABLE_UPDATE_1);
                    //db_ptr_->sql_db.execDML(SQLITE3_TABLE_UPDATE_2);
                    //db_ptr_->sql_db.execDML(SQLITE3_TABLE_UPDATE_3);
                    set_db_version(CURRENT_TAB_VER);
                }
                
#endif
                //if(db_ptr_->sql_db.tableExists("chat"));
                //    db_ptr_->sql_db.execDML("ALTER TABLE chat ADD COLUMN new_msg_count INTEGER;");
			}


			if(fr_db_)
				delete fr_db_;

			fr_db_ = new FriendDatabase(db_ptr_);

			if(cdr_db_)
				delete cdr_db_;

			cdr_db_ = new CdrDatabase(db_ptr_);

			if(chat_db_)
				delete chat_db_;

			chat_db_ = new ChatDatabase(db_ptr_);
		}
#ifdef WIN32
		delete utf_str;
#endif
		return 0;
	}else{
		return -1;
	}
}

bool UserDataBase::db_is_open()
{
	return db_ptr_->sql_db.db_is_open();
}

int UserDataBase::close_db()
{
	if(db_ptr_->sql_db.db_is_open()){
		db_ptr_->sql_db.close();

		if(fr_db_){
			delete fr_db_;
			fr_db_=NULL;
		}

		if(cdr_db_){
			delete cdr_db_;
			cdr_db_=NULL;
		}

		if(chat_db_){
			delete chat_db_;
			chat_db_=NULL;
		}

	}else{
		return -1;
	}

	return 0;
}



UserDataBase* UserDataBase::get_instance()
{
	static UserDataBase s_user_database;
	return &s_user_database;
}
