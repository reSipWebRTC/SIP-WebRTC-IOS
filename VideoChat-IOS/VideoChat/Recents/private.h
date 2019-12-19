#ifndef DATABASE_PRIVATE_H
#define DATABASE_PRIVATE_H

#include "CppSQLite3.h"

#ifndef WIN32
#undef snprintf
#endif

#include <memory.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <vector>

#define SQLITE3_KEY "Micr0voicePaSSwd"
#define SQLITE3_KEY_LEN strlen(SQLITE3_KEY)


#ifdef WIN32
extern char *G2U(const char*);
#define snprintf _snprintf
#define strcasecmp _stricmp
#endif // WIN32

typedef struct user_data
{
    CppSQLite3DB sql_db;
} user_data_t;

#define SQLITE3_CREATE_TABLE_VERSION "CREATE TABLE [version] ([id] INTEGER PRIMARY KEY, [table_name] CHAR(128),[version] INTEGER);"

#define SQLITE3_CREATE_CONTACTS_TABLE "CREATE TABLE [friends] ([id] INTEGER PRIMARY KEY,[name] CHAR(128), [number] CHAR(128), [signature] CHAR(128),[is_favourite] INTEGER, [photo] BLOB);"

#define SQLITE3_CREATE_CDR_TABLE "CREATE TABLE [cdr] ([id] INTEGER PRIMARY KEY, [type] INTEGER, [status] INTEGER, [duration] INTEGER, [is_video] INTEGER,[name] CHAR(128), [number] CHAR(128), [start_date] CHAR(32), [record_path] CHAR(2048));"

#define SQLITE3_CREATE_CHAT_TABLE "CREATE TABLE [chat] ([id] INTEGER PRIMARY KEY,[peer_num] CHAR(128), [last_date] CHAR(32), [last_message] CHAR(1024));"

#define SQLITE3_CREATE_MESSAGE_TABLE "CREATE TABLE [message] ([id] INTEGER PRIMARY KEY,[chat_id] INTEGER,[image] INTEGER,[status] INTEGER,[dir] INTEGER,[text] CHAR(1025), [message_id] CHAR(32), [date_time] CHAR(32));"

#define SQLITE3_CREATE_CDR_DETAIL_TABLE "CREATE TABLE [cdr_detail] ([id] INTEGER PRIMARY KEY, [cdr_id] INTEGER, [status] INTEGER, [duration] INTEGER, [video_call] INTEGER, [start_date] CHAR(32));"

#define SQLITE3_TABLE_UPDATE 1

#define SQLITE3_TABLE_UPDATE_1 "ALTER TABLE chat ADD COLUMN new_msg_count INTEGER;"
#define SQLITE3_TABLE_UPDATE_2 "ALTER TABLE chat ALTER COLUMN last_message TYPE VARCHAR(1024);"
#define SQLITE3_TABLE_UPDATE_3 "ALTER TABLE message ALTER COLUMN text TYPE VARCHAR(1025);"


#define CURRENT_TAB_VER 1

#endif