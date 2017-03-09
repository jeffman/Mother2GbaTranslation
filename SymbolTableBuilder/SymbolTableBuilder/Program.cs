using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace SymbolTableBuilder
{
    class Program
    {
        static void Main(string[] args)
        {
            // Arg 0: output file
            // Remaining args: input files to combine

            if (args.Length < 1)
            {
                Usage();
                return;
            }

            string outputFile = args[0];
            var inputFiles = args.Skip(1);
            var table = new List<string>();

            foreach (string inputFile in inputFiles)
            {
                ParseTable(inputFile, table);
            }

            using (var writer = File.CreateText(outputFile))
            {
                foreach (var line in table)
                    writer.WriteLine(line);
            }
        }

        static void Usage()
        {
            Console.WriteLine("Usage: symbols.exe [output] [input1] [input2] ...");
        }

        static void ParseTable(string inputFile, List<string> outputTable)
        {
            using (var reader = File.OpenText(inputFile))
            {
                string line;
                while ((line = reader.ReadLine()) != null)
                {
                    outputTable.Add(RemoveNamespace(line));
                }
            }
        }

        static string RemoveNamespace(string line)
        {
            int namespaceSeparatorIndex = line.IndexOf("::");
            if (namespaceSeparatorIndex >= 0)
            {
                // Backtrack to the start of the namespace
                int namespaceIndex = line.LastIndexOf(' ', namespaceSeparatorIndex);

                // Get the address chunk
                string addressChunk = line.Substring(0, namespaceIndex);

                // Get the remaining chunk
                string remainingChunk = line.Substring(namespaceSeparatorIndex + 2);

                return addressChunk + " " + remainingChunk;
            }
            else
            {
                return line;
            }
        }
    }
}
