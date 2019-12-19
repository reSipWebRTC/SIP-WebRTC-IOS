#include "cdr_database.h"
#include "private.h"


using namespace std;

CdrDatabase::CdrDatabase(void)
{
    db_ptr_ = new user_data_t();
}

CdrDatabase::CdrDatabase( user_data_t *db ):
db_ptr_(db)
{

	if(db_ptr_)
		load_cdrs();
}

CdrDatabase::~CdrDatabase(void)
{
	if(db_ptr_)
		unload_cdrs();
    
    delete db_ptr_;
}

int CdrDatabase::open_db( const char *db_name )
{
    if(db_ptr_ && !db_ptr_->sql_db.db_is_open()){
        
#ifdef WIN32
        char buf[2048];
        memset(buf,0,sizeof(buf));
        snprintf(buf,sizeof(buf),"%s.db",db_name);
        char *utf_str = G2U(buf);
#else
        const char *utf_str = db_name;
#endif
        
        if(db_ptr_->sql_db.open(utf_str,SQLITE3_KEY,SQLITE3_KEY_LEN))
        {
            if(db_ptr_->sql_db.execDML("PRAGMA cache_size = 8000")==0){
                
            }
            
            if(db_ptr_->sql_db.execDML("PRAGMA synchronous = off")==0){
                
            }
            
            if(db_ptr_->sql_db.execDML("PRAGMA case_sensitive_like=1")==0){
                
            }
            
            if (!db_ptr_->sql_db.tableExists("cdr")){
                db_ptr_->sql_db.execDML(SQLITE3_CREATE_CDR_TABLE);
            }
            
            if (!db_ptr_->sql_db.tableExists("cdr_detail")){
                db_ptr_->sql_db.execDML(SQLITE3_CREATE_CDR_DETAIL_TABLE);
            }
            
            load_cdrs();
        }
#ifdef WIN32
        delete utf_str;
#endif
        return 0;
    }else{
        return -1;
    }
}

int CdrDatabase::load_cdrs()
{
	char szQuery[] = "SELECT * FROM cdr ORDER BY start_date DESC;";
	int count = 0;
	if(!db_ptr_->sql_db.db_is_open()) return -1;

	CppSQLite3Query q = db_ptr_->sql_db.execQuery(szQuery); 

	while(!q.eof()){ 

		call_report *cdr= new call_report;

		cdr->id = q.getIntField(0);
		cdr->phone_type = q.getIntField("type");
		cdr->duration = q.getIntField("duration");
		cdr->status = q.getIntField("status");
		cdr->video_call = q.getIntField("is_video");

		snprintf(cdr->name,sizeof(cdr->name),"%s",q.getStringField("name"));
		snprintf(cdr->number,sizeof(cdr->number),"%s",q.getStringField("number"));
		snprintf(cdr->start_date,sizeof(cdr->start_date),"%s",q.getStringField("start_date"));
		snprintf(cdr->record_path,sizeof(cdr->record_path),"%s",q.getStringField("record_path"));

		/*载入呼叫细节*/
		load_cdr_details(cdr);

		cdr_list_.push_back(cdr);
		count++;
		q.nextRow(); 
	}

	return count;
}

int CdrDatabase::load_cdr_details(call_report *cdr){

	char szQuery[1024] = "\0";
	int count = 0;
	if(!db_ptr_->sql_db.db_is_open()) return -1;

	snprintf(szQuery,sizeof(szQuery), "SELECT * FROM cdr_detail WHERE cdr_id=%d ORDER BY start_date DESC;",cdr->id);

	CppSQLite3Query q = db_ptr_->sql_db.execQuery(szQuery); 

	while(!q.eof()){ 

		call_report_detail *cdr_detail= new call_report_detail;

		cdr_detail->id = q.getIntField("id");
		cdr_detail->cdr_id = q.getIntField("cdr_id");
		cdr_detail->duration = q.getIntField("duration");
		cdr_detail->status = q.getIntField("status");
        cdr_detail->video_call = q.getIntField("video_call");

		snprintf(cdr_detail->start_date,sizeof(cdr_detail->start_date),"%s",q.getStringField("start_date"));

		cdr->details_.insert(cdr->details_.begin(),cdr_detail);
		count++;
		q.nextRow(); 
	}

	cdr->detail_count = count;

	return count;
}


int CdrDatabase::unload_cdrs()
{
	vector<call_report *>::iterator iter;  
	for (iter=cdr_list_.begin();iter!=cdr_list_.end();iter++)  
	{  
		call_report *cdr = *iter;
		unload_cdr_details(cdr);
		delete cdr;
	}  
	cdr_list_.clear();
	return 0;
}

int CdrDatabase::unload_cdr_details(call_report *cdr){
	
	vector<call_report_detail *>::iterator iter;  
	for (iter=cdr->details_.begin();iter!=cdr->details_.end();iter++)  
	{  
		call_report_detail *cdr_detail = *iter;
		delete cdr_detail;
	}  
	cdr->details_.clear();
	return 0;
}

int CdrDatabase::cdr_size(int status)
{
	if(status==kAllCalls){
		return (int)cdr_list_.size();
	}else{
		int count=0;

		vector<call_report *>::iterator iter;  
		for (iter=cdr_list_.begin();iter!=cdr_list_.end();iter++)  
		{  
			call_report *cdr = *iter;
			if((cdr->status == kOutgoingFailed||  cdr->status == kIncomingMissed) && status == kAllMissedCall){
				count++;
			}
		}
		return count;
	}
}


call_report *CdrDatabase::cdr_at( int index,int status)
{
	if(status==kAllCalls){
		return (call_report *)cdr_list_.at(index);
	}else{
		int count=0;

		vector<call_report *>::iterator iter;  
		for (iter=cdr_list_.begin();iter!=cdr_list_.end();iter++)  
		{  
			call_report *cdr = *iter;
			if((cdr->status == kOutgoingFailed||  cdr->status == kIncomingMissed) && status == kAllMissedCall){

				if(index==count)
					return cdr;

				count++;
			}
		}
		return NULL;    
	}
}


bool CdrDatabase::cdr_remove_all()
{
	char szQuery[] ="DELETE FROM cdr;"; 

	if(!db_ptr_->sql_db.db_is_open()) return false;

	if(db_ptr_->sql_db.execDML(szQuery) >= SQLITE_OK){
		unload_cdrs();
		return true;
	}

	cdr_detial_remove_all();

	return false;
}

int CdrDatabase::cdr_detial_remove_all(){

	char szQuery[] ="DELETE FROM cdr_detail;"; 

	if(!db_ptr_->sql_db.db_is_open()) return false;

	if(db_ptr_->sql_db.execDML(szQuery) >= SQLITE_OK){
		return 0;
	}
	return -1;
}

bool CdrDatabase::cdr_remove(call_report *cdr)
{
	char szQuery[1024];

	if(!db_ptr_->sql_db.db_is_open() || !cdr) return false;


	snprintf(szQuery,sizeof(szQuery),"DELETE FROM cdr WHERE  id='%d';",
		cdr->id);

	if(db_ptr_->sql_db.execDML(szQuery) >=SQLITE_OK){

		vector<call_report *>::iterator iter;  
		for (iter=cdr_list_.begin();iter!=cdr_list_.end();iter++)  
		{  
			if(*iter == cdr){
				cdr_list_.erase(iter);
				if(cdr->detail_count>0)
					cdr_detial_remove(cdr->id);
				delete cdr;
				return true;
			}
		}
		return true;
	}

	return false;
}

int CdrDatabase::cdr_detial_remove(int cdr_id){

	char szQuery[1024];

	if(!db_ptr_->sql_db.db_is_open() || cdr_id<=0) return -1;

	snprintf(szQuery,sizeof(szQuery),"DELETE FROM cdr_detail WHERE cdr_id='%d';",cdr_id);

	if(db_ptr_->sql_db.execDML(szQuery) >=SQLITE_OK){
		return 0;
	}

	return -1;
}

call_report *CdrDatabase::last_cdr()
{
    if(cdr_list_.size() > 0)
    {
        return cdr_list_.front();
    }
    
    return NULL;
}

bool check_call_status(call_report *cdr1, call_report *cdr2){

	if(cdr1->status == kIncomingMissed && cdr2->status ==kIncomingMissed) /*二次插入的记录同时为 漏接则合并记录*/
		return true;
	else if((cdr1->status==kOutgoingCall || cdr1->status==kIncomingCall) && cdr2->status !=kIncomingMissed) /*之前记录为接通， 则再次插入的记录为也为接通或外部失败*/
		return true;
        else if(cdr1->status== kOutgoingFailed && cdr2->status== kOutgoingFailed) /*多次失败也合并纪录*/
                return true;

	return false;
}

bool check_call_date(call_report *cdr1, call_report *cdr2){

	/*2012-08-28 11:05 比较前面10个字符是否为同一天*/
	if(strncmp(cdr1->start_date,cdr2->start_date,10)==0)
		return true;

	return false;
}

call_report *CdrDatabase::cdr_insert( call_report &cdr )
{
	call_report *new_cdr = NULL;

	/* 检查新插入的通话记录和最后一条是否为同一个号码，如果是则插入到cdr_details 增加*/
	if(cdr_list_.size()>0)
    {
        call_report *front_cdr = cdr_list_.front();

        std::vector<call_report *>::iterator it = cdr_list_.begin();
        while (it != cdr_list_.end()) {
            call_report *old_cdr = *it;
            
            if(strcmp(old_cdr->number,cdr.number) == 0)
            {
                if(old_cdr->detail_count < NB_MAX_CDR_DETAILS)
                {
                    call_report_detail *cdr_detail = new call_report_detail;
                    memset(cdr_detail,0,sizeof(call_report_detail));
                    cdr_detail->cdr_id = old_cdr->id;
                    cdr_detail->duration = cdr.duration;
                    cdr_detail->status = cdr.status;
                    cdr_detail->video_call = cdr.video_call;
                    strcpy(cdr_detail->start_date,cdr.start_date);
                    cdr_detail_insert(cdr_detail);
                    
                    old_cdr->details_.insert(old_cdr->details_.begin(),cdr_detail);
                    old_cdr->detail_count = (int)old_cdr->details_.size();
                    old_cdr->status = cdr.status;
                    old_cdr->duration = cdr.duration;
                    strcpy(old_cdr->start_date,cdr.start_date);
                    old_cdr->video_call = cdr.video_call;
                    
                    /*updata old cdr*/
                    
                    if(db_ptr_->sql_db.db_is_open())
                    {
                        char szQuery[1024];
                        //CREATE TABLE [cdr] ([id] INTEGER PRIMARY KEY, [type] INTEGER, [status] INTEGER, [duration] INTEGER, [is_video] INTEGER,[name] CHAR(128), [number] CHAR(128), [start_date] CHAR(32), [record_path] CHAR(2048));
                        
                        snprintf(szQuery,sizeof(szQuery),"UPDATE cdr SET status = '%d', duration = '%d', is_video = '%d', start_date = '%s' WHERE id = %d;",
                                 cdr.status,cdr.duration,cdr.video_call,cdr.start_date,old_cdr->id);
                        
                        if(db_ptr_->sql_db.execDML(szQuery) >= SQLITE_OK){
                        }
                    }
                    
                    if(strcmp(old_cdr->number,front_cdr->number) != 0)
                    {
                        unload_cdrs();
                        load_cdrs();
                    }
                    
                    return old_cdr;
                }else
                {
                    /*Skip search, create new record !*/
                    break;
                }
            }
            
            it++;
        }
        
        /*
         if(strcmp(front_cdr->number,cdr.number)==0
         && (front_cdr->detail_count < NB_MAX_CDR_DETAILS)
         && check_call_status(front_cdr,&cdr)
         && check_call_date(front_cdr,&cdr)
         && front_cdr->video_call == cdr.video_call){
         
         call_report_detail *cdr_detail = new call_report_detail;
         memset(cdr_detail,0,sizeof(call_report_detail));
         cdr_detail->cdr_id = front_cdr->id;
         cdr_detail->duration = cdr.duration;
         cdr_detail->status = cdr.status;
         strcpy(cdr_detail->start_date,cdr.start_date);
         cdr_detail_insert(cdr_detail);
         
         front_cdr->details_.insert(front_cdr->details_.begin(),cdr_detail);
         front_cdr->detail_count = front_cdr->details_.size();
         
         return front_cdr;
         }*/
    }
        
	new_cdr = new call_report;
	memcpy(new_cdr,&cdr,sizeof(call_report));

	cdr_list_.insert(cdr_list_.begin(),new_cdr);

	/*通话记录超过最大数量,删除旧条码*/
	if(cdr_list_.size() > NB_MAX_CDR_RECORD){
		call_report *last_cdr = cdr_list_.back();
		cdr_remove(last_cdr);
	}

	if(db_ptr_->sql_db.db_is_open())
    {
		char szQuery[1024];

		snprintf(szQuery,sizeof(szQuery),"INSERT INTO cdr VALUES(NULL,'%d','%d','%d','%d','%s','%s','%s','%s');",
			new_cdr->phone_type,new_cdr->status,new_cdr->duration,new_cdr->video_call,new_cdr->name,new_cdr->number,new_cdr->start_date,new_cdr->record_path);

		if(db_ptr_->sql_db.execDML(szQuery) >= SQLITE_OK){
			snprintf(szQuery,sizeof(szQuery),"SELECT id FROM cdr ORDER BY id DESC LIMIT 1;");
			CppSQLite3Query q = db_ptr_->sql_db.execQuery(szQuery); 

			while(!q.eof()){ 
				new_cdr->id = q.getIntField(0);
				q.nextRow();
			}
		}
	}

	return new_cdr;
}

call_report * CdrDatabase::cdr_insert( int phone_type, int status,int duration,bool video_call, const char *name,const char *number,const char *start_date,const char *record_path)
{
	call_report new_cdr;

	new_cdr.phone_type = phone_type;
	new_cdr.duration = duration;
	new_cdr.status = status;
	new_cdr.video_call = video_call? 1 : 0;
	snprintf(new_cdr.name,sizeof(new_cdr.name),"%s",name);
	snprintf(new_cdr.number,sizeof(new_cdr.number),"%s",number);
	snprintf(new_cdr.start_date,sizeof(new_cdr.start_date),"%s",start_date);
	snprintf(new_cdr.record_path,sizeof(new_cdr.record_path),"%s",record_path);

	return cdr_insert(new_cdr);
}

int CdrDatabase::cdr_detail_insert(call_report_detail *cdr_detail){

	if(db_ptr_->sql_db.db_is_open()){
		char szQuery[1024];
		snprintf(szQuery,sizeof(szQuery),"INSERT INTO cdr_detail VALUES(NULL,'%d','%d','%d','%d','%s');",
			cdr_detail->cdr_id,cdr_detail->status,cdr_detail->duration,cdr_detail->video_call,cdr_detail->start_date);

		if(db_ptr_->sql_db.execDML(szQuery) >= SQLITE_OK){
			snprintf(szQuery,sizeof(szQuery),"SELECT id FROM cdr_detail ORDER BY id DESC LIMIT 1;");
			CppSQLite3Query q = db_ptr_->sql_db.execQuery(szQuery); 

			while(!q.eof()){ 
				cdr_detail->id = q.getIntField(0);
				q.nextRow();
			}
		}

		return 0;
	}

	return -1;
}