import React from 'react';
import { Container, Form, Button, Card, Col, Row } from 'react-bootstrap';
import axios from 'axios';

export default class Login extends React.Component {
  constructor(props) {
    super(props);
    this.state = { 
      email: null,
      password: null,
      error: null
    };
  }

  handleInputChange = (key, value) => {
    this.setState({
      [key]: value,
      error: null
    })
  }

  handleLogin = (e) => {
    e.preventDefault();

    const data = {
      email: this.state.email,
      password: this.state.password
    };

    axios.post('/admin/login', data)
      .then(resp => {
        window.location.replace('/admin');
      })
      .catch(error => {
        if (error.response && error.response.data && error.response.data.error_code === 'auth_failed') {
          this.setState({
            error: 'You shall not pass!'
          })
        }
      })

  }

  render() {
    return (
      <Container>
        <Row>
          <Col xs={12} sm={8} md={8} lg={5} xl={5} style={{margin: '0 auto'}}>
            <Card style={{marginTop: '5rem'}}>
              <Card.Body>
                <Card.Title className="mb-4 mt-1 text-center">Admin Login</Card.Title>
                <Form>
                  <Form.Group controlId="formBasicEmail">
                    <Form.Label>Email</Form.Label>
                    <Form.Control 
                      type="email" 
                      placeholder="Email"
                      value={this.state.email}
                      onChange={(e) => this.handleInputChange('email', e.target.value)}
                    />
                  </Form.Group>
                  <Form.Group controlId="formBasicPassword">
                    <Form.Label>Password</Form.Label>
                    <Form.Control 
                      type="password" 
                      placeholder="Password"
                      value={this.state.password}
                      onChange={(e) => this.handleInputChange('password', e.target.value)}
                    />
                  </Form.Group>
                  <div style={{color: '#dc3545'}}>{ this.state.error }</div>
                  <Button className="mt-4" variant="primary" type="submit" block onClick={this.handleLogin}>
                    Login
                  </Button>
                </Form>
              </Card.Body>
            </Card>
          </Col>
        </Row>
      </Container>
    );
  }
}