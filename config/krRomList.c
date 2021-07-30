/* 
 *  AttractMode list maker
 *  Author       : sana2dang ( fly9p ) - sana2dang@naver.com
 *  Cafe         : http://cafe.naver.com/raspigamer
 *  Thanks to    : zzeromin, smyani, GreatKStar, KimPanda, StarNDevil, angel
 * 
 * - complie -
 * sudo gcc romlist.c -o romlist
 * sudo romlist
 */

#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <unistd.h>

int main (int argc, char **argv)
{	
	
	FILE *fIn;
	FILE *fOut;
	
	char listKr[10000];

	char cfgText[10000];
	char get_list[10000];
	char outputFileName[10000] = "";
	
	int writeListFlag = 0;
	int flnKrFlag = 0;
	DIR *spDir;
	DIR *spList;

	char *file_name;
	char *compare;
	int length = 0;

	struct dirent* am_entry = NULL;
	struct dirent* rom_entry = NULL;

	char attractList_path[10000] = "/home/odroid/.attract/romlists/";	// 어트랙트 롬리스트 경로
	char krList_path[10000] = "/home/odroid/.attract/romlists_kr/";			//  어트랙트 한글롬리스트 경로

	char amRomList[10000] = "";
	char newAmRomList[10000] = "";
	char krRomList[10000] = "";

	char esRomList[10000] = "";
	int fileCnt = 0;

	char outListKr[10000];
	char cmpToken[100] = "#Name";
	
	printf("[Start] kr list create\n");	

	if( (spDir=opendir( attractList_path ))==NULL )
		puts("error");

	while( (am_entry = readdir(spDir)) != NULL )		// AM 롬리스트에서 파일 읽어오기
	{
		fileCnt  = 1;		// 파일이 하나라도 존재함
		int kk = 0;

		//printf("%s\n", am_entry->d_name );	
		file_name = am_entry->d_name;
		length=strlen(file_name);
		compare=&file_name[length-3];
		if( !strcmp("txt", compare) || !strcmp("TXT", compare) )
		{
			printf("[LOG] AM ROMLIST : %s\n", am_entry->d_name );
			strcpy(amRomList, attractList_path);
			//printf("1\n");
			strcat(amRomList, am_entry->d_name );
			//printf("2\n");			
			//printf("%s\n", amRomList);

			strcpy(newAmRomList, attractList_path);
			strcat(newAmRomList,"kr/");
			strcat(newAmRomList, am_entry->d_name );
			//printf("%s\n", newAmRomList);
				

			// 새로 생성할 파일 열기
			if( (fOut = fopen( newAmRomList,"w")) == NULL )
			{
				printf("%s output list error!\n", newAmRomList);
				continue;
			}
			//printf("4 : %s\n", newAmRomList);			

			// AM 롬리스트 파일 읽기
			if( (fIn= fopen( amRomList,"r")) == NULL )
			{
				printf("%s AM list empty!\n", amRomList);
				continue;
			}
			fseek(fIn, 0L, SEEK_SET );
			
			//printf("5 : %s : %d\n", amRomList , fIn);			

			
			while(1)
			{
				
				char token[10000];
				char *ptr;	
				char outList[10000];
				char list[10000];
				FILE *fInKr;

				//printf("6\n");

				if( fgets(list,10000,fIn)==NULL )
				{
					break;
				}
				//printf("6 : %s\n", list);
				//printf("#!#\n"); 
				strcpy(outList , list);
				
				ptr = strtok( list, ";");
				strcpy( token, ptr );
				strcpy(krRomList, krList_path);
				strcat(krRomList, am_entry->d_name);
			
				//printf("%s - %s\n", token, cmpToken );
				if( !strcmp( token, cmpToken  ) )
					continue;
				
				//printf("[LOG4]\n");

				// kr 롬리스트 파일 읽기
				if( (fInKr= fopen( krRomList,"r")) == NULL )
				{
					//printf("%s kr list empty!\n", krRomList);
					fprintf(fOut, "%s", outList );
					flnKrFlag = 1;
					continue;;
				}
				//fseek(fInKr, 0L, SEEK_SET );
				
				
			 	while(1)
				{		
				
					char tokenKr[10000];
					char	*ptrKr;
					
					if( fgets(listKr,10000,fInKr)==NULL ) 
						break;
					

					strcpy(outListKr , listKr);
					ptrKr = strtok( listKr, ";");
					strcpy( tokenKr, ptrKr );
					writeListFlag = 0 ;
					if( !strcmp( token, tokenKr ) )	// 리스트에 있으면
					{	
						
						//printf("%s / %s\n", token, tokenKr );
						fprintf(fOut, "%s", outListKr );
						writeListFlag = 1;
						break;
					}					
				}
	
				if( writeListFlag == 0 )
				{				
					//printf("!!!%s\n",outList);			
					fprintf(fOut, "%s", outList );
				}
				

				fclose(fInKr);
				if( flnKrFlag == 1 && fInKr != NULL )
				{
						
				}
			}
			fclose(fIn);	
			fclose(fOut);
			
			


		}
	}	
	printf("[End] kr list create\n");
	return -1;	
}
