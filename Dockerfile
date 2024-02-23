FROM gcr.io/distroless/static-debian12

COPY vault-plugin-secrets-kv /bin/vault-plugin-secrets-kv

ENTRYPOINT [ "/bin/vault-plugin-secrets-kv" ]
