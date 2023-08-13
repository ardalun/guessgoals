import React from 'react';
import { connect } from 'react-redux';
import { Input } from 'antd';
import { deepRead } from 'lib/helpers';
import { setField } from 'redux/form';
import styled, { css } from 'styled-components';

const StyledInput = styled(Input)`
  border-radius: 4px;
  border: 2px solid #37424C;
  background: #1E262D;
  color: white;
  padding: 0.6rem;
  height: 48px;
  vertical-align: bottom;
  font-size: 1rem;
  font-family: 'Open Sans', sans-serif;

  &:hover {
    border-right-width: 2px !important;
    border-color: #37424C;
  }

  &:focus {
    border-right-width: 2px !important;
    box-shadow: none;
    border-color: #FF7E00;
  }

  &:-webkit-autofill,
  &:-webkit-autofill:hover, 
  &:-webkit-autofill:focus, 
  &:-webkit-autofill:active  {
    -webkit-box-shadow: 0 0 0 30px #1E262D inset !important;
    -webkit-text-fill-color: #f90;
  }

  &::placeholder {
    color: #4C5660;
    opacity: 1;
  }

  &:-ms-input-placeholder {
    color: #4C5660;
  }

  &::-ms-input-placeholder {
    color: #4C5660;
  }

  ${props => props.error && css`
    border-color: #F64747 !important;
  `}
`;

class FormInput extends React.Component {
  changeFieldValue = (e) => {
    this.props.setField(this.props.formName, this.props.fieldName, e.target.value);
    if (!!this.props.onChange) {
      this.props.onChange(e);
    }
  }
  render() {
    let newProps = { ...this.props };
    delete newProps.className;
    delete newProps.formName;
    delete newProps.fieldName;
    delete newProps.setField;
    return(
      <div>
        <StyledInput 
          {...newProps}
          error={this.props.error}
          value={this.props.value}
          onChange={this.changeFieldValue}
        />
        { this.renderError() }
      </div>
    );
  }
  
  renderError = () => {
    if (!this.props.error) return;
    const ErrorText = styled.span`
      color: #F64747;
      font-size: 0.845rem;
    `;
    return (
      <ErrorText>{ this.props.error }</ErrorText>
    );
  }
}

const mapStateToProps = (store, ownProps) => ({
  value: deepRead(store, `form.${ownProps.formName}.data.${ownProps.fieldName}`),
  error: deepRead(store, `form.${ownProps.formName}.errors.${ownProps.fieldName}`)
});
const mapDispatchToProps = {
  setField
};

export default connect(mapStateToProps, mapDispatchToProps)(FormInput);