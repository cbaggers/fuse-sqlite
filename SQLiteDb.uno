using Uno;
using Uno.IO;
using Uno.Collections;

using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;

public class SQLiteDb
{
    string _filename;
    extern (CIL) string db;
    extern (iOS) IntPtr db;
    extern (Android) Java.Object db;
    extern (Uno) int db;

    SQLiteDb(string filename)
    {
        _filename = filename;
        db = SQLiteImpl.OpenImpl(_filename);
    }

    public void Close()
    {
        SQLiteImpl.CloseImpl(db);
    }

    public void Execute(string statement, string[] param)
    {
        SQLiteImpl.ExecImpl(db, statement, param);
    }

    List<Dictionary<string,string>> Query(string statement, string[] param)
    {
        if (defined(CIL))
        {
            return SQLiteImpl.QueryImpl(db, statement, param);
        }
        else
        {
            var res = QueryRes();
            SQLiteImpl.QueryImpl(res, db, statement, param);
            return res;
        }
    }

    public static object Open (string filename)
    {
        var filepath = Path.Combine(Directory.GetUserDirectory(UserDirectory.Data), filename);
        return new SQLiteDb(filepath);
    }

    public static object OpenFromBundle (string filename)
    {
        var filepath = Path.Combine(Directory.GetUserDirectory(UserDirectory.Data), filename);

        if (File.Exists(filepath))
        {
            return Open(filepath);
        }

        BundleFile found = null;

        foreach (var f in Uno.IO.Bundle.AllFiles)
        {
            if (f.SourcePath == filename)
            {
                found = f;
                break;
            }
        }
        if (found != null)
        {
            // http://stackoverflow.com/questions/230128/how-do-i-copy-the-contents-of-one-stream-to-another
            var input = found.OpenRead();
            var output = File.OpenWrite(filepath);
            byte[] buffer = new byte[1024];
            int read;
            while ((read = input.Read(buffer, 0, buffer.Length)) > 0)
            {
                output.Write (buffer, 0, read);
            }
            input.Close();
            output.Close();
        }
        else
        {
            debug_log filename + " not found in bundle";
        }
        return Open(filepath);
    }
}

class QueryRes
{
    List<Dictionary<string,string>> _result = new List<Dictionary<string,string>>();
    Dictionary<string,string> _wip = new Dictionary<string,string>();

    public void SetElem(string key, string val)
    {
        _wip[key] = val;
    }

    public void PushRow()
    {
        _result.Add(_wip);
        _wip = new Dictionary<string,string>();
    }
}
