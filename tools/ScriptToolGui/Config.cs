using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using Newtonsoft.Json;
using ScriptTool;

namespace ScriptToolGui
{
    class Config
    {
        public string WorkingFolder { get; set; }

        public static Config Read(string configPath)
        {
            if (!File.Exists(Asset.GetFullPath(configPath)))
                return null;

            return JsonConvert.DeserializeObject<Config>(Asset.ReadAllText(configPath));
        }
    }
}
