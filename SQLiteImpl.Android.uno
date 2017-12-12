using Fuse;

using Uno.Compiler.ExportTargetInterop;
using Uno.Collections;

// http://developer.android.com/reference/android/database/sqlite/SQLiteDatabase.html
[TargetSpecificImplementation]
public extern(Android) static class SQLiteImpl {

    [Foreign(Language.Java)]
    public static extern Java.Object OpenImpl(string filename)
    @{
        return android.database.sqlite.SQLiteDatabase.openOrCreateDatabase(filename, null);
    @}

    [Foreign(Language.Java)]
    public static extern void ExecImpl(Java.Object db, string statement, string[] param)
    @{
        ((android.database.sqlite.SQLiteDatabase)db).execSQL(statement, param.copyArray());
    @}

    [Foreign(Language.Java)]
    public static extern void CloseImpl(Java.Object db)
    @{
        ((android.database.sqlite.SQLiteDatabase)db).close();
    @}

    [Foreign(Language.Java)]
    public static extern void QueryImpl(QueryRes result, Java.Object db, string statement, string[] param)
    @{
        android.database.Cursor curs = ((android.database.sqlite.SQLiteDatabase)db).rawQuery(statement, param.copyArray());
        curs.moveToFirst();
        while (!curs.isAfterLast())
        {
            for (int i=0; i<curs.getColumnCount(); i++) {
                @{QueryRes:Of(result).SetElem(string,string):Call(curs.getColumnName(i), curs.getString(i))};
            }

            @{QueryRes:Of(result).PushRow():Call()};
            curs.moveToNext();
        }
    @}
}
