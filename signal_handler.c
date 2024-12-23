#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <errno.h>

#define RED     "\x1b[31m"
#define GREEN   "\x1b[32m"
#define RESET   "\x1b[0m"

void custom_handler(int sig) {
    printf(GREEN);
    printf("\nSignal %s is raised\n", strsignal(sig));
    fflush(stdout);
    printf(RESET);
}

void original_handler(int sig) {
    signal(sig, SIG_DFL);
}


void override_signals() {
    signal(SIGTERM, custom_handler);
    signal(SIGTSTP, custom_handler);
    signal(SIGCONT, custom_handler);
    signal(SIGALRM, custom_handler);
    signal(SIGINT, custom_handler);   
    printf(GREEN);
    printf("\nCustom signal handlers are now active.\n");
    printf(RESET);
}

void original_signals() {
    original_handler(SIGTERM);
    original_handler(SIGSTOP);
    original_handler(SIGTSTP);
    original_handler(SIGCONT);
    original_handler(SIGALRM);
    original_handler(SIGINT);
    printf(GREEN);
    printf("\nDefault signal handlers are now active.\n");
    printf(RESET);
}

int main() {

   
    
    while (1) {
        printf("\nSignal Handler Program");
        printf("\n1. Override signal handlers\n");
        printf("2. Revert to default signal handlers\n");
        printf("3. Send a SIGTERM Signal\n");
        printf("4. Send a SIGKILL Signal\n");
        printf("5. Send a SIGSEGV Signal\n");
        printf("6. Send a SIGTSTP Signal\n");
        printf("7. Send a SIGCONT Signal\n");
        printf("8. Send a SIGALRM Signal\n");
        printf("9. Send a SIGINT Signal\n");
        printf("10. Back to Daemon Manager\n");
        printf("\nEnter your choice: ");
        int choice;
        scanf("%d", &choice);

        switch (choice)
        {
        case 1:
            override_signals();
            break;
        case 2:
            original_signals();
            break;
        case 3:
            raise(SIGTERM);
            break;
        case 4:
            printf(RED);
            printf("Sending SIGKILL signal (UNCATCHABLE)\n" RESET);
            raise(SIGKILL);
            break;
        case 5:
            printf(RED);
            printf("Sending SIGSEGV signal (UNCATCHABLE)\n" RESET);
            raise(SIGSEGV);
            break;
        case 6:
            raise(SIGTSTP);
            break;
        case 7:
            raise(SIGCONT);
            break;
        case 8:
            raise(SIGALRM);
            break;
        case 9:
            raise(SIGINT);
            break;
        case 10:
            exit(0);
            break;  
        default:
            printf(RED);
            printf("Invalid choice. Please try again.\n");
            printf(RESET);
            break;
        }
    }

    return 0;
}