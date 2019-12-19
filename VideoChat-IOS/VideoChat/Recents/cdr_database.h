#ifndef CDR_DATABASE_H
#define CDR_DATABASE_H
#include <vector>

struct user_data;
typedef struct user_data user_data_t;

#define NB_MAX_CDR_RECORD 100 /*最多保留100条通话记录*/
#define NB_MAX_CDR_DETAILS 8

#define kAllCalls -1
#define kOutgoingCall 1
#define kIncomingCall 2
#define kIncomingMissed 3
#define kOutgoingFailed 4
#define kAllMissedCall 5


typedef struct call_report_detail_t
{
	int id;
	int cdr_id;
	int status;
	int duration;
    int video_call;
    char start_date[32];
	call_report_detail_t()
    :id(0),
    cdr_id(0),
    duration(0),
    status(kOutgoingCall)
    {
        memset(start_date,0,sizeof(start_date));
	};

}call_report_detail;

/*通话记录*/
typedef struct call_report_t{
	int id;
	int phone_type;
	int status;
	int duration;
	int video_call;
	char name[128];
	char number[128];
	char start_date[32];
	char record_path[512];
	int detail_count;
	std::vector<call_report_detail *> details_;

	call_report_t(){
		id=0;
		phone_type=kAllCalls;
		status = kOutgoingCall;
		duration = 0;
		video_call = 0;
		detail_count = 0;

		memset(name,0,sizeof(name));
		memset(number,0,sizeof(number));
		memset(start_date,0,sizeof(start_date));
		memset(record_path,0,sizeof(record_path));
	};
}call_report;


class CdrDatabase
{
public:
	CdrDatabase(void);
	CdrDatabase(user_data_t *db);
	~CdrDatabase(void);
    
    int open_db(const char *db_path);

public:	/*通话记录*/
	/*话单总数,或按 status = 接通,未通,来电去电计算总数*/
	int cdr_size(int status=kAllCalls);
	/*按idx索引话单,或增加过滤条件*/
	call_report *cdr_at(int index, int status=kAllCalls);
    
    call_report *last_cdr();

	/*删除话单*/
	bool cdr_remove(call_report *cdr);
	bool cdr_remove_all();

	/*插入话单*/
	call_report *cdr_insert(call_report &cdr);
	call_report *cdr_insert(int phone_type, int status,int duration, bool video_call,
		const char *name,const char *number,const char *start_date,const char *record_path);
private:
	user_data_t *db_ptr_;
	std::vector<call_report *> cdr_list_;
	int load_cdrs();
	int load_cdr_details(call_report *cdr);
	int unload_cdrs();
	int unload_cdr_details(call_report *cdr);
	int cdr_detail_insert(call_report_detail *cdr_detail);
	int cdr_detial_remove(int cdr_id);
	int cdr_detial_remove_all();
};

#endif

