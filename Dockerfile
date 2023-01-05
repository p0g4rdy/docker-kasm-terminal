ARG BASE_TAG="1.12.0-rolling"
ARG BASE_IMAGE="core-ubuntu-jammy"
FROM kasmweb/$BASE_IMAGE:$BASE_TAG
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

RUN apt-get update && apt-get install -y tmux screen nano dnsutils zip

RUN apt-get install -y iputils-ping traceroute telnet

RUN echo "set -g mouse on" > $HOME/.tmux.conf && chown 1000:1000  $HOME/.tmux.conf

### Update .bashrc to run an arbitrary command if specified as an environment variable
RUN echo "if [ ! -z \"\${SHELL_EXEC}\" ] && [ \"\${TERM}\" == \"xterm-256color\" ] ; \n\
then \n\
    set +e \n\
    eval \${SHELL_EXEC} \n\
fi  " >> $HOME/.bashrc && chown 1000:1000  $HOME/.bashrc

COPY ./src/ubuntu/install/terminal/custom_startup.sh $STARTUPDIR/custom_startup.sh
RUN chmod +x $STARTUPDIR/custom_startup.sh
RUN chmod 755 $STARTUPDIR/custom_startup.sh

# Update the desktop environment to be optimized for a single application
RUN cp $HOME/.config/xfce4/xfconf/single-application-xfce-perchannel-xml/* $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/
RUN cp /usr/share/extra/backgrounds/bg_kasm.png /usr/share/extra/backgrounds/bg_default.png
RUN apt-get remove -y xfce4-panel


######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000