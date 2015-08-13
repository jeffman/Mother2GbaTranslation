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
    }
}
