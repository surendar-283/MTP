#include <iostream>
#include <csignal>
#include <unistd.h>   // for fork()
#include <sys/types.h> // for pid_t

using namespace std;

void handle_signal(int signal_num) 
{
    cout << "Received signal: " << signal_num << endl;
}

int main() 
{
    signal(SIGINT, handle_signal);
    pid_t pid = fork();
    if (pid < 0) 
    {
        cerr << "Fork failed!" << endl;
        return 1;
    }
    else if (pid == 0)
    cout << "Hello from Child! PID = " << getpid() << ", Parent PID = " << getppid() << endl;
    else
    cout << "Hello from Parent! PID = " << getpid() << ", Child PID = " << pid << endl;
    if(pid==0) kill(pid, SIGINT);
    cout<<"PID = "<<getpid()<<endl;
    return 0;
}
