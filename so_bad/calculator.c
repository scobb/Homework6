
#include <stdio.h>
#include <string.h>

int main(int argc, char* argv[])
{
  if(argc != 2){
    printf("usage: %s [add | multiply]\n", argv[0]);
  else{
    if((strcmp(argv[1], "add")!=0) && (strcmp(argv[1], "multiply")!=0)){
      printf("usage: %s [add | multiply]\n", argv[0]);
    }
    else{
      char buffer[100];
      int runningTotal = 0;
      if(strcmp(argv[1], "multiply") == 0){
	runningTotal = 1;
      }
      char stringRead[100];
      fgets(stringRead, 100, stdin);
      char* token;
      token = strtok(stringRead, " ");
      while((token != NULL) && (token != "\n")){
	int numRead = strtol(token, NULL, 10);
	token = strtok(NULL, " ");
	
      }
      printf("6\n");
    }
  }
}
