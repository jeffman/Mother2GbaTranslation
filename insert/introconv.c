// converts intro.bmp into a format usable by the translation patch

#include <stdio.h>

struct color {
   int r;
   int g;
   int b;
};

void ClearPic(unsigned char [256][256]);
int LoadBmp(char[], unsigned char[256][256], int&, int&, color[256]);
int WriteTile(FILE*, int, int, unsigned char[256][256]);
int ConvertPalette(color[256]);
char* errors[] = { "Error opening BMP file", "Dimensions not right; BMP must be 240 wide by 136 tall",
                   "BMP file must be in 8-bit (256 color) format", "BMP file must not use compression" };


int main(int argc, char* argv[])
{
   unsigned char pic[256][256];
   int           width;
   int           height;
   int           retVal;
   FILE*         fout;
   color         palette[256];

   ClearPic(pic);
   retVal = LoadBmp("intro.bmp", pic, width, height, palette);
   if (retVal != 0)
   {
      printf("\r\n Error converting intro.bmp, quitting.\r\n Error message: (%s)\r\n", errors[retVal]);
	  return -1;
   }

   printf("\r\n Converting intro.bmp...");

   fout = fopen("intro_screen_gfx.bin", "wb");
   for (int y = 0; y < 17; y++)
   {
      for (int x = 0; x < 30; x++)
	  {
	     WriteTile(fout, x * 8, y * 8, pic);
	  }
   }
   fclose(fout);
   printf(" DONE!\r\n");


   printf(" Converting intro.bmp palette...");
   ConvertPalette(palette);
   printf(" DONE!\r\n");

   return 0;
}

void ClearPic(unsigned char pic[256][256])
{
   for (int y = 0; y < 256; y++)
   {
      for (int x = 0; x < 256; x++)
      {
         pic[y][x] = 0;
      }
   }
}


int LoadBmp(char filename[256], unsigned char pic[256][256], int& width, int& height, color palette[256])
{
   // return values:
   //    1 - error opening file
   //    2 - dimensions too big (must be 240x136)
   //    3 - not 8-bit
   //    4 - compression being used

   FILE* bmp;
   unsigned int  start;
   unsigned char ch;
   int           bpp;
   int           compr;
   int           x = 0;
   int           y = 0;

   bmp = fopen(filename, "rb");
   if (bmp == NULL)
      return 1;

   fseek(bmp, 18, SEEK_SET);
   width = fgetc(bmp);
   width += fgetc(bmp) << 8;
   width += fgetc(bmp) << 16;
   width += fgetc(bmp) << 24;

   height = fgetc(bmp);
   height += fgetc(bmp) << 8;
   height += fgetc(bmp) << 16;
   height += fgetc(bmp) << 24;

   fseek(bmp, 28, SEEK_SET);
   bpp = fgetc(bmp);
   bpp += fgetc(bmp) << 8;

   compr = fgetc(bmp);
   compr += fgetc(bmp) << 8;
   compr += fgetc(bmp) << 16;
   compr += fgetc(bmp) << 24;

   if (width != 240 || height != 136)
   {
      fclose(bmp);
      return 2;
   }

   if (bpp != 8)
   {
      fclose(bmp);
      return 3;
   }

   if (compr != 0)
   {
      fclose(bmp);
      return 4;
   }

   fseek(bmp, 10, SEEK_SET);
   start = fgetc(bmp);
   start += fgetc(bmp) << 8;
   start += fgetc(bmp) << 16;
   start += fgetc(bmp) << 24;

   fseek(bmp, start, SEEK_SET);

   y = height - 1;

   ch = fgetc(bmp);
   while (!feof(bmp) && (y >= 0))
   {
      //pic[y][x++] = (ch & 0xF0) >> 4;
	  pic[y][x++] = ch;
      if (x >= width)
      {
         x = 0;
         y--;
      }

      ch = fgetc(bmp);
   }


   fseek(bmp, 0x36, SEEK_SET);
   for (int i = 0; i < 256; i++)
   {
      palette[i].r = fgetc(bmp);
	  palette[i].g = fgetc(bmp);
	  palette[i].b = fgetc(bmp);
	  fgetc(bmp);
   }

   fclose(bmp);

   return 0;
}

int WriteTile(FILE* fout, int x, int y, unsigned char pic[256][256])
{
   if (!fout)
      return -1;

   for (int iy = 0; iy < 8; iy++)
   {
	  for (int ix = 0; ix < 8; ix++)
	  {
	     fputc(pic[y + iy][x + ix], fout);
	  }
   }
}

int ConvertPalette(color palette[256])
{
   FILE* fout;
   int   newValue;

   fout = fopen("intro_screen_pal.bin", "wb");

   for (int i = 0; i < 256; i++)
   {
      newValue = 0;
	  newValue = (palette[i].r / 8) << 10;
	  newValue |= (palette[i].g / 8) << 5;
	  newValue |= (palette[i].b / 8);


	  fputc(newValue & 0xFF, fout);
	  fputc(newValue >> 8, fout);
	  }

   fclose(fout);
}
