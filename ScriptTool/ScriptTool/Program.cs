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
        static Decompiler m12Decompiler;
        static Decompiler ebDecompiler;

        static IDictionary<byte, string> m12CharLookup;
        static IDictionary<byte, string> ebCharLookup;

        // Compiler setup
        static Compiler m12Compiler;
        static StreamWriter IncludeFile;

        static void Main(string[] args)
        {
            options = ParseCommandLine(args);
            if (options == null)
            {
                Usage();
                return;
            }

            m12CharLookup = JsonConvert.DeserializeObject<Dictionary<byte, string>>(File.ReadAllText("m12-char-lookup.json"));
            ebCharLookup = JsonConvert.DeserializeObject<Dictionary<byte, string>>(File.ReadAllText("eb-char-lookup.json"));

            if (options.Command == CommandType.Decompile)
            {
                // Set up decompilers
                m12Decompiler = new Decompiler(M12ControlCode.Codes, m12CharLookup, (rom, address) => rom[address + 1] == 0xFF);
                ebDecompiler = new Decompiler(EbControlCode.Codes, ebCharLookup, (rom, address) => rom[address] < 0x20);

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
                    DecompileEb();
                    DecompileM12();
                }
            }
            else if (options.Command == CommandType.Compile)
            {
                // Set up compilers
                m12Compiler = new Compiler(M12ControlCode.Codes, (rom, address) => rom[address + 1] == 0xFF);

                using (IncludeFile = File.CreateText(Path.Combine(options.WorkingDirectory, "m12-includes.asm")))
                {
                    IncludeFile.WriteLine("arch gba.thumb");

                    // Compile main string tables
                    if (options.DoMainText)
                    {
                        CompileM12();
                    }

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

        static void DecompileEb()
        {
            // Pull all string refs from the ROM
            var allRefs = new List<Tuple<string, MainStringRef[]>>();

            var tptTuple = EbTextTables.ReadTptRefs(ebRom);
            allRefs.Add(Tuple.Create("eb-tpt-primary", tptTuple.Item1));
            allRefs.Add(Tuple.Create("eb-tpt-secondary", tptTuple.Item2));
            allRefs.Add(Tuple.Create("eb-battle-actions", EbTextTables.ReadBattleActionRefs(ebRom)));
            allRefs.Add(Tuple.Create("eb-prayers", EbTextTables.ReadPrayerRefs(ebRom)));
            allRefs.Add(Tuple.Create("eb-item-help", EbTextTables.ReadItemHelpRefs(ebRom)));
            allRefs.Add(Tuple.Create("eb-psi-help", EbTextTables.ReadPsiHelpRefs(ebRom)));
            allRefs.Add(Tuple.Create("eb-phone", EbTextTables.ReadPhoneRefs(ebRom)));
            allRefs.Add(Tuple.Create("eb-enemy-encounters", EbTextTables.ReadEnemyEncounters(ebRom)));
            allRefs.Add(Tuple.Create("eb-enemy-deaths", EbTextTables.ReadEnemyDeaths(ebRom)));

            // Decompile
            var allPointers = allRefs.SelectMany(rl => rl.Item2).Select(r => r.OldPointer);
            ebDecompiler.LabelMap.AddRange(allPointers);

            IList<int[]> textRanges = new List<int[]>();
            textRanges.Add(new int[] { 0x50000, 0x5FFEC });
            textRanges.Add(new int[] { 0x60000, 0x6FFE3 });
            textRanges.Add(new int[] { 0x70000, 0x7FF40 });
            textRanges.Add(new int[] { 0x80000, 0x8BC2D });
            textRanges.Add(new int[] { 0x8D9ED, 0x8FFF3 });
            textRanges.Add(new int[] { 0x90000, 0x9FF2F });
            textRanges.Add(new int[] { 0x2F4E20, 0x2FA460 });

            var strings = new List<string>();
            foreach (var range in textRanges)
            {
                ebDecompiler.ScanRange(ebRom, range[0], range[1]);
            }

            foreach (var range in textRanges)
            {
                strings.Add(ebDecompiler.DecompileRange(ebRom, range[0], range[1], true));
            }

            // Update labels for all refs and write to JSON
            foreach (var refList in allRefs)
            {
                foreach (var stringRef in refList.Item2)
                    stringRef.Label = ebDecompiler.LabelMap.Labels[stringRef.OldPointer];

                File.WriteAllText(Path.Combine(options.WorkingDirectory, refList.Item1 + ".json"),
                    JsonConvert.SerializeObject(refList.Item2, Formatting.Indented));
            }

            // Write the strings
            File.WriteAllText(Path.Combine(options.WorkingDirectory, "eb-strings.txt"), String.Join(Environment.NewLine, strings));
        }

        static void DecompileM12()
        {
            // Pull all string refs from the ROM
            var allRefs = new List<Tuple<string, MainStringRef[]>>();

            var tptTuple = M12TextTables.ReadTptRefs(m12Rom);
            allRefs.Add(Tuple.Create("m12-tpt-primary", tptTuple.Item1));
            allRefs.Add(Tuple.Create("m12-tpt-secondary", tptTuple.Item2));
            allRefs.Add(Tuple.Create("m12-psi-help", M12TextTables.ReadPsiHelpRefs(m12Rom)));
            allRefs.Add(Tuple.Create("m12-battle-actions", M12TextTables.ReadBattleActionRefs(m12Rom)));
            allRefs.Add(Tuple.Create("m12-item-help", M12TextTables.ReadItemHelpRefs(m12Rom)));
            allRefs.Add(Tuple.Create("m12-movements", M12TextTables.ReadMovementRefs(m12Rom)));
            allRefs.Add(Tuple.Create("m12-objects", M12TextTables.ReadObjectRefs(m12Rom)));
            allRefs.Add(Tuple.Create("m12-phone-list", M12TextTables.ReadPhoneRefs(m12Rom)));
            allRefs.Add(Tuple.Create("m12-unknown", M12TextTables.ReadUnknownRefs(m12Rom)));
            allRefs.Add(Tuple.Create("m12-enemy-encounters", M12TextTables.ReadEnemyEncounters(m12Rom)));
            allRefs.Add(Tuple.Create("m12-enemy-deaths", M12TextTables.ReadEnemyDeaths(m12Rom)));
            allRefs.Add(Tuple.Create("m12-prayers", M12TextTables.ReadPrayerRefs(m12Rom)));
            allRefs.Add(Tuple.Create("m12-asmrefs", M12TextTables.ReadAsmRefs(m12Rom)));

            // Decompile
            var allPointers = allRefs.SelectMany(rl => rl.Item2).Select(r => r.OldPointer);
            m12Decompiler.LabelMap.AddRange(allPointers);

            var strings = new List<string>();
            m12Decompiler.ScanRange(m12Rom, 0x3697F, 0x8C4B0);
            strings.Add(m12Decompiler.DecompileRange(m12Rom, 0x3697F, 0x8C4B0, true));

            // Update labels for all refs
            foreach (var refList in allRefs)
            {
                foreach (var stringRef in refList.Item2)
                    stringRef.Label = m12Decompiler.LabelMap.Labels[stringRef.OldPointer];
            }

            // Write to JSON
            foreach (var refList in allRefs)
            {
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

            // PSI targets
            var miscText2 = M12TextTables.ReadPsiTargets(m12Rom);
            DecompileFixedStringCollection(m12Decompiler, m12Rom, "m12-psitargets", miscText2);
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

        static void CompileM12()
        {
            int baseAddress = 0xB80000;
            int referenceAddress = baseAddress;
            var buffer = new List<byte>();

            // Get the strings
            string m12Strings = File.ReadAllText(Path.Combine(options.WorkingDirectory, "m12-strings-english.txt"));

            // Compile
            m12Compiler.ScanString(m12Strings, ref referenceAddress, ebCharLookup, false);
            referenceAddress = baseAddress;
            m12Compiler.CompileString(m12Strings, buffer, ref referenceAddress, ebCharLookup);
            File.WriteAllBytes(Path.Combine(options.WorkingDirectory, "m12-main-strings.bin"), buffer.ToArray());

            // Update labels
            string[] labelFiles = {
                                      "m12-tpt-primary",
                                      "m12-tpt-secondary",
                                      "m12-psi-help",
                                      "m12-battle-actions",
                                      "m12-item-help",
                                      "m12-movements",
                                      "m12-objects",
                                      "m12-phone-list",
                                      "m12-unknown",
                                      "m12-asmrefs",
                                      "m12-enemy-encounters",
                                      "m12-enemy-deaths",
                                      "m12-prayers"
                                  };

            using (var labelAsmFile = File.CreateText(Path.Combine(options.WorkingDirectory, "m12-main-strings.asm")))
            {
                labelAsmFile.WriteLine(String.Format("org ${0:X}; incbin m12-main-strings.bin", baseAddress | 0x8000000));
                labelAsmFile.WriteLine();
                
                foreach (var file in labelFiles)
                {
                    var mainStringRefs = JsonConvert.DeserializeObject<MainStringRef[]>(File.ReadAllText(
                        Path.Combine(options.WorkingDirectory, file + ".json")));

                    foreach (var stringRef in mainStringRefs)
                    {
                        labelAsmFile.WriteLine(String.Format("org ${0:X}; dd ${1:X8}",
                            stringRef.PointerLocation | 0x8000000, m12Compiler.AddressMap[stringRef.Label] | 0x8000000));
                    }
                }
            }

            IncludeFile.WriteLine("incsrc m12-main-strings.asm");
        }

        static void CompileM12Misc()
        {
            int referenceAddress = 0xB70000;

            // Item names
            CompileM12MiscStringCollection("m12-itemnames", ref referenceAddress);
            
            // Misc text
            CompileM12MiscStringCollection("m12-misctext", ref referenceAddress);

            // PSI text
            CompileM12MiscStringCollection("m12-psitext", ref referenceAddress);

            // Enemy names
            CompileM12MiscStringCollection("m12-enemynames", ref referenceAddress);

            // PSI names
            var newPsiPointers = CompileM12FixedStringCollection("m12-psinames", ref referenceAddress);

            // Fix pointers to specific PSI strings
            int psiPointer = newPsiPointers[1];
            int[] updateAddresses = {
                                        0xC21AC,
                                        0xC2364,
                                        0xC2420,
                                        0xC24DC,
                                        0xD3998
                                    };

            IncludeFile.WriteLine();
            IncludeFile.WriteLine("// Fix pointers to \"PSI \"");
            foreach (var address in updateAddresses)
            {
                IncludeFile.WriteLine(String.Format("org ${0:X}; dd ${1:X8}",
                    address | 0x8000000, psiPointer | 0x8000000));
            }

            // PSI targets
            CompileM12FixedStringCollection("m12-psitargets", ref referenceAddress);
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
                foreach (var str in stringCollection.StringRefs.OrderBy(s => s.Index))
                {
                    offsetFile.WriteLine(String.Format("org ${0:X}; dd ${1:X8}",
                        str.OffsetLocation | 0x8000000, referenceAddress - stringCollection.StringsLocation));

                    m12Compiler.CompileString(str.New, buffer, ref referenceAddress, ebCharLookup);
                }
            }

            // Write the buffer
            File.WriteAllBytes(Path.Combine(options.WorkingDirectory, name + ".bin"), buffer.ToArray());

            // Add to the include file
            IncludeFile.WriteLine("incsrc " + name + ".asm");
        }

        static IList<int> CompileM12FixedStringCollection(string name, ref int referenceAddress)
        {
            int baseAddress = referenceAddress;
            var buffer = new List<byte>();
            var newPointers = new List<int>();

            // Read the JSON
            FixedStringCollection stringCollection = JsonConvert.DeserializeObject<FixedStringCollection>(
                File.ReadAllText(Path.Combine(options.WorkingDirectory, name + ".json")));

            // Open the data ASM file
            using (var offsetFile = File.CreateText(Path.Combine(options.WorkingDirectory, name + ".asm")))
            {
                // Include the binfile
                offsetFile.WriteLine(String.Format("org ${0:X}; incbin {1}.bin",
                    baseAddress | 0x8000000, name));
                offsetFile.WriteLine();

                // Update table pointers
                foreach (int tablePointer in stringCollection.TablePointers)
                {
                    offsetFile.WriteLine(String.Format("org ${0:X}; dd ${1:X8}",
                        tablePointer | 0x8000000, baseAddress | 0x8000000));
                }

                // Compile all strings
                foreach (var str in stringCollection.StringRefs.OrderBy(s => s.Index))
                {
                    newPointers.Add(referenceAddress);
                    m12Compiler.CompileString(str.New, buffer, ref referenceAddress, ebCharLookup, stringCollection.EntryLength);
                }
            }

            // Write the buffer
            File.WriteAllBytes(Path.Combine(options.WorkingDirectory, name + ".bin"), buffer.ToArray());

            // Add to the include file
            IncludeFile.WriteLine("incsrc " + name + ".asm");

            return newPointers;
        }
    }
}
