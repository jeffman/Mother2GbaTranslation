using System;
using System.Collections.Generic;
using System.Text;

namespace ScriptTool
{
    static class PreProcessStrings
    {
        private static string date_command_str = "\\date";
        private static DateTime currentTime = DateTime.UtcNow;

        public static string PrepareMainText(string m12Strings)
        {
            string result = m12Strings.Replace(date_command_str, currentTime.ToString());
            return result;
        }
    }
}
