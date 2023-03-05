#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#define BUFFSIZE 4096
#define SERVERPORT 7799
int main(int argc,char* argv[]){
	if(argc != 2)
	{printf("Usage ./client file_name\n");
		return 0;}
int c_sock;
struct sockaddr_in server_addr, client_addr;
socklen_t c_addr_size;
char buf[BUFFSIZE] = {0};
char File_Address[BUFFSIZE];
char buffer[BUFFSIZE] = {0};
char buffersize[BUFFSIZE] ={0};
strcpy(File_Address,argv[1]);//다운 받을 파일 이름을 구조체에 저장
c_sock = socket(AF_INET,SOCK_STREAM,0);
bzero(&server_addr,sizeof(server_addr));
server_addr.sin_family = AF_INET;
server_addr.sin_port = htons(SERVERPORT);
server_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
if(connect(c_sock,(struct sockaddr *)&server_addr,sizeof(server_addr))== -1){
perror("FAILED");
exit(1);
}
if(send(c_sock,File_Address,BUFFSIZE,0)==-1){//다운받을 파일의 이름 전송
perror("[CLIENT] cant send message\n");
exit(1);
}
if(recv(c_sock,buf,BUFFSIZE,0) == -1 ){//파일의 존재여부에 대한 메세지 받기
perror("[CLIENT] CANT RECIEVE MESSAGE\n");
	exit(1);
}
if(strcmp(buf,"ERROR")==0){//파일이 존재하는지를 문자열 비교를 통해 확인
	printf("[CLIENT]File(%s) doesnt exist\n",argv[1]);
	exit(1);
}
if(recv(c_sock,buffersize,BUFFSIZE,0)==-1){//파일의 크기를 문자열로 받기
perror("{CLIENT} cant recive size\n");
exit(1);
}
int SIZE = atoi(buffersize);//받은 문자열을 형변환
printf("[CLIENT]%s: DOWNLOADING FILE \n",buf);
printf("[CLIENT] SIZEOFBUFF: %s %d\n",buffersize,SIZE);
FILE * file = fopen(argv[1],"wb");//파일 생성
if(file == NULL){
perror("[CLIENT] FILE ERROR\n");
	exit(1);
}
ssize_t len;
//int remain_data = atoi(buffersize);
printf("[");
while((SIZE > 0) && ((len = recv(c_sock,buf,BUFFSIZE,0))> 0)){
fwrite(buf,sizeof(char),len,file);//생성된 파일에 서버가 보낸 내용을 씀
SIZE -= len;
printf("=");
}
printf("]");
fclose(file);
printf("[CLIENT] FINISH DOWNLOAD AT [%s/%s]\n",argv[0],argv[1]);
return 0;
}
