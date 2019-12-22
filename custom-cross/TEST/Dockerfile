FROM debian:buster
RUN mkdir -p /usr/lib64 /usr/lib/x86_64-linux-gnu
RUN cp /lib64/ld-linux-x86-64.so.2 /usr/lib64/
RUN cp /lib/x86_64-linux/libc.so.6 /usr/lib/x86_64-linux/
RUN chroot /usr /bin/test ok
