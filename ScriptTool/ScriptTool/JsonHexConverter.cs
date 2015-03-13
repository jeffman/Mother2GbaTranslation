using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace ScriptTool
{
    public class JsonHexConverter : JsonConverter
    {
        private static readonly Type[] allowedTypes = {
                                                typeof(int),
                                                typeof(uint),
                                                typeof(byte),
                                                typeof(sbyte),
                                                typeof(short),
                                                typeof(ushort),
                                                typeof(long),
                                                typeof(ulong)
                                            };

        public override bool CanConvert(Type objectType)
        {
            return allowedTypes.Contains(objectType);
        }

        public override object ReadJson(JsonReader reader, Type objectType, object existingValue, JsonSerializer serializer)
        {
            if (reader.TokenType == JsonToken.Integer)
            {
                var hex = serializer.Deserialize(reader, objectType);
                return hex;
            }
            throw new Exception("Unexpected token");
        }

        public override void WriteJson(JsonWriter writer, object value, JsonSerializer serializer)
        {
            writer.WriteRawValue(String.Format("0x{0:X}", value));
        }
    }
}
