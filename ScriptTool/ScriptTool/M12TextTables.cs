using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptTool
{
    class M12TextTables
    {
        private static int[] StupidIndices =
        {
            0xB9, 0xBF, 0xC0, 0x164, 0x169, 
            0x16D, 0x16F, 0x171, 0x1B0, 0x1B1,
            0x1B3, 0x1C1, 0x233, 0x239, 0x247,
            0x286, 0x2AD, 0x2AE, 0x2AF, 0x2E7,
            0x30A, 0x318, 0x3E1, 0x458, 0x45D,
            0x48C, 0x48D, 0x514, 0x515, 0x516,
            0x57D
        };

        public static MainStringRef[] ReadTptRefs(byte[] rom)
        {
            var refs = new List<MainStringRef>();

            int address = 0x8EB14;
            int entries = 1584;

            for (int i = 0; i < entries; i++)
            {
                if (StupidIndices.Contains(i))
                {
                    int firstPointer = rom.ReadGbaPointer(address + 9);
                    if (firstPointer != 0)
                        refs.Add(new MainStringRef { Index = i, PointerLocation = address + 9, OldPointer = firstPointer });

                    byte type = rom[address];
                    if (type != 2)
                    {
                        int secondPointer = rom.ReadGbaPointer(address + 13);
                        if (secondPointer != 0)
                            refs.Add(new MainStringRef { Index = i, PointerLocation = address + 13, OldPointer = secondPointer });
                    }
                }
                else
                {
                    int firstPointer = rom.ReadGbaPointer(address + 12);
                    if (firstPointer != 0)
                        refs.Add(new MainStringRef { Index = i, PointerLocation = address + 12, OldPointer = firstPointer });

                    byte type = rom[address];
                    if (type != 2)
                    {
                        int secondPointer = rom.ReadGbaPointer(address + 16);
                        if (secondPointer != 0)
                            refs.Add(new MainStringRef { Index = i, PointerLocation = address + 16, OldPointer = secondPointer });
                    }
                }

                address += 20;
            }

            return refs.ToArray();
        }

        /*public static StringRef[] ReadBattleActionRefs(byte[] rom)
        {
            var refs = new List<StringRef>();
            int address = 0x157B68;
            for (int i = 0; i < 318; i++)
            {
                int pointer = rom.ReadPointer(address + 4);
                if (pointer != 0)
                    refs.Add(new StringRef { Index = i, PointerLocation = address + 4, OldPointer = pointer });
                address += 12;
            }
            return refs.ToArray();
        }

        public static StringRef[] ReadPrayerRefs(byte[] rom)
        {
            var refs = new List<StringRef>();
            int address = 0x4A309;
            for (int i = 0; i < 10; i++)
            {
                int pointer = rom.ReadPointer(address);
                if (pointer != 0)
                    refs.Add(new StringRef { Index = i, PointerLocation = address, OldPointer = pointer });
                address += 4;
            }
            return refs.ToArray();
        }

        public static StringRef[] ReadItemHelpRefs(byte[] rom)
        {
            var refs = new List<StringRef>();
            int address = 0x155000;
            for (int i = 0; i < 254; i++)
            {
                int pointer = rom.ReadPointer(address + 0x23);
                if (pointer != 0)
                    refs.Add(new StringRef { Index = i, PointerLocation = address + 0x23, OldPointer = pointer });
                address += 39;
            }
            return refs.ToArray();
        }

        public static StringRef[] ReadPsiHelpRefs(byte[] rom)
        {
            var refs = new List<StringRef>();
            int address = 0x158A50;
            for (int i = 0; i < 53; i++)
            {
                int pointer = rom.ReadPointer(address + 11);
                if (pointer != 0)
                    refs.Add(new StringRef { Index = i, PointerLocation = address + 11, OldPointer = pointer });
                address += 15;
            }
            return refs.ToArray();
        }

        public static StringRef[] ReadPhoneRefs(byte[] rom)
        {
            var refs = new List<StringRef>();
            int address = 0x157AAE;
            for (int i = 0; i < 6; i++)
            {
                int pointer = rom.ReadPointer(address + 0x1B);
                if (pointer != 0)
                    refs.Add(new StringRef { Index = i, PointerLocation = address + 0x1B, OldPointer = pointer });
                address += 31;
            }
            return refs.ToArray();
        }

        public static StringRef[] ReadEnemyTextRefs(byte[] rom)
        {
            var refs = new List<StringRef>();
            int address = 0x159589;
            for (int i = 0; i < 231; i++)
            {
                int pointer = rom.ReadPointer(address + 0x2D);
                if (pointer != 0)
                    refs.Add(new StringRef { Index = i, PointerLocation = address + 0x2D, OldPointer = pointer });

                pointer = rom.ReadPointer(address + 0x31);
                if (pointer != 0)
                    refs.Add(new StringRef { Index = i, PointerLocation = address + 0x31, OldPointer = pointer });

                address += 94;
            }
            return refs.ToArray();
        }*/

        public static MiscStringCollection ReadPointerTable(byte[] rom, int tableAddress, int stringsAddress)
        {
            var refs = new List<MiscStringRef>();
            int entries = rom.ReadInt(tableAddress);

            int currentTableAddress = tableAddress;
            currentTableAddress += 4;

            for (int i = 0; i < entries; i++)
            {
                int offset = rom.ReadInt(currentTableAddress);
                refs.Add(new MiscStringRef
                {
                    OffsetLocation = currentTableAddress,
                    OldPointer = offset + stringsAddress,
                    Index = i
                });
                currentTableAddress += 4;
            }

            return new MiscStringCollection
            {
                OffsetTableLocation = tableAddress,
                StringsLocation = stringsAddress,
                StringRefs = refs
            };
        }

        public static FixedStringCollection ReadFixedStringTable(byte[] rom, int stringsAddress, int numEntries, int entryLength)
        {
            var refs = new List<FixedStringRef>();
            int currentStringAddress = stringsAddress;

            for(int i=0;i<numEntries;i++)
            {
                refs.Add(new FixedStringRef
                {
                    OldPointer = currentStringAddress,
                    Index = i
                });
                currentStringAddress += entryLength;
            }

            return new FixedStringCollection
            {
                StringsLocation = stringsAddress,
                NumEntries = numEntries,
                EntryLength = entryLength,
                StringRefs = refs
            };
        }

        public static MiscStringCollection ReadItemNames(byte[] rom)
        {
            return ReadPointerTable(rom, 0xB1AF94, 0xB1A694);
        }

        public static MiscStringCollection ReadMenuChoices(byte[] rom)
        {
            return ReadPointerTable(rom, 0xB19A64, 0xB198B4);
        }

        public static MiscStringCollection ReadMiscText(byte[] rom)
        {
            var miscStrings = ReadPointerTable(rom, 0xB17EE4, 0xB17424);

            // Flag basic mode refs
            for (int i = 0x4A; i <= 0x55; i++)
                miscStrings.StringRefs[i].BasicMode = true;

            return miscStrings;
        }

        public static MiscStringCollection ReadDadText(byte[] rom)
        {
            return ReadPointerTable(rom, 0xB18310, 0xB18160);
        }

        public static MiscStringCollection ReadPsiText(byte[] rom)
        {
            return ReadPointerTable(rom, 0xB194BC, 0xB18344);
        }

        public static MiscStringCollection ReadEnemyNames(byte[] rom)
        {
            return ReadPointerTable(rom, 0xB1A2F0, 0xB19AD0);
        }

        public static FixedStringCollection ReadPsiNames(byte[] rom)
        {
            return ReadFixedStringTable(rom, 0xB1B916, 0x12, 0xD);
        }
    }
}
