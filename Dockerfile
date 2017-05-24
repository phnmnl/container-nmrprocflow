FROM container-registry.phenomenal-h2020.eu/phnmnl/rbase:latest

MAINTAINER PhenoMeNal-H2020 Project <phenomenal-h2020-users@googlegroups.com>

LABEL software=nmrprocflow
LABEL software.version=1.2.6
LABEL version=0.1

LABEL Description="nmrglue is a module for working with NMR data in Python."

# Install dependencies
RUN apt-get -y update && apt-get -y install --no-install-recommends git gcc make ca-certificates sudo wget curl ed p7zip libcurl4-gnutls-dev libcairo2-dev libxt-dev libxml2-dev libv8-dev gdebi-core pandoc pandoc-citeproc software-properties-common

# Install needed R packages
RUN apt-get install -y --no-install-recommends r-cran-rcurl r-cran-foreach r-cran-multicore r-cran-base64enc r-cran-xml

# Install Rapache 
#RUN add-apt-repository ppa:opencpu/rapache && apt-get -y update && apt-get install -y libapache2-mod-r-base
RUN apt-get -y install devscripts apache2-dev libapreq2-dev r-base-dev libapache2-mod-r-base
#WORKDIR /usr/src
#RUN git clone https://github.com/jeffreyhorner/rapache
#WORKDIR /usr/src/rapache
#RUN debuild -d -i -us -uc -b
#WORKDIR /usr/src
#RUN dpkg -i libapache2-mod-r-base*.deb

# Set environment
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen en_US.utf8 && /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# Download and install shiny server
RUN wget --no-verbose http://download3.rstudio.org/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt) && \
    wget --no-verbose "http://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb

# Install R dependencies
RUN apt-get install -y libnlopt-dev
RUN R -e "install.packages(c('Rcpp','rjson', 'V8'), repos='http://cran.rstudio.com')"
RUN R -e "install.packages( c( 'httpuv', 'mime', 'jsonlite', 'xtable', 'htmltools', 'R6', 'shiny'), repos='http://cran.rstudio.com/')"
RUN R -e "install.packages(c('shinyBS', 'shinyjs', 'stringi', 'docopt','doParallel','signal','ptw', 'openxlsx'), repos='http://cran.rstudio.com')"
RUN R -e "source('http://bioconductor.org/biocLite.R'); biocLite('MassSpecWavelet'); install.packages('speaq', repos='http://cran.rstudio.com')"

RUN apt-get install -y libgsl2 libgsl-dev gsl-bin
RUN R -e "install.packages(c('gsl','RcppGSL','inline'), repos='http://cran.rstudio.com')"

# Configure Apache
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_SERVERADMIN admin@localhost
ENV APACHE_SERVERNAME localhost
ENV APACHE_SERVERALIAS docker.localhost
ENV APACHE_DOCUMENTROOT /var/www

# Copy configuration files
COPY conf/shiny-server.conf /etc/shiny-server/shiny-server.conf
COPY conf/global.ini /srv/shiny-server/global.ini
COPY conf/apache2.conf /etc/apache2/apache2.conf
COPY conf/my-site.conf /etc/apache2/sites-enabled/001-my-site.conf
RUN mv /etc/apache2/mods-available /etc/apache2/mods-enabled
RUN touch /etc/apache2/ports.conf
RUN mkdir /etc/apache2/conf-enabled
COPY conf/mpm.load /etc/apache2/mods-enabled/mpm.load
COPY conf/launch-server.sh /usr/bin/launch-server.sh
RUN chmod 755 /usr/bin/launch-server.sh

# Volume as the root directory that will contain the output data
RUN mkdir -p /opt/data
WORKDIR /opt/data

ADD ./ /srv/shiny-server

# Install Rnmr1D package
WORKDIR /usr/src
RUN git clone https://bitbucket.org/nmrprocflow/nmrproc.git
RUN cd /srv/shiny-server && cp -rf /usr/src/nmrproc/nmrspec/exec /srv/shiny-server/ && \
    echo 'library(Rcpp); Rcpp.package.skeleton(name="Rnmr1D", code_files="exec/libspec/Rnmr.R",  cpp_files = "exec/libspec/libCspec.cpp", example_code = FALSE, author="Daniel Jacob", email="djacob65@gmail.com"); ' | /usr/bin/R BATCH --vanilla && \
    cp ./exec/libspec/configure* ./Rnmr1D/ && \
    chmod 755 ./Rnmr1D/configure* && \
    cp ./exec/libspec/Makevars.in ./Rnmr1D/src && \
    echo 'install.packages("Rnmr1D", lib=c("/usr/local/lib/R/site-library/"), repos = NULL, type = "source");' | /usr/bin/R BATCH --vanilla && \
    [ -d "./Rnmr1D" ] && rm -rf ./Rnmr1D

EXPOSE 3838
EXPOSE 80

CMD ["/usr/bin/launch-server.sh"]



