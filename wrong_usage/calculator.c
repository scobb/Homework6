// EID:wrongusage101

#include <stdio.h>
#include <string.h>

//here's my main method
int main(int argc, char* argv[])
{
  if(argc != 2){
    // you used it wrong!
    printf("usage: %s [add | multiply]\n", argv[0]);
  }
  else{
    // you used it wrong again!
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
      // get the user's input
      fgets(stringRead, 100, stdin);
      char* token;
      // get the first token
      token = strtok(stringRead, " ");
      while((token != NULL) && (token != "\n")){
	// add in the last token read
	int numRead = strtol(token, NULL, 10);
	if(strcmp(argv[1], "add") == 0){
	  runningTotal = runningTotal + numRead;
	}
	else{
	  runningTotal = runningTotal * numRead;
	}
	// get the next token and quit if it's null
	token = strtok(NULL, " ");
	
      }
      // print out the final total
      printf("%d\n", runningTotal);
    }
  }
  return 0;
}
