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

        public static Tuple<MainStringRef[], MainStringRef[]> ReadTptRefs(byte[] rom)
        {
            var primaryRefs = new List<MainStringRef>();
            var secondaryRefs = new List<MainStringRef>();

            int address = 0x8EB14;
            int entries = 1584;

            for (int i = 0; i < entries; i++)
            {
                if (StupidIndices.Contains(i))
                {
                    int firstPointer = rom.ReadGbaPointer(address + 9);
                    if (firstPointer != 0)
                        primaryRefs.Add(new MainStringRef { Index = i, PointerLocation = address + 9, OldPointer = firstPointer });

                    byte type = rom[address];
                    if (type != 2)
                    {
                        int secondPointer = rom.ReadGbaPointer(address + 13);
                        if (secondPointer != 0)
                            secondaryRefs.Add(new MainStringRef { Index = i, PointerLocation = address + 13, OldPointer = secondPointer });
                    }
                }
                else
                {
                    int firstPointer = rom.ReadGbaPointer(address + 12);
                    if (firstPointer != 0)
                        primaryRefs.Add(new MainStringRef { Index = i, PointerLocation = address + 12, OldPointer = firstPointer });

                    byte type = rom[address];
                    if (type != 2)
                    {
                        int secondPointer = rom.ReadGbaPointer(address + 16);
                        if (secondPointer != 0)
                            secondaryRefs.Add(new MainStringRef { Index = i, PointerLocation = address + 16, OldPointer = secondPointer });
                    }
                }

                address += 20;
            }

            return Tuple.Create(primaryRefs.ToArray(), secondaryRefs.ToArray());
        }

        public static MainStringRef[] ReadPsiHelpRefs(byte[] rom)
        {
            var refs = new List<MainStringRef>();
            int address = 0xB2A9C0;
            for (int i = 0; i < 53; i++)
            {
                int pointer = rom.ReadGbaPointer(address + 12);
                if (pointer != 0)
                    refs.Add(new MainStringRef { Index = i, PointerLocation = address + 12, OldPointer = pointer });
                address += 16;
            }
            return refs.ToArray();
        }

        public static MainStringRef[] ReadBattleActionRefs(byte[] rom)
        {
            var refs = new List<MainStringRef>();
            int address = 0xB204E4;
            for (int i = 0; i < 318; i++)
            {
                int pointer = rom.ReadGbaPointer(address + 4);
                if (pointer != 0)
                    refs.Add(new MainStringRef { Index = i, PointerLocation = address + 4, OldPointer = pointer });
                address += 12;
            }
            return refs.ToArray();
        }

        public static MainStringRef[] ReadItemHelpRefs(byte[] rom)
        {
            var refs = new List<MainStringRef>();
            int address = 0xB1D62C;
            for (int i = 0; i < 253; i++)
            {
                int pointer = rom.ReadGbaPointer(address + 16);
                if (pointer != 0)
                    refs.Add(new MainStringRef { Index = i, PointerLocation = address + 16, OldPointer = pointer });
                address += 20;
            }
            return refs.ToArray();
        }

        public static MainStringRef[] ReadMovementRefs(byte[] rom)
        {
            var refs = new List<MainStringRef>();
            int count = 0;
            for (int address = 0x27188; address < 0x3697C; address++)
            {
                // Attempt to read a pointer
                int ptr = rom.ReadInt(address);

                // Check if it's in text range
                if (ptr >= 0x803697F && ptr < 0x808C4B0)
                {
                    // Check if the code before it is an endcode
                    ptr = ptr & 0x1FFFFFF;
                    if ((rom[ptr - 2] == 0 && rom[ptr - 1] == 0xFF) || (rom[ptr - 6] == 0x80 && rom[ptr - 5] == 0xFF))
                    {
                        refs.Add(new MainStringRef { Index = count, PointerLocation = address, OldPointer = ptr });
                        address += 3;
                    }

                    count++;
                }
            }
            return refs.ToArray();
        }

        public static MainStringRef[] ReadObjectRefs(byte[] rom)
        {
            var refs = new List<MainStringRef>();
            int address = 0x8C574;
            int index = 0;

            // 8C574 block
            while (address < 0x8D818)
            {
                int count = rom.ReadInt(address);
                if (address == 0x8D060)
                    count = 8; // bug in rom

                address += 4;

                for (int i = 0; i < count; i++)
                {
                    int pointer = rom.ReadGbaPointer(address + 12);
                    if (pointer != 0)
                    {
                        refs.Add(new MainStringRef
                        {
                            Index = index++,
                            PointerLocation = address + 12,
                            OldPointer = pointer
                        });
                    }
                    address += 16;
                }
            }

            // 8C4BB block
            address = 0x8C4BB;
            for (int i = 0; i < 17;i++)
            {
                int pointer = rom.ReadGbaPointer(address);

                refs.Add(new MainStringRef
                {
                    Index = index++,
                    PointerLocation = address,
                    OldPointer = pointer
                });

                address += 4;
            }
            
            // 8C4FF-8C573 block
            for (address = 0x8C4FF; address < 0x8C574; address++)
            {
                // Attempt to read a pointer
                int ptr = rom.ReadInt(address);

                // Check if it's in text range
                if (ptr >= 0x803697F && ptr < 0x808C4B0)
                {
                    refs.Add(new MainStringRef { Index = index++, PointerLocation = address, OldPointer = ptr & 0x1FFFFFF });
                    address += 3;
                }
            }

            return refs.ToArray();
        }

        public static MainStringRef[] ReadPhoneRefs(byte[] rom)
        {
            var refs = new List<MainStringRef>();
            int address = 0xB1B3B8;
            for (int i = 0; i < 5; i++)
            {
                int pointer = rom.ReadGbaPointer(address + 0x4);
                if (pointer != 0)
                    refs.Add(new MainStringRef { Index = i, PointerLocation = address + 4, OldPointer = pointer });
                address += 8;
            }
            return refs.ToArray();
        }

        public static MainStringRef[] ReadUnknownRefs(byte[] rom)
        {
            var refs = new List<MainStringRef>();
            int address = 0x72E404;
            for (int i = 0; i < 0xED; i++)
            {
                int pointer = rom.ReadGbaPointer(address + 8);
                if (pointer != 0)
                    refs.Add(new MainStringRef { Index = i, PointerLocation = address + 8, OldPointer = pointer });
                address += 16;
            }
            return refs.ToArray();
        }

        public static MainStringRef[] ReadEnemyEncounters(byte[] rom)
        {
            var refs = new List<MainStringRef>();
            int address = 0x739D1C;
            for (int i = 0; i < 231; i++)
            {
                int pointer = rom.ReadGbaPointer(address + 20);
                if (pointer != 0)
                    refs.Add(new MainStringRef { Index = i, PointerLocation = address + 20, OldPointer = pointer });

                address += 64;
            }
            return refs.ToArray();
        }

        public static MainStringRef[] ReadEnemyDeaths(byte[] rom)
        {
            var refs = new List<MainStringRef>();
            int address = 0x739D1C;
            for (int i = 0; i < 231; i++)
            {
                int pointer = rom.ReadGbaPointer(address + 24);
                if (pointer != 0)
                    refs.Add(new MainStringRef { Index = i, PointerLocation = address + 24, OldPointer = pointer });

                address += 64;
            }
            return refs.ToArray();
        }

        public static MainStringRef[] ReadPrayerRefs(byte[] rom)
        {
            var refs = new List<MainStringRef>();
            int address = 0xB1F59C;
            for (int i = 0; i < 10; i++)
            {
                int pointer = rom.ReadGbaPointer(address);
                if (pointer != 0)
                    refs.Add(new MainStringRef { Index = i, PointerLocation = address, OldPointer = pointer });
                address += 4;
            }
            return refs.ToArray();
        }

        private static void AddAsmRef(byte[] rom, IList<MainStringRef> refs, int index, int pointerLocation)
        {
            refs.Add(new MainStringRef
            {
                Index = index,
                PointerLocation = pointerLocation,
                OldPointer = rom.ReadGbaPointer(pointerLocation)
            });
        }

        public static MainStringRef[] ReadAsmRefs(byte[] rom)
        {
            var refs = new List<MainStringRef>();
            int index = 0;
            AddAsmRef(rom, refs, index++, 0x1EB18); // Who are you talking to?
            AddAsmRef(rom, refs, index++, 0x1EFF4); // No problem here.
            AddAsmRef(rom, refs, index++, 0x1F3F0); // No problem here.
            AddAsmRef(rom, refs, index++, 0x23F5C); // No problem here.
            AddAsmRef(rom, refs, index++, 0x1F8C4); // ... got soaked! But nothing happened. (not sure what this is?)
            AddAsmRef(rom, refs, index++, 0xCD200); // Learned PSI Teleport alpha
            AddAsmRef(rom, refs, index++, 0xDE084); // [user] fell asleep!
            AddAsmRef(rom, refs, index++, 0xDE098); // [00 FF]
            AddAsmRef(rom, refs, index++, 0xDE024); // Chicken-related
            AddAsmRef(rom, refs, index++, 0xDF1C4); // Chicken-related
            AddAsmRef(rom, refs, index++, 0xDF1E4); // Related to feeling strange
            AddAsmRef(rom, refs, index++, 0xDF21C); // Related to feeling strange
            AddAsmRef(rom, refs, index++, 0xDE9F0); // Tried to get away, but failed
            AddAsmRef(rom, refs, index++, 0xEA590); // Battle action related?
            AddAsmRef(rom, refs, index++, 0xEA5B0); // Battle action related?
            AddAsmRef(rom, refs, index++, 0xEA5D0); // Battle action related?
            AddAsmRef(rom, refs, index++, 0xE6FB8); // It tasted good
            AddAsmRef(rom, refs, index++, 0xE7000); // It did not taste good
            AddAsmRef(rom, refs, index++, 0xE5E88); // Teleport box
            AddAsmRef(rom, refs, index++, 0xE5EA4); // Teleport box
            AddAsmRef(rom, refs, index++, 0xE62B0); // Equipped
            AddAsmRef(rom, refs, index++, 0xE6508); // Equipped
            AddAsmRef(rom, refs, index++, 0xE62CC); // Could not equip
            AddAsmRef(rom, refs, index++, 0xE6528); // Could not equip
            AddAsmRef(rom, refs, index++, 0xB9C34); // Battle-related?

            AddAsmRef(rom, refs, index++, 0xE65A8); // 0x5FE45
            AddAsmRef(rom, refs, index++, 0xE6590); // 0x5FEA0
            AddAsmRef(rom, refs, index++, 0xE66D4); // 0x5FF98
            AddAsmRef(rom, refs, index++, 0xE8D30); // 0x600E6
            AddAsmRef(rom, refs, index++, 0xE8C2C); // 0x600FD
            AddAsmRef(rom, refs, index++, 0xE8CFC); // 0x60114
            AddAsmRef(rom, refs, index++, 0xE8C08); // 0x6012B
            AddAsmRef(rom, refs, index++, 0xE8CC8); // 0x60142
            AddAsmRef(rom, refs, index++, 0xE855C); // 0x60160
            AddAsmRef(rom, refs, index++, 0xE8580); // 0x6016A
            AddAsmRef(rom, refs, index++, 0xE2940); // 0x6018C
            AddAsmRef(rom, refs, index++, 0xE29CC); // 0x6018C
            AddAsmRef(rom, refs, index++, 0xE4CD8); // 0x6018C
            AddAsmRef(rom, refs, index++, 0xE4EDC); // 0x6018C
            AddAsmRef(rom, refs, index++, 0xE4FFC); // 0x6018C
            AddAsmRef(rom, refs, index++, 0xE6038); // 0x6018C
            AddAsmRef(rom, refs, index++, 0xE6110); // 0x6018C
            AddAsmRef(rom, refs, index++, 0xE3B20); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE3C0C); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE3D9C); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE3E20); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE44C8); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE454C); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE45C0); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE4620); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE4680); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE46F8); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE4758); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE47EC); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE4870); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE48C8); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE49A0); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE4A00); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE4A60); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE4AF4); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE5754); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE57B0); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE5878); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE5980); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE5A84); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE5B4C); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE5BE8); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE6AD0); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE8A48); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE9890); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE9E94); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xEA3A0); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xEA86C); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xEA8CC); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xEA90C); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xEAE80); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xEAED4); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xEB64C); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xEB70C); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xEB7CC); // 0x601A4
            AddAsmRef(rom, refs, index++, 0xE34D0); // 0x601D0
            AddAsmRef(rom, refs, index++, 0xEA9AC); // 0x601D0
            AddAsmRef(rom, refs, index++, 0xE84C4); // 0x6020F
            AddAsmRef(rom, refs, index++, 0xDF37C); // 0x6021F
            AddAsmRef(rom, refs, index++, 0xE5814); // 0x6023A
            AddAsmRef(rom, refs, index++, 0xE5858); // 0x60253
            AddAsmRef(rom, refs, index++, 0xE3CF0); // 0x6026C
            AddAsmRef(rom, refs, index++, 0xE4AD0); // 0x60282
            AddAsmRef(rom, refs, index++, 0xDEE30); // 0x6029B
            AddAsmRef(rom, refs, index++, 0xDEE40); // 0x602B7
            AddAsmRef(rom, refs, index++, 0xDEE50); // 0x602CE
            AddAsmRef(rom, refs, index++, 0xDEE7C); // 0x602EA
            AddAsmRef(rom, refs, index++, 0xEA990); // 0x6031B
            AddAsmRef(rom, refs, index++, 0xEAB4C); // 0x60336
            AddAsmRef(rom, refs, index++, 0xE2A60); // 0x60351
            AddAsmRef(rom, refs, index++, 0xE2A84); // 0x60365
            AddAsmRef(rom, refs, index++, 0xE2AB4); // 0x60374
            AddAsmRef(rom, refs, index++, 0xE2AD8); // 0x60386
            AddAsmRef(rom, refs, index++, 0xE2AFC); // 0x60397
            AddAsmRef(rom, refs, index++, 0xE2B20); // 0x603A9
            AddAsmRef(rom, refs, index++, 0xE2B44); // 0x603BA
            AddAsmRef(rom, refs, index++, 0xE2B68); // 0x603CC
            AddAsmRef(rom, refs, index++, 0xE73CC); // 0x603DF
            AddAsmRef(rom, refs, index++, 0xE73F0); // 0x603FD
            AddAsmRef(rom, refs, index++, 0xE44A4); // 0x60419
            AddAsmRef(rom, refs, index++, 0xE6168); // 0x60419
            AddAsmRef(rom, refs, index++, 0xE3D78); // 0x6043D
            AddAsmRef(rom, refs, index++, 0xE4528); // 0x6043D
            AddAsmRef(rom, refs, index++, 0xE9880); // 0x6043D
            AddAsmRef(rom, refs, index++, 0xE45FC); // 0x60459
            AddAsmRef(rom, refs, index++, 0xE465C); // 0x6047D
            AddAsmRef(rom, refs, index++, 0xE4D28); // 0x6047D
            AddAsmRef(rom, refs, index++, 0xE5C50); // 0x6047D
            AddAsmRef(rom, refs, index++, 0xE46D4); // 0x60496
            AddAsmRef(rom, refs, index++, 0xE4734); // 0x604B1
            AddAsmRef(rom, refs, index++, 0xE47C4); // 0x604CD
            AddAsmRef(rom, refs, index++, 0xE484C); // 0x604F1
            AddAsmRef(rom, refs, index++, 0xE4A3C); // 0x604F1
            AddAsmRef(rom, refs, index++, 0xEA8FC); // 0x604F1
            AddAsmRef(rom, refs, index++, 0xE48A4); // 0x6050E
            AddAsmRef(rom, refs, index++, 0xE459C); // 0x6052B
            AddAsmRef(rom, refs, index++, 0xE59D8); // 0x6052B
            AddAsmRef(rom, refs, index++, 0xE5ADC); // 0x6052B
            AddAsmRef(rom, refs, index++, 0xEA354); // 0x6052B
            AddAsmRef(rom, refs, index++, 0xE497C); // 0x60548
            AddAsmRef(rom, refs, index++, 0xE5730); // 0x60548
            AddAsmRef(rom, refs, index++, 0xE3DFC); // 0x6057E
            AddAsmRef(rom, refs, index++, 0xE49DC); // 0x6057E
            AddAsmRef(rom, refs, index++, 0xEA8BC); // 0x6057E
            AddAsmRef(rom, refs, index++, 0xEAEC0); // 0x6057E
            AddAsmRef(rom, refs, index++, 0xE3BE8); // 0x6059A
            AddAsmRef(rom, refs, index++, 0xEAE6C); // 0x6059A
            AddAsmRef(rom, refs, index++, 0xE9244); // 0x605B2
            AddAsmRef(rom, refs, index++, 0xE9A94); // 0x605B2
            AddAsmRef(rom, refs, index++, 0xE37A8); // 0x607B0
            AddAsmRef(rom, refs, index++, 0xE3738); // 0x607D0
            AddAsmRef(rom, refs, index++, 0xE3590); // 0x607EC
            AddAsmRef(rom, refs, index++, 0xE353C); // 0x60806
            AddAsmRef(rom, refs, index++, 0xE5534); // 0x60806
            AddAsmRef(rom, refs, index++, 0xE33F8); // 0x60822
            AddAsmRef(rom, refs, index++, 0xE35F0); // 0x6083A
            AddAsmRef(rom, refs, index++, 0xDF874); // 0x6085A
            AddAsmRef(rom, refs, index++, 0xE3658); // 0x6088F
            AddAsmRef(rom, refs, index++, 0xE8F84); // 0x6088F
            AddAsmRef(rom, refs, index++, 0xE344C); // 0x608A6
            AddAsmRef(rom, refs, index++, 0xDF810); // 0x608C3
            AddAsmRef(rom, refs, index++, 0xE34AC); // 0x608C3
            AddAsmRef(rom, refs, index++, 0xE89E4); // 0x608C3
            AddAsmRef(rom, refs, index++, 0xDF92C); // 0x608D7
            AddAsmRef(rom, refs, index++, 0xEAC24); // 0x608FB
            AddAsmRef(rom, refs, index++, 0xE3818); // 0x60912
            AddAsmRef(rom, refs, index++, 0xE390C); // 0x6091F
            AddAsmRef(rom, refs, index++, 0xE38E8); // 0x6093E
            AddAsmRef(rom, refs, index++, 0xE396C); // 0x6095B
            AddAsmRef(rom, refs, index++, 0xE3948); // 0x6097B
            AddAsmRef(rom, refs, index++, 0xE39CC); // 0x6099A
            AddAsmRef(rom, refs, index++, 0xE39A8); // 0x609B8
            AddAsmRef(rom, refs, index++, 0xE3A2C); // 0x609D5
            AddAsmRef(rom, refs, index++, 0xE3A08); // 0x609F8
            AddAsmRef(rom, refs, index++, 0xE578C); // 0x60A1C
            AddAsmRef(rom, refs, index++, 0xE8868); // 0x60A1C
            AddAsmRef(rom, refs, index++, 0xE8940); // 0x60A1C
            AddAsmRef(rom, refs, index++, 0xEA02C); // 0x60A1C
            AddAsmRef(rom, refs, index++, 0xEA0C8); // 0x60A1C
            AddAsmRef(rom, refs, index++, 0xE8830); // 0x60A36
            AddAsmRef(rom, refs, index++, 0xE9FCC); // 0x60A5D
            AddAsmRef(rom, refs, index++, 0xE9FE0); // 0x60A85
            AddAsmRef(rom, refs, index++, 0xE6A30); // 0x60AA7
            AddAsmRef(rom, refs, index++, 0xDF73C); // 0x60ACC
            AddAsmRef(rom, refs, index++, 0xE6918); // 0x60ACC
            AddAsmRef(rom, refs, index++, 0xEA630); // 0x60AE4
            AddAsmRef(rom, refs, index++, 0xE3A94); // 0x60B07
            AddAsmRef(rom, refs, index++, 0xE5350); // 0x60B07
            AddAsmRef(rom, refs, index++, 0xE5318); // 0x60B24
            AddAsmRef(rom, refs, index++, 0xE5DAC); // 0x60B24
            AddAsmRef(rom, refs, index++, 0xE557C); // 0x60B42
            AddAsmRef(rom, refs, index++, 0xE6D68); // 0x60B42
            AddAsmRef(rom, refs, index++, 0xE55C0); // 0x60B5C
            AddAsmRef(rom, refs, index++, 0xE6DAC); // 0x60B5C
            AddAsmRef(rom, refs, index++, 0xE4B70); // 0x60B77
            AddAsmRef(rom, refs, index++, 0xE5D50); // 0x60B91
            AddAsmRef(rom, refs, index++, 0xE5604); // 0x60BB0
            AddAsmRef(rom, refs, index++, 0xE6DF0); // 0x60BB0
            AddAsmRef(rom, refs, index++, 0xE564C); // 0x60BCC
            AddAsmRef(rom, refs, index++, 0xE6E3C); // 0x60BCC
            AddAsmRef(rom, refs, index++, 0xE5690); // 0x60BEA
            AddAsmRef(rom, refs, index++, 0xE6E88); // 0x60BEA
            AddAsmRef(rom, refs, index++, 0xE4BDC); // 0x60C05
            AddAsmRef(rom, refs, index++, 0xE61C8); // 0x60C05
            AddAsmRef(rom, refs, index++, 0xE3AFC); // 0x60C21
            AddAsmRef(rom, refs, index++, 0xE4C18); // 0x60C21
            AddAsmRef(rom, refs, index++, 0xE5F24); // 0x60C3E
            AddAsmRef(rom, refs, index++, 0xE5F54); // 0x60C70
            AddAsmRef(rom, refs, index++, 0xB8FA0); // 0x60DF3
            AddAsmRef(rom, refs, index++, 0xE0958); // 0x60DF3
            AddAsmRef(rom, refs, index++, 0xEA788); // 0x60E3F
            AddAsmRef(rom, refs, index++, 0xE3C94); // 0x60E51
            AddAsmRef(rom, refs, index++, 0xE4A94); // 0x60E51
            AddAsmRef(rom, refs, index++, 0xE70B4); // 0x60F72
            AddAsmRef(rom, refs, index++, 0xE720C); // 0x61068
            AddAsmRef(rom, refs, index++, 0xE823C); // 0x61254
            AddAsmRef(rom, refs, index++, 0xE7D4C); // 0x61AED
            AddAsmRef(rom, refs, index++, 0xE7FE0); // 0x61B20
            AddAsmRef(rom, refs, index++, 0xE803C); // 0x61BE7
            AddAsmRef(rom, refs, index++, 0xE8098); // 0x61C39
            AddAsmRef(rom, refs, index++, 0xE8108); // 0x61C8B
            AddAsmRef(rom, refs, index++, 0xE75D0); // 0x61CAA
            AddAsmRef(rom, refs, index++, 0xE4230); // 0x61CE2
            AddAsmRef(rom, refs, index++, 0xE4214); // 0x61CF9
            AddAsmRef(rom, refs, index++, 0xE3EBC); // 0x61D0A
            AddAsmRef(rom, refs, index++, 0xE3EB0); // 0x61D22
            AddAsmRef(rom, refs, index++, 0xE444C); // 0x61D36
            AddAsmRef(rom, refs, index++, 0xDDF9C); // 0x61D9E
            AddAsmRef(rom, refs, index++, 0xDE650); // 0x61DB3
            AddAsmRef(rom, refs, index++, 0xDFB24); // 0x61DC7
            AddAsmRef(rom, refs, index++, 0xDFB0C); // 0x61E17
            AddAsmRef(rom, refs, index++, 0xE1548); // 0x61E31
            AddAsmRef(rom, refs, index++, 0xE1A78); // 0x61E31
            AddAsmRef(rom, refs, index++, 0xDF9A8); // 0x61E63
            AddAsmRef(rom, refs, index++, 0xDFE70); // 0x61E63
            AddAsmRef(rom, refs, index++, 0xEC980); // 0x61E7C
            AddAsmRef(rom, refs, index++, 0xECA04); // 0x61E90
            AddAsmRef(rom, refs, index++, 0xECA84); // 0x61EA8
            AddAsmRef(rom, refs, index++, 0xECB04); // 0x61EC1
            AddAsmRef(rom, refs, index++, 0xECB84); // 0x61ED8
            AddAsmRef(rom, refs, index++, 0xECC3C); // 0x61EEE
            AddAsmRef(rom, refs, index++, 0xECCF4); // 0x61F07
            AddAsmRef(rom, refs, index++, 0xECD74); // 0x61F1C
            AddAsmRef(rom, refs, index++, 0xECE20); // 0x61F32
            AddAsmRef(rom, refs, index++, 0xECF04); // 0x61F4B
            AddAsmRef(rom, refs, index++, 0xECF94); // 0x61F64
            AddAsmRef(rom, refs, index++, 0xDFB54); // 0x61FDC
            AddAsmRef(rom, refs, index++, 0xE1644); // 0x61FDC
            AddAsmRef(rom, refs, index++, 0xE1BE0); // 0x61FDC
            AddAsmRef(rom, refs, index++, 0xE2BC4); // 0x621FA
            AddAsmRef(rom, refs, index++, 0xA0BD8); // 0x6C21F
            AddAsmRef(rom, refs, index++, 0xA0BF0); // 0x6C2E9
            AddAsmRef(rom, refs, index++, 0xA0BDC); // 0x6C3A7
            AddAsmRef(rom, refs, index++, 0xA0BF4); // 0x6C3B1
            AddAsmRef(rom, refs, index++, 0x25BB4); // 0x6D2EF
            AddAsmRef(rom, refs, index++, 0x1CF78); // 0x6D790
            AddAsmRef(rom, refs, index++, 0xA0BC0); // 0x75416
            AddAsmRef(rom, refs, index++, 0xA0C08); // 0x75416
            AddAsmRef(rom, refs, index++, 0xA0BC4); // 0x75642
            AddAsmRef(rom, refs, index++, 0xA0C0C); // 0x75642
            AddAsmRef(rom, refs, index++, 0xA0B60); // 0x7ECAF
            AddAsmRef(rom, refs, index++, 0xA0B78); // 0x7ECC9
            AddAsmRef(rom, refs, index++, 0xA0B90); // 0x7ECE3
            AddAsmRef(rom, refs, index++, 0xA0BA8); // 0x7ECFD
            AddAsmRef(rom, refs, index++, 0xA0B64); // 0x7F215
            AddAsmRef(rom, refs, index++, 0xA0B7C); // 0x7F215
            AddAsmRef(rom, refs, index++, 0xA0B94); // 0x7F215
            AddAsmRef(rom, refs, index++, 0xA0BAC); // 0x7F215
            AddAsmRef(rom, refs, index++, 0x8E028); // 0x80109
            AddAsmRef(rom, refs, index++, 0x8E230); // 0x80109
            AddAsmRef(rom, refs, index++, 0xA0B34); // 0x82208
            AddAsmRef(rom, refs, index++, 0xA0B1C); // 0x829FB
            AddAsmRef(rom, refs, index++, 0xBA580); // 0x8450D
            AddAsmRef(rom, refs, index++, 0xBA590); // 0x84563
            AddAsmRef(rom, refs, index++, 0xBA5BC); // 0x84574
            AddAsmRef(rom, refs, index++, 0xBA600); // 0x845B4
            AddAsmRef(rom, refs, index++, 0xBA6EC); // 0x845DF
            AddAsmRef(rom, refs, index++, 0xBA4C4); // 0x846CD
            AddAsmRef(rom, refs, index++, 0xB9BD8); // 0x84739
            AddAsmRef(rom, refs, index++, 0xD28EC); // 0x847CF
            AddAsmRef(rom, refs, index++, 0x1F498); // 0x84855
            AddAsmRef(rom, refs, index++, 0xB90E8); // 0x84879
            AddAsmRef(rom, refs, index++, 0xB7A24); // 0x84A0B
            AddAsmRef(rom, refs, index++, 0xB7B4C); // 0x84A0B
            AddAsmRef(rom, refs, index++, 0xA2128); // 0x852D5
            AddAsmRef(rom, refs, index++, 0xBCAA8); // 0x852D5
            AddAsmRef(rom, refs, index++, 0xA218C); // 0x85EF5
            AddAsmRef(rom, refs, index++, 0xA2364); // 0x85EF5

            AddAsmRef(rom, refs, index++, 0x1F514); // 0x846FB (related to using a battle item outside)
            AddAsmRef(rom, refs, index++, 0xB9C94); // 0x846FB (related to using a battle item outside)

            AddAsmRef(rom, refs, index++, 0xEA978); // 0x60801 (related to recovering HP)

            return refs.ToArray();
        }

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

            for (int i = 0; i < numEntries; i++)
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

        public static FixedStringCollection ReadPsiTargets(byte[] rom)
        {
            var table = ReadFixedStringTable(rom, 0xB1B3EF, 10, 11);
            table.TablePointers = new int[] {
                0xB8B2C,
                0xB8BA4
            };
            return table;
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
            var table = ReadFixedStringTable(rom, 0xB1B916, 0x12, 0xD);
            table.TablePointers = new int[] {
                0xC211C,
	            0xC22F0,
	            0xC2398,
	            0xC2478,
	            0xC2528,
	            0xD39D0
            };
            return table;
        }
    }
}
