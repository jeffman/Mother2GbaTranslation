using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace ScriptTool
{
    internal static class Asset
    {
        public static readonly string AssetPath;

        static Asset()
        {
            AssetPath = AppDomain.CurrentDomain.BaseDirectory;
        }

        private static string GetFullPath(string path)
            => Path.Combine(AssetPath, path);

        public static string ReadAllText(string path)
            => File.ReadAllText(GetFullPath(path));

        public static byte[] ReadAllBytes(string path)
            => File.ReadAllBytes(GetFullPath(path));
    }
}
