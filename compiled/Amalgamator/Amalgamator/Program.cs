using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.IO;
using System.Diagnostics;
using Fclp;
using ELFSharp.ELF;
using ELFSharp.ELF.Sections;

namespace Amalgamator
{
    class Program
    {
        const string GccExec = "arm-none-eabi-gcc";
        const string LdExec = "arm-none-eabi-ld";
        const string CompiledAsmFile = "m2-compiled.asm";
        const string ArmipsExec = "armips.exe";
        const string HackFile = "m2-hack.asm";
        const string ArmipsSymFile = "armips-symbols.sym";
        const string LinkerScript = "linker.ld";
        const string LinkedObjectFile = "linked.o";

        const string ArmipsSymbolRegex = @"([0-9a-fA-F]{8}) ([^\.@]\S+)";

        static int Main(string[] args)
        {
            int exitCode = MainInternal(args);
            return exitCode;
        }

        // I'm having Main wrap everything so that it's easier to break on error before the program returns
        static int MainInternal(string[] args)
        {
            var options = GetOptions(args);
            if (options == null)
                return 1;

            var functionSymbols = new Dictionary<string, uint>();
            var undefinedSymbols = new HashSet<string>();
            var linkerScript = new StringBuilder();

            foreach (string codeFile in options.CodeFiles)
            {
                bool success = CompileCodeFile(codeFile);
                if (!success)
                {
                    Console.Error.WriteLine($"Error compiling {codeFile}");
                    return 2;
                }

                // Skip the dummy function stubs from ext.o
                if (codeFile == "ext.c")
                    continue;

                var elf = ELFReader.Load(GetObjectFileName(codeFile));
                var symbols = elf.GetSection(".symtab") as SymbolTable<uint>;

                foreach (var symbol in symbols.Entries.Where(
                    s => s.Type == SymbolType.Function && s.Binding.HasFlag(SymbolBinding.Global)))
                {
                    functionSymbols.Add(symbol.Name, symbol.Value);
                }

                foreach (var symbol in symbols.Entries.Where(
                    s => s.Type == SymbolType.NotSpecified && s.Binding.HasFlag(SymbolBinding.Global) && s.PointedSectionIndex == 0))
                {
                    undefinedSymbols.Add(symbol.Name);
                }
            }

            GenerateCompiledLabelsFile(options.GetRootFile(CompiledAsmFile),
                functionSymbols, options.CompiledAddress);

            if (!RunAssembler(options.RootDirectory))
                return 3;

            linkerScript.AppendLine($"SECTIONS {{ .text 0x{options.CompiledAddress:X} : {{ *(.text .data .rodata) }} }}");

            foreach (var sym in EnumerateArmipsSymbols(options.GetRootFile(ArmipsSymFile))
                .Where(s => undefinedSymbols.Contains(s.Key)))
            {
                linkerScript.AppendLine($"{sym.Key} = 0x{sym.Value:X};");
            }

            File.WriteAllText(LinkerScript, linkerScript.ToString());

            if (!RunLinker(options.RootDirectory, options.CodeFiles.Select(c => GetObjectFileName(c))))
                return 4;

            byte[] code = GenerateCompiledBinfile();
            if (code == null)
                return 5;

            RemoveUnwantedCodeDataSymbol(options.GetRootFile(ArmipsSymFile), options.CompiledAddress);
            IncludeBinfile(options.GetRootFile(options.RomName), code, options.CompiledAddress);

            return 0;
        }

        static Options GetOptions(string[] args)
        {
            var options = new Options();
            var parser = new FluentCommandLineParser();

            parser.Setup<string>('c', "compiled-address")
                .Callback(i => options.CompiledAddress = (int)new System.ComponentModel.Int32Converter().ConvertFromString(i))
                .Required();

            parser.Setup<string>('d', "root-directory")
                .Callback(s => options.RootDirectory = s);

            parser.Setup<string>('r', "rom-file")
                .Callback(s => options.RomName = s)
                .Required();

            parser.Setup<List<string>>('i', "input-files")
                .Callback(s => options.CodeFiles = s)
                .Required();

            var result = parser.Parse(args);

            if (result.HasErrors)
                Console.WriteLine(result.ErrorText);

            return result.HasErrors ? null : options;
        }

        static int ParsePossiblyHexNumber(string str)
        {
            return (int)new System.ComponentModel.Int32Converter().ConvertFromString(str);
        }

        static int RunLocalProcess(string fileName, params string[] args)
            => RunProcess(fileName, null, args);

        static int RunProcess(string fileName, string workingDirectory, params string[] args)
            => RunProcess(fileName, Process_OutputDataReceived, Process_ErrorDataReceived, workingDirectory, args);

        static int RunProcess(string fileName,
            DataReceivedEventHandler outputCallback,
            DataReceivedEventHandler errorCallback,
            string workingDirectory,
            params string[] args)
        {
            var process = new Process();
            process.StartInfo.FileName = Path.Combine((workingDirectory ?? ""), fileName);
            process.StartInfo.Arguments = String.Join(" ", args);
            if (workingDirectory != null)
            {
                process.StartInfo.WorkingDirectory = Path.GetFullPath(workingDirectory);
            }

            Console.WriteLine($"Executing: {process.StartInfo.FileName} {process.StartInfo.Arguments}");

            process.StartInfo.CreateNoWindow = true;
            process.StartInfo.UseShellExecute = false;

            process.StartInfo.RedirectStandardError = true;
            process.StartInfo.RedirectStandardOutput = true;

            if (errorCallback != null)
                process.ErrorDataReceived += errorCallback;

            if (outputCallback != null)
                process.OutputDataReceived += outputCallback;

            process.Start();
            process.BeginErrorReadLine();
            process.BeginOutputReadLine();
            process.WaitForExit();

            return process.ExitCode;
        }

        static int RunProcess(string fileName, out string standardOutput, params string[] args)
        {
            var outputBuilder = new StringBuilder();
            DataReceivedEventHandler outputCallback = (o, e) => outputBuilder.AppendLine(e.Data);

            int exitCode = RunProcess(fileName, outputCallback, null, null, args);
            standardOutput = outputBuilder.ToString();

            return exitCode;
        }

        static string GetObjectFileName(string codeFileName)
        {
            return Path.GetFileNameWithoutExtension(codeFileName) + ".o";
        }

        static void Process_OutputDataReceived(object sender, DataReceivedEventArgs e)
        {
            if (!string.IsNullOrEmpty(e.Data))
                Console.Out.WriteLine(e.Data);
        }

        static void Process_ErrorDataReceived(object sender, DataReceivedEventArgs e)
        {
            if (!string.IsNullOrEmpty(e.Data))
                Console.Error.WriteLine(e.Data);
        }

        static bool CompileCodeFile(string fileName)
        {
            string objectName = GetObjectFileName(fileName);

            return RunLocalProcess(GccExec,
                "-o", objectName,
                "-c",
                "-O3",
                fileName,
                "-march=armv4t",
                "-mtune=arm7tdmi",
                "-mthumb",
                "-mno-long-calls") == 0;
        }

        static IEnumerable<KeyValuePair<string, int>> ParseAddressSymbolMatches(IEnumerable<Match> matches)
        {
            var symbols = new Dictionary<string, int>();

            foreach (var match in matches)
            {
                // There should be exactly three groups (one for the full match + 2 captured groups)
                if (match.Groups.Count != 3)
                    continue;

                string addressString = match.Groups[1].Value;
                string symbolName = match.Groups[2].Value;
                int address = int.Parse(addressString, System.Globalization.NumberStyles.HexNumber);

                symbols.Add(symbolName, address);
            }

            return symbols;
        }

        static IEnumerable<KeyValuePair<string, int>> EnumerateArmipsSymbols(string armipsSymbolsFile)
        {
            string armipsSymbols = File.ReadAllText(armipsSymbolsFile);

            var regex = new Regex(ArmipsSymbolRegex);
            var matches = regex.Matches(armipsSymbols).Cast<Match>();
            return ParseAddressSymbolMatches(matches);
        }

        static void GenerateCompiledLabelsFile(string fileName,
            IEnumerable<KeyValuePair<string, uint>> functionSymbols, int compiledAddress)
        {
            using (var writer = File.CreateText(fileName))
            {
                // Need to clear the 1 bit because armips requires aligned label addresses
                foreach (var kv in functionSymbols)
                    writer.WriteLine($".definelabel {kv.Key},0x{(kv.Value & ~1) + compiledAddress:X}");
            }
        }

        static bool RunAssembler(string rootDirectory)
        {
            return RunProcess(ArmipsExec, rootDirectory, HackFile, "-sym", ArmipsSymFile) == 0;
        }

        static bool RunLinker(string rootDirectory, IEnumerable<string> objectFiles)
        {
            return RunLocalProcess(LdExec,
                "-o", LinkedObjectFile,
                String.Join(" ", objectFiles),
                "-T", LinkerScript) == 0;
        }

        static byte[] GenerateCompiledBinfile()
        {
            var code = ExtractObjectSection(LinkedObjectFile, ".text");
            return code;
        }

        static byte[] ExtractObjectSection(string objectFile, string sectionName)
        {
            var elf = ELFReader.Load(objectFile);
            var section = elf.GetSection(sectionName);
            return section.GetContents();
        }

        static void RemoveUnwantedCodeDataSymbol(string symbolFile, int compiledAddress)
        {
            var symbols = File.ReadAllLines(symbolFile).ToList();

            int unwantedIndex = symbols.FindIndex(l =>
                 l.StartsWith(compiledAddress.ToString("X8")) &&
                 l.Substring(9, 5) == ".byt:");

            if (unwantedIndex >= 0)
                symbols.RemoveAt(unwantedIndex);

            File.WriteAllLines(symbolFile, symbols.ToArray());
        }

        static void IncludeBinfile(string outputFile, byte[] data, int compiledAddress)
        {
            byte[] output = File.ReadAllBytes(outputFile);
            Array.Copy(data, 0, output, compiledAddress & 0x1FFFFFF, data.Length);
            File.WriteAllBytes(outputFile, output);
        }
    }

    class Options
    {
        public int CompiledAddress { get; set; }
        public string RootDirectory { get; set; }
        public string RomName { get; set; }
        public List<string> CodeFiles { get; set; }

        public string GetRootFile(string fileName)
        {
            return Path.Combine(Path.GetFullPath(RootDirectory), fileName);
        }

        public string GetQuotedRootFile(string fileName)
        {
            return "\"" + GetRootFile(fileName) + "\"";
        }
    }
}
