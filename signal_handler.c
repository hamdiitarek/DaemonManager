#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <errno.h>
#include <stdbool.h>

#define RED     "\x1b[31m"
#define GREEN   "\x1b[32m"
#define YELLOW  "\x1b[33m"
#define BLUE    "\x1b[34m"
#define RESET   "\x1b[0m"
#define BOLD    "\x1b[1m"

static bool custom_handlers_active = false;

void custom_handler(int sig) {
    printf(GREEN BOLD);
    printf("\n[CUSTOM HANDLER] Signal %s (%d) received\n", strsignal(sig), sig);
    printf(RESET);
    fflush(stdout);
    
    switch(sig) {
        case SIGINT:
            printf(YELLOW "Caught SIGINT - Use Ctrl+\\ (SIGQUIT) to force quit or continue normally\n" RESET);
            break;
        case SIGTSTP:
            printf(YELLOW "Caught SIGTSTP - Job control signal received\n" RESET);
            break;
        case SIGTERM:
            printf(YELLOW "Caught SIGTERM - Termination request received\n" RESET);
            break;
        case SIGALRM:
            printf(YELLOW "Caught SIGALRM - Alarm signal received\n" RESET);
            break;
        case SIGCONT:
            printf(YELLOW "Caught SIGCONT - Continue signal received\n" RESET);
            break;
        default:
            printf(YELLOW);
            printf("Signal %d handled by custom handler\n", sig);
            printf(RESET);
    }
}

void original_handler(int sig) {
    if (signal(sig, SIG_DFL) == SIG_ERR) {
        printf(RED);
        printf("Error: Failed to reset signal %d to default handler\n", sig);
        printf(RESET);
    }
}

void override_signals() {
    if (signal(SIGTERM, custom_handler) == SIG_ERR ||
        signal(SIGTSTP, custom_handler) == SIG_ERR ||
        signal(SIGCONT, custom_handler) == SIG_ERR ||
        signal(SIGALRM, custom_handler) == SIG_ERR ||
        signal(SIGINT, custom_handler) == SIG_ERR) {
        printf(RED "Error: Failed to set custom signal handlers\n" RESET);
        return;
    }
    
    custom_handlers_active = true;
    printf(GREEN BOLD "\n✓ Custom signal handlers are now active.\n" RESET);
    printf(BLUE "Signals being handled: SIGTERM, SIGTSTP, SIGCONT, SIGALRM, SIGINT\n" RESET);
}

void original_signals() {
    original_handler(SIGTERM);
    original_handler(SIGTSTP);  
    original_handler(SIGCONT);
    original_handler(SIGALRM);
    original_handler(SIGINT);
    
    custom_handlers_active = false;
    printf(GREEN BOLD "\n✓ Default signal handlers are now active.\n" RESET);
}

void print_menu() {
    printf("\n" BLUE BOLD "=== Signal Handler Program ===" RESET "\n");
    printf(BOLD "Status: " RESET);
    if (custom_handlers_active) {
        printf(GREEN "Custom handlers active" RESET "\n");
    } else {
        printf(YELLOW "Default handlers active" RESET "\n");
    }
    printf("\n");
    printf("1.  Override signal handlers\n");
    printf("2.  Revert to default signal handlers\n");
    printf("3.  Send SIGTERM Signal (Termination)\n");
    printf("4.  Send SIGKILL Signal (Force kill - UNCATCHABLE)\n");
    printf("5.  Send SIGSEGV Signal (Segmentation fault - UNCATCHABLE)\n");
    printf("6.  Send SIGTSTP Signal (Terminal stop)\n");
    printf("7.  Send SIGCONT Signal (Continue)\n");
    printf("8.  Send SIGALRM Signal (Alarm)\n");
    printf("9.  Send SIGINT Signal (Interrupt)\n");
    printf("10. Show signal information\n");
    printf("11. Back to Daemon Manager\n");
    printf("\nEnter your choice: ");
}

void show_signal_info() {
    printf("\n" BLUE BOLD "=== Signal Information ===" RESET "\n");
    printf("SIGTERM (%d): Termination signal - Can be caught\n", SIGTERM);
    printf("SIGKILL (%d): Kill signal - Cannot be caught or ignored\n", SIGKILL);
    printf("SIGSEGV (%d): Segmentation fault - Cannot be caught normally\n", SIGSEGV);
    printf("SIGTSTP (%d): Terminal stop signal - Can be caught\n", SIGTSTP);
    printf("SIGCONT (%d): Continue signal - Can be caught\n", SIGCONT);
    printf("SIGALRM (%d): Alarm signal - Can be caught\n", SIGALRM);
    printf("SIGINT  (%d): Interrupt signal (Ctrl+C) - Can be caught\n", SIGINT);
    printf("\n");
}

int get_valid_input() {
    int choice;
    char buffer[100];
    
    if (fgets(buffer, sizeof(buffer), stdin) == NULL) {
        return -1;
    }
    
    if (sscanf(buffer, "%d", &choice) != 1) {
        return -1;
    }
    
    return choice;
}

int main() {
    printf(GREEN BOLD "Signal Handler Program Starting...\n" RESET);
    
    while (1) {
        print_menu();
        int choice = get_valid_input();

        switch (choice) {
        case 1:
            override_signals();
            break;
        case 2:
            original_signals();
            break;
        case 3:
            printf(YELLOW "Sending SIGTERM signal...\n" RESET);
            raise(SIGTERM);
            break;
        case 4:
            printf(RED "Sending SIGKILL signal (UNCATCHABLE)\n" RESET);
            raise(SIGKILL);
            break;
        case 5:
            printf(RED "Sending SIGSEGV signal (UNCATCHABLE)\n" RESET);
            raise(SIGSEGV);
            break;
        case 6:
            printf(YELLOW "Sending SIGTSTP signal...\n" RESET);
            raise(SIGTSTP);
            break;
        case 7:
            printf(YELLOW "Sending SIGCONT signal...\n" RESET);
            raise(SIGCONT);
            break;
        case 8:
            printf(YELLOW "Sending SIGALRM signal...\n" RESET);
            raise(SIGALRM);
            break;
        case 9:
            printf(YELLOW "Sending SIGINT signal...\n" RESET);
            raise(SIGINT);
            break;
        case 10:
            show_signal_info();
            break;
        case 11:
            printf(GREEN "Returning to Daemon Manager...\n" RESET);
            exit(0);
            break;  
        case -1:
            printf(RED "Invalid input. Please enter a number.\n" RESET);
            break;
        default:
            printf(RED "Invalid choice. Please try again.\n" RESET);
            break;
        }
    }

    return 0;
}
