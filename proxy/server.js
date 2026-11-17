const http = require('node:http');

const PORT = 3001;
const CPTEC_BASE = 'http://servicos.cptec.inpe.br/XML';

const server = http.createServer(async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    return res.end();
  }

  if (req.method !== 'GET') {
    res.writeHead(405);
    return res.end('Method not allowed');
  }

  const path = req.url || '';

  const rotaPermitida =
    /^\/cptec\/listaCidades(?:\?.*)?$/.test(path) ||
    /^\/cptec\/cidade\/\d+\/previsao\.xml$/.test(path);

  if (!rotaPermitida) {
    res.writeHead(404);
    return res.end('Route not found');
  }

  try {
    const upstreamUrl = CPTEC_BASE + path.replace('/cptec', '');

    const resposta = await fetch(upstreamUrl, {
      signal: AbortSignal.timeout(20000),
    });

    const conteudo = Buffer.from(await resposta.arrayBuffer());

    res.writeHead(resposta.statusCode || resposta.status, {
      'Content-Type': resposta.headers.get('content-type') || 'application/xml',
    });

    res.end(conteudo);
  } catch (erro) {
    console.error('Erro ao consultar CPTEC:', erro.message);

    res.writeHead(502, {
      'Content-Type': 'text/plain; charset=utf-8',
    });

    res.end('Nao foi possivel consultar o CPTEC/INPE.');
  }
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`Servidor intermediario ativo em http://127.0.0.1:${PORT}`);
});
