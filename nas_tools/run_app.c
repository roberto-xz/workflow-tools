#include <unistd.h>
#include <stdio.h>

/*
** roberto-xz 26,Jul 2025
*/

int main() {
    setuid(0);
    execl("/usr/sbin/app.sh", "app.sh", NULL);
    return 0;
}
