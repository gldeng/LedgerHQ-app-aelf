FROM ghcr.io/ledgerhq/ledger-app-builder/ledger-app-dev-tools:latest
RUN pip3 install ragger --upgrade
RUN pip3 install base58
RUN pip3 install eth-keys
RUN pip3 install aelf-sdk