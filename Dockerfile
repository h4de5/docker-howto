FROM ubuntu:focal
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y bash git htop python3 python3-pip tmux screenfetch vim

# build parameter .. dh. die nur währends des build verfügbar
# standard werte sind 1000:1000
ARG USER_ID=1000
ARG GROUP_ID=1000

# sind immer verfügbar
# wir setzen environment auf argument
ENV USER_ID=$USER_ID
ENV GROUP_ID=$GROUP_ID

# copy files
# ADD ./app /app

# WIRD NUR BEIM BUILD ausgegeben!
# NICHT BEIM run .. 
RUN echo "---------------------------" && \
  echo "GroupID: ${GROUP_ID}" && \
  echo "UserID: ${USER_ID}"

#RUN if getent passwd container-user ; then userdel container-user; fi &&\
#  if getent group container-group ; then groupdel container-group; fi &&\
# dem benutzer einen namen geben - ansonsten reichts wenn nur die USERID zu setzen
RUN if ! getent group ${GROUP_ID} ; then groupadd -g ${GROUP_ID} container-group ; fi && \
  # useradd -l -u ${USER_ID} -g ${GROUP_ID} container-user
  adduser --uid ${USER_ID} --gid ${GROUP_ID} --disabled-password container-user

# RUN mkdir /app
# RUN mv "/home/container-user/.bashrc" "/home/container-user/.bashrc.bac"

# während der LAUFZEIT (d.h. beim run) wird des verzeichnis /app vom HOST gemountet
# wird automatisch a mkdir gemacht
# während des builds ist das verzeichnis leer
VOLUME ["/app"]
# für files braucht man kein volume
# ich glaun fast ma braucht generell ka volume...
# VOLUME ["/home/container-user/.bashrc"]
WORKDIR /app

# dateien während des builds kopieren
# hier NICHT auf VOLUME kopieren, 
# da volumes zur laufzeit mit dem inhalt vom host überschrieben werden
RUN mkdir /tmp/myfiles
COPY myfiles/* /tmp/myfiles

# wenn du daten vom host während des builds brauchst
# musst mit COPY arbeiten
RUN echo ${USER_ID}:${GROUP_ID}

# den user schon beim image setzen
# dann braucht man den user nicht mehr im compose file angeben
USER ${USER_ID}:${GROUP_ID}
RUN echo current user: $(id -u):$(id -g)

# HEALTHCHECK CMD ls newfile.txt || exit 1

# CMD [ "echo", "$CONTENT", ">>", "/app/newfile.txt" ]
# RUN is build time .. im image
# CMD/ENTRYPOINT is run time .. im container
CMD [ "touch", "watchfile.txt" ]
# CMD [ "tail", "-f", "watchfile.txt" ]
# CMD ["/usr/bin/bash"]