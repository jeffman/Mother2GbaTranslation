$input_rom_file        = "bin/m12fresh.gba"
$output_rom_file       = "bin/m12.gba"
$output_rom_file_zeros = "bin/m12-00.gba"
$output_ips_file       = "bin/m12.ips"

Function New-BlankFile([string]$path, [int]$size, [byte]$value)
{
    $file = [System.IO.File]::Create($path)
    $bytes = ,$value * $size
    $file.Write($bytes, 0, $size);
    $file.Close()
}

Add-Type @"
using System.IO;

namespace M12
{
    public class Builder
    {
        public static void CreateIpsPatch(byte[] zeros, byte[] ones, Stream outputStream)
        {
            using (var writer = new BinaryWriter(outputStream))
            {
                writer.Write(0x43544150);
                writer.Write((byte)0x48);

                for (int i = 0; i < zeros.Length; i++)
                {
                    if (zeros[i] == ones[i])
                    {
                        bool isRun = true;
                        int j = i + 1;

                        for (; j < zeros.Length; j++)
                        {
                            if (zeros[j] != ones[j])
                                break;

                            if ((j - i) >= 0xFFFF)
                            {
                                j = i + 0xFFFF;
                                break;
                            }

                            if ((zeros[j] != zeros[i]) && isRun)
                                isRun = false;
                        }

                        int length = j - i;

                        bool correctedForEof = false;

                        if (i == 0x454F46)
                        {
                            i--;
                            length++;
                            correctedForEof = true;
                            isRun = false;
                        }

                        WriteInt24(writer, i);

                        /*if (isRun && (length > 3))
                        {
                            WriteInt16(writer, 0);
                            writer.Write((byte)zeros[i]);
                        }
                        else*/
                        {
                            WriteInt16(writer, length);

                            for (j = 0; j < length; j++)
                            {
                                writer.Write(zeros[i + j]);
                            }
                        }

                        if (correctedForEof)
                            i++;

                        i += length - 1;
                    }
                }

                writer.Write((ushort)0x4F45);
                writer.Write((byte)0x46);
            }
        }

        static void WriteInt24(BinaryWriter writer, int value)
        {
            writer.Write((byte)((value >> 16) & 0xFF));
            writer.Write((byte)((value >> 8) & 0xFF));
            writer.Write((byte)(value & 0xFF));
        }

        static void WriteInt16(BinaryWriter writer, int value)
        {
            writer.Write((byte)((value >> 8) & 0xFF));
            writer.Write((byte)(value & 0xFF));
        }
    }
}
"@

Function Create-Patch([string]$path1, [string]$path2, [string]$output_path)
{
    $bytes1 = [System.IO.File]::ReadAllBytes($path1)
    $bytes2 = [System.IO.File]::ReadAllBytes($path2)
    $file = [System.IO.File]::Create($output_path)
    [M12.Builder]::CreateIpsPatch($bytes1, $bytes2, $file)
    $file.Close()
}

.\build-tools.ps1
New-BlankFile $input_rom_file 16777216 0
.\build.ps1
Copy-Item $output_rom_file -Destination $output_rom_file_zeros
New-BlankFile $input_rom_file 16777216 255
.\build.ps1
Create-Patch $output_rom_file $output_rom_file_zeros $output_ips_file
