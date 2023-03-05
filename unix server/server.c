#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <pthread.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/sendfile.h>
#define MAX_THREAD (10)
#define BUFFSIZE 4096
#define SERVERPORT 7799
pthread_t tid[MAX_THREAD];
void* sendFile(void *arg){
	int c_sock = *((int *)arg);
	int *ret,sent_bytes;
	size_t textsize;
	char buf[BUFFSIZE] = {0};
	char buffer[BUFFSIZE] = {0};
	long length;
	ret = (int *) malloc(sizeof(int));
	*ret = c_sock;
	if(recv(c_sock,buf,BUFFSIZE,0)==-1){ //파일 이름을 전송 받음
	perror("[SERVER]Can't receive message");	
	pthread_exit(ret);
	}
	char Fname[sizeof(buf)];
	strcpy(Fname,buf);//뒤의 공백 제거하기 위해 다른 버퍼에 저장
	FILE * file;
	file = fopen(Fname,"r");//파일 열기
       	if(file==NULL){
	if(send(c_sock,"ERROR",6,0)==-1){//파일이 존재하지 않을 경우 오류메세지 전송
		perror("[SERVER] FAILED TO SEND ERROR");
	pthread_exit(ret);
	}	
	pthread_exit(ret);
	}else {
		printf("[SERVER] FILE EXIST\n");
	if(send(c_sock,"YES",4,0)==-1){//존재하면 존재한다는 메세지 전송
		printf("[SERVER] FILE SENDING ERROR");
	pthread_exit(ret);
	}}
	fclose(file);	
	sleep(1);
	struct stat file_stat;
	int file1 = open(Fname,O_RDONLY);//파일 열기
	if(fstat(file1, &file_stat)<0){//미리 생성한 구조체에 파일의 메타메이터를 저장
	pthread_exit(ret);
	}
	sprintf(buf, "%d",file_stat.st_size);//파일의 크기를 문자열에 저장
	long int offset = 0;
	int remain_data = file_stat.st_size;
	printf("[SERVER] THREAD %d %d\n",c_sock,remain_data);
	if(send(c_sock,buf,BUFFSIZE,0)==-1){//파일의 크기를 저장한 문자열을 전송
		perror("[SEVER] FAILED TO SEND SIZE");
	pthread_exit(ret);
	}
	while(((sent_bytes = sendfile(c_sock,file1,&offset,BUFFSIZE))>0)//파일의 내용을 쪼개서 전송
	 && (remain_data > 0)){
	remain_data -= sent_bytes;//보낸 파일의 양만큼 남은 크기에서 빼줌
	}
	printf("[SERVER] END OF THE DOWNLOAD");
	close(c_sock);
	pthread_exit(NULL);}
int main(void){
int i=0, s_sock, c_sock, *status,args[10];
struct sockaddr_in server_addr, client_addr;
socklen_t c_addr_size;
char buf[BUFFSIZE] = {0};
s_sock = socket(AF_INET,SOCK_STREAM,0);
int option = 1;
setsockopt(s_sock, SOL_SOCKET,SO_REUSEADDR,&option,sizeof(option));
bzero(&server_addr,sizeof(server_addr));
server_addr.sin_family = AF_INET;
server_addr.sin_port = htons(SERVERPORT);
server_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
if(bind(s_sock,(struct sockaddr *) &server_addr, sizeof(server_addr)) == -1){
perror("[SERVER] FAILED TO BIND A SOCKET.\n");
exit(1);
}
listen(s_sock,1);
while(i<10){
c_sock = accept(s_sock,(struct sockaddr *)&client_addr,&c_addr_size);
if(c_sock == -1){
perror("[Server] Cant accept a connection");
continue;
}
printf("[SERVER] CONNECTED TO %d\n",c_sock);
args[i]=c_sock;
if(pthread_create(&tid[i],NULL,sendFile,&args[i]) != 0){
perror("Failed to crate thread");
}
pthread_detach(tid[i]);
i++;
}
for(int x=0; x<i;x++){//스레드 종료를 기다림, 모든 다운이 끝나야 서버 종료
pthread_join(tid[i],(void **) &status);
printf("[SERVER] FINISH DOWNLOAD: %d",x);
}
close(s_sock);
return 0;
}
