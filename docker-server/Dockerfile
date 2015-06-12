FROM google/nodejs

WORKDIR /app/server
ADD ./server /app/server
ADD ./.config-db /app/.config-db
RUN npm install

CMD []
ENTRYPOINT ["/nodejs/bin/npm", "start"]