/* eslint-disable @typescript-eslint/no-var-requires */
/* eslint-disable no-console */
const path = require('path');
const express = require('express');
const compression = require('compression');

const app = express(); // create express app
const { createProxyMiddleware } = require('http-proxy-middleware');
require('dotenv').config({ path: `${__dirname}/.env` });

const staticPath = process.env.PUBLIC_URL || '';
const apiVersion = `v${process.env.API_VERSION}` || 'v1.0';

app.use(compression());
app.use(staticPath, express.static(path.join(__dirname, 'build')));

const apiProxyPath =
  staticPath !== '' ? `${staticPath}/${apiVersion}/api` : `/${apiVersion}/api`;
function pathRewriteFn(rewritePath) {
  console.log('called', rewritePath);
  return rewritePath.replace(apiProxyPath, `${apiVersion}/api`);
}
const proxyOptions = {
  target: 'http://localhost:8000',
  changeOrigin: true,
  pathRewrite: pathRewriteFn,
};
console.log('apiProxyPath: ', apiProxyPath);
app.use(apiProxyPath, createProxyMiddleware(proxyOptions));
app.use((req, res) => {
  res.sendFile(path.join(__dirname, 'build', 'index.html'));
});

// start express server on port 3000
app.listen(3000, () => {
  console.log('server started on port 3000');
});
