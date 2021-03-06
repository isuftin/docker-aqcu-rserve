FROM r-base:3.3.3

MAINTAINER Ivan Suftin <isuftin@usgs.gov>

RUN apt-get update && \
  apt-get install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
    telnet \
    libcurl3-dev \
    libgdal-dev \
    libxml2-dev \
    texlive-latex-base \
    texlive-xetex \
    libgmp-dev \
    libssl-dev \
    p7zip-full && \
  apt-get clean

ENV RSERVE_HOME /opt/rserve
ENV R_LIBS ${RSERVE_HOME}/R_libs
ARG PANDOC_VERSION=1.19.2.1
ARG REPGEN_VERSION=master
ARG GSPLOT_VERSION=0.8.1
ENV USERNAME ${USERNAME:-rserve}
ENV PASSWORD ${PASSWORD:-rserve}

RUN install.r Rserve && \
  rm -rf /tmp/downloaded_packages/ /tmp/*.rds

RUN useradd rserve \
	&& mkdir ${RSERVE_HOME} \
	&& usermod -d ${RSERVE_HOME} rserve

COPY etc ${RSERVE_HOME}/etc

RUN chown -R rserve:rserve ${RSERVE_HOME}

COPY run_rserve.sh ${RSERVE_HOME}/bin/

RUN chmod 755 ${RSERVE_HOME}/bin/run_rserve.sh

# Install Pandoc
RUN wget -O /tmp/pandoc.deb https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-amd64.deb && \
  dpkg -i /tmp/pandoc.deb && \
  rm /tmp/pandoc.deb

RUN wget -O /tmp/oberdiek.tds.zip http://mirrors.ctan.org/install/macros/latex/contrib/oberdiek.tds.zip && \
  wget -O /tmp/ifxetex.tds.zip http://mirrors.ctan.org/install/macros/generic/ifxetex.tds.zip && \
	7z x /tmp/oberdiek.tds.zip -o/usr/share/texmf -y && \
  7z x /tmp/ifxetex.tds.zip -o/usr/share/texmf -y && \
  cd /usr/share/texmf && \
  /usr/bin/texhash && \
  rm /tmp/oberdiek.tds.zip && \
  rm /tmp/ifxetex.tds.zip

USER $USERNAME

RUN mkdir ${RSERVE_HOME}/R_libs && \
  mkdir ${RSERVE_HOME}/work && \
  mkdir -p /tmp/install/gsplot_description_dir && \
  mkdir -p /tmp/install/repgen_description_dir

RUN wget -O /tmp/install/gsplot_description_dir/DESCRIPTION https://raw.githubusercontent.com/USGS-R/gsplot/v${GSPLOT_VERSION}/DESCRIPTION && \
  Rscript /tmp/install/installPackages.R && \
  Rscript -e "library(devtools);install_url('https://github.com/USGS-R/gsplot/archive/v${GSPLOT_VERSION}.zip', dependencies = F)"

RUN wget -O /tmp/install/installPackages.R https://raw.githubusercontent.com/USGS-R/repgen/${REPGEN_VERSION}/inst/extdata/installPackages.R && \
  wget -O /tmp/install/repgen_description_dir/DESCRIPTION https://raw.githubusercontent.com/USGS-R/repgen/${REPGEN_VERSION}/DESCRIPTION && \
  cd /tmp/install/repgen_description_dir && \
  Rscript /tmp/install/installPackages.R && \
  Rscript -e "library(devtools);install_url('https://github.com/USGS-R/repgen/archive/${REPGEN_VERSION}.zip', dependencies = F)"

RUN rm -rf /tmp/install

EXPOSE 6311

HEALTHCHECK --interval=2s --timeout=3s \
 CMD sleep 1 | \
 		telnet localhost 6311 | \
		grep -q Rsrv0103QAP1 || exit 1
USER root

CMD ["/opt/rserve/bin/run_rserve.sh"]
