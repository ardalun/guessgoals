import React from 'react';
import { connect } from 'react-redux';
import NextHead from 'next/head';
import cookieJar from 'lib/cookie_jar';
import metaImage from 'assets/images/home.png';
import jstz from 'jstz';
import { deepRead } from 'lib/helpers';
import 'antd/dist/antd.css';
import 'assets/stylesheets/application.css';

class Head extends React.Component {
  constructor(props) {
    super(props);
  }

  componentDidMount() {
    cookieJar.setDocumentCookie('timezone', jstz.determine().name(), 1000);
  }
  
  getGA = () => {
    if (process.env.NODE_ENV !== 'production')
      return;
    
    return `
      window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments); }
      gtag('js', new Date());
      gtag('config', 'UA-130232500-1');
    `;
  }

  render() {
    const { title, description } = this.props;
    return (
      <NextHead>
        <meta name="google" content="notranslate" />
        
        <link rel="apple-touch-icon" sizes="180x180" href="/static/images/apple-touch-icon.png" />
        <link rel="icon" type="image/png" sizes="32x32" href="/static/images/favicon-32x32.png" />
        <link rel="icon" type="image/png" sizes="16x16" href="/static/images/favicon-16x16.png" />
        <link rel="manifest" href="/site.webmanifest"></link>

        <link href="https://fonts.googleapis.com/css?family=Open+Sans:400,600" rel="stylesheet" />
        <link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:400,600&display=swap" rel="stylesheet" />
        <link href="https://fonts.googleapis.com/css?family=Roboto+Condensed&display=swap" rel="stylesheet" />
        <meta name="msapplication-TileColor" content="#da532c" />
        <meta name="theme-color" content="#010E28" />

        <meta name="viewport" content="width=device-width, initial-scale=1" />
        
        <title>{title}</title>
        <meta name='description' content={description} />

        <meta property='twitter:card' content='summary_large_image' />
        <meta property='twitter:site' content='@guessgoals' />
        <meta property='twitter:title' content={title} />
        <meta property='twitter:description' content={description} />
        <meta property='twitter:image' content={metaImage} />

        <meta property='og:site_name' content='GuessGoals' />
        <meta property='og:type' content='website' />
        <meta property='og:url' content='https://guessgoals.com/' />
        <meta property='og:title' content={title} />
        <meta property='og:description' content={description} />
        <meta property='og:image' content={metaImage} />
        <script async src="https://www.googletagmanager.com/gtag/js?id=UA-119392120-1"></script>
        <script dangerouslySetInnerHTML={{ __html: this.getGA() }}></script>
        <meta name="verifyownership" content="0f6c034db90edbad095a4ae7b08c69fb"/>
      </NextHead> 
    );
  }
}

const mapStateToProps = (store, ownProps) => ({
  title: deepRead(store, 'page.title'),
  description: deepRead(store, 'page.description'),
});
const mapDispatchToProps = {};

export default connect(mapStateToProps, mapDispatchToProps)(Head);