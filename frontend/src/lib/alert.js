import { message } from 'antd';
import styled, { css } from 'styled-components';
import Box from 'components/Box';
import Icon from 'components/Icon';

const MessageBox = styled.div`
  max-width: 570px;
  width: 100%;
  display: flex;
  padding: 1rem;
  border-radius: 3px;
  
  ${props => props.error && css`
    background-color: #F64747;
    color: white;
  `}

  ${props => props.success && css`
    background-color: #00B16A;
    color: white;
  `}
`;

const IconWrapper = styled.div`
  position: relative;
  top: 2px;
`;

export const alertError = (errorMessage, duration = 8) => {
  let toBeRenderedMessage = null;
  if (typeof errorMessage === 'string') {
    toBeRenderedMessage = errorMessage;
  } else {
    toBeRenderedMessage = errorMessage.map((e, index) => <div key={`line_${index}`}>{e}</div>);
  }
  const content = (
    <MessageBox error>
      <IconWrapper>
        <Icon thick name="im-error-circle" mr={0.75} size={1.2} />
      </IconWrapper> 
      <Box left body2>{toBeRenderedMessage}</Box>
    </MessageBox>
  );
  message.open({
    content: content,
    duration: duration
  });
};

export const alertSuccess = (successMessage, duration = 8) => {
  const content = (
    <MessageBox success>
      <IconWrapper>
        <Icon thick name="im-checkmark" mr={0.75} size={1.2}/>
      </IconWrapper>
      <Box left body2>{successMessage}</Box>
    </MessageBox>
  );
  message.open({
    content: content,
    duration: duration
  });
};