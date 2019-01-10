using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace ScriptTool
{
    public static class Asset
    {
        public static readonly string AssetPath;

        static Asset()
        {
            AssetPath = AppDomain.CurrentDomain.BaseDirectory;
        }

        public static string GetFullPath(string path)
            => Path.Combine(AssetPath, path);

        public static string ReadAllText(string path)
            => File.ReadAllText(GetFullPath(path));

        public static byte[] ReadAllBytes(string path)
            => File.ReadAllBytes(GetFullPath(path));

        public static string[] ReadAllLines(string path)
            => File.ReadAllLines(GetFullPath(path));

        public static void WriteAllText(string path, string text)
            => File.WriteAllText(GetFullPath(path), text);
    }
}
