using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptTool
{
    class EbTextTables
    {
        public static Tuple<MainStringRef[], MainStringRef[]> ReadTptRefs(byte[] rom)
        {
            var primaryRefs = new List<MainStringRef>();
            var secondaryRefs = new List<MainStringRef>();

            int address = 0xF8985;
            int entries = 1584;

            for (int i = 0; i < entries; i++)
            {
                int firstPointer = rom.ReadSnesPointer(address + 9);
                if (firstPointer != 0)
                    primaryRefs.Add(new MainStringRef { Index = i, PointerLocation = address + 9, OldPointer = firstPointer });

                byte type = rom[address];
                if (type != 2)
                {
                    int secondPointer = rom.ReadSnesPointer(address + 13);
                    if (secondPointer != 0)
                        secondaryRefs.Add(new MainStringRef { Index = i, PointerLocation = address + 13, OldPointer = secondPointer });
                }

                address += 17;
            }

            return Tuple.Create(primaryRefs.ToArray(), secondaryRefs.ToArray());
        }

        public static MainStringRef[] ReadBattleActionRefs(byte[] rom)
        {
            var refs = new List<MainStringRef>();
            int address = 0x157B68;
            for (int i = 0; i < 318; i++)
            {
                int pointer = rom.ReadSnesPointer(address + 4);
                if (pointer != 0)
                    refs.Add(new MainStringRef { Index = i, PointerLocation = address + 4, OldPointer = pointer });
                address += 12;
            }
            return refs.ToArray();
        }

        public static MainStringRef[] ReadPrayerRefs(byte[] rom)
        {
            var refs = new List<MainStringRef>();
            int address = 0x4A309;
            for (int i = 0; i < 10; i++)
            {
                int pointer = rom.ReadSnesPointer(address);
                if (pointer != 0)
                    refs.Add(new MainStringRef { Index = i, PointerLocation = address, OldPointer = pointer });
                address += 4;
            }
            return refs.ToArray();
        }

        public static MainStringRef[] ReadItemHelpRefs(byte[] rom)
        {
            var refs = new List<MainStringRef>();
            int address = 0x155000;
            for (int i = 0; i < 254; i++)
            {
                int pointer = rom.ReadSnesPointer(address + 0x23);
                if (pointer != 0)
                    refs.Add(new MainStringRef { Index = i, PointerLocation = address + 0x23, OldPointer = pointer });
                address += 39;
            }
            return refs.ToArray();
        }

        public static MainStringRef[] ReadPsiHelpRefs(byte[] rom)
        {
            var refs = new List<MainStringRef>();
            int address = 0x158A50;
            for (int i = 0; i < 53; i++)
            {
                int pointer = rom.ReadSnesPointer(address + 11);
                if (pointer != 0)
                    refs.Add(new MainStringRef { Index = i, PointerLocation = address + 11, OldPointer = pointer });
                address += 15;
            }
            return refs.ToArray();
        }

        public static MainStringRef[] ReadPhoneRefs(byte[] rom)
        {
            var refs = new List<MainStringRef>();
            int address = 0x157AAE;
            for (int i = 0; i < 6; i++)
            {
                int pointer = rom.ReadSnesPointer(address + 0x1B);
                if (pointer != 0)
                    refs.Add(new MainStringRef { Index = i, PointerLocation = address + 0x1B, OldPointer = pointer });
                address += 31;
            }
            return refs.ToArray();
        }

        public static MainStringRef[] ReadEnemyEncounters(byte[] rom)
        {
            var refs = new List<MainStringRef>();
            int address = 0x159589;
            for (int i = 0; i < 231; i++)
            {
                int pointer = rom.ReadSnesPointer(address + 0x2D);
                if (pointer != 0)
                    refs.Add(new MainStringRef { Index = i, PointerLocation = address + 0x2D, OldPointer = pointer });

                address += 94;
            }
            return refs.ToArray();
        }

        public static MainStringRef[] ReadEnemyDeaths(byte[] rom)
        {
            var refs = new List<MainStringRef>();
            int address = 0x159589;
            for (int i = 0; i < 231; i++)
            {
                int pointer = rom.ReadSnesPointer(address + 0x31);
                if (pointer != 0)
                    refs.Add(new MainStringRef { Index = i, PointerLocation = address + 0x31, OldPointer = pointer });

                address += 94;
            }
            return refs.ToArray();
        }

        public static FixedStringCollection ReadEnemyNames(byte[] rom)
        {
            var refs = new List<FixedStringRef>();
            int address = 0x159589;
            for (int i = 0; i < 0xE7; i++)
            {
                refs.Add(new FixedStringRef
                {
                    Index = i,
                    OldPointer = address + 1
                });
                address += 94;
            }

            return new FixedStringCollection
            {
                EntryLength = 25,
                NumEntries = 0xE7,
                StringRefs = refs,
                StringsLocation = 0x159589
            };
        }

        public static MainStringRef[][] ReadDoors(byte[] rom)
        {
            var doorRefs = new List<MainStringRef>();
            int doorConfigAddress = 0xF0000;

            int[][] gaps = new int[][] {
                new int[] { 0xF0580, 0xF05AC },
                new int[] { 0xF05D8, 0xF05F8 },
                new int[] { 0xF0624, 0xF0648 },
                new int[] { 0xF0997, 0xF09B7 },
                new int[] { 0xF0ACA, 0xF0AD2 },
                new int[] { 0xF0DDF, 0xF0DE7 },
                new int[] { 0xF0E34, 0xF0E58 },
                new int[] { 0xF0EF2, 0xF0EF6 },
                new int[] { 0xF127C, 0xF1280 },
                new int[] { 0xF13A9, 0xF13AD },
                new int[] { 0xF1B74, 0xF1B80 },
                new int[] { 0xF1B8B, 0xF1BA3 },
                new int[] { 0xF1DB3, 0xF1DD3 },
                new int[] { 0xF1DE9, 0xF1DF5 },
                new int[] { 0xF1F4A, 0xF1F6C },
                new int[] { 0xF20E2, 0xF20F7 },
                new int[] { 0xF21E9, 0xF2299 },
                new int[] { 0xF23B7, 0xF23C3 },
                new int[] { 0xF25A7, 0xF25BF },
                new int[] { 0xF2643, 0xF264F } };

            int index = 0;
            while (doorConfigAddress < 0xF264F)
            {
                // Check if we're at a gap
                var gapMatch = gaps.FirstOrDefault(g => g[0] == doorConfigAddress);
                if (gapMatch != null)
                {
                    doorConfigAddress = gapMatch[1];
                    continue;
                }

                // Read current door
                int pointer = rom.ReadSnesPointer(doorConfigAddress);
                int flag = rom.ReadShort(doorConfigAddress + 4);
                int temp = rom.ReadShort(doorConfigAddress + 6);
                int y = temp & 0x3FFF;
                int direction = (temp >> 14) & 3;
                int x = rom.ReadShort(doorConfigAddress + 8);
                int style = rom[doorConfigAddress + 10];

                doorRefs.Add(new MainStringRef
                {
                    Index = index,
                    OldPointer = pointer,
                    PointerLocation = doorConfigAddress
                });

                doorConfigAddress += 11;
                index++;
            }

            // The first 14 gaps are just pointer arrays
            var doorGapRefs = new List<MainStringRef>();
            var dungeonManRefs = new List<MainStringRef>();
            int gapIndex = 0;
            for (int i = 0; i < 14; i++)
            {
                var gap = gaps[i];
                for (int address = gap[0]; address < gap[1]; address += 4)
                    doorGapRefs.Add(new MainStringRef
                    {
                        Index = gapIndex++,
                        OldPointer = rom.ReadSnesPointer(address),
                        PointerLocation = address
                    });
            }

            // The 15th gap is an array of (pointer, flag), except the last element, which is just a pointer
            for (int address = gaps[14][0]; address < gaps[14][1]; address += 6)
                doorGapRefs.Add(new MainStringRef
                {
                    Index = gapIndex++,
                    OldPointer = rom.ReadSnesPointer(address),
                    PointerLocation = address
                });

            // 16th gap is fucky, there's a pointer at the start and two at the end, with garbage in between
            int gapAddress = gaps[15][0];
            doorGapRefs.Add(new MainStringRef
            {
                Index = gapIndex++,
                OldPointer = rom.ReadSnesPointer(gapAddress),
                PointerLocation = gapAddress
            });
            doorGapRefs.Add(new MainStringRef
            {
                Index = gapIndex++,
                OldPointer = rom.ReadSnesPointer(gapAddress + 13),
                PointerLocation = gapAddress + 13
            });
            doorGapRefs.Add(new MainStringRef
            {
                Index = gapIndex++,
                OldPointer = rom.ReadSnesPointer(gapAddress + 17),
                PointerLocation = gapAddress + 17
            });

            // 17th gap is Dungeon Man signs
            int dungeonManIndex = 0;
            for (int address = gaps[16][0]; address < gaps[16][1]; address += 4)
            {
                dungeonManRefs.Add(new ScriptTool.MainStringRef
                {
                    Index = dungeonManIndex++,
                    OldPointer = rom.ReadSnesPointer(address),
                    PointerLocation = address
                });
            }

            // Remaining gaps are pointer arrays
            for (int i = 17; i < 20; i++)
            {
                var gap = gaps[i];
                for (int address = gap[0]; address < gap[1]; address += 4)
                    doorGapRefs.Add(new MainStringRef
                    {
                        Index = gapIndex++,
                        OldPointer = rom.ReadSnesPointer(address),
                        PointerLocation = address
                    });
            }

            return new MainStringRef[][] { doorRefs.ToArray(), doorGapRefs.ToArray(), dungeonManRefs.ToArray() };
        }
    }
}
