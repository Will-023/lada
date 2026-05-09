# FROM dockerproxy.net/ladaapp/lada:latest
FROM ladaapp/lada:latest
USER root
RUN PY=$(ls /usr/local/lib | grep -E '^python[0-9]+\.[0-9]+$' | head -1) && \
    SP_SRC=/home/lada/.local/lib/${PY}/site-packages && \
    SP_DST=/usr/local/lib/${PY}/site-packages && \
    BIN_SRC=/home/lada/.local/bin && \
    BIN_DST=/usr/local/bin && \
    mkdir -p ${SP_DST} ${BIN_DST} && \
    mv ${SP_SRC}/* ${SP_DST}/ && \
    mv ${BIN_SRC}/* ${BIN_DST}/ && \
    rm -rf /home/lada/.local && \
    sed -i '1s|^#!.*python.*|#!/usr/local/bin/python3|' /usr/local/bin/lada-cli /usr/local/bin/lada 2>/dev/null || true && \
    chmod -R a+rX /usr/local/lib /usr/local/bin
ENV LADA_MODEL_WEIGHTS_DIR=/model_weights
ENTRYPOINT ["lada-cli"]
CMD ["--help"]
