const express      = require('express');
const path         = require('path');
const axios        = require('axios');
const cookieParser = require('cookie-parser');
const bodyParser   = require('body-parser');
const cors         = require('cors');
const next         = require('next');
const getConfig    = require('./next.config.js');
const dev          = process.env.NODE_ENV !== 'production';
const app          = next({ dev, dir: './src' });
const handle       = app.getRequestHandler();

const { publicRuntimeConfig } = getConfig;

function wwwRedirect(req, res, next) {
  if (req.headers.host.slice(0, 4) === 'www.') {
    var newHost = req.headers.host.slice(4);
    return res.redirect(301, req.protocol + '://' + newHost + req.originalUrl);
  }
  next();
};

app.prepare()
  .then(() => {
    const server = express();
    server.use(cors());
    server.use(bodyParser.json());
    server.use(bodyParser.urlencoded({ extended: false }));
    server.use(cookieParser());
    server.set('trust proxy', true);
    server.use(wwwRedirect);
    
    server.get('/', (req, res) => {
      res.redirect('/football');
    });
    server.get('/notifications', (req, res) => {
      app.render(req, res, '/notifications', {});
    });
    server.get('/wallet', (req, res) => {
      app.render(req, res, '/wallet', {});
    });
    server.get('/my-bets', (req, res) => {
      app.render(req, res, '/my-bets', {});
    });
    server.get('/privacy-policy', (req, res) => {
      app.render(req, res, '/privacy-policy', {});
    });
    server.get('/terms-and-conditions', (req, res) => {
      app.render(req, res, '/terms-and-conditions', {});
    });
    server.get('/how-to-play', (req, res) => {
      app.render(req, res, '/how-to-play', {});
    });
    server.get('/faq', (req, res) => {
      app.render(req, res, '/faq', {});
    });
    server.get('/contact-us', (req, res) => {
      app.render(req, res, '/contact-us', {});
    });
    server.get('/login', (req, res) => {
      app.render(req, res, '/auth/login', {});
    });
    server.get('/signup', (req, res) => {
      app.render(req, res, '/auth/signup', {});
    });
    server.get('/activate/:token', (req, res) => {
      app.render(req, res, '/auth/activate', {});
    })
    server.get('/forgot-password', (req, res) => {
      app.render(req, res, '/auth/forgot-password', {});
    });
    server.get('/reset-password/:token', (req, res) => {
      app.render(req, res, '/auth/reset-password', {});
    });

    server.get('/football/:league_handle?/highlights', (req, res) => {
      const query = { league_handle: req.params.league_handle || 'all' };
      app.render(req, res, '/highlights', query)
    });
    
    server.get('/football/:league_handle?', (req, res) => {
      const query = { league_handle: req.params.league_handle || 'all' };
      app.render(req, res, '/matches', query)
    });

    server.get('/football/:league_handle/:match_id', (req, res) => {
      const query = { match_id: req.params.match_id };
      app.render(req, res, '/match', query)
    });

    server.get('/logout', (req, res) => {
      res.clearCookie('id_token');
      res.redirect('/');
    });

    server.post('/login', (req, res) => {
      axios({
        method: 'post',
        url: `${publicRuntimeConfig.backendRoute}/auth/login`,
        data: {
          email: req.body.email,
          password: req.body.password
        }
      })
        .then(backResp => {
          res.cookie('id_token', backResp.data.id_token);
          res.status(200).json(backResp.data);
        })
        .catch(error => {
          res.status(error.response.status).json(error.response.data);
        })
    });

    server.post('/sessions', (req, res) => {
      axios({
        method: 'post',
        url: `${publicRuntimeConfig.backendRoute}/auth/sessions`,
        data: {
          id_token: req.body.id_token
        }
      })
        .then(backResp => {
          res.cookie('id_token', backResp.data.id_token);
          res.status(200).json(backResp.data);
        })
        .catch(error => {
          res.clearCookie('id_token');
          res.status(error.response.status).json(error.response.data);
        })
    });

    server.get('/robots.txt', (req, res) => {
      res.sendFile(path.join(__dirname, 'robots.txt'));
    });

    server.get('/sitemap.xml', (req, res) => {
      axios.get(`${publicRuntimeConfig.backendRoute}/sitemap.xml`)
        .then(back_res => {
          res.set('Content-Type', 'text/xml');
          res.send(back_res.data);
        })
        .catch(e => {
          console.log(e)
        })
    });

    server.get('*', (req, res) => {
      return handle(req, res)
    })

    server.listen(5000, (err) => {
      if (err) throw err
      console.log('> Ready on http://localhost:5000')
    })
  })
  .catch((ex) => {
    console.error(ex.stack)
    process.exit(1)
  })
