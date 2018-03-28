// you are a hot dog

// i hope you like messy code

#include <stdio.h>
#include <string.h>
#include <ctype.h>

struct tableEntry
{
	int  hexVal;
	char str[500];
};

tableEntry table[500];
int        tableLen = 0;

void 		  LoadTable(void);
void          PrepString(char[], char[], int);
unsigned char ConvChar(unsigned char);
void          ConvComplexString(char[], int&);
void          CompileCC(char[], int&, unsigned char[], int&);
int           CharToHex(char);
unsigned int  hstrtoi(char*);
void          InsertMainStuff(void);
void          InsertSpecialText(void);
void          InsertAltWindowData(void);
void          InsertItemArticles(void);

void          LoadM2Table(void);
void          InsertM2WindowText(void);
void          InsertM2MiscText(void);
void          InsertM2Items(void);
void          InsertM2Enemies(void);
void          InsertM2PSI1(void);
void          InsertM2Locations(void);
void          ConvComplexMenuString(char[], int&);

//void          UpdatePointers(int, int, FILE*, char*);
//void          InsertEnemies(FILE*);
//void          InsertMenuStuff1(FILE*);
//void          InsertStuff(FILE*, char[], int, int, int);
//void          InsertMenuStuff2(FILE*);

int quoteCount = 0;

//=================================================================================================

int main(void)
{
	printf("\r\n MOTHER 1 STUFF\r\n");
	printf("=====================================\r\n");
	LoadTable();
	InsertMainStuff();
	InsertSpecialText();
	InsertAltWindowData();
	InsertItemArticles();
    printf("\r\nDone!\r\n");

	return 0;
}

//=================================================================================================

void ConvComplexString(char str[5000], int& newLen)
{
	char          newStr[5000] = "";
	unsigned char newStream[100];
	int           streamLen =  0;
	int           len = strlen(str) - 1; // minus one to take out the newline
	int           counter = 0;
	int           i;

	newLen = 0;

    quoteCount = 0;

    while (counter < len)
    {
		//printf("%c", str[counter]);
		if (str[counter] == '[')
		{
		   CompileCC(str, counter, newStream, streamLen);
		   for (i = 0; i < streamLen; i++)
		   {
			   newStr[newLen] = newStream[i];
			   newLen++;
		   }
		   counter++; // to skip past the ]
		}
		else
		{
		   newStr[newLen] = ConvChar(str[counter]);
		   newLen++;

		   counter++;
		}
	}

    for (i = 0; i < 5000; i++)
       str[i] = '\0';
	for (i = 0; i < newLen; i++)
	   str[i] = newStr[i];
}


//=================================================================================================

void CompileCC(char str[5000], int& strLoc, unsigned char newStream[100], int& streamLen)
{
   char  str2[5000] = "";
   char* ptr[5000];
   int   ptrCount = 0;
   int   totalLength = strlen(str);
   int   i;
   int   j;
   FILE* fin;
   char  hexVal[100] = "";
   char  specialStr[100] = "";
   int   retVal = 0;


   // we're gonna mess with the original string, so make a backup for later
   strcpy(str2, str);

   // first we gotta parse the codes, what a pain
   ptr[ptrCount++] = &str[strLoc + 1];
   while (str[strLoc] != ']' && strLoc < totalLength)
   {
      if (str[strLoc] == ' ')
      {
         ptr[ptrCount++] = &str[strLoc + 1];
         str[strLoc] = 0;
      }

      strLoc++;
   }

   if (str[strLoc] == ']')
      str[strLoc] = 0;


   // Capitalize all the arguments for ease of use
   for (i = 0; i < ptrCount; i++)
   {
      for (j = 0; j < strlen(ptr[i]); j++)
         ptr[i][j] = toupper(ptr[i][j]);
   }

   // now the actual compiling into the data stream
   streamLen = 0;
   if (strcmp(ptr[0], "END") == 0)
       newStream[streamLen++] = 0x00;
   else if (strcmp(ptr[0], "BREAK") == 0)
       newStream[streamLen++] = 0x02;
   else if (strcmp(ptr[0], "PAUSE") == 0)
   {
	   newStream[streamLen++] = 0x03;
       newStream[streamLen++] = 0x02;
   }



   else if ((isalpha(ptr[0][0]) == true) && (strlen(ptr[0]) != 2))
   {
	    i = 0;

		while ((i < tableLen) && (retVal == 0))
		{
			if (strcmp(ptr[0], table[i].str) == 0)
			   retVal = table[i].hexVal;
			else
			   i++;
		}

		newStream[streamLen++] = retVal;
		//newStream[streamLen++] = 0x00;
		if (retVal == 0)
		   printf("Couldn't convert control code: %s\n", ptr[0]);


      //printf("%s\r\n", ptr[0]);

   }



   // going to assume raw codes now, in 2-char hex things, like [FA 1A 2C EE]
   else if (strlen(ptr[0]) == 2)
   {
      for (i = 0; i < ptrCount; i++)
         newStream[streamLen++] = hstrtoi(ptr[i]);
   }

   else
      printf("UNKNOWN CONTROL CODE: %s\n", ptr[0]);

   // restore backup string
   strcpy(str, str2);
}

//=================================================================================================

unsigned char ConvChar(unsigned char ch)
{
	unsigned char retVal = 0;
	char          origChar[100] = "";
	int           i = 0;

	while ((i < tableLen) && (retVal == 0))
	{
		sprintf(origChar, "%c", ch);


		if (strcmp(origChar, table[i].str) == 0)
		{
		   retVal = table[i].hexVal;
		   if (ch == '\"')
		   {
			   // implementing smart quotes
			   if (quoteCount % 2 == 0)
			      retVal = 0xAC;

			   quoteCount++;
		   }
	    }
		else
		   i++;
	}

	if (retVal == 0)
		printf("UNABLE TO CONVERT CHARACTER: %c %02X\n", ch, ch);

	return retVal;
}

//=================================================================================================

void LoadTable(void)
{
   FILE* fin;
   char  tempStr[500] = "";
   int i;

   tableLen = 0;

   fin = fopen("eng_table.txt", "r");
   if (fin == NULL)
   {
	   printf("Can't open eng_table.txt!\n");
	   return;
   }

   /*i = fgetc(fin);
   i = fgetc(fin);
   i = fgetc(fin);*/


   fscanf(fin, "%s", tempStr);
   table[tableLen].hexVal = hstrtoi(tempStr);
   fscanf(fin, "%s", table[tableLen].str);
   while (!feof(fin))
   {
	   tableLen++;

   	   fscanf(fin, "%s", tempStr);
   	   table[tableLen].hexVal = hstrtoi(tempStr);
       fscanf(fin, "%s", table[tableLen].str);
       //printf("%s\n", table[tableLen].str);
   }

   table[0x01].str[0] = ' ';
   table[0x01].str[1] = '\0';

   fclose(fin);
}

//=================================================================================================

unsigned int hstrtoi(char* string)
{
   unsigned int retval = 0;

   for (int i = 0; i < strlen(string); i++)
   {
      retval <<= 4;
      retval += CharToHex(string[i]);
   }

   return retval;
}

//=================================================================================================

int CharToHex(char ch)
{
   // Converts a single hex character to an integer.

   int retVal = 0;

   ch = toupper(ch);

   switch (ch)
   {
      case '0':
      {
         retVal = 0;
         break;
      }
      case '1':
      {
         retVal = 1;
         break;
      }
      case '2':
      {
         retVal = 2;
         break;
      }
      case '3':
      {
         retVal = 3;
         break;
      }
      case '4':
      {
         retVal = 4;
         break;
      }
      case '5':
      {
         retVal = 5;
         break;
      }
      case '6':
      {
         retVal = 6;
         break;
      }
      case '7':
      {
         retVal = 7;
         break;
      }
      case '8':
      {
         retVal = 8;
         break;
      }
      case '9':
      {
         retVal = 9;
         break;
      }
      case 'A':
      {
         retVal = 10;
         break;
      }
      case 'B':
      {
         retVal = 11;
         break;
      }
      case 'C':
      {
         retVal = 12;
         break;
      }
      case 'D':
      {
         retVal = 13;
         break;
      }
      case 'E':
      {
         retVal = 14;
         break;
      }
      case 'F':
      {
         retVal = 15;
         break;
      }
   }

   return retVal;
}

//=================================================================================================

void PrepString(char str[5000], char str2[5000], int startPoint)
{
	int j;
	int ctr;

    for (j = 0; j < 5000; j++)
	    str2[j] = '\0';

    ctr = 0;
	for (j = startPoint; j < strlen(str); j++)
	{
	   str2[ctr] = str[j];
	   ctr++;
	}

}

//=================================================================================================

void InsertMainStuff(void)
{
	FILE* fin;
	FILE* fout;
	char  str[5000];
	char  str2[5000];
	int   lineNum = 0;
        int   loc = 0xF7EA00;
	int   ptrLoc;
	int   temp;
	int   len;
	int   i;

	fin = fopen("m1_main_text.txt", "r");
	if (fin == NULL)
	{
		printf("Can't open m1_main_text.txt\n");
		return;
	}

	fout = fopen("m12.gba", "rb+");
	if (fout == NULL)
	{
		printf("Can't open m12.gba\n");
		fclose(fin);
		return;
	}


	fgets(str, 5000, fin);
	while(strstr(str, "-E: ") == NULL)
	{
	   fgets(str, 5000, fin);
	}
    while(!feof(fin))
    {
  		PrepString(str, str2, 7);

  		if (str2[0] != '\n')
  		{
			//printf("%d", str2[0]);
//                       printf("%X %s\n", loc, str);
			ptrLoc = 0xF27A90 + lineNum * 4;
			fseek(fout, ptrLoc, SEEK_SET);

			temp = loc + 0x8000000;
	        fputc(temp & 0x000000FF, fout);
            fputc((temp & 0x0000FF00) >> 8, fout);
	        fputc((temp & 0x00FF0000) >> 16, fout);
            fputc(temp >> 24, fout);

			ConvComplexString(str2, len);
			str2[len] = 0x00;
			len++;

            fseek(fout, loc, SEEK_SET);
            for (i = 0; i < len; i++)
            {
			   //printf("%02X ", str2[i]);
               fputc(str2[i], fout);
			}
			//printf("\n");

		    loc += len;
		}


        lineNum++;
	    fgets(str, 5000, fin);
	    while(strstr(str, "-E: ") == NULL && !feof(fin))
	    {
			fgets(str, 5000, fin);
    	}

	}

    printf(" Main text:\tINSERTED\r\n");

    fclose(fout);
	fclose(fin);
}

//=================================================================================================

void InsertSpecialText(void)
{
	FILE* fin;
	FILE* fout;
	char  str[5000];
	char  str2[5000];
	char  line[5000];
	int   loc;
	int   temp;
	int   len;
	int   i;


    fin = fopen("m1_misc_text.txt", "r");
    if (fin == NULL)
    {
		printf("Can't open m1_misc_text.txt");
		return;
	}

	fout = fopen("m12.gba", "rb+");
	if (fout == NULL)
	{
		printf("Can't open m12.gba");
		fclose(fin);
		return;
	}

    //fscanf(fin, "%x", &loc);
//    fscanf(fin, "%s", str);
    //fscanf(fin, "%s", line);
    fgets(line, 5000, fin);
    while(!feof(fin))
    {
		if (line[0] != '/' && line[0] != '\r' && line[0] != 10)
		{
		   sscanf(line, "%x %[^\t\n]", &loc, str);
           strcat(str, " ");

           //printf("%2d %X - %s\n", line[0], loc, str);
     	   PrepString(str, str2, 0);
		   ConvComplexString(str2, len);

           fseek(fout, loc, SEEK_SET);
           for (i = 0; i < len; i++)
	          fputc(str2[i], fout);
	    }

	    //fscanf(fin, "%s", line);
	    fgets(line, 5000, fin);

    	//fscanf(fin, "%x", &loc);
//    	fscanf(fin, "%s", str);
	}

    printf(" Misc. text:\tINSERTED\r\n");

	fclose(fout);
	fclose(fin);
}

void InsertAltWindowData(void)
{
	FILE* fin;
	FILE* fout;
	char  str[1000];
	int   lineNum;
	int   insertLoc = 0xFED000;
	int   totalSize = 0x1000;
	int   totalFound = 0;

	fin = fopen("m1_small_windows_list.txt", "r");
	if (!fin)
	{
		printf("Can't open m1_small_windows_list.txt, doh\r\n");
		return;
	}

	fout = fopen("m12.gba", "rb+");
	if (!fout)
	{
		printf("Can't open m12.gba, doh\r\n");
		return;
	}

	fseek(fout, insertLoc, SEEK_SET);
	for (int i = 0; i < totalSize; i++)
	   fputc(0, fout);

	fscanf(fin, "%x", &lineNum);
    while(!feof(fin))
    {
		if (lineNum < totalSize)
		{
			fseek(fout, insertLoc + lineNum, SEEK_SET);
			fputc(1, fout);
			totalFound++;
		}

	   fscanf(fin, "%x", &lineNum);
	}

	fclose(fout);
	fclose(fin);

    printf(" Alt. windows:\tINSERTED (Total: %d)\r\n", totalFound);
    return;
}

void InsertItemArticles(void)
{
	FILE* fin;
	FILE* fout;
	char  line[1000];
	char* str;
	int   lineNum = 0;
	int   startLoc = 0xFFE000;
	int   i;

	fin = fopen("m1_item_articles.txt", "r");
	if (!fin)
	{
		printf("Can't open m1_item_articles.txt, doh\r\n");
		return;
	}

	fout = fopen("m12.gba", "rb+");
	if (!fout)
	{
		printf("Can't open m12.gba, doh\r\n");
		return;
	}

	fgets(line, 1000, fin);
    while(!feof(fin))
    {
		line[strlen(line) - 2] = '\0';
		str = &line[13];

		fseek(fout, startLoc + lineNum * 0x10, SEEK_SET);
		for (i = 0; i < 0x10; i++)
		   fputc(0, fout);

		fseek(fout, startLoc + lineNum * 0x10, SEEK_SET);
		for (i = 0; i < strlen(str); i++)
		   fputc(ConvChar(str[i]), fout);

        lineNum++;
	    fgets(line, 1000, fin);
	}

    printf(" Item articles:\tINSERTED\r\n");

	fclose(fout);
	return;
}

//=================================================================================================
//=================================================================================================
//=================================================================================================

void LoadM2Table(void)
{
   FILE* fin;
   char  tempStr[500] = "";
   int i;

   tableLen = 0;

   fin = fopen("m2_jpn_table.txt", "r");
   if (fin == NULL)
   {
	   printf("Can't open m2_jpn_table.txt!\n");
	   return;
   }

   i = fgetc(fin);
   i = fgetc(fin);
   i = fgetc(fin);


   fscanf(fin, "%s", tempStr);
   table[tableLen].hexVal = hstrtoi(tempStr);
   fscanf(fin, "%s", table[tableLen].str);
   while (!feof(fin))
   {
	   tableLen++;

   	   fscanf(fin, "%s", tempStr);
   	   table[tableLen].hexVal = hstrtoi(tempStr);
       fscanf(fin, "%s", table[tableLen].str);
   }

   table[0x00].str[1] = '\0';
   table[0x4D].str[0] = ' ';

   fclose(fin);
}

//=================================================================================================

void InsertM2WindowText(void)
{
	FILE* fin;
	FILE* fout;
	char  str[5000];
	char  str2[5000];
	char  line[5000];
	int   loc;
	int   temp;
	int   len;
	int   i;


    fin = fopen("m2_window_text.txt", "r");
    if (fin == NULL)
    {
		printf("Can't open m1_window_text.txt");
		return;
	}

	fout = fopen("m12.gba", "rb+");
	if (fout == NULL)
	{
		printf("Can't open m12.gba");
		fclose(fin);
		return;
	}

    //fscanf(fin, "%x", &loc);
//    fscanf(fin, "%s", str);
    //fscanf(fin, "%s", line);
    fgets(line, 5000, fin);
    while(!feof(fin))
    {
		if (line[0] != '/' && line[0] != '\r' && line[0] != 10)
		{
		   sscanf(line, "%x %[^\t\n]", &loc, str);
           strcat(str, " ");

           //printf("%2d %X - %s\n", line[0], loc, str);
     	   PrepString(str, str2, 0);
		   ConvComplexMenuString(str2, len);

           fseek(fout, loc, SEEK_SET);
           for (i = 0; i < len; i++)
	          fputc(str2[i], fout);
	    }

	    //fscanf(fin, "%s", line);
	    fgets(line, 5000, fin);

    	//fscanf(fin, "%x", &loc);
//    	fscanf(fin, "%s", str);
	}

    printf(" Misc. text:\tINSERTED\r\n");

	fclose(fout);
	fclose(fin);
}

//=================================================================================================

void InsertM2Items(void)
{
	FILE* fin;
	FILE* fout;
	char  str[5000];
	char  str2[5000];
	int   lineNum = 0;
    int   loc = 0xB30000;
	int   ptrLoc;
	int   temp;
	int   len;
	int   i;

	fin = fopen("m2_items.txt", "r");
	if (fin == NULL)
	{
		printf("Can't open m2_items.txt\n");
		return;
	}

	fout = fopen("m12.gba", "rb+");
	if (fout == NULL)
	{
		printf("Can't open m12.gba\n");
		fclose(fin);
		return;
	}


	fgets(str, 5000, fin);
	while(strstr(str, "-E: ") == NULL)
	{
	   fgets(str, 5000, fin);
	}
    while(!feof(fin))
    {
  		PrepString(str, str2, 7);

  		if (str2[0] != '\n')
  		{
			//printf("%d", str2[0]);
			//printf(str2);
//                       printf("%X %s\n", loc, str);
			ptrLoc = 0xb1af94 + lineNum * 4;
			fseek(fout, ptrLoc, SEEK_SET);

			temp = (loc - 0xb1a694);
	        fputc(temp & 0x000000FF, fout);
            fputc((temp & 0x0000FF00) >> 8, fout);
	        fputc((temp & 0x00FF0000) >> 16, fout);
            fputc(temp >> 24, fout);

			ConvComplexString(str2, len);
            str2[len++] = 0x00;
			str2[len++] = 0xFF;

            fseek(fout, loc, SEEK_SET);
            for (i = 0; i < len; i++)
            {
			   //printf("%02X ", str2[i]);
               fputc(str2[i], fout);
			}
			//printf("\n");

		    loc += len;
		}


        lineNum++;
	    fgets(str, 5000, fin);
	    while(strstr(str, "-E: ") == NULL && !feof(fin))
	    {
			fgets(str, 5000, fin);
    	}

	}

    printf(" Item names:\tINSERTED\r\n");

    fclose(fout);
	fclose(fin);
}

//=================================================================================================

void InsertM2Enemies(void)
{
	FILE* fin;
	FILE* fout;
	char  str[5000];
	char  str2[5000];
	int   lineNum = 0;
    int   loc = 0xB31000;
	int   ptrLoc;
	int   temp;
	int   len;
	int   i;

	fin = fopen("m2_enemies.txt", "r");
	if (fin == NULL)
	{
		printf("Can't open m2_enemies.txt\n");
		return;
	}

	fout = fopen("m12.gba", "rb+");
	if (fout == NULL)
	{
		printf("Can't open m12.gba\n");
		fclose(fin);
		return;
	}


	fgets(str, 5000, fin);
	while(strstr(str, "-E: ") == NULL)
	{
	   fgets(str, 5000, fin);
	}
    while(!feof(fin))
    {
  		PrepString(str, str2, 7);

  		if (str2[0] != '\n')
  		{
			//printf("%d", str2[0]);
//			printf(str2);
//                       printf("%X %s\n", loc, str);
			ptrLoc = 0xb1a2f0 + lineNum * 4;
			fseek(fout, ptrLoc, SEEK_SET);

			temp = (loc - 0xb19ad0);
	        fputc(temp & 0x000000FF, fout);
            fputc((temp & 0x0000FF00) >> 8, fout);
	        fputc((temp & 0x00FF0000) >> 16, fout);
            fputc(temp >> 24, fout);

			ConvComplexString(str2, len);
            str2[len++] = 0x00;
			str2[len++] = 0xFF;

            fseek(fout, loc, SEEK_SET);
            for (i = 0; i < len; i++)
            {
			   //printf("%02X ", str2[i]);
               fputc(str2[i], fout);
			}
			//printf("\n");

		    loc += len;
		}


        lineNum++;
	    fgets(str, 5000, fin);
	    while(strstr(str, "-E: ") == NULL && !feof(fin))
	    {
			fgets(str, 5000, fin);
    	}

	}

    printf(" Enemy names:\tINSERTED\r\n");

    fclose(fout);
	fclose(fin);
}


//=================================================================================================

void InsertM2MiscText(void)
{
	FILE* fin;
	FILE* fout;
	char  str[5000];
	char  str2[5000];
	char  line[5000];
	int   loc;
	int   temp;
	int   len;
	int   i;


    fin = fopen("m2_misc_text.txt", "r");
    if (fin == NULL)
    {
		printf("Can't open m2_misc_text.txt");
		return;
	}

	fout = fopen("m12.gba", "rb+");
	if (fout == NULL)
	{
		printf("Can't open m12.gba");
		fclose(fin);
		return;
	}

    fgets(line, 5000, fin);
    while(!feof(fin))
    {
		if (line[0] != '/' && line[0] != '\r' && line[0] != 10)
		{
		   sscanf(line, "%x %[^\t\n]", &loc, str);
           strcat(str, " ");

           //printf("%2d %X - %s\n", line[0], loc, str);
     	   PrepString(str, str2, 0);
		   ConvComplexString(str2, len);

           fseek(fout, loc, SEEK_SET);
           for (i = 0; i < len; i++)
	          fputc(str2[i], fout);
	    }

	    //fscanf(fin, "%s", line);
	    fgets(line, 5000, fin);

    	//fscanf(fin, "%x", &loc);
//    	fscanf(fin, "%s", str);
	}

    printf(" Misc. text:\tINSERTED\r\n");

	fclose(fout);
	fclose(fin);
}



void ConvComplexMenuString(char str[5000], int& newLen)
{
	char          newStr[5000] = "";
	unsigned char newStream[100];
	int           streamLen =  0;
	int           len = strlen(str) - 1; // minus one to take out the newline
	int           counter = 0;
	int           i;

	newLen = 0;

    quoteCount = 0;

    while (counter < len)
    {
		//printf("%c", str[counter]);
		if (str[counter] == '[')
		{
		   CompileCC(str, counter, newStream, streamLen);
		   for (i = 0; i < streamLen; i++)
		   {
			   newStr[newLen] = newStream[i];
			   newLen++;
		   }
		   counter++; // to skip past the ]
		}
		else
		{
		   newStr[newLen++] = 0x82;
		   newStr[newLen++] = str[counter] + 0x1F;

		   counter++;
		}
	}

    for (i = 0; i < 5000; i++)
       str[i] = '\0';
	for (i = 0; i < newLen; i++)
	   str[i] = newStr[i];
}

//=================================================================================================

void InsertM2PSI1(void)
{
	FILE* fin;
	FILE* fout;
	char  str[5000];
	char  str2[5000];
	int   lineNum = 0;
    int   loc = 0xb1b916;
	int   ptrLoc;
	int   temp;
	int   len;
	int   i;

	fin = fopen("m2_psi.txt", "r");
	if (fin == NULL)
	{
		printf("Can't open m2_psi.txt\n");
		return;
	}

	fout = fopen("m12.gba", "rb+");
	if (fout == NULL)
	{
		printf("Can't open m12.gba\n");
		fclose(fin);
		return;
	}


	fgets(str, 5000, fin);
	while(strstr(str, "-E: ") == NULL)
	{
	   fgets(str, 5000, fin);
	}
    while(!feof(fin))
    {
  		PrepString(str, str2, 7);

  		if (str2[0] != '\n')
  		{
			ptrLoc = 0xb1b916 + lineNum * 0xD;
			//printf("%02X - %6X - %s", lineNum, ptrLoc, str2);

			ConvComplexString(str2, len);
            str2[len++] = 0x00;
			str2[len++] = 0xFF;

			fseek(fout, ptrLoc, SEEK_SET);
            for (i = 0; i < len; i++)
            {
			   //printf("%02X ", str2[i]);
               fputc(str2[i], fout);
			}
			//printf("\n");

		    loc += len;
		}


        lineNum++;
	    fgets(str, 5000, fin);
	    while(strstr(str, "-E: ") == NULL && !feof(fin))
	    {
			fgets(str, 5000, fin);
    	}

	}

    printf(" PSI, etc. #1:\tINSERTED\r\n");

    fclose(fout);
	fclose(fin);
}

//=================================================================================================

void InsertM2Locations(void)
{
	FILE* fin;
	FILE* fout;
	char  str[5000];
	char  str2[5000];
	int   lineNum = 0;
    int   loc = 0xb2ad24;
	int   ptrLoc;
	int   temp;
	int   len;
	int   i;

	fin = fopen("m2_locations.txt", "r");
	if (fin == NULL)
	{
		printf("Can't open m2_locations.txt\n");
		return;
	}

	fout = fopen("m12.gba", "rb+");
	if (fout == NULL)
	{
		printf("Can't open m12.gba\n");
		fclose(fin);
		return;
	}


	fgets(str, 5000, fin);
	while(strstr(str, "-E: ") == NULL)
	{
	   fgets(str, 5000, fin);
	}
    while(!feof(fin))
    {
  		PrepString(str, str2, 7);

  		if (str2[0] != '\n')
  		{
			ptrLoc = 0xb2ad24 + lineNum * 0x14;
			//printf("%02X - %6X - %s", lineNum, ptrLoc, str2);

			ConvComplexString(str2, len);
            str2[len++] = 0x00;
			str2[len++] = 0xFF;

			fseek(fout, ptrLoc, SEEK_SET);
            for (i = 0; i < len; i++)
            {
			   //printf("%02X ", str2[i]);
               fputc(str2[i], fout);
			}
			//printf("\n");

		    loc += len;
		}


        lineNum++;
	    fgets(str, 5000, fin);
	    while(strstr(str, "-E: ") == NULL && !feof(fin))
	    {
			fgets(str, 5000, fin);
    	}

	}

    printf(" Loc. names:\tINSERTED\r\n");

    fclose(fout);
	fclose(fin);
}
