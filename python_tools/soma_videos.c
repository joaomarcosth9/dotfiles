#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>
#include <ctype.h>

#define MAX_PROCS 16  // ajuste para a quantidade de núcleos

typedef struct Node {
    char *path;
    struct Node *next;
} Node;

void push(Node **head, const char *path) {
    Node *node = malloc(sizeof(Node));
    node->path = strdup(path);
    node->next = *head;
    *head = node;
}

void free_list(Node *head) {
    while (head) {
        Node *tmp = head;
        free(head->path);
        head = head->next;
        free(tmp);
    }
}

int ends_with_mp4(const char *path) {
    int len = strlen(path);
    return len > 4 && strcasecmp(path + len - 4, ".mp4") == 0;
}

void scan_dir(const char *dirpath, Node **file_list) {
    struct dirent *entry;
    DIR *dp = opendir(dirpath);
    if (!dp) return;

    while ((entry = readdir(dp)) != NULL) {
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) continue;
        char path[2048];
        snprintf(path, sizeof(path), "%s/%s", dirpath, entry->d_name);
        struct stat st;
        if (stat(path, &st) < 0) continue;
        if (S_ISDIR(st.st_mode)) {
            scan_dir(path, file_list);
        } else if (S_ISREG(st.st_mode) && ends_with_mp4(path)) {
            push(file_list, path);
        }
    }
    closedir(dp);
}

double get_duration(const char *filepath) {
    char cmd[2048];
    snprintf(cmd, sizeof(cmd),
        "ffprobe -v error -show_entries format=duration "
        "-of default=noprint_wrappers=1:nokey=1 \"%s\" 2>/dev/null", filepath);

    FILE *fp = popen(cmd, "r");
    if (!fp) return 0.0;
    char buf[128];
    if (!fgets(buf, sizeof(buf), fp)) {
        pclose(fp);
        return 0.0;
    }
    pclose(fp);
    return atof(buf);
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Uso: %s <diretorio>\n", argv[0]);
        return 1;
    }
    Node *files = NULL;
    scan_dir(argv[1], &files);

    // Contar arquivos
    int nfiles = 0;
    for (Node *cur = files; cur; cur = cur->next) nfiles++;

    // Paralelizar:
    Node *cur = files;
    double total_seconds = 0.0;
    int running = 0;
    pid_t pids[MAX_PROCS];
    int pipes[MAX_PROCS][2];
    int idx = 0;

    while (cur || running > 0) {
        // Lança novos processos até o limite
        while (cur && running < MAX_PROCS) {
            if (pipe(pipes[running]) != 0) exit(2);
            pid_t pid = fork();
            if (pid < 0) exit(3);
            if (pid == 0) {
                // filho
                close(pipes[running][0]);
                double dur = get_duration(cur->path);
                write(pipes[running][1], &dur, sizeof(double));
                close(pipes[running][1]);
                _exit(0);
            } else {
                // pai
                close(pipes[running][1]);
                pids[running] = pid;
                running++;
                cur = cur->next;
            }
        }
        // Espera qualquer processo terminar
        int status;
        pid_t done = wait(&status);
        for (int i = 0; i < running; i++) {
            if (pids[i] == done) {
                double dur;
                read(pipes[i][0], &dur, sizeof(double));
                close(pipes[i][0]);
                total_seconds += dur;
                // Remover processo da lista
                for (int j = i; j < running-1; j++) {
                    pids[j] = pids[j+1];
                    pipes[j][0] = pipes[j+1][0];
                    pipes[j][1] = pipes[j+1][1];
                }
                running--;
                break;
            }
        }
    }

    // Formatar saída
    int hours = (int)(total_seconds / 3600);
    int minutes = (int)((total_seconds - hours * 3600) / 60);
    int seconds = (int)(total_seconds) % 60;
    printf("Total: %02dh %02dm %02ds\n", hours, minutes, seconds);

    free_list(files);
    return 0;
}

