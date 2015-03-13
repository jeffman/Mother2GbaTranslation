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
        static IList<ControlCode> EbControlCodes = new List<ControlCode>();
        static IList<ControlCode> M12ControlCodes = new List<ControlCode>();

        // Decompiler setup
        static EbTextDecompiler ebDecompiler;
        static M12TextDecompiler m12Decompiler;

        static void Main(string[] args)
        {
            CommandOptions options = ParseCommandLine(args);
            if (options == null)
            {
                Usage();
                return;
            }

            LoadControlCodes();

            if (options.Command == CommandType.Decompile)
            {
                ebDecompiler = new EbTextDecompiler() { ControlCodes = EbControlCodes };
                m12Decompiler = new M12TextDecompiler() { ControlCodes = M12ControlCodes };

                // Load ROMs
                byte[] ebRom = File.ReadAllBytes(options.EbRom);
                byte[] m12Rom = File.ReadAllBytes(options.M12Rom);

                // Decompile misc string tables
                if (options.DoMiscText)
                {
                    DecompileEbMisc(ebRom, options.WorkingDirectory);
                    DecompileM12Misc(m12Rom, options.WorkingDirectory);
                }

                // Decompile main string tables
                if (options.DoMainText)
                {
                    DecompileEb(ebRom, options.WorkingDirectory);
                    DecompileM12(m12Rom, options.WorkingDirectory);
                }
            }
            else if (options.Command == CommandType.Compile)
            {
                // TBD
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

        static void LoadControlCodes()
        {
            EbControlCodes = ControlCode.LoadEbControlCodes("eb-codelist.txt");
            M12ControlCodes = ControlCode.LoadM12ControlCodes("m12-codelist.txt");
        }

        static void DecompileEb(byte[] ebRom, string workingDirectory)
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

        }

        static void DecompileM12(byte[] m12Rom, string workingDirectory)
        {
            
            var context = new DecompileContext();

            // Pull all string refs from the ROM
            var allRefs = new List<Tuple<string, MainStringRef[]>>();
            allRefs.Add(Tuple.Create("m12-tpt", M12TextTables.ReadTptRefs(m12Rom)));

            // Decompile
            var allPointers = allRefs.SelectMany(rl => rl.Item2).Select(r => r.OldPointer).ToArray();
            m12Decompiler.Decompile(m12Rom, allPointers, context);

            // Update labels for all refs and write to JSON
            foreach (var refList in allRefs)
            {
                foreach (var stringRef in refList.Item2)
                    stringRef.Label = context.LabelMap[stringRef.OldPointer];

                File.WriteAllText(Path.Combine(workingDirectory, refList.Item1 + ".json"), JsonConvert.SerializeObject(refList.Item2, Formatting.Indented));
            }

            // Write the strings
            File.WriteAllText(Path.Combine(workingDirectory, "m12-strings.txt"), String.Join(Environment.NewLine, context.Strings));
        }

        static void DecompileM12Misc(byte[] m12Rom, string workingDirectory)
        {
            // Item names
            var itemNames = M12TextTables.ReadItemNames(m12Rom);
            DecompileM12MiscStringCollection(m12Rom, workingDirectory, "m12-itemnames", itemNames);

            // Menu choices
            var menuChoices = M12TextTables.ReadMenuChoices(m12Rom);
            DecompileM12MiscStringCollection(m12Rom, workingDirectory, "m12-menuchoices", menuChoices);

            // Misc text
            var miscText = M12TextTables.ReadMiscText(m12Rom);
            DecompileM12MiscStringCollection(m12Rom, workingDirectory, "m12-misctext", miscText);

            // PSI names
            var psiNames = M12TextTables.ReadPsiNames(m12Rom);
            DecompileM12FixedStringCollection(m12Rom, workingDirectory, "m12-psinames", psiNames);
        }

        static void DecompileM12MiscStringCollection(byte[] rom, string workingDirectory, string name, MiscStringCollection miscStringCollection)
        {
            // Decompile the strings
            foreach (var miscStringRef in miscStringCollection.StringRefs)
            {
                miscStringRef.Old =
                    miscStringRef.New =
                    m12Decompiler.ReadString(rom, miscStringRef.OldPointer, -1, miscStringRef.BasicMode);
            }

            // Write JSON
            File.WriteAllText(Path.Combine(workingDirectory, name + ".json"), JsonConvert.SerializeObject(miscStringCollection, Formatting.Indented));
        }

        static void DecompileM12FixedStringCollection(byte[] rom, string workingDirectory, string name, FixedStringCollection fixedStringCollection)
        {
            // Decompile the strings
            foreach (var fixedStringRef in fixedStringCollection.StringRefs)
            {
                fixedStringRef.Old =
                    fixedStringRef.New =
                    m12Decompiler.ReadString(rom, fixedStringRef.OldPointer,
                    fixedStringRef.OldPointer + fixedStringCollection.EntryLength,
                    false);
            }

            // Write JSON
            File.WriteAllText(Path.Combine(workingDirectory, name + ".json"), JsonConvert.SerializeObject(fixedStringCollection, Formatting.Indented));
        }

        //static void CompileM12Misc()
    }
}
