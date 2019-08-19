//bin/mkdir -p "${TMPDIR:-/tmp}/${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}" && exec \
//usr/bin/make -C "$_" -sf/dev/null --eval="!:${n%.*};./$<" VPATH="$d" CXXFLAGS=-std=c++11 LDFLAGS="-lsqlite3 -lpthread" "$@"
// vim:ft=cpp
//---
// SUMMARY: two simultaneous exec() is impossible even for readonly db
// USAGE: $ ./$0
//---
#include <sqlite3.h>

#include <atomic>
#include <chrono>
#include <iostream>
#include <thread>
#include <unistd.h>

int
callback(void* mydata, int ncols, char** values, char** names)
{
    std::this_thread::sleep_for(std::chrono::seconds(*(int*)mydata));
    std::string msg = " :: ";
    for (int i = 0; i < ncols; ++i) {
        std::string const key = names[i];
        std::string const val = values[i] ? values[i] : "NULL";
        msg += key + "=" + val;
        if (i < ncols - 1) {
            msg += ", ";
        }
    }
    std::cout << std::hex << std::this_thread::get_id() << msg << std::endl;
    return 0;
}

void
dbslowread(sqlite3* db)
{
    char* errmsg = nullptr;
    char const* query = "SELECT * FROM mytable LIMIT 3";
    int delay = 1;
    int rc = sqlite3_exec(db, query, callback, &delay, &errmsg);
    if (rc) {
        perror(errmsg);
        exit(EXIT_FAILURE);
    }
}

int
main(int argc, char** argv)
{
    sqlite3* db = nullptr;
    int rc = SQLITE_ERROR;

    rc = sqlite3_config(SQLITE_CONFIG_SERIALIZED);
    if (rc) {
        perror("can't serialized");
        exit(EXIT_FAILURE);
    }

    rc = sqlite3_open_v2("testing.db", &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nullptr);
    if (rc || !db) {
        sqlite3_close(db);
        perror("can't open DB");
        exit(EXIT_FAILURE);
    }

    char const* preparesql =
            "CREATE TABLE IF NOT EXISTS mytable (myid INTEGER PRIMARY KEY AUTOINCREMENT, myname INTEGER);"
            "WITH RECURSIVE placeholders(x) AS (SELECT 0 UNION ALL SELECT x FROM placeholders LIMIT 2000)"
            "INSERT INTO mytable(myname) SELECT x FROM placeholders;";

    char* errmsg = nullptr;
    rc = sqlite3_exec(db, preparesql, callback, nullptr, &errmsg);
    if (rc) {
        perror(errmsg);
        exit(EXIT_FAILURE);
    }
    sqlite3_close(db);

    rc = sqlite3_open_v2("testing.db", &db, SQLITE_OPEN_READONLY, nullptr);
    if (rc || !db) {
        sqlite3_close(db);
        perror("can't open DB");
        exit(EXIT_FAILURE);
    }

    auto t1 = std::thread([db] { dbslowread(db); });
    auto t2 = std::thread([db] { dbslowread(db); });

    std::cout << "waiting..." << std::endl;
    t1.join();
    t2.join();

    sqlite3_close(db);
    return EXIT_SUCCESS;
}
