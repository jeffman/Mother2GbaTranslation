using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using Newtonsoft.Json;

namespace ScriptTool
{
    class Program
    {
        // Options
        static CommandOptions options;

        // ROMs
        static byte[] ebRom;
        static byte[] m12Rom;

        // Decompiler setup
        static M12Decompiler m12Decompiler;

        // Compiler setup
        static M12Compiler m12Compiler;
        static StreamWriter IncludeFile;

        static void Main(string[] args)
        {
            options = ParseCommandLine(args);
            if (options == null)
            {
                Usage();
                return;
            }

            if (options.Command == CommandType.Decompile)
            {
                m12Decompiler = new M12Decompiler();

                // Load ROMs
                ebRom = File.ReadAllBytes(options.EbRom);
                m12Rom = File.ReadAllBytes(options.M12Rom);

                // Decompile misc string tables
                if (options.DoMiscText)
                {
                    //DecompileEbMisc();
                    DecompileM12Misc();
                }

                // Decompile main string tables
                if (options.DoMainText)
                {
                    //DecompileEb();
                    DecompileM12();
                }
            }
            else if (options.Command == CommandType.Compile)
            {
                m12Compiler = new M12Compiler();

                using (IncludeFile = File.CreateText(Path.Combine(options.WorkingDirectory, "m12-includes.asm")))
                {
                    IncludeFile.WriteLine("arch gba.thumb");

                    // Compile misc string tables
                    if (options.DoMiscText)
                    {
                        CompileM12Misc();
                    }
                }
            }
        }

        static void Usage()
        {
            Console.WriteLine("Usage:");
            Console.WriteLine("  ScriptTool.exe [-decompile or -compile] [-misc] [-main] workingdirectory [ebrom m12rom]");;
        }

        static CommandOptions ParseCommandLine(string[] args)
        {
            var argList = new List<string>(args);

            // Check for decompile switch
            CommandType command;
            if (argList.Contains("-decompile") && !argList.Contains("-compile"))
            {
                command = CommandType.Decompile;
                argList.Remove("-decompile");
            }
            else if (argList.Contains("-compile") && !argList.Contains("-decompile"))
            {
                command = CommandType.Compile;
                argList.Remove("-compile");
            }
            else
            {
                return null;
            }

            // Check for main and misc flags
            bool doMain = false;
            bool doMisc = false;
            if (argList.Contains("-main"))
            {
                doMain = true;
                argList.Remove("-main");
            }
            if (argList.Contains("-misc"))
            {
                doMisc = true;
                argList.Remove("-misc");
            }

            // Check for working directory
            if (argList.Count < 1)
                return null;

            string working = argList[0];
            if (!Directory.Exists(working))
                return null;

            // Check for ROM paths
            string ebRom = null;
            string m12Rom = null;
            if (command == CommandType.Decompile && argList.Count == 3)
            {
                ebRom = argList[1];
                m12Rom = argList[2];
                if (!File.Exists(ebRom) || !File.Exists(m12Rom))
                    return null;
            }

            return new CommandOptions
            {
                WorkingDirectory = working,
                EbRom = ebRom,
                M12Rom = m12Rom,
                Command = command,
                DoMainText = doMain,
                DoMiscText = doMisc
            };
        }

        /*static void DecompileEb(byte[] ebRom, string workingDirectory)
        {
            var context = new DecompileContext();

            // Pull all string refs from the ROM
            var allRefs = new List<Tuple<string, MainStringRef[]>>();
            allRefs.Add(Tuple.Create("eb-tpt", EbTextTables.ReadTptRefs(ebRom)));
            allRefs.Add(Tuple.Create("eb-battle-actions", EbTextTables.ReadBattleActionRefs(ebRom)));
            allRefs.Add(Tuple.Create("eb-prayers", EbTextTables.ReadPrayerRefs(ebRom)));
            allRefs.Add(Tuple.Create("eb-item-help", EbTextTables.ReadItemHelpRefs(ebRom)));
            allRefs.Add(Tuple.Create("eb-psi-help", EbTextTables.ReadPsiHelpRefs(ebRom)));
            allRefs.Add(Tuple.Create("eb-phone", EbTextTables.ReadPhoneRefs(ebRom)));
            allRefs.Add(Tuple.Create("eb-enemy-encounters", EbTextTables.ReadEnemyTextRefs(ebRom)));

            // Decompile
            var allPointers = allRefs.SelectMany(rl => rl.Item2).Select(r => r.OldPointer).ToArray();
            ebDecompiler.Decompile(ebRom, allPointers, context);

            // Update labels for all refs and write to JSON
            foreach (var refList in allRefs)
            {
                foreach (var stringRef in refList.Item2)
                    stringRef.Label = context.LabelMap[stringRef.OldPointer];

                File.WriteAllText(Path.Combine(workingDirectory, refList.Item1 + ".json"), JsonConvert.SerializeObject(refList.Item2, Formatting.Indented));
            }

            // Write the strings
            File.WriteAllText(Path.Combine(workingDirectory, "eb-strings.txt"), String.Join(Environment.NewLine, context.Strings));
        }

        static void DecompileEbMisc(byte[] ebRom, string workingDirectory)
        {
            // Enemy names
            var enemyNames = EbTextTables.ReadEnemyNames(ebRom);
            DecompileFixedStringCollection(ebDecompiler, ebRom, workingDirectory, "eb-enemynames", enemyNames);
        }*/

        static void DecompileM12()
        {
            // Pull all string refs from the ROM
            var allRefs = new List<Tuple<string, MainStringRef[]>>();
            allRefs.Add(Tuple.Create("m12-tpt", M12TextTables.ReadTptRefs(m12Rom)));
            // TODO: small pointer table at B1B3B0

            // Decompile
            var allPointers = allRefs.SelectMany(rl => rl.Item2).Select(r => r.OldPointer);
            m12Decompiler.LabelMap.AddRange(allPointers);

            var strings = new List<string>();
            m12Decompiler.ScanRange(m12Rom, 0x3697F, 0x8C4B0);
            strings.Add(m12Decompiler.DecompileRange(m12Rom, 0x3697F, 0x8C4B0, true));

            // Update labels for all refs and write to JSON
            foreach (var refList in allRefs)
            {
                foreach (var stringRef in refList.Item2)
                    stringRef.Label = m12Decompiler.LabelMap.Labels[stringRef.OldPointer];

                File.WriteAllText(Path.Combine(options.WorkingDirectory, refList.Item1 + ".json"),
                    JsonConvert.SerializeObject(refList.Item2, Formatting.Indented));
            }

            // Write the strings
            File.WriteAllText(Path.Combine(options.WorkingDirectory, "m12-strings.txt"), String.Join(Environment.NewLine, strings));
        }

        static void DecompileM12Misc()
        {
            // Item names
            var itemNames = M12TextTables.ReadItemNames(m12Rom);
            DecompileM12MiscStringCollection("m12-itemnames", itemNames);

            // Menu choices
            var menuChoices = M12TextTables.ReadMenuChoices(m12Rom);
            DecompileM12MiscStringCollection("m12-menuchoices", menuChoices);

            // Misc text
            var miscText = M12TextTables.ReadMiscText(m12Rom);
            DecompileM12MiscStringCollection("m12-misctext", miscText);

            // Dad
            var dadText = M12TextTables.ReadDadText(m12Rom);
            DecompileM12MiscStringCollection("m12-dadtext", dadText);

            // PSI text
            var psiText = M12TextTables.ReadPsiText(m12Rom);
            DecompileM12MiscStringCollection("m12-psitext", psiText);

            // Enemy names
            var enemyNames = M12TextTables.ReadEnemyNames(m12Rom);
            DecompileM12MiscStringCollection("m12-enemynames", enemyNames);

            // PSI names
            var psiNames = M12TextTables.ReadPsiNames(m12Rom);
            DecompileFixedStringCollection(m12Decompiler, m12Rom, "m12-psinames", psiNames);
        }

        static void DecompileM12MiscStringCollection(string name, MiscStringCollection miscStringCollection)
        {
            // Decompile the strings
            foreach (var miscStringRef in miscStringCollection.StringRefs)
            {
                string decompiledString;

                if (miscStringRef.BasicMode)
                {
                    decompiledString = m12Decompiler.ReadFFString(m12Rom, miscStringRef.OldPointer);
                }
                else
                {
                    decompiledString = m12Decompiler.DecompileString(m12Rom, miscStringRef.OldPointer, false);
                }

                miscStringRef.Old =
                    miscStringRef.New = decompiledString;
            }

            // Write JSON
            File.WriteAllText(Path.Combine(options.WorkingDirectory, name + ".json"),
                JsonConvert.SerializeObject(miscStringCollection, Formatting.Indented));
        }

        static void DecompileFixedStringCollection(IDecompiler decompiler, byte[] rom, string name, FixedStringCollection fixedStringCollection)
        {
            // Decompile the strings
            foreach (var fixedStringRef in fixedStringCollection.StringRefs)
            {
                fixedStringRef.Old =
                    fixedStringRef.New =
                    decompiler.DecompileRange(rom, fixedStringRef.OldPointer,
                    fixedStringRef.OldPointer + fixedStringCollection.EntryLength, false);
            }

            // Write JSON
            File.WriteAllText(Path.Combine(options.WorkingDirectory, name + ".json"),
                JsonConvert.SerializeObject(fixedStringCollection, Formatting.Indented));
        }

        static void CompileM12Misc()
        {
            int referenceAddress = 0xB3C000;

            // Item names
            CompileM12MiscStringCollection("m12-itemnames", ref referenceAddress);
            
            // Misc text
            CompileM12MiscStringCollection("m12-misctext", ref referenceAddress);

            // PSI text
            CompileM12MiscStringCollection("m12-psitext", ref referenceAddress);
        }

        static void CompileM12MiscStringCollection(string name, ref int referenceAddress)
        {
            int baseAddress = referenceAddress;
            var buffer = new List<byte>();
            
            // Read the JSON
            MiscStringCollection stringCollection = JsonConvert.DeserializeObject<MiscStringCollection>(
                File.ReadAllText(Path.Combine(options.WorkingDirectory, name + ".json")));

            // Open the offset ASM file
            using (var offsetFile = File.CreateText(Path.Combine(options.WorkingDirectory, name + ".asm")))
            {
                // Include the binfile
                offsetFile.WriteLine(String.Format("org ${0:X}; incbin {1}.bin",
                    baseAddress | 0x8000000, name));
                offsetFile.WriteLine();

                // Compile all strings
                foreach (var str in stringCollection.StringRefs)
                {
                    offsetFile.WriteLine(String.Format("org ${0:X}; dd ${1:X8}",
                        str.OffsetLocation | 0x8000000, referenceAddress - stringCollection.StringsLocation));

                    m12Compiler.CompileString(str.New, buffer, ref referenceAddress);
                }
            }

            // Write the buffer
            File.WriteAllBytes(Path.Combine(options.WorkingDirectory, name + ".bin"), buffer.ToArray());

            // Add to the include file
            IncludeFile.WriteLine("incsrc " + name + ".asm");
        }
    }
}
